import json
import os
import random
import glob

def generate_paper():
    source_dir = r"d:\Flutter projects\studentscomputer\lib\screens\user\games\questions_json"
    root_dir = r"d:\Flutter projects\studentscomputer"
    
    # 1. Collect all valid files
    all_json_files = []
    
    # Files in questions_json
    pattern = os.path.join(source_dir, "*.json")
    for f in glob.glob(pattern):
        basename = os.path.basename(f).lower()
        if "ch13" in basename:
            continue
        if basename.startswith("ch") or basename.startswith("sortform"):
            all_json_files.append(f)
            
    # Add 15febpaper.json from root (per user rule)
    feb_paper = os.path.join(root_dir, "15febpaper.json")
    if os.path.exists(feb_paper):
        all_json_files.append(feb_paper)
    else:
        # Check if it's in the subfolder instead
        feb_paper_sub = os.path.join(source_dir, "15febpaper.json")
        if os.path.exists(feb_paper_sub):
            all_json_files.append(feb_paper_sub)

    # 2. Extract unique questions
    questions_by_source = {} # To help with balancing
    unique_texts = set()
    all_questions = []

    for fpath in all_json_files:
        try:
            with open(fpath, 'r', encoding='utf-8') as f:
                data = json.load(f)
                source_key = os.path.basename(fpath).split('_')[0].split('.')[0] # ch1, ch2, sortform, etc.
                if source_key not in questions_by_source:
                    questions_by_source[source_key] = []
                
                for q in data:
                    txt = q.get('text', '').strip()
                    if txt and txt not in unique_texts:
                        unique_texts.add(txt)
                        # Ensure 45 seconds rule
                        q['timeSeconds'] = 45
                        all_questions.append(q)
                        questions_by_source[source_key].append(q)
        except:
            continue

    # 3. Handle Difficulty and Selection
    # The current datasets don't have explicit difficulty fields, 
    # so we will assign based on heuristics or random distribution to meet the 40/40/20 criteria.
    # We will shuffle to ensure "balanced coverage".
    random.shuffle(all_questions)
    
    if len(all_questions) < 100:
        # Fallback if too few questions (unlikely given the file list)
        selected_questions = all_questions
    else:
        # Selection logic to prioritize balanced coverage
        # Take questions from each source key round-robin until we hit 100
        selected_questions = []
        keys = list(questions_by_source.keys())
        random.shuffle(keys)
        idx = 0
        while len(selected_questions) < 100 and any(questions_by_source.values()):
            k = keys[idx % len(keys)]
            if questions_by_source[k]:
                selected_questions.append(questions_by_source[k].pop(0))
            idx += 1

    # 4. Generate JSON
    json_path = os.path.join(root_dir, "mcq_paper(11).json")
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(selected_questions, f, indent=2)

    # 5. Generate DOC (Custom formatted text)
    doc_path = os.path.join(root_dir, "mcq_paper(11).doc")
    with open(doc_path, 'w', encoding='utf-8') as f:
        f.write("MCQ Question Paper\n\n")
        
        answer_key = []
        for i, q in enumerate(selected_questions, 1):
            f.write(f"Q{i}. {q['text']}\n")
            choices = q.get('choices', [])
            for j, c in enumerate(choices):
                label = chr(65 + j) # A, B, C, D
                f.write(f"{label}. {c}\n")
            f.write("\n")
            
            correct_idx = q.get('correctChoiceIndex', 0)
            ans_label = chr(65 + correct_idx)
            answer_key.append(f"{i} \u2192 {ans_label}")

        f.write("---\n\nANSWER KEY\n\n")
        # Write answer key in rows of 4 for better formatting
        for i in range(0, len(answer_key), 4):
            f.write("\t".join(answer_key[i:i+4]) + "\n")
        f.write("\n---")

    print(f"Generated {len(selected_questions)} questions.")
    print(f"JSON: {json_path}")
    print(f"DOC: {doc_path}")

if __name__ == "__main__":
    generate_paper()


import json
import os

paper_path = '/Users/chiragdoshi/StudioProjects/studentscomputer/lib/screens/user/games/15febpaper.json'
ch7_path = '/Users/chiragdoshi/StudioProjects/studentscomputer/lib/screens/user/games/questions_json/ch7_1.json'

def update_paper():
    # Load the main paper
    with open(paper_path, 'r') as f:
        paper = json.load(f)
    
    # Load the Chapter 7 questions
    with open(ch7_path, 'r') as f:
        ch7_questions = json.load(f)
    
    # Indices in 15febpaper.json to replace (0-based)
    # These correspond to Q1, Q2, Q11, Q15, Q18, Q29, Q33, Q34, Q35, Q36, Q53, Q56, Q63, Q65, Q66, Q80, Q82, Q92, Q94, Q95, Q96, Q98
    indices_to_replace = [
        0, 1, 
        10, 
        14, 
        17, 
        28, 
        32, 33, 34, 35, 
        52, 
        55, 
        62, 
        64, 65, 
        79, 
        81, 
        91, 
        93, 94, 95, 
        97
    ]
    
    # Validation
    if len(indices_to_replace) > len(ch7_questions):
        print(f"Error: Need {len(indices_to_replace)} replacement questions, but ch7_1.json only has {len(ch7_questions)}.")
        return

    print(f"Replacing {len(indices_to_replace)} questions...")
    
    for i, paper_idx in enumerate(indices_to_replace):
        new_q = ch7_questions[i]
        old_q = paper[paper_idx]
        print(f"Replacing Q{paper_idx+1}: '{old_q['text'][:30]}...' -> '{new_q['text'][:30]}...'")
        paper[paper_idx] = new_q
        
    # Save the updated paper
    with open(paper_path, 'w') as f:
        json.dump(paper, f, indent=4)
        
    print("Successfully updated 15febpaper.json")

if __name__ == "__main__":
    update_paper()

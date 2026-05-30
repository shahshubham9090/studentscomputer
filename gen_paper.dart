import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() async {
  final sourceDir = Directory(r'd:\Flutter projects\studentscomputer\lib\screens\user\games\questions_json');
  final rootDir = Directory(r'd:\Flutter projects\studentscomputer');
  
  final List<FileSystemEntity> files = sourceDir.listSync();
  final List<File> jsonFiles = [];
  
  // 1. Collect valid JSON files
  for (var file in files) {
    if (file is File && file.path.endsWith('.json')) {
      final name = file.uri.pathSegments.last.toLowerCase();
      if (name.contains('ch13')) continue;
      if (name.startsWith('ch') || name.startsWith('sortform')) {
        jsonFiles.add(file);
      }
    }
  }
  
  // Add 15febpaper.json if it exists in root or questions_json
  final febPaperRoot = File(r'd:\Flutter projects\studentscomputer\15febpaper.json');
  if (febPaperRoot.existsSync()) {
    jsonFiles.add(febPaperRoot);
  } else {
    final febPaperSub = File(r'd:\Flutter projects\studentscomputer\lib\screens\user\games\questions_json\15febpaper.json');
    if (febPaperSub.existsSync()) {
      jsonFiles.add(febPaperSub);
    }
  }

  // 2. Extract unique questions
  final Map<String, List<Map<String, dynamic>>> questionsBySource = {};
  final Set<String> uniqueTexts = {};
  final List<Map<String, dynamic>> allQuestions = [];

  for (var file in jsonFiles) {
    try {
      final content = file.readAsStringSync();
      final List<dynamic> data = jsonDecode(content);
      final sourceKey = file.uri.pathSegments.last.split('_')[0].split('.')[0];
      
      questionsBySource.putIfAbsent(sourceKey, () => []);
      
      for (var q in data) {
        if (q is Map<String, dynamic>) {
          final text = q['text']?.toString().trim() ?? '';
          if (text.isNotEmpty && !uniqueTexts.contains(text)) {
            uniqueTexts.add(text);
            q['timeSeconds'] = 45; // Apply rule 8
            allQuestions.add(q);
            questionsBySource[sourceKey]!.add(q);
          }
        }
      }
    } catch (e) {
      print('Error reading ${file.path}: $e');
    }
  }

  // 3. Selection Logic (Balanced Coverage)
  allQuestions.shuffle();
  List<Map<String, dynamic>> selectedQuestions = [];
  
  if (allQuestions.length <= 100) {
    selectedQuestions = allQuestions;
  } else {
    final keys = questionsBySource.keys.toList();
    keys.shuffle();
    int idx = 0;
    while (selectedQuestions.length < 100 && questionsBySource.values.any((l) => l.isNotEmpty)) {
      final k = keys[idx % keys.length];
      if (questionsBySource[k]!.isNotEmpty) {
        selectedQuestions.add(questionsBySource[k]!.removeAt(0));
      }
      idx++;
    }
  }

  // Ensure exactly 100 if possible (just in case)
  if (selectedQuestions.length > 100) {
    selectedQuestions = selectedQuestions.sublist(0, 100);
  }

  // 4. Generate JSON Output
  final jsonOutputFile = File(r'd:\Flutter projects\studentscomputer\mcq_paper(11).json');
  jsonOutputFile.writeAsStringSync(jsonEncode(selectedQuestions));
  print('Generated ${selectedQuestions.length} questions in JSON.');

  // 5. Generate DOC Output (Formatted Text)
  final docOutputFile = File(r'd:\Flutter projects\studentscomputer\mcq_paper(11).doc');
  final StringBuffer buffer = StringBuffer();
  buffer.writeln('MCQ Question Paper\n');
  
  final List<String> answerKey = [];
  for (int i = 0; i < selectedQuestions.length; i++) {
    final q = selectedQuestions[i];
    final questionNum = i + 1;
    buffer.writeln('Q$questionNum. ${q['text']}');
    
    final List<dynamic> choices = q['choices'] ?? [];
    final List<String> choiceStrings = [];
    for (int j = 0; j < choices.length; j++) {
      final label = String.fromCharCode(65 + j); // A, B, C, D
      choiceStrings.add('$label. ${choices[j]}');
    }
    buffer.writeln(choiceStrings.join(' '));
    buffer.writeln();
    
    final int correctIdx = q['correctChoiceIndex'] ?? 0;
    final ansLabel = String.fromCharCode(65 + correctIdx);
    answerKey.add('$questionNum \u2192 $ansLabel');
  }

  buffer.writeln('---');
  buffer.writeln('ANSWER KEY\n');
  
  // Format Answer Key in columns
  for (int i = 0; i < answerKey.length; i += 4) {
    final end = (i + 4 < answerKey.length) ? i + 4 : answerKey.length;
    buffer.writeln(answerKey.sublist(i, end).join('\t'));
  }
  buffer.writeln('\n---');

  docOutputFile.writeAsStringSync(buffer.toString());
  print('Generated DOC output.');
  print('Final paths:');
  print('JSON: ${jsonOutputFile.path}');
  print('DOC: ${docOutputFile.path}');
}

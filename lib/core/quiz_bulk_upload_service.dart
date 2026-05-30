import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as ex;
import '../../models/quiz_model.dart';

class QuizBulkUploadService {
  static Future<List<Question>> pickAndParseQuestions() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'csv', 'xlsx', 'xls'],
      withData: true, // Ensure bytes are loaded on all platforms (especially useful if path is null on mobile)
    );

    if (result == null || result.files.isEmpty) return [];

    final file = result.files.first;
    final extension = file.extension?.toLowerCase();
    
    String content = '';
    if (extension == 'json' || extension == 'csv') {
      if (kIsWeb || file.path == null) {
        if (file.bytes != null) {
          content = utf8.decode(file.bytes!);
        } else {
          throw Exception('Unable to read selected file: no data found.');
        }
      } else {
        content = await File(file.path!).readAsString();
      }
    }

    if (extension == 'json') {
      return _parseJson(content);
    } else if (extension == 'csv') {
      return _parseCsv(content);
    } else if (extension == 'xlsx' || extension == 'xls') {
      final Uint8List bytes;
      if (kIsWeb || file.path == null) {
        if (file.bytes != null) {
          bytes = file.bytes!;
        } else {
          throw Exception('Unable to read selected Excel file: no data found.');
        }
      } else {
        bytes = await File(file.path!).readAsBytes();
      }
      return _parseExcel(bytes);
    }

    return [];
  }

  static List<Question> _parseJson(String content) {
    final List<dynamic> data = json.decode(content);
    return data.map((q) => Question(
      id: const Uuid().v4(),
      text: q['text'] ?? '',
      choices: List<String>.from(q['choices'] ?? []),
      correctChoiceIndex: q['correctChoiceIndex'] ?? 0,
      explanation: q['explanation'],
      timeSeconds: q['timeSeconds'] ?? 30,
    )).toList();
  }

  static List<Question> _parseCsv(String content) {
    final csvData = const CsvToListConverter().convert(content);
    List<Question> questions = [];
    // Skip header row
    for (var i = 1; i < csvData.length; i++) {
      final row = csvData[i];
      if (row.length >= 6) {
        questions.add(Question(
          id: const Uuid().v4(),
          text: row[0].toString(),
          choices: [row[1].toString(), row[2].toString(), row[3].toString(), row[4].toString()],
          correctChoiceIndex: int.tryParse(row[5].toString()) ?? 0,
          explanation: row.length > 7 ? row[7].toString() : null,
          timeSeconds: row.length > 6 ? (int.tryParse(row[6].toString()) ?? 30) : 30,
        ));
      }
    }
    return questions;
  }

  static List<Question> _parseExcel(Uint8List bytes) {
    var excel = ex.Excel.decodeBytes(bytes);
    List<Question> questions = [];
    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table]!;
      for (var i = 1; i < sheet.maxRows; i++) {
        var row = sheet.rows[i];
        if (row.length >= 6 && row[0] != null) {
          questions.add(Question(
            id: const Uuid().v4(),
            text: row[0]?.value.toString() ?? '',
            choices: [
              row[1]?.value.toString() ?? '',
              row[2]?.value.toString() ?? '',
              row[3]?.value.toString() ?? '',
              row[4]?.value.toString() ?? '',
            ],
            correctChoiceIndex: int.tryParse(row[5]?.value.toString() ?? '0') ?? 0,
            explanation: row.length > 7 ? row[7]?.value.toString() : null,
            timeSeconds: row.length > 6 ? (int.tryParse(row[6]?.value.toString() ?? '30') ?? 30) : 30,
          ));
        }
      }
      break; 
    }
    return questions;
  }
}

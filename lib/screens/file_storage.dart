import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStorage {
  final String filePath;

  FileStorage(this.filePath);

  //returns the correct local path to store files
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  //reference the file you will use to store data
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$filePath');
  }

  //append data to the localfile
  Future<File> writeString(String data) async {
    final file = await _localFile;
    // Append text to the file
    return file.writeAsString(data, mode: FileMode.append);
  }

  //overwrite data to the localfile
  Future<File> writeAll(String data) async {
    final file = await _localFile;
    return file.writeAsString(data);
  }

  //read data from the file as lines
  //this will return a list of string per line
  Future<List<String>?> readFile() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsLines();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return null;
    }
  }

  Future<File> clearFile() async {
    try {
      final file = await _localFile;
      return file.writeAsString('', mode: FileMode.write);
    } catch (e) {
      print('Error clearing file: $e');
      rethrow;
    }
  }
}

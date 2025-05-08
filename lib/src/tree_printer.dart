import 'dart:io';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'configuration.dart';

class TreePrinter {
  final Configuration config;
  final _buffer = StringBuffer();

  TreePrinter(this.config);

  void printTree(String rootPath, [String indent = '']) {
    final dir = Directory(rootPath);
    _walk(dir, indent);
    stdout.write(_buffer);
  }

  void _walk(Directory dir, String indent) {
    final entries = dir.listSync()
        .where((e) {
      final rel = p.relative(e.path, from: config.rootPath);
      return !config.ignorePatterns.any((g) => g.matches(rel));
    })
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (var e in entries) {
      final name = p.basename(e.path);
      _buffer.writeln('$indent├── $name');
      if (e is Directory) {
        _walk(e, '$indent│   ');
      }
    }
  }

  Future<void> saveToFile(String path) async {
    await File(path).writeAsString(_buffer.toString());
  }
}
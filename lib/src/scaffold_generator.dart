import 'dart:io';
import 'package:path/path.dart' as p;
import 'configuration.dart';

class ScaffoldGenerator {
  final String rootPath;
  final Map<String, dynamic> tree;
  ScaffoldGenerator(this.rootPath, this.tree);

  Future<void> generate() async {
    await _walk(tree, Directory(rootPath));
  }

  Future<void> _walk(Map<String, dynamic> node, Directory dir) async {
    // files
    if (node.containsKey('_files')) {
      for (var f in node['_files'] as List<String>) {
        final file = File(p.join(dir.path, f));
        if (!await file.exists()) {
          await file.create(recursive: true);
          if (f.endsWith('.dart')) {
            await file.writeAsString(_dartStub(f));
          }
        }
      }
    }
    // dirs
    for (var key in node.keys.where((k) => k != '_files')) {
      final sub = Directory(p.join(dir.path, key));
      if (!await sub.exists()) await sub.create(recursive: true);
      await _walk(node[key] as Map<String, dynamic>, sub);
    }
  }

  String _dartStub(String fileName) {
    final base = p.basenameWithoutExtension(fileName);
    final className = base.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join();
    return '''/// Auto-generated stub
class $className {
  $className();
}
''';
  }
}
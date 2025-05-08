import 'package:yaml/yaml.dart';

abstract class ManifestParser {
  /// Produces a nested Map<String, dynamic> tree.
  Map<String, dynamic> parse(String text);
}

class YamlTreeParser implements ManifestParser {
  @override
  Map<String, dynamic> parse(String text) {
    final yaml = loadYaml(text);
    return Map<String, dynamic>.from(yaml as YamlMap);
  }
}

class AsciiTreeParser implements ManifestParser {
  final int indentSize;
  final _pattern = RegExp(r'^[\s│├└─]+');

  AsciiTreeParser({this.indentSize = 2});

  @override
  Map<String, dynamic> parse(String text) {
    final root = <String, dynamic>{};
    final stack = [root];
    final levels = [0];
    for (var line in text.split('\n')) {
      if (line.trim().isEmpty) continue;
      final stripped = line.replaceFirstMapped(_pattern, (m) {
        final spaces = m[0]!
            .split('')
            .where((c) => c == ' ')
            .length;
        return ' ' * spaces;
      });
      final depth = ((stripped.length - stripped.trimLeft().length) / indentSize).floor();
      final name = stripped.trim();
      while (depth < levels.last) {
        stack.removeLast(); levels.removeLast();
      }
      final parent = stack.last;
      if (name.contains('.')) {
        parent.putIfAbsent('_files', () => <String>[]).add(name);
      } else {
        final child = <String, dynamic>{};
        parent[name] = child;
        stack.add(child); levels.add(depth + 1);
      }
    }
    return root;
  }
}
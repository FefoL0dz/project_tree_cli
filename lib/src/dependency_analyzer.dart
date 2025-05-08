import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;
import 'configuration.dart' as c;

class DependencyAnalyzer {
  final c.Configuration config;
  DependencyAnalyzer(this.config);

  Future<Map<String, Set<String>>> buildGraph() async {
    final graph = <String, Set<String>>{};
    final dir = Directory(config.rootPath);
    await for (var f in dir.list(recursive: true)) {
      if (f is File && f.path.endsWith('.dart')) {
        final rel = p.relative(f.path, from: config.rootPath);
        if (config.ignorePatterns.any((g) => g.matches(rel))) continue;
        final src = await f.readAsString();
        final unit = parseString(content: src).unit;
        final imports = unit.directives
            .whereType<ImportDirective>()
            .map((i) => i.uri.stringValue ?? '')
            .where((u) => u.endsWith('.dart'))
            .toSet();
        graph[rel] = imports;
      }
    }
    return graph;
  }

  void printGraph(Map<String, Set<String>> graph) {
    graph.forEach((k, v) => print('$k -> ${v.join(', ')}'));
    _detectCycles(graph);
  }

  void _detectCycles(Map<String, Set<String>> g) {
    final visited = <String>{};
    final stack = <String>[];
    void dfs(String node) {
      if (stack.contains(node)) {
        final cyc = stack.skip(stack.indexOf(node)).join(' -> ');
        print('Circular: $cyc');
        return;
      }
      if (visited.contains(node)) return;
      visited.add(node);
      stack.add(node);
      for (var to in g[node] ?? {}) dfs(to);
      stack.removeLast();
    }
    for (var n in g.keys) dfs(n);
  }

  Future<void> saveGraph(String path) async {
    final g = await buildGraph();
    final buf = StringBuffer('digraph G {\n');
    g.forEach((f, tos) {
      for (var t in tos) buf.writeln('  "$f" -> "$t";');
    });
    buf.writeln('}');
    await File(path).writeAsString(buf.toString());
  }
}
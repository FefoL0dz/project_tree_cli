library git_tree_cli;

import 'dart:io';

import 'src/configuration.dart' as c;
import 'git_tree_cli.dart';
export 'src/tree_printer.dart';
export 'src/dependency_analyzer.dart';
export 'src/manifest_parser.dart';
export 'src/scaffold_generator.dart';

class GitTreeCLI {
  static Future<void> runTree(List<String> args) async {
    final config = await c.Configuration.load();
    final printer = TreePrinter(config);
    printer.printTree(config.rootPath);
    final treeOutput = config.treeOutput;
    if (treeOutput != null) await printer.saveToFile(treeOutput);
    if (config.outputPath != null) {
      await printer.saveToFile(config.outputPath!);
    }
  }

  static Future<void> runDeps(List<String> args) async {
    final config = await c.Configuration.load();
    final analyzer = DependencyAnalyzer(config);
    final graph = await analyzer.buildGraph();
    analyzer.printGraph(graph);
    final depsOutput = config.depsOutput;
    if (depsOutput != null) await analyzer.saveGraph(depsOutput);
    if (config.outputPath != null) {
      await analyzer.saveGraph(config.outputPath!);
    }
  }

  static Future<void> runScaffold(List<String> args) async {
    final config = await c.Configuration.load();
    final parser = config.format == 'yaml'
        ? YamlTreeParser()
        : AsciiTreeParser(indentSize: config.indent);
    final manifestText = await File(config.manifestPath).readAsString();
    final treeMap = parser.parse(manifestText);
    final generator = ScaffoldGenerator(config.rootPath, treeMap);
    await generator.generate();
  }
}
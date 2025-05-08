import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:glob/glob.dart';

class Configuration {
  final String rootPath;
  final List<Glob> ignorePatterns;
  final String? outputPath;
  final String? depsOutput;
  final String? treeOutput;
  final String manifestPath;
  final String format;
  final int indent;

  Configuration._(
      this.rootPath,
      this.ignorePatterns,
      this.outputPath,
      this.manifestPath,
      this.format,
      this.indent,
      this.depsOutput,
      this.treeOutput,
      );

  static Future<Configuration> load() async {
    final file = File('git_tree.yaml');
    if (!await file.exists()) {
      throw Exception('Missing git_tree.yaml');
    }
    final doc = loadYaml(await file.readAsString());
    final root = doc['root'] as String? ?? '.';
    final ignores = (doc['ignore'] as List?)?.cast<String>() ?? [];
    final patterns = ignores.map((p) => Glob(p)).toList();
    final output = doc['output'] as String?;
    final depsOutput = doc['deps_output'] as String?;
    final treeOutput = doc['tree_output'] as String?;
    final manifest = doc['manifest'] as String? ?? 'project-tree.txt';
    final format = doc['format'] as String?
        ?? (manifest.endsWith('.yaml') ? 'yaml' : 'ascii');
    final indent = doc['indent'] as int? ?? 2;
    return Configuration._(
      root,
      patterns,
      output,
      manifest,
      format,
      indent,
      depsOutput,
      treeOutput,
    );
  }
}
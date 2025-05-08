import 'dart:io';
import 'package:args/args.dart';
import 'package:git_tree_cli/git_tree_cli.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('tree')
    ..addCommand('deps')
    ..addCommand('scaffold')
    ..addFlag('help', abbr: 'h', negatable: false);

  final results = parser.parse(arguments);
  if (results['help'] as bool || results.command == null) {
    print('Usage: git_tree <command> [options]\n');
    print('Commands: tree, deps, scaffold');
    exit(0);
  }

  final cmd = results.command!;
  switch (cmd.name) {
    case 'tree':
      await GitTreeCLI.runTree(cmd.arguments);
      break;
    case 'deps':
      await GitTreeCLI.runDeps(cmd.arguments);
      break;
    case 'scaffold':
      await GitTreeCLI.runScaffold(cmd.arguments);
      break;
    default:
      print('Unknown command: ${cmd.name}');
      exit(1);
  }
}
import 'dart:io';

import 'path.dart';
import 'quick_snippet.dart';
import 'separator.dart' as separator;
import 'snippet_engine.dart';
import 'utils.dart';
import 'engine_formats/lua_snip.dart';

void main(List<String> args) {
  if (args.contains('-h') || args.contains('--help') || args.contains('help')) {
    print("""
usage dart main.dart <engine1> <engine2> ...
usage dart main.dart help
usage dart main.dart print luasnip 
usage dart path="./snippets/" luasnip
options:
  help => displays this message
  path = <path> => sets the path to parse the snippets, if not previded defaults to the snippets directory in the repo.
  print: prints output instead of writing to a file, will be used by default if no paths are specified for the engine 
  supported engines:
  luasnip
    """);
    exit(1);
  }

  String? path;
  bool onlyPrint = false;

  List<String> engines = [];

  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg.trimLeft().startsWith("path")) {
      if (arg.contains('=')) {
        printError("missing equals sign when assigning path");
        exit(-1);
      }
      path = arg.substring(arg.indexOf('=') + 1).trim();
    } else if (arg.trimLeft().startsWith("print")) {
      onlyPrint = true;
    } else if (arg.trim() != "") {
      engines.add(arg);
    }
  }

  path = path?.asAbsolute ?? Platform.script.path.parent.joinPath("snippets");

  Map<String, dynamic> jsonConfig = readJsonConfig(Directory(path));
  separator.tab = jsonConfig['tab'] ?? separator.tab;
  final processor = EngineProcessor()..updateSnippets(path, jsonConfig);

  if (engines.isEmpty) {
    engines.add(Engine.luaSnip.label);
  }

  for (String engine in engines) {
    final String? enginePath = jsonConfig["${engine}_path"];
    final String engineOutput = processor.process(engine);
    if (onlyPrint || enginePath == null) {
      print(engineOutput);
    } else {
      final file = File(enginePath.asAbsolute);
      file.createSync();
      file.writeAsStringSync(engineOutput);
    }
  }
}

class EngineProcessor {
  List<Snippet> snippets = [];
  void updateSnippets(String path, Map<String, dynamic> config) {
    snippets = readSnippets(Directory(path), config);
  }

  String process(String engineName) {
    Engine? engine = Engine.getMatchingEngine(engineName);
    String out;
    if (engine == null) {
      print("invalid engine");
      exit(1);
    }

    switch (engine) {
      case Engine.luaSnip:
        out = formatLuasnip(snippets);
    }

    return out;
  }
}

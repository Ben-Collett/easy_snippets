import 'dart:convert';
import 'dart:io';

import 'path.dart';
import 'quick_snippet.dart';
import 'constants.dart';
import 'utils.dart';

enum Engine {
  luaSnip("lua_snip");

  final String label;

  static Engine? getMatchingEngine(String label) =>
      values.where((eng) => eng.label == label).firstOrNull;

  const Engine(this.label);
}

Map<String, dynamic> readJsonConfig(Directory dir) {
  return _getSnipJson(dir.listSync());
}

List<Snippet> readSnippets(Directory dir, Map<String, dynamic> json) {
  List<Snippet> out = [];
  List<FileSystemEntity> entries = dir.listSync();

  final bool autoExpandByDefault = json[autoExpandByDefaultKey] ?? true;
  List<String> alternativeExpanding =
      json[alternativeExpandingKey]?.cast<String>() ?? [];

  List<Directory> dirs = entries.whereType<Directory>().toList();

  for (Directory dir in dirs) {
    String language = dir.path.baseName;
    List<File> files = dir.listSync(recursive: true).whereType<File>().toList();
    for (File file in files) {
      out.addAll(
        _getSnippets(
          json,
          alternativeExpanding,
          autoExpandByDefault,
          file,
          language: language,
        ),
      );
    }
  }
  return out;
}

Iterable<Snippet> _getSnippets(
  Map<String, dynamic> json,
  List<String> alternativeExpanding,
  bool autoExpandByDefault,
  File file, {
  String? language,
}) {
  String fileContent = file.readAsStringSync();

  Map<String, dynamic> overrideMap = {};

  if (fileContent.startsWith(overrideBehaviorStart)) {
    final endIndex = fileContent.indexOf(overrideBehaviorEnd);
    if (endIndex == -1) {
      printError(
        "overrideBehaviorStart without override behvoire end in ${file.path}",
      );
      exit(1);
    }
    final override = fileContent.substring(
      overrideBehaviorStart.length,
      endIndex,
    );

    overrideMap = jsonDecode(override);

    fileContent = fileContent.substring(
      endIndex + overrideBehaviorEnd.length + 1,
    );
  }

  final name = file.path.baseName.withoutExtension;
  List<String> snippetTriggers;
  if (overrideMap.containsKey('trigs')) {
    snippetTriggers = (overrideMap['trigs'] as List).cast<String>();
  } else if (json[name] is List) {
    snippetTriggers = (json[name] as List).cast<String>();
  } else {
    snippetTriggers = [json[name] ?? name];
  }
  bool autoExpand = autoExpandByDefault;
  if (alternativeExpanding.contains(snippetTriggers)) {
    autoExpand = !autoExpand;
  }

  bool shouldAutoExpand(String trig) {
    const autoExpandKey = 'autoexpand';
    if (overrideMap[autoExpandKey] is List &&
        overrideMap[autoExpandKey].contains(trig)) {
      return true;
    }
    if (overrideMap.isNotEmpty) {
      return false;
    }

    bool shouldExpand = autoExpandByDefault;

    if (alternativeExpanding.contains(trig)) {
      shouldExpand = !autoExpandByDefault;
    }
    return shouldExpand;
  }

  return snippetTriggers.map(
    (trig) => Snippet(
      fileContent,
      input: trig,
      language: language,
      isAutoExpanding: shouldAutoExpand(trig),
    ),
  );
}

Map<String, dynamic> _getSnipJson(List<FileSystemEntity> entries) {
  Map<String, dynamic> json = {};
  FileSystemEntity? entry = entries
      .where((en) => en.path.baseName == snipJsonFileName)
      .firstOrNull;
  if (entry != null && entry is File) {
    json = jsonDecode(entry.readAsStringSync());
  }

  return json;
}

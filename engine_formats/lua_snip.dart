import '../quick_snippet.dart';
import '../separator.dart';
import '../utils.dart';

String formatLuasnip(List<Snippet> snips) {
  String? language(Snippet snip) => snip.language;

  List<List<Snippet>> snippets = snips.groupBy<String?>(language);

  StringBuffer out = StringBuffer();
  out.writeln('local M = {}');
  out.writeln(_helperFunctions);

  Set<String> functionHeaders = {};

  for (List<Snippet> group in snippets) {
    if (group.isEmpty) {
      printWarning("empty group");
      continue;
    }

    String? language = group.first.language;
    String funcName = language ?? "universal";

    final String header = "$funcName(ls, s, t, i, fmt, rep)";
    out.writeln("local function $header");
    functionHeaders.add(header);
    bool initializedFields = false;
    for (Snippet snippet in group) {
      final String args;
      final String content;
      if (initializedFields) {
        args = "args = ${_getArgs(snippet)}";
        content = "content = ${_getContent(snippet)}";
      } else {
        args = "local args = ${_getArgs(snippet)}";

        content = "local content = ${_getContent(snippet)}";
      }

      final trigger = snippet.input;
      final type = snippet.isAutoExpanding ? "auto" : "manual";
      out.writeln("$tab$args");
      out.writeln("$tab$content");
      out.writeln(
        '${tab}define_${type}_snippet("$language", "$trigger", content, args, ls, s, fmt)',
      );

      initializedFields = true;
    }
    out.writeln('end');
  }

  out.writeln("function M.set_up_snippets(ls, s, t, i, fmt, rep)");
  for (String header in functionHeaders) {
    out.writeln("$tab$header");
  }
  out.writeln("end");

  out.writeln("\n\n--don't copy if you are not using as external module");
  out.write("return M");

  return out.toString();
}

String get _helperFunctions => """
local function define_auto_snippet(language, trig, content, args, ls, s, fmt)
  ls.add_snippets(language, { s({ trig = trig, snippetType = "autosnippet", wordTrig = true }, fmt(content, args)) })
end

local function define_manual_snippet(language, trig, content, args, ls, s, fmt)
  ls.add_snippets(language, { s(trig, fmt(content, args)) })
end
""";

_getContent(Snippet snippet) {
  final content = snippet.content;

  bool escaped = false;
  StringBuffer out = StringBuffer();
  for (int i = 0; i < content.length - 1; i++) {
    if (content[i] == r'\' && content[i + 1] == r'\') {
      out.write(r'\');
      i++;
    } else if (content[i] == r'\' && content[i + 1] == r'{') {
      out.write('{{');
      i++;
    } else if (content[i] == r'\' && content[i + 1] == r'}') {
      out.write('}}');
      i++;
    } else {
      if (!escaped) {
        out.write(content[i]);
      }
      if (content[i] == "{") {
        escaped = true;
      }
      if (content[i] == "}") {
        escaped = false;
        out.write("}");
      }
    }
  }
  return stringifyLua(out.toString());
}

String stringifyLua(String content) {
  content = content.replaceAll('\n', r'\n');
  content = content.replaceAll('"', r'\"');
  return '"$content"';
}

String _getArgs(Snippet snippet) {
  List<Pair> pairs = snippet.pairsInOrder;
  StringBuffer args = StringBuffer("{");

  final List<Field> fields = snippet.fields.values.toSet().toList();
  final Set<Field> seen = {};
  for (int i = 0; i < pairs.length; i++) {
    final pair = pairs[i];
    final field = snippet.fields[pair]!;
    final fieldIndex = fields.indexOf(field) + 1;
    if (seen.contains(field)) {
      args.write("rep($fieldIndex");
    } else {
      args.write("i($fieldIndex");
    }

    if (!field.isPrivate) {
      args.write(',');
      args.write(stringifyLua(field.value));
    }
    args.write(')');

    if (i < pairs.length - 1) {
      args.write(",");
    }
  }
  args.write("}");
  return args.toString();
}

extension NestMap<T> on List<List<T>> {
  List<List<K>> nestedMap<K>(K map(T)) {
    List<List<K>> out = [];
    for (List<T> list in this) {
      out.add([]);
      for (T val in list) {
        out.last.add(map(val));
      }
    }
    return out;
  }
}

extension GroupBy<T> on List<T> {
  List<List<T>> groupBy<K>(K Function(T) toCompare) {
    Map<K, List<T>> map = {};

    for (T value in this) {
      K key = toCompare(value);
      map.putIfAbsent(key, () => List<T>.empty(growable: true));
      map[key]!.add(value);
    }

    return map.values.toList();
  }
}

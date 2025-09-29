import 'utils.dart';

//take snippet file->extract fields
class Snippet {
  late Map<Pair, Field> fields;
  final String? language;
  final bool isAutoExpanding;
  final String content;
  final String input;
  Snippet(
    this.content, {
    this.language,
    this.isAutoExpanding = false,
    required this.input,
  }) {
    fields = {};
    int? currentPairStart;
    for (int i = 0; i < content.length; i++) {
      if (content[i] == r'\') {
        if (i == content.length - 1) {
          printError(r"invalid syntax \ at end of file");
        }
        i++;
        continue;
      }

      if (content[i] == '{') {
        currentPairStart = i;
      } else if (content[i] == '}') {
        int start = currentPairStart!;
        int end = i;

        String out = content.substring(start + 1, end);

        fields[Pair(start, end)] = Field(out);
      }
    }
  }
  List<Pair> get pairsInOrder {
    List<Pair> pairs = fields.keys.toList();
    int byStart(Pair p1, Pair p2) => p1.start.compareTo(p2.start);
    pairs.sort(byStart);
    return pairs;
  }
}

class Field {
  final String _value;
  String get value => isPrivate ? _value.substring(1) : _value;
  bool get isPrivate => _value.startsWith("_");

  @override
  bool operator ==(Object other) {
    if (other is Field) {
      return value == other.value && isPrivate == other.isPrivate;
    }

    return false;
  }

  @override
  String toString() {
    return "(value = $value, private = $isPrivate)";
  }

  const Field(String value) : _value = value;
}

class Pair {
  final int start, end;

  @override
  String toString() {
    return "($start,$end)";
  }

  Pair(this.start, this.end);
}

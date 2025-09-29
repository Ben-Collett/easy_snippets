import 'quick_snippet.dart';

void main(List<String> args) {
  testSnippet();
  testSecondSnippet();
}

void testSnippet() {
  final snippet = Snippet("hello {there} {_dog}", input: "");
  Pair firstPair = snippet.fields.keys.first;
  Pair lastPair = snippet.fields.keys.last;
  const String testName = "snippet test";
  formattedAssert(firstPair.start == 6, testName, "wrong start in first pair");
  formattedAssert(firstPair.end == 12, testName, "wrong end in first pair");
  formattedAssert(lastPair.start == 14, testName, "wrong start in second pair");
  formattedAssert(lastPair.end == 19, testName, "wrong end in second pair");

  Field firstField = snippet.fields[firstPair]!;
  Field secondField = snippet.fields[lastPair]!;
  formattedAssert(
    !firstField.isPrivate,
    testName,
    "first field shouldn't be private",
  );
  formattedAssert(
    secondField.isPrivate,
    testName,
    "second field should be private",
  );
  formattedAssert(
    firstField.value == "there",
    testName,
    "wrong name for first field",
  );
  formattedAssert(
    secondField.value == "dog",
    testName,
    "wrong name for second field",
  );

  print("$testName finished");
}

void testSecondSnippet() {
  String snippetStr = r"""class {className}\{
  {_content}
\}{_end}
""";

  Snippet snippet = Snippet(snippetStr, input: "");
  List<Field> expectedFields = [
    Field("className"),
    Field("_content"),
    Field("_end"),
  ];
  List<Field> actualFields = snippet.fields.values.toList();
  for (int i = 0; i < expectedFields.length; i++) {
    formattedAssert(
      _equalFields(actualFields, expectedFields),
      "snippet2",
      "fields don't match expected: $actualFields!=$expectedFields",
    );
  }
}

void formattedAssert(bool condition, String testName, String reason) {
  if (!condition) {
    print("failed $testName, $reason");
  }
}

bool _equalFields(List<Field> fields1, List<Field> fields2) {
  if (fields1.length != fields2.length) return false;
  for (int i = 0; i < fields1.length; i++) {
    if (fields1[i] != fields2[i]) {
      return false;
    }
  }
  return true;
}

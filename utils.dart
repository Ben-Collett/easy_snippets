import 'ansii.dart' as ansii;

void printError(Object? toPrint) {
  print("${ansii.red}${toPrint?.toString()}${ansii.reset}");
}

void printWarning(Object? toPrint) {
  print("${ansii.yellow}${toPrint?.toString()}${ansii.reset}");
}

void printDebug(Object? toPrint) {
  print("${ansii.blue}${toPrint?.toString()}${ansii.reset}");
}

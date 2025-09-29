import 'dart:io';
import 'dart:vmservice_io';

extension Path on String {
  String get baseName => _getBasname(this);
  String get withoutExtension => _withoutExtension(this);

  bool get isAbsolute =>
      (!Platform.isWindows && startsWith("/")) ||
      (Platform.isWindows && _checkAbsoluteWindows(this));
  String joinPath(String path) {
    return "$this${Platform.pathSeparator}$path";
  }

  String get parent {
    String separator = Platform.pathSeparator;
    int lastIndexOfSeparator = lastIndexOf(separator);
    if (lastIndexOfSeparator == -1) {
      return this;
    }
    return substring(0, lastIndexOfSeparator);
  }

  String get asAbsolute {
    if (isAbsolute) {
      return this;
    }
    if (startsWith('~/') || this == '~') {
      return replaceFirst('~', homeDir!.path);
    }
    return Directory.current.path.joinPath(this);
  }
}

bool _checkAbsoluteWindows(String path) {
  return path.startsWith(RegExp(r'[A-Za-z]:\\')) || // Drive letter (e.g., C:\)
      path.startsWith(r'\\'); // UNC path (e.g., \\server\share)
}

String _getBasname(String path) {
  String separator = Platform.pathSeparator;
  return path.split(separator).last;
}

String _withoutExtension(String path) {
  final lastIndex = path.lastIndexOf('.');
  if (lastIndex == -1) {
    return path;
  }
  return path.substring(0, lastIndex);
}

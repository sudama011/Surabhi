// lib/core/utils/string_extensions.dart

extension StringCasingExtension on String {
  /// Capitalizes the first letter and lowercases the rest.
  /// Example: "hello" -> "Hello", "WORLD" -> "World"
  String get toCapitalized => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  /// Capitalizes the first letter of every word.
  /// Example: "hello world" -> "Hello World"
  String get toTitleCase => replaceAll(RegExp(' +'), ' ').trim().split(' ').map((str) => str.toCapitalized).join(' ');
}

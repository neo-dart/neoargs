import 'package:meta/meta.dart';

export 'src/argv.dart';

/// A simple argument parser result and with support for strings only.
///
/// ## Equality
///
/// Both [==] and [hashCode] are _structurally_ checked; a [StringArgs] is
/// equal to another (and produces the same hash) if [parameters] are both
/// present and in the exact same order, while [options] are considered
/// unordered.
@immutable
@sealed
class StringArgs {
  /// Positional parameters that were parsed.
  final List<String> parameters;

  /// Named options that were parsed, normally as a [String].
  ///
  /// An option that was parsed more than once is stored as a `List<String>`.
  final Map<String, Object> options;

  const StringArgs._(this.parameters, this.options);

  static String _entryToString(MapEntry<Object?, Object?> e) {
    return '${e.key}=${e.value}';
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(parameters),
      Object.hashAllUnordered(options.entries.map(_entryToString)),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! StringArgs ||
        parameters.length != other.parameters.length ||
        options.length != other.options.length) {
      return false;
    }
    for (var i = 0; i < parameters.length; i++) {
      if (parameters[i] != other.parameters[i]) {
        return false;
      }
    }
    for (final option in options.entries) {
      final a = option.value;
      final b = other.options[option.key];
      if (a is String) {
        return b is String && a == b;
      } else {
        final aList = a as List<String>;
        if (b is List<String> && a.length == b.length) {
          final bList = b;
          for (var i = 0; i < aList.length; i++) {
            if (aList[i] != bList[i]) {
              return false;
            }
          }
        } else {
          return false;
        }
      }
    }
    return true;
  }

  @override
  String toString() {
    final output = StringBuffer();
    const StringArgsPrinter().print(this, output);
    return output.toString();
  }
}

/// Prints a string representation of [StringArgs], often for debugging.
@immutable
@sealed
class StringArgsPrinter {
  final bool _preferQuotes;
  final bool _preferSingle;

  /// Creates a default printer that only quotes values if necessary.
  const StringArgsPrinter()
      : _preferQuotes = false,
        _preferSingle = false;

  /// Creates a default printer that prefers quoting values with single quotes.
  const StringArgsPrinter.preferSingleQuotes()
      : _preferQuotes = true,
        _preferSingle = true;

  /// Creates a default printer that prefers quoting values with double quotes.
  const StringArgsPrinter.preferDoubleQuotes()
      : _preferQuotes = true,
        _preferSingle = false;

  static final _whitespace = RegExp(r'\w');

  /// As-needed, wraps and returns [input] in quotes.
  ///
  /// How this method behaves depends on [_preferQuotes] and [_preferSingle].
  String _quote(String input) {
    if (input.contains(_whitespace) || _preferQuotes) {
      final q = _preferSingle ? "'" : '"';
      return '$q$input$q';
    } else {
      return input;
    }
  }

  /// Wraps and returns [input] as an option assignment.
  String _option(MapEntry<String, Object> input) {
    final key = input.key.length == 1 ? '-${input.key}' : '--${input.key}';
    final value = input.value;
    if (value is String) {
      return value.isEmpty ? key : '$key=${_quote(value)}';
    } else if (value is List<String>) {
      return value.map((e) => e.isEmpty ? key : '$key=${_quote(e)}').join(' ');
    } else {
      throw StateError('Unexpected: $value');
    }
  }

  /// Prints a text representation of [args] to the provided [output].
  void print(StringArgs args, StringSink output) {
    output
      ..writeAll(args.parameters.map(_quote), ' ')
      ..writeAll(args.options.entries.map(_option), ' ');
  }
}

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
    // Early exit if different object OR with a different amount of arguments.
    if (other is! StringArgs ||
        parameters.length != other.parameters.length ||
        options.length != other.options.length) {
      return false;
    }

    // Every positional parameter must be the same AND in the same order.
    for (var i = 0; i < parameters.length; i++) {
      if (parameters[i] != other.parameters[i]) {
        return false;
      }
    }

    // Every named option must be the same (but without ordering guarantees).
    for (final option in options.entries) {
      final a = option.value;
      final b = other.options[option.key];
      if (a is String) {
        // String options must be the same as other strings.
        return b is String && a == b;
      } else {
        // List options must be the same as other strings AND in the same order.
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

    // By this point, the objects are (structurally) equivalent.
    return true;
  }

  @override
  String toString() {
    final output = StringBuffer();
    const _StringArgsPrinter().print(this, output);
    return output.toString();
  }
}

/// Prints a string representation of [StringArgs], often for debugging.
///
/// In a future release this can be made public for customized output.
@immutable
@sealed
class _StringArgsPrinter {
  static const _preferQuotes = false;
  static const _preferSingle = false;

  /// Creates a default printer that only quotes values if necessary.
  const _StringArgsPrinter();

  static final _whitespace = RegExp(r'\w');

  /// As-needed, wraps and returns [input] in quotes.
  ///
  /// How this method behaves depends on [_preferQuotes] and [_preferSingle].
  String _quote(String input) {
    if (input.contains(_whitespace) || _preferQuotes) {
      const q = _preferSingle ? "'" : '"';
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

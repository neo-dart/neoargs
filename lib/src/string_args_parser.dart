part of '../neoargs.dart';

/// Helper class for parsing `List<String>` into structured data.
///
/// The provided methods [onValue], [onOption], [onOptionWithValue] are invoked
/// when [parse] is called and there is a matching structured data.
class _StringArgsParser {
  static const _$hyphen = 0x2d;
  static const _$equals = 0x3d;

  /// Invoked when a positional parameter _or_ an option value is parsed.
  ///
  /// Context can only be determined if the previous call was [onOption].
  final void Function(String) onValue;

  /// Invoked when a named option is parsed.
  ///
  /// The next call to [onValue] should be considered the value of this option.
  final void Function(String) onOption;

  /// Invoked when a named option/value pair is parsed.
  final void Function(String, String) onOptionWithValue;

  _StringArgsParser({
    required this.onValue,
    required this.onOption,
    required this.onOptionWithValue,
  });

  void parse(List<String> args) {
    var parseOptions = true;

    for (final arg in args) {
      if (arg.isEmpty) {
        continue;
      }
      if (parseOptions && arg.codeUnitAt(0) == _$hyphen) {
        parseOptions = _parseOptionOrStopParsingOptions(arg);
        continue;
      }
      onValue(arg);
    }
  }

  bool _parseOptionOrStopParsingOptions(String arg) {
    // Not a valid option.
    if (arg.length == 1) {
      return true;
    }

    // Whether we parsed a short option ("-pVM" or "-p").
    if (arg.codeUnitAt(1) != _$hyphen) {
      _parseShortOption(arg);
      return true;
    }

    // Whether we parsed "--".
    if (arg.length == 2) {
      return false;
    }

    // Whether we parsed a long option("--platform=VM" or "--platform").
    _parseLongOption(arg);
    return true;
  }

  void _parseShortOption(String arg) {
    if (arg.length == 2) {
      onOption(arg[1]);
    } else {
      onOptionWithValue(arg[1], arg.substring(2));
    }
  }

  void _parseLongOption(String arg) {
    int? equals;
    for (var i = 2; i < arg.length; i++) {
      if (arg.codeUnitAt(i) == _$equals) {
        equals = i;
        break;
      }
    }
    if (equals == null) {
      onOption(arg.substring(2));
    } else {
      final option = arg.substring(2, equals);
      final value = arg.substring(equals + 1);
      onOptionWithValue(option, value);
    }
  }
}

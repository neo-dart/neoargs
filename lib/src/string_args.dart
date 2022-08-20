// ignore_for_file: prefer_const_constructors_in_immutables

part of '../neoargs.dart';

/// A set of parameters (positional arguments) and options (named arguments).
///
/// [StringArgs] is intended to be the _simplest_ **complete** way to parse and
/// refer to parsed command-line [String] arguments, similar to the NPM package
/// [minimist][]:
///
/// ```dart
/// import 'dart:io';
///
/// /// Example that parses `<source> --recursive` and calls [File.createSync].
/// void main(List<String> args) {
///   final parsed = StringArgs.parse(args);
///   final target = parsed.requireParameter(0, 'target');
///   final recursive = parsed.getOption('recursive').optionalOnce() == '';
///   File(target).createSync(recursive: recursive);
/// }
/// ```
///
/// [minimist]: https://www.npmjs.com/package/minimist
///
/// ## Equality
///
/// Instances of this class are considered structurally equal ([==], [hashCode])
/// if and only if they contain exactly the same positional arguments (in the
/// same order) and exactly the same named arguments - however, **order is not
/// considered** for the options themselves:
///
/// ```sh
/// # All of these arguments would be considered structurally equal.
/// foo bar --option a --option b
/// foo --option a bar --option b
/// --option a --option b foo bar
///
/// # These the arguments are not considered structurally equal.
/// foo bar --option a --option b
/// foo bar --option b --option a
/// bar foo --option a --option b
/// ```
@immutable
@sealed
abstract class StringArgs {
  /// [StringArgs] that is considered to have no parameters or options.
  ///
  /// This field can be used as a default parameter, i.e.:
  /// ```dart
  /// void run([StringArgs args = StringArgs.empty]) {
  ///   // ...
  /// }
  /// ```
  static const StringArgs empty = _StringArgs([], {});

  /// Creates [StringArgs] from the provided [parameters] and [options].
  ///
  /// Valid values for [options] must be either `String` or `Iterable<String>`.
  ///
  /// While this constructor can be useful for some forms of testing, it is
  /// recommended to **prefer** using [StringArgs.parse], potentially combined
  /// with [argv], in order to better simulate real-world conditions:
  ///
  /// ```dart
  /// void runWith(StringArgs args) { /* ... */ }
  ///
  /// test('should foo when foo is enabled', () {
  ///   // Example code.
  ///   expect(runWith(StringArgs.parse(argv('--foo=true))), doesFoo);
  /// });
  /// ```
  factory StringArgs.from(
    Iterable<String> parameters, [
    Map<String, Object> options = const {},
  ]) {
    return _StringArgs(List.of(parameters), options.map((key, value) {
      if (value is String) {
        return MapEntry(key, StringArgsOption.oneValue(key, value));
      } else if (value is Iterable<String>) {
        return MapEntry(key, StringArgsOption.manyValues(key, value));
      } else {
        throw ArgumentError('Unexpected value ($key): $value.');
      }
    }));
  }

  /// Parses and returns arguments.
  ///
  /// [args] is expected to be pre-parsed command-line arguments, i.e. either
  /// from a `void main(List<String> args)` function, created by [argv], or
  /// something similar.
  factory StringArgs.parse(List<String> args) {
    final parameters = <String>[];
    final options = <String, List<String>>{};

    String? option;

    void ifPreviousOptionThenClear() {
      final o = option;
      if (o != null) {
        (options[o] ??= []).add('');
      }
      option = null;
    }

    _StringArgsParser(
      onValue: (v) {
        final o = option;

        // Whether a plain value was parsed.
        if (o == null) {
          parameters.add(v);
          return;
        }

        // Whether a value was parsed associated with a prior option.
        (options[o] ??= []).add(v);
        option = null;
      },
      onOption: (o) {
        ifPreviousOptionThenClear();
        option = o;
      },
      onOptionWithValue: (o, v) {
        ifPreviousOptionThenClear();
        (options[o] ??= []).add(v);
      },
    ).parse(args);

    ifPreviousOptionThenClear();

    return _StringArgs(
      parameters,
      options.map(
        (option, values) => MapEntry(
          option,
          values.length > 1
              ? StringArgsOption.manyValues(option, values)
              : StringArgsOption.oneValue(option, values.first),
        ),
      ),
    );
  }

  const StringArgs._();

  /// Returns a wrapper around the value, if any, for the provided named option.
  ///
  /// As all options are treated as strings, a value of an empty string (`''`)
  /// could be treated as `true`, i.e. the representation of `--verbose`.
  StringArgsOption getOption(String name);

  /// Number of positional parameters.
  ///
  /// This method can be used to expect a certain number of parameters:
  /// ```dart
  /// void example(StringArgs args) {
  ///   if (args.length != 2) {
  ///     print('Expected <source> <destination>');
  ///   }
  /// }
  /// ```
  int get length;

  /// Returns the value of the positional parameter of the provided index.
  ///
  /// If [index] equals or exceeds [length], an error is thrown. An optional
  /// [debugName] may be provided in order to throw a more descriptive error
  /// message (for debugging purposes only).
  @nonVirtual
  String requireParameter(int index, {String? debugName}) {
    final value = optionalParameter(index);
    if (value == null) {
      if (debugName == null) {
        throw StateError('No parameter #$index');
      } else {
        throw StateError('No parameter #$index ($debugName)');
      }
    }
    return value;
  }

  /// Returns the value of the positional parameter of the provided index.
  ///
  /// If [index] equals or exceeds [length], `null` is returned.
  String? optionalParameter(int index);

  /// Returns a collection of all positional parameters as a list.
  ///
  /// Order is guaranteed to be identical to parsing order.
  ///
  /// **NOTE**: For reading specific parameters, it is recommended to use the
  /// [requireParameter] or [optionalParameter] method for more consistent
  /// behavior with options.
  List<String> parametersToList();

  /// Returns a collection of all named options as a map.
  ///
  /// Order is guaranteed to be identical to parsing order.
  ///
  /// **NOTE**: For reading specific options, it is recommended to use the
  /// [getOption] method, as a missing (but expected) option will return an
  /// instance of [StringArgsOption.noValue], while this function will never
  /// return options that were not parsed ([StringArgsOption.wasPresent]).
  Map<String, StringArgsOption> optionsToMap();
}

@immutable
@sealed
class _StringArgs extends StringArgs {
  // Positional arguments with parsing order preserved.
  final List<String> _parameters;

  /// Named arguments with parsing order preserved.
  final Map<String, StringArgsOption> _options;

  const _StringArgs(this._parameters, this._options) : super._();

  @override
  bool operator ==(Object other) {
    // Obvious issues: different type, different amount of arguments.
    if (other is! _StringArgs ||
        _parameters.length != other._parameters.length ||
        _options.length != other._options.length) {
      return false;
    }

    // Different values for parameters.
    for (var i = 0; i < _parameters.length; i++) {
      if (_parameters[i] != other._parameters[i]) {
        return false;
      }
    }

    // Different names, values, or number of values for options.
    final entries = _options.entries.toList();
    final others = other._options.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      if (entries[i].key != others[i].key ||
          entries[i].value.length != others[i].value.length) {
        return false;
      }
      final a = entries[i].value.optionalMany();
      final b = entries[i].value.optionalMany();
      for (var n = 0; n < a.length; n++) {
        if (a[n] != b[n]) {
          return false;
        }
      }
    }

    // Structurally equivalent.
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(_parameters),
      Object.hashAll(_options.values),
    );
  }

  @override
  StringArgsOption getOption(String name) {
    return _options[name] ?? StringArgsOption.noValue(name);
  }

  @override
  int get length => _parameters.length;

  @override
  String? optionalParameter(int index) {
    RangeError.checkNotNegative(index, 'index');
    if (index >= length) {
      return null;
    }
    return _parameters[index];
  }

  @override
  Map<String, StringArgsOption> optionsToMap() => Map.of(_options);

  @override
  List<String> parametersToList() => _parameters.toList();

  @override
  String toString() => [..._parameters, ..._options.values].join(' ');
}

/// A parsed named option pair (i.e. `--name=value`).
///
/// Possible invariants:
/// - [StringArgsOption.noValue]
/// - [StringArgsOption.oneValue]
/// - [StringArgsOption.manyValues]
///
/// ## Equality
///
/// Instances of this class are considered structurally equal ([==], [hashCode])
/// if and only if they are the same invariant, with the same value (if any),
/// and with values in the same order (if applicable):
///
/// ```dart
/// // true
/// StringArgsOption.none('a') == StringArgsOption.none('a')
///
/// // true
/// StringArgsOption.oneValue('a', 'b') == StringArgsOption.oneValue('a', 'b')
///
/// // true
/// StringArgsOption.manyValues('a', ['b', 'c']) == StringArgsOption.manyValues('a', ['b', 'c'])
/// ```
@immutable
@sealed
abstract class StringArgsOption {
  /// Name of the option being looked up.
  ///
  /// The presence of this field does **not** guarantee a value was found.
  final String name;

  /// Create an option for [name] that represents no parsed value.
  ///
  /// This is a stand-in for missing options that allows reasonable behavior
  /// supporting both `requireX` and `optionalX` methods. For example, when
  /// parsing an empty argument list, [StringArgsOption.noValue] should be
  /// returned for any option read.
  factory StringArgsOption.noValue(
    String name,
  ) = _NoneStringArgsOption;

  /// Create an option for [name] that represents a single parsed value.
  ///
  /// This represents parsing `--name=value` or similar.
  factory StringArgsOption.oneValue(
    String name,
    String value,
  ) = _OneValueStringArgsOption;

  /// Create an option for [name] that represents multiple parsed values.
  ///
  /// This represents parsing `--name=value1 --name=value2` or similar.
  ///
  /// If [values] is not at least 2 elements, an error is thrown.
  factory StringArgsOption.manyValues(
    String name,
    Iterable<String> values,
  ) = _ManyValuesStringArgsOption;

  /// Private constructor used for inheritance only.
  const StringArgsOption._(this.name);

  /// How many values are present for the option.
  int get length;

  /// Whether this option was considered _present_, or as a result of parsing.
  ///
  /// When possible it is recommended to either...
  ///
  /// **Explicitly fail**:
  ///
  /// ```dart
  /// void example(StringArgsOption name) {
  ///   print('Name was: ${name.requireOnly()}');
  /// }
  /// ```
  ///
  /// **Gracefully handle**:
  ///
  /// ```dart
  /// void example(StringArgsOption name) {
  ///   print('Name was: ${name.optionalOnly() ?? 'GUEST'}');
  /// }
  /// ```
  ///
  /// Otherwise, [wasPresent] is the canonical way of explicitly checking for
  /// [StringArgsOption.noValue] (i.e. without calling a function that throws
  /// or returns a default value):
  ///
  /// ```dart
  /// void example(StringArgsOption name) {
  ///   if (!name.wasPresent) {
  ///     // Custom error message versus throwing with requireOnly.
  ///     print('"name" argument is required');
  ///   }
  /// }
  /// ```
  bool get wasPresent => true;

  /// Returns the value (or first value of many) associated with this option.
  ///
  /// - If omitted, an error is thrown.
  /// - If associated with multiple values, the first is returned.
  ///
  /// See also: [optionalFirst].
  @nonVirtual
  String requireFirst() {
    return optionalFirst() ?? (throw StateError('No option named "$name"'));
  }

  /// Returns the value (or first value of many) associated with this option.
  ///
  /// - If omitted, `null` is returned.
  /// - If associated with multiple values, the first is returned.
  ///
  /// See also: [requireFirst].
  String? optionalFirst();

  /// Returns the value (and only value) associated with this option.
  ///
  /// - If omitted, an error is thrown.
  /// - If associated with multiple values, an error is thrown.
  ///
  /// See also: [optionalOnce].
  @nonVirtual
  String requireOnce() {
    return optionalOnce() ?? (throw StateError('No option named "$name"'));
  }

  /// Returns the value (and only value) associated with this option.
  ///
  /// - If omitted, `null` is returned.
  /// - If associated with multiple values, an error is thrown.
  String? optionalOnce();

  /// Returns the values associated with this option.
  ///
  /// - If **not** associated with at least 1 value, an error is thrown.
  ///
  /// See also: [optionalMany].
  @nonVirtual
  List<String> requireMany() {
    final result = optionalMany();
    return result.isEmpty
        ? (throw StateError('No option named "$name"'))
        : result;
  }

  /// Returns the values associated with this option.
  ///
  /// - If **not** associated with at least 1 value, an empty list is returned.
  List<String> optionalMany();
}

@immutable
@sealed
class _NoneStringArgsOption extends StringArgsOption {
  const _NoneStringArgsOption(String name) : super._(name);

  @override
  bool get wasPresent => false;

  @override
  int get length => 0;

  @override
  bool operator ==(Object other) {
    return other is _NoneStringArgsOption && name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String? optionalFirst() => null;

  @override
  String? optionalOnce() => null;

  @override
  List<String> optionalMany() => const [];
}

@immutable
@sealed
class _OneValueStringArgsOption extends StringArgsOption {
  final String _value;

  const _OneValueStringArgsOption(String name, this._value) : super._(name);

  @override
  int get length => 1;

  @override
  bool operator ==(Object other) {
    return other is _OneValueStringArgsOption && _value == other._value;
  }

  @override
  int get hashCode => Object.hash(name, _value);

  @override
  String? optionalFirst() => _value;

  @override
  String? optionalOnce() => _value;

  @override
  List<String> optionalMany() => [_value];

  @override
  String toString() {
    final output = '${name.length == 1 ? '-' : '--'}$name';
    return _value.isEmpty ? output : '$output $_value';
  }
}

@immutable
@sealed
class _ManyValuesStringArgsOption extends StringArgsOption {
  final List<String> _values;

  _ManyValuesStringArgsOption(
    String name,
    Iterable<String> values,
  )   : _values = List.of(values),
        super._(name) {
    if (_values.length < 2) {
      throw ArgumentError(
        'Values must have at least 2 elements, got ${_values.length}',
      );
    }
  }

  @override
  int get length => _values.length;

  @override
  bool operator ==(Object other) {
    if (other is! _ManyValuesStringArgsOption) {
      return false;
    }
    if (_values.length != other._values.length) {
      return false;
    }
    for (var i = 0; i < _values.length; i++) {
      if (_values[i] != other._values[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(name, Object.hashAll(_values));

  @override
  String? optionalFirst() => _values.first;

  @override
  String? optionalOnce() {
    throw StateError('More than one option named "$name"');
  }

  @override
  List<String> optionalMany() => _values.toList();

  @override
  String toString() {
    return _values.map((v) => _OneValueStringArgsOption(name, v)).join(' ');
  }
}

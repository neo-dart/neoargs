// ignore_for_file: prefer_const_constructors_in_immutables

part of '../neoargs.dart';

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
}

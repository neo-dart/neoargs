// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:neoargs/neoargs.dart';
import 'package:test/test.dart';

void main() {
  group('StringArgsOption', () {
    group('.noValue', () {
      final namedA = StringArgsOption.noValue('a');

      test('should retain the name provided', () {
        expect(namedA.name, 'a');
      });

      test('should be equal to .noValue with the same name', () {
        expect(namedA, StringArgsOption.noValue('a'));
        expect(namedA.hashCode, StringArgsOption.noValue('a').hashCode);
      });

      test('requireFirst should throw', () {
        expect(namedA.requireFirst, throwsStateError);
      });

      test('optionalFirst should return null', () {
        expect(namedA.optionalFirst(), isNull);
      });

      test('requireOnce should throw', () {
        expect(namedA.requireOnce, throwsStateError);
      });

      test('optionalOnce should return null', () {
        expect(namedA.optionalOnce(), isNull);
      });

      test('requireMany should throw', () {
        expect(namedA.requireMany, throwsStateError);
      });

      test('optionalMany should return an empty list', () {
        expect(namedA.optionalMany(), isEmpty);
      });
    });

    group('.oneValue', () {
      final namedA = StringArgsOption.oneValue('a', 'b');

      test('should retain the name provided', () {
        expect(namedA.name, 'a');
      });

      test('should be equal to .noValue with the same name', () {
        expect(namedA, StringArgsOption.oneValue('a', 'b'));
        expect(namedA.hashCode, StringArgsOption.oneValue('a', 'b').hashCode);
      });

      test('requireFirst should return the provided value', () {
        expect(namedA.requireFirst(), 'b');
      });

      test('optionalFirst should return the provided value', () {
        expect(namedA.optionalFirst(), 'b');
      });

      test('requireOnce should return the provided value', () {
        expect(namedA.requireOnce(), 'b');
      });

      test('optionalOnce should return the provided value', () {
        expect(namedA.optionalOnce(), 'b');
      });

      test('requireMany should return a list with the provided value', () {
        expect(namedA.requireMany(), ['b']);
      });

      test('optionalMany should return a list with the provided value', () {
        expect(namedA.optionalMany(), ['b']);
      });
    });

    group('.manyValues', () {
      test('should throw if created with no values', () {
        expect(
          () => StringArgsOption.manyValues('a', []),
          throwsArgumentError,
        );
      });

      test('should throw if created with one values', () {
        expect(
          () => StringArgsOption.manyValues('a', ['b']),
          throwsArgumentError,
        );
      });

      final namedA = StringArgsOption.manyValues('a', ['b', 'c']);

      test('should retain the name provided', () {
        expect(namedA.name, 'a');
      });

      test('should be equal to .noValue with the same name', () {
        expect(namedA, StringArgsOption.manyValues('a', ['b', 'c']));
        expect(
          namedA.hashCode,
          StringArgsOption.manyValues('a', ['b', 'c']).hashCode,
        );
      });

      test('requireFirst should return the provided value', () {
        expect(namedA.requireFirst(), 'b');
      });

      test('optionalFirst should return the provided value', () {
        expect(namedA.optionalFirst(), 'b');
      });

      test('requireOnce should throw', () {
        expect(namedA.requireOnce, throwsStateError);
      });

      test('optionalOnce should throw', () {
        expect(namedA.requireOnce, throwsStateError);
      });

      test('requireMany should return a list with the provided values', () {
        expect(namedA.requireMany(), ['b', 'c']);
      });

      test('optionalMany should return a list with the provided values', () {
        expect(namedA.optionalMany(), ['b', 'c']);
      });
    });
  });
}

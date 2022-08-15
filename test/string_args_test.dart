// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_declarations

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

      test('wasPresent should be false', () {
        expect(namedA.wasPresent, isFalse);
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

      test('wasPresent should be true', () {
        expect(namedA.wasPresent, isTrue);
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

      test('wasPresent should be true', () {
        expect(namedA.wasPresent, isTrue);
      });
    });
  });

  group('StringArgs', () {
    test('.empty should be empty', () {
      final empty = StringArgs.empty;
      expect(empty.length, 0);
      expect(empty.parametersToList(), isEmpty);
      expect(empty.optionsToMap(), isEmpty);
    });

    group('.from', () {
      test('support no arguments (empty)', () {
        expect(StringArgs.from([]), StringArgs.empty);
        expect(StringArgs.from([], {}), StringArgs.empty);
      });

      test('should support parameters', () {
        final args = StringArgs.from(['a', 'b']);
        expect(args, hasLength(2));
        expect(args.requireParameter(0), 'a');
        expect(args.requireParameter(1), 'b');
        expect(args.optionalParameter(2), isNull);
        expect(() => args.requireParameter(3), throwsStateError);
        expect(
          () => args.requireParameter(3, debugName: 'three'),
          throwsA(
            isA<StateError>().having(
              (e) => '$e',
              '',
              contains(
                'No parameter #3 (three)',
              ),
            ),
          ),
        );
      });

      test('should support missing options', () {
        final args = StringArgs.empty;
        expect(args.getOption('foo').wasPresent, isFalse);
        expect(args.getOption('foo'), hasLength(0));
      });

      test('should support single value options', () {
        final args = StringArgs.from([], {'foo': 'bar'});
        expect(args.getOption('foo').requireFirst(), 'bar');
      });

      test('should support multi value options', () {
        final args = StringArgs.from([], {
          'foo': ['bar', 'baz']
        });
        expect(args.getOption('foo').requireMany(), ['bar', 'baz']);
      });

      test('should reject invalid values', () {
        expect(() => StringArgs.from([], {'foo': 1}), throwsArgumentError);
        expect(() => StringArgs.from([], {'foo': true}), throwsArgumentError);
        expect(
          () => StringArgs.from([], {
            'foo': [1]
          }),
          throwsArgumentError,
        );
      });

      test('should be structurally equivalent', () {
        final a = StringArgs.from([
          'a'
        ], {
          'b': 'c',
          'd': ['e', 'f']
        });
        final b = StringArgs.from([
          'a'
        ], {
          'b': 'c',
          'd': ['e', 'f']
        });
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('should return a list representations of the parameters', () {
        expect(StringArgs.from(['a', 'b']).parametersToList(), ['a', 'b']);
      });

      test('should return a map representations of the options', () {
        expect(
          StringArgs.from([], {
            'a': 'b',
            'c': ['d', 'e'],
          }).optionsToMap(),
          {
            'a': StringArgsOption.oneValue('a', 'b'),
            'c': StringArgsOption.manyValues('c', ['d', 'e']),
          },
        );
      });

      test('should have a readable toString', () {
        expect(StringArgs.empty.toString(), '');
        expect(StringArgs.from(['a']).toString(), 'a');
        expect(StringArgs.from(['a'], {'b': 'c'}).toString(), 'a -b c');
        expect(
          StringArgs.from([
            'a'
          ], {
            'name': ['foo', 'bar']
          }).toString(),
          'a --name foo --name bar',
        );
      });
    });

    group('.parse', () {
      test('should parse empty arguments', () {
        expect(StringArgs.parse([]), StringArgs.empty);
      });

      test('should parse positional parameters', () {
        expect(StringArgs.parse(['a']), StringArgs.from(['a']));
        expect(StringArgs.parse(['a', 'bee']), StringArgs.from(['a', 'bee']));
      });

      group('should parse options', () {
        test('single flag-like "-a"', () {
          expect(StringArgs.parse(['-a']), StringArgs.from([], {'a': ''}));
        });

        test('single with value "-a1"', () {
          expect(StringArgs.parse(['-a1']), StringArgs.from([], {'a': '1'}));
        });

        test('single with value "-a 1"', () {
          expect(StringArgs.parse(['-a 1']), StringArgs.from([], {'a': '1'}));
        });

        test('multiple with values "-a 1 -a 2"', () {
          expect(
            StringArgs.parse([
              '-a 1',
              '-a -2',
            ]),
            StringArgs.from([], {
              'a': ['1', '2']
            }),
          );
        });
      });

      group('should parse long options', () {
        test('single flag-like "--name"', () {
          expect(
            StringArgs.parse(['--name']),
            StringArgs.from([], {'name': ''}),
          );
        });

        test('single with value "--name 1"', () {
          expect(
            StringArgs.parse(['--name 1']),
            StringArgs.from([], {'name': '1'}),
          );
        });

        test('single with value "--name=1"', () {
          expect(
            StringArgs.parse(['--name=1']),
            StringArgs.from([], {'name': '1'}),
          );
        });

        test('multiple with values "--name 1 --name 2', () {
          expect(
            StringArgs.parse([
              '--name 1',
              '--name -2',
            ]),
            StringArgs.from([], {
              'name': ['1', '2']
            }),
          );
        });
      });
    });
  });
}

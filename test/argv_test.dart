import 'package:neoargs/neoargs.dart';
import 'package:test/test.dart';

void main() {
  test('should parse empty/no arguments', () {
    expect(argv(''), isEmpty);
  });

  test('should parse empty/no arguments (whitespace only)', () {
    expect(argv(' '), isEmpty);
    expect(argv('\t'), isEmpty);
    expect(argv('\n'), isEmpty);
    expect(argv(' \t\n'), isEmpty);
  });

  test('should parse an unquoted string', () {
    expect(argv('foo'), ['foo']);
  });

  test('should parse a single quoted string', () {
    expect(argv("'foo'"), ['foo']);
  });

  test('should parse a double quoted string', () {
    expect(argv('"foo"'), ['foo']);
  });

  test('should parse embedded quote types', () {
    expect(argv('"Don\'t"'), ["Don't"]);
  });

  test('should concatenate strings into a single argument', () {
    expect(argv('"This "is" an "\'argument\'.'), ['This is an argument.']);
  });

  test('should parse an escaped double quote', () {
    expect(argv('\\"'), ['"']);
  });

  test('should parse an escaped single quote', () {
    expect(argv("\\'"), ["'"]);
  });

  test('should parse an escaped backslash', () {
    expect(argv('\\\\'), ['\\']);
  });

  test('should fail on a terminal backlash', () {
    expect(() => argv('\\'), throwsFormatException);
  });

  test('should split argument on a space', () {
    expect(argv('1 2 3'), ['1', '2', '3']);
  });

  test('should split argument on a tab', () {
    expect(argv('1\t2\t3'), ['1', '2', '3']);
  });

  test('should split argument on a new line', () {
    expect(argv('1\n2\n3'), ['1', '2', '3']);
  });

  test('should support null arguments', () {
    expect(argv('--x --y="" --z=\'\''), ['--x', '--y=', '--z=']);
  });

  test('should fail on unterminated quotes', () {
    expect(() => argv('"Hello'), throwsFormatException);
    expect(() => argv("'Hello"), throwsFormatException);
  });
}

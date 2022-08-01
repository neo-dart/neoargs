import 'package:meta/meta.dart';

/// Parses a shell-style string [input] into a list of arguments.
///
/// ```dart
/// // [-x, 3, -y, 4, -abc, -beep=boop, foo, bar, baz]
/// print(argv('-x 3 -y 4 -abc -beep=boop foo "bar" \'baz\''));
/// ```
///
/// **WARNING**: This API is experimental, and may change without bumping major
/// releases. Once the rest of the API gets into a stable state, this condition
/// will be relaxed.
@experimental
List<String> argv(String input) {
  const $space = 0x20;
  const $tab = 0x09;
  const $newLine = 0x0a;
  const $backSlash = 0x5c;
  const $doubleQuote = 0x22;
  const $singleQuote = 0x27;

  final output = <String>[];
  StringBuffer? argument;
  int startingQuoteIndex;

  for (var i = 0; i < input.length; i++) {
    final code = input.codeUnitAt(i);

    // If we've started an argument, then end it, otherwise keep waiting.
    if (code == $space || code == $tab || code == $newLine) {
      if (argument != null) {
        output.add(argument.toString());
        argument = null;
      }
      continue;
    }

    // Start composing a new argument.
    argument ??= StringBuffer();

    switch (code) {
      case $backSlash:
        if (i + 1 < input.length) {
          final lookAhead = input.codeUnitAt(i + 1);
          switch (lookAhead) {
            case $space:
            case $tab:
            case $newLine:
              break;
            default:
              argument.writeCharCode(lookAhead);
              break;
          }
        } else {
          throw FormatException(
            'Unexpected terminal backslash',
            input,
            input.length - 1,
          );
        }
        i++;
        break;
      case $doubleQuote:
      case $singleQuote:
        startingQuoteIndex = i;
        while (++i < input.length) {
          if (code == input.codeUnitAt(i)) {
            argument.write(input.substring(startingQuoteIndex + 1, i));
            break;
          }
        }
        if (i == input.length) {
          final type = code == $doubleQuote ? 'double' : 'single';
          throw FormatException(
            'Unterminated $type quote',
            input,
            startingQuoteIndex,
          );
        }
        break;
      default:
        argument.writeCharCode(code);
        break;
    }
  }

  if (argument != null && argument.isNotEmpty) {
    output.add(argument.toString());
  }

  return output;
}

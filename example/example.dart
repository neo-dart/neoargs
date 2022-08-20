// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:neoargs/neoargs.dart' show argv, StringArgs;

void main() {
  // Demonstrates argv, which parses shell-style strings in memory.
  // This can be useful for testing, or for emulating shell behavior.

  // [-x , 3, -y, 4, -abc, -beep=boop, foo, bar, baz]
  print(argv('-x 3 -y 4 -abc -beep=boop foo "bar" \'baz\''));

  // Demonstrates StringArgs, which parses shell-style string arguments.
  final parsed = StringArgs.parse([
    '-x',
    '3',
    '-y',
    '4',
    '--abc',
    '--beep=boop',
    'foo',
    '"bar"',
    "'baz'",
  ]);

  // Parameters.
  print('parsed.requireParameter(0): ${parsed.requireParameter(0)}');
  print('parsed.optionalParameter(3): ${parsed.optionalParameter(3)}');
  print('parsed.parametersToList(): ${parsed.parametersToList()}');

  // Options
  final abc = parsed.getOption('abc');
  print('abc.requireOnce(): ${abc.requireOnce()}');
}

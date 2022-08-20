import 'package:neoargs/neoargs.dart' show argv;

void main() {
  // Demonstrates argv, which parses shell-style strings in memory.
  // This can be useful for testing, or for emulating shell behavior.

  // [-x , 3, -y, 4, -abc, -beep=boop, foo, bar, baz]
  print(argv('-x 3 -y 4 -abc -beep=boop foo "bar" \'baz\''));

  // Demonstrates StringArgs, which parses shell-style string arguments.
  // StringArgs
}

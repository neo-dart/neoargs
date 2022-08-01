import 'package:neoargs/neoargs.dart' show argv;

/// Demonstrates [argv], which parses shell-style strings in memory.
///
/// This can be useful for testing, or for emulating shell behavior.
void main() {
  // [-x, 3, -y, 4, -abc, -beep=boop, foo, bar, baz]
  print(argv('-x 3 -y 4 -abc -beep=boop foo "bar" \'baz\''));
}

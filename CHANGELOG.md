# CHANGELOG

## 0.0.1

- Added `StringArgs`, a [minimist][]-like API for simple string-based parsing:

```dart
// Assume args = ["foo.txt", "--output", "bar.txt"]
void main(List<String> args) {
  final parsed = StringArgs.parse(args);
  print(parsed.requireParameter(0, debugName: 'input'));
  print(parsed.getOption('output').requireOnce());
}
```

- Added `StringArgsOption`, a name-value pair class that represents the parsed
  result of something like `--name=value` or `--name=value1 --name=value2`.

[minimist]: https://www.npmjs.com/package/minimist

## 0.0.0

- Initial release, which is mostly a stub library with a function `argv`.

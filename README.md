# neoargs

A fluent and idiomatic argument parser (usually for command-line apps) in Dart.

[![On pub.dev][pub_img]][pub_url]
[![Code coverage][cov_img]][cov_url]
[![Github action status][gha_img]][gha_url]
[![Dartdocs][doc_img]][doc_url]
[![Style guide][sty_img]][sty_url]

[pub_url]: https://pub.dartlang.org/packages/neoargs
[pub_img]: https://img.shields.io/pub/v/neoargs.svg
[gha_url]: https://github.com/neo-dart/neoargs/actions
[gha_img]: https://github.com/neo-dart/neoargs/workflows/Dart/badge.svg
[cov_url]: https://codecov.io/gh/neo-dart/neoargs
[cov_img]: https://codecov.io/gh/neo-dart/neoargs/branch/main/graph/badge.svg
[doc_url]: https://www.dartdocs.org/documentation/neoargs/latest
[doc_img]: https://img.shields.io/badge/Documentation-neoargs-blue.svg
[sty_url]: https://pub.dev/packages/neodart
[sty_img]: https://img.shields.io/badge/style-neodart-9cf.svg

Currently, this library is a stub. More will be added in the near future.

## Usage

```dart
// [-x, 3, -y, 4, -abc, -beep=boop, foo, bar, baz]
print(argv('-x 3 -y 4 -abc -beep=boop foo "bar" \'baz\''));
```

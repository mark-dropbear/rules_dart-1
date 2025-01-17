# Dart rules for [Bazel](https://bazel.build/)

This is an unofficial set of rules for using Dart with Bazel.

[![CI](https://github.com/matanlurey/rules_dart/actions/workflows/ci.yml/badge.svg)](https://github.com/matanlurey/rules_dart/actions/workflows/ci.yml)

Support is limited to:

- Bazel 7 using `WORKSPACE` and `Bzlmod`;
- ARM64 Macs[^local], [Intel Macs][], or [Linux x64][].

[intel macs]: https://github.com/search?q=repo%3Amatanlurey%2Frules_dart+%22macos-x64%22&type=code
[linux x64]: https://github.com/search?q=repo%3Amatanlurey%2Frules_dart%20%22linux-x64%22&type=code

[^local]: I develop on an ARM64 Mac, but it not running on CI.

In addition, only Dart `3.3.1` is tested on CI.

## Installation

[`Bzlmod`](https://docs.bazel.build/versions/main/bzlmod.html) is required to
use these rules.

<details>

<summary>

### New to Bazel?

</summary>

<p>

Install `bazelisk`: <https://github.com/bazelbuild/bazelisk>. To get started:

```sh
touch WORKSPACE.bazel
touch BUILD.bazel
echo "7.2.0" > .bazelversion

bazel --version
```

You'll also want to become failiar with the [Bazel documentation](https://bazel.build/), and/or check out our [examples](./examples) for a quick start, as the rest of the documentation assumes you have a basic understanding of Bazel.

</details>

### Add Dependency

Add the following to your `MODULE.bazel` file to use `dev_lurey_rules_dart`:

```starlark
bazel_dep(
    name = "dev_lurey_rules_dart",
    version = "0.0.0",
)

# This package is not yet published, so you must use an override.
# See also: https://bazel.build/rules/lib/globals/module.
git_override(
    module_name = "dev_lurey_rules_dart",
    remote = "https://github.com/matanlurey/rules_dart",
    # TODO: Pin to a specific commit.
    # commit = '...',
)

dart = use_extension("@dev_lurey_rules_dart//dart:extensions.bzl", "dart")
dart.toolchain(
    name = "dart",
    version = "3.3.1",
)
```

### Rules

[Build rules](https://bazel.build/concepts/build-files#types-of-build-rules) for
Dart.

```starlark
load(
    "@dev_lurey_rules_dart//dart:defs.bzl",
    "dart_binary",
    "dart_library",
    "dart_package_config",
)
```

> [!TIP]
> For tested example usage, see the [examples](./examples).

#### `dart_binary`

Creates a new Dart binary target, which can be run using `bazel run`.

```dart
// example.dart
void main() {
  print('Hello, World!');
}
```

```starlark
# BUILD.bazel
load("@dev_lurey_rules_dart//dart:defs.bzl", "dart_binary")

dart_binary(
    name = "example",
    main = "example.dart",
)
```

```sh
$ bazel run :example
> Hello, World!
```

| Argument   | Description                                                                                                                             |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `name`     | The name of the target (required).                                                                                                      |
| `main`     | The entrypoint Dart file (required).                                                                                                    |
| `srcs`     | Additional source files to include in the binary.<br>For a binary target, this is typically not needed.                                 |
| `deps`     | Dependencies (`dart_library`) required to run the binary.                                                                               |
| `packages` | [`dart_package_config`](#dart_package_config) target to resolve package URIs.<br>A default package config is generated if not provided. |

#### `dart_library`

Creates a new Dart library target, which can be imported by other Dart code.

```dart
// example.dart
class Example {}
```

```starlark
# BUILD.bazel
load("@dev_lurey_rules_dart//dart:defs.bzl", "dart_library")

dart_library(
    name = "example",
    srcs = ["example.dart"],
)
```

| Argument | Description                                            |
| -------- | ------------------------------------------------------ |
| `name`   | The name of the target (required).                     |
| `srcs`   | The source files to include in the library (required). |
| `deps`   | Dependencies (`dart_library`) used by the library.     |

#### `dart_package_config`

Generates a [`package_config.json`][] file given a (transitive) list of dependencies.

[`package_config.json`]: https://dart.dev/go/dot-packages-deprecation

```starlark
# BUILD.bazel
load("@dev_lurey_rules_dart//dart:defs.bzl", "dart_package_config")

dart_package_config(
    name = "package_config",
    deps = [
        "//packages/foo",
    ],
)
```

> [!INFO]
> This rule is typically generated by default by [`dart_binary`](#dart_binary).

| Argument | Description                                              |
| -------- | -------------------------------------------------------- |
| `name`   | The name of the target (required).                       |
| `deps`   | A list of dependencies to include in the package config. |

### Extensions

[Module extensions](https://bazel.build/external/extension) for the Dart
ecosystem, in this case interaction with `pub`.

```starlark
pub = use_extension(
    "@dev_lurey_rules_dart//dart/extensions:pub.bzl",
    "pub",
)
```

#### `pub.package`

Downloads a Dart package from the [pub.dev](https://pub.dev) repository.

```starlark
pub.package(
    name = "foo",
    version = "1.2.3",
    sha256 = "...",
    build_file = "//packages:foo.BUILD",
)
```

| Argument     | Description                                                    |
| ------------ | -------------------------------------------------------------- |
| `name`       | The name of the package (required).                            |
| `version`    | The version of the package to download (required).             |
| `sha256`     | The SHA256 hash of the package archive (required).             |
| `build_file` | The path to the `BUILD.bazel` file for the package (required). |

## Contributing

Follow the official style guide at <https://bazel.build/rules/deploying>.

To automatically generate (some) parts of `BUILD.bazel` files:

```sh
bazel run //:gazelle update
```

To format the rules:

```sh
bazel run //:buildifier.fix
```

To run the tests:

```sh
bazel test //...
```

### Adding a new version

See [`versions.bzl`](./dart/private/versions.bzl).

## See also

- <https://github.com/bazel-contrib/rules-template>
- <https://github.com/bazelbuild/examples/tree/main/rules>

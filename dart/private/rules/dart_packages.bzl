"""Working with package_config.json files and related."""

load(
    "//dart/private:providers.bzl",
    "DartLibraryInfo",
    "DartPackageConfigInfo",
    "DartPackageRootInfo",
    "get_transitive_deps",
)

# buildifier: disable=function-docstring
def _dart_packages_impl(ctx):
    return [
        DartPackageConfigInfo(
            config = ctx.attr.config,
        ),
    ]

dart_packages = rule(
    implementation = _dart_packages_impl,
    attrs = {
        "config": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
    },
    doc = "Provides access to the package_config.json file for a Dart package.",
)

# buildifier: disable=function-docstring
def _dart_package_config_impl(ctx):
    config_version = 2
    packages = []

    for dep in get_transitive_deps(ctx.attr.deps).to_list():
        info = dep[DartPackageRootInfo]
        packages.append({
            "name": info.package_name,
            "rootUri": info.package_root,
            "packageUri": "lib/",
        })

    out = None

    # If omitte, default to "package_config.json"
    if not ctx.attr.out:
        out = ctx.actions.declare_file("package_config.json")
    else:
        out = ctx.actions.declare_file(ctx.attr.out.name)

    ctx.actions.write(
        out,
        content = json.encode_indent({
            "configVersion": config_version,
            "packages": packages,
        }),
    )

    return [
        DefaultInfo(
            files = depset([out]),
        ),
        DartPackageConfigInfo(
            config = out,
        ),
    ]

dart_package_config = rule(
    implementation = _dart_package_config_impl,
    attrs = {
        "deps": attr.label_list(
            providers = [DartLibraryInfo],
            doc = "The Dart libraries to include in the package_config.json file.",
        ),
        "out": attr.output(
            doc = "The package_config.json file to generate.",
        ),
    },
    doc = """Generates a package_config.json file.

When using Dart with the "pub" package manager, the package_config.json file
is automatically generated by "pub get" and "pub upgrade" commands. This rule
does not run "pub" commands, but instead generates a package_config.json file
based on the dependencies provided to it.

For example:
        load("@dev_lurey_rules_dart//dart:defs.bzl", "dart_package_config")
    
        dart_package_config(
            deps = [
                ":my_library",
                "@some_other_repo//:their_library",
            ],
        )

Would generate a package_config.json file that looks something like:
        {
            "configVersion": 2,
            "packages": [
                {
                    "name": "my_library",
                    "rootUri": "file:///path/to/my_library",
                    "packageUri": "lib/",
                },
                {
                    "name": "their_library",
                    "rootUri": "file:///path/to/their_library",
                    "packageUri": "lib/",
                },
            ],
        }

Note that the file locations specified are intended to match the locations of
the Dart libraries in the build, and are not necessarily the same as the
locations on disk. For that reason, this rule is not currently useful to provide
offline support for tools, i.e. IDEs that expect to find the package_config.json
in ".dart_tool/package_config.json" in the workspace root.

See https://dart.dev/tools/pub/package-config for more information.""",
)

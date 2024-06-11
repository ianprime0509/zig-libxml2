# zig-libxml2

This project is a wrapper around
[libxml2](https://gitlab.gnome.org/GNOME/libxml2) and
[libxslt](https://gitlab.gnome.org/GNOME/libxslt) to build them using the Zig
build system. It supports Zig 0.12.0, 0.13.0, and the latest master (at the time
of writing).

By default, only libxml2 is fetched and built. To include libxslt as well, pass
the `xslt` option (via `.xslt = true` in `build.zig` or `-Dxslt` in the build
command). Several other options are available to customize the build, which can
be found through `zig build --help` (note that since XSLT support is dependent
on `-Dxslt`, `zig build -Dxslt --help` must be used to view XSLT-specific
options).

The executable programs `xmllint`, `xmlcatalog`, and `xsltproc` (only with
`xslt` enabled) are also built alongside the libraries.

Thanks to the existing projects
[mitchellh/zig-libxml2](https://github.com/mitchellh/zig-libxml2) and
[mitchellh/zig-build-libxml2](https://github.com/mitchellh/zig-build-libxml2/)
for providing inspiration for this project. This project is not directly built
on either of them, as I wanted to take another direction with this wrapper (and
also bring in libxslt).

## License

This repository (the Zig build configuration) is released under
[0BSD](https://spdx.org/licenses/0BSD.html). libxml, libxslt, and libexslt
themselves are all under the MIT license(s) in their respective upstreams.

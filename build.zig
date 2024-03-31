const std = @import("std");

pub const libxml2_version: std.SemanticVersion = .{ .major = 2, .minor = 12, .patch = 6 };
pub const libxml2_version_string = std.fmt.comptimePrint("{}.{}.{}", .{ libxml2_version.major, libxml2_version.minor, libxml2_version.patch });
pub const libxml2_version_number = std.fmt.comptimePrint("{}{:0>2}{:0>2}", .{ libxml2_version.major, libxml2_version.minor, libxml2_version.patch });

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libxml2_upstream = b.dependency("libxml2", .{});
    const libxml2 = b.addStaticLibrary(.{
        .name = "xml2",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    b.installArtifact(libxml2);

    // Options and defaults are the same as they are in libxml2's configure.ac.
    const minimal = b.option(bool, "minimal", "Enable only core features by default") orelse false;
    const with_c14n = b.option(bool, "c14n", "Enable Canonical XML 1.0 support") orelse !minimal;
    const with_catalog = b.option(bool, "catalog", "Enable XML Catalogs support") orelse !minimal;
    const with_debug = b.option(bool, "debug", "Enable debugging module and shell") orelse !minimal;
    const with_ftp = b.option(bool, "ftp", "Enable FTP support") orelse false;
    // TODO: --with-history (depends on readline)
    // TODO: --with-readline
    const with_html = b.option(bool, "html", "Enable HTML parser") orelse !minimal;
    const with_http = b.option(bool, "http", "Enable HTTP support") orelse !minimal;
    // TODO: --with-iconv
    // TODO: --with-icu
    const with_iso8859x = b.option(bool, "iso8859x", "Enable ISO-8859-X support") orelse !minimal;
    // TODO: --with-lzma
    const with_mem_debug = b.option(bool, "mem-debug", "Enable memory debugging module") orelse false;
    const with_modules = b.option(bool, "modules", "Enable dynamic modules support") orelse !minimal;
    var with_output = b.option(bool, "output", "Enable serialization support") orelse !minimal;
    var with_pattern = b.option(bool, "pattern", "Enable xmlPattern selection interface") orelse !minimal;
    var with_push = b.option(bool, "push", "Enable push parser interfaces") orelse !minimal;
    // TODO: --with-python
    const with_reader = b.option(bool, "reader", "Enable xmlReader parsing interface") orelse !minimal;
    var with_regexps = b.option(bool, "regexps", "Enable regular expressions support") orelse !minimal;
    // TODO: --with-run-debug is irrelevant?
    // TODO: --with-legacy and --with-sax1
    const with_schemas = b.option(bool, "schemas", "Enable XML Schemas 1.0 and RELAX NG support") orelse !minimal;
    const with_schematron = b.option(bool, "schematron", "Enable Schematron support") orelse !minimal;
    const with_threads = b.option(bool, "threads", "Enable multithreading support") orelse !minimal;
    var with_tree = b.option(bool, "tree", "Enable DOM-like tree manipulation APIs") orelse !minimal;
    const with_valid = b.option(bool, "valid", "Enable DTD validation support") orelse !minimal;
    const with_writer = b.option(bool, "writer", "Enable xmlWriter serialization interface") orelse !minimal;
    const with_xinclude = b.option(bool, "xinclude", "Enable XInclude 1.0 support") orelse !minimal;
    var with_xpath = b.option(bool, "xpath", "Enable XPath 1.0 support") orelse !minimal;
    const with_xptr = b.option(bool, "xptr", "Enabel XPointer support") orelse !minimal;
    const with_xptr_locs = b.option(bool, "xptr-locs", "Enable XPointer ranges and points") orelse false;
    // TODO: --with-zlib
    // In contrast with libxml2's configure script, which disables dependent
    // modules if their dependencies are not enabled, we choose to instead
    // enable any dependencies of the user's selected modules.
    if (with_c14n or with_writer) {
        with_output = true;
    }
    if (with_schemas or with_schematron) {
        with_pattern = true;
    }
    if (with_reader or with_writer) {
        with_push = true;
    }
    if (with_schemas) {
        with_regexps = true;
    }
    if (with_reader or with_schematron) {
        with_tree = true;
    }
    if (with_c14n or with_schematron or with_xinclude or with_xptr) {
        with_xpath = true;
    }

    libxml2.addIncludePath(libxml2_upstream.path("include"));
    libxml2.installHeadersDirectoryOptions(.{
        .source_dir = libxml2_upstream.path("include/libxml"),
        .install_dir = .header,
        .install_subdir = "libxml",
        .include_extensions = &.{".h"},
    });
    // Using the the CMake version of config.h here is more convenient than
    // trying to figure out all the possible defines Autotools is trying to
    // populate, even though the Autotools build is used as the canonical
    // reference for this project.
    // TODO: some of these values will differ by system, especially for Windows.
    // The current configuration was established based on my Linux system.
    const libxml2_config_h = b.addConfigHeader(.{
        .style = .{ .cmake = libxml2_upstream.path("config.h.cmake.in") },
    }, .{
        .ATTRIBUTE_DESTRUCTOR = "__attribute__((destructor))",
        .HAVE_ARPA_INET_H = true,
        .HAVE_ATTRIBUTE_DESTRUCTOR = true,
        .HAVE_DLFCN_H = true,
        .HAVE_DLOPEN = true,
        .HAVE_DL_H = false,
        .HAVE_FCNTL_H = true,
        .HAVE_FTIME = true,
        .HAVE_GETTIMEOFDAY = true,
        .HAVE_INTTYPES_H = true,
        .HAVE_ISASCII = true,
        .HAVE_LIBHISTORY = false,
        .HAVE_LIBREADLINE = false,
        .HAVE_MMAP = true,
        .HAVE_MUNMAP = true,
        .HAVE_NETDB_H = true,
        .HAVE_NETINET_IN_H = true,
        .HAVE_POLL_H = true,
        .HAVE_PTHREAD_H = true,
        .HAVE_SHLLOAD = false,
        .HAVE_STAT = true,
        .HAVE_STDINT_H = true,
        .HAVE_SYS_MMAN_H = true,
        .HAVE_SYS_SELECT_H = true,
        .HAVE_SYS_SOCKET_H = true,
        .HAVE_SYS_STAT_H = true,
        .HAVE_SYS_TIMER_H = true,
        .HAVE_SYS_TIME_H = true,
        .HAVE_UNISTD_H = true,
        .HAVE_VA_COPY = true,
        .HAVE_ZLIB_H = false,
        .HAVE___VA_COPY = true,
        .SUPPORT_IP6 = false,
        .VA_LIST_IS_ARRAY = true,
        .VERSION = libxml2_version_string,
        .XML_SOCKLEN_T = "socklen_t",
        .XML_THREAD_LOCAL = null,
        ._UINT32_T = null,
        .uint32_t = null,
    });
    libxml2.addConfigHeader(libxml2_config_h);
    const libxml2_xmlversion_h = b.addConfigHeader(.{
        .style = .{ .cmake = libxml2_upstream.path("include/libxml/xmlversion.h.in") },
        .include_path = "libxml/xmlversion.h",
    }, .{
        .VERSION = libxml2_version_string,
        .LIBXML_VERSION_NUMBER = libxml2_version_number,
        .LIBXML_VERSION_EXTRA = "",
        .WITH_TRIO = false,
        .WITH_THREADS = with_threads,
        .WITH_THREAD_ALLOC = false,
        .WITH_TREE = with_tree,
        .WITH_OUTPUT = with_output,
        .WITH_PUSH = with_push,
        .WITH_READER = with_reader,
        .WITH_PATTERN = with_pattern,
        .WITH_WRITER = with_writer,
        .WITH_SAX1 = false,
        .WITH_FTP = with_ftp,
        .WITH_HTTP = with_http,
        .WITH_VALID = with_valid,
        .WITH_HTML = with_html,
        .WITH_LEGACY = false,
        .WITH_C14N = with_c14n,
        .WITH_CATALOG = with_catalog,
        .WITH_XPATH = with_xpath,
        .WITH_XPTR = with_xptr,
        .WITH_XPTR_LOCS = with_xptr_locs,
        .WITH_XINCLUDE = with_xinclude,
        .WITH_ICONV = false,
        .WITH_ICU = false,
        .WITH_ISO8859X = with_iso8859x,
        .WITH_DEBUG = with_debug,
        .WITH_MEM_DEBUG = with_mem_debug,
        .WITH_REGEXPS = with_regexps,
        .WITH_SCHEMAS = with_schemas,
        .WITH_SCHEMATRON = with_schematron,
        .WITH_MODULES = with_modules,
        .MODULE_EXTENSION = target.result.dynamicLibSuffix(),
        .WITH_ZLIB = false,
        .WITH_LZMA = false,
    });
    libxml2.addConfigHeader(libxml2_xmlversion_h);
    libxml2.installConfigHeader(libxml2_xmlversion_h, .{});

    // See libxml2's Makefile.am for which sources are included.
    var libxml2_sources = std.ArrayList([]const u8).init(b.allocator);
    libxml2_sources.appendSlice(&.{
        "buf.c",
        "chvalid.c",
        "dict.c",
        "entities.c",
        "encoding.c",
        "error.c",
        "globals.c",
        "hash.c",
        "list.c",
        "parser.c",
        "parserInternals.c",
        "SAX2.c",
        "threads.c",
        "tree.c",
        "uri.c",
        "valid.c",
        "xmlIO.c",
        "xmlmemory.c",
        "xmlstring.c",
    }) catch @panic("OOM");
    if (with_c14n) {
        libxml2_sources.append("c14n.c") catch @panic("OOM");
    }
    if (with_catalog) {
        libxml2_sources.append("catalog.c") catch @panic("OOM");
    }
    if (with_debug) {
        libxml2_sources.append("debugXML.c") catch @panic("OOM");
    }
    if (with_ftp) {
        libxml2_sources.append("nanoftp.c") catch @panic("OOM");
    }
    if (with_html) {
        libxml2_sources.appendSlice(&.{ "HTMLparser.c", "HTMLtree.c" }) catch @panic("OOM");
    }
    if (with_http) {
        libxml2_sources.append("nanohttp.c") catch @panic("OOM");
    }
    if (with_modules) {
        libxml2_sources.append("xmlmodule.c") catch @panic("OOM");
    }
    if (with_output) {
        libxml2_sources.append("xmlsave.c") catch @panic("OOM");
    }
    if (with_pattern) {
        libxml2_sources.append("pattern.c") catch @panic("OOM");
    }
    if (with_reader) {
        libxml2_sources.append("xmlreader.c") catch @panic("OOM");
    }
    if (with_regexps) {
        libxml2_sources.appendSlice(&.{ "xmlregexp.c", "xmlunicode.c" }) catch @panic("OOM");
    }
    if (with_schemas) {
        libxml2_sources.appendSlice(&.{ "relaxng.c", "xmlschemas.c", "xmlschemastypes.c" }) catch @panic("OOM");
    }
    if (with_schematron) {
        libxml2_sources.append("schematron.c") catch @panic("OOM");
    }
    if (with_writer) {
        libxml2_sources.append("xmlwriter.c") catch @panic("OOM");
    }
    if (with_xinclude) {
        libxml2_sources.append("xinclude.c") catch @panic("OOM");
    }
    if (with_xpath or with_schemas) {
        libxml2_sources.append("xpath.c") catch @panic("OOM");
    }
    if (with_xptr) {
        libxml2_sources.appendSlice(&.{ "xlink.c", "xpointer.c" }) catch @panic("OOM");
    }
    libxml2.addCSourceFiles(.{
        .root = libxml2_upstream.path("."),
        .files = libxml2_sources.items,
        .flags = &.{
            "-pedantic",
            "-Wall",
            "-Wextra",
            "-Wshadow",
            "-Wpointer-arith",
            "-Wcast-align",
            "-Wwrite-strings",
            "-Wstrict-prototypes",
            "-Wmissing-prototypes",
            "-Wno-long-long",
            "-Wno-format-extra-args",
        },
    });

    const enable_libxslt = b.option(bool, "xslt", "Enable libxslt") orelse false;
    if (enable_libxslt) libxslt: {
        const libxslt_upstream = b.lazyDependency("libxslt", .{}) orelse break :libxslt;
        _ = libxslt_upstream;
        // TODO
    }
}

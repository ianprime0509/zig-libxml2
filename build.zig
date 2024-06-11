const std = @import("std");

pub const libxml2_version: std.SemanticVersion = .{ .major = 2, .minor = 12, .patch = 6 };
pub const libxslt_version: std.SemanticVersion = .{ .major = 1, .minor = 1, .patch = 39 };
pub const libexslt_version: std.SemanticVersion = .{ .major = 0, .minor = 8, .patch = 21 };

inline fn versionString(comptime v: std.SemanticVersion) []const u8 {
    return std.fmt.comptimePrint("{}.{}.{}", .{ v.major, v.minor, v.patch });
}

inline fn versionNumber(comptime v: std.SemanticVersion) []const u8 {
    return std.mem.trimLeft(u8, std.fmt.comptimePrint("{}{:0>2}{:0>2}", .{ v.major, v.minor, v.patch }), "0");
}

inline fn versionExtra(comptime v: std.SemanticVersion) []const u8 {
    return if (v.pre) |pre| std.fmt.comptimePrint("-{s}", .{pre}) else "";
}

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
    var with_html = b.option(bool, "html", "Enable HTML parser") orelse !minimal;
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

    // libxslt may also require certain libxml2 features to be enabled if it is
    // desired.
    const enable_libxslt = b.option(bool, "xslt", "Enable libxslt") orelse false;
    if (enable_libxslt) {
        with_html = true;
        with_output = true;
        with_tree = true;
        with_xpath = true;
    }

    libxml2.addIncludePath(libxml2_upstream.path("include"));
    libxml2.installHeadersDirectory(libxml2_upstream.path("include/libxml"), "libxml", .{
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
        .VERSION = versionString(libxml2_version),
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
        .VERSION = versionString(libxml2_version),
        .LIBXML_VERSION_NUMBER = versionNumber(libxml2_version),
        .LIBXML_VERSION_EXTRA = versionExtra(libxml2_version),
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
    libxml2.installConfigHeader(libxml2_xmlversion_h);

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
    const libxml2_cflags: []const []const u8 = &.{
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
    };
    libxml2.addCSourceFiles(.{
        .root = libxml2_upstream.path("."),
        .files = libxml2_sources.items,
        .flags = libxml2_cflags,
    });

    const xmllint = b.addExecutable(.{
        .name = "xmllint",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    b.installArtifact(xmllint);
    xmllint.linkLibrary(libxml2);
    xmllint.addConfigHeader(libxml2_config_h);
    xmllint.addCSourceFile(.{
        .file = libxml2_upstream.path("xmllint.c"),
        .flags = libxml2_cflags,
    });

    const xmlcatalog = b.addExecutable(.{
        .name = "xmlcatalog",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    b.installArtifact(xmlcatalog);
    xmlcatalog.linkLibrary(libxml2);
    xmlcatalog.addConfigHeader(libxml2_config_h);
    xmlcatalog.addCSourceFile(.{
        .file = libxml2_upstream.path("xmlcatalog.c"),
        .flags = libxml2_cflags,
    });

    if (enable_libxslt) libxslt: {
        const libxslt_upstream = b.lazyDependency("libxslt", .{}) orelse break :libxslt;

        const libxslt = b.addStaticLibrary(.{
            .name = "xslt",
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        b.installArtifact(libxslt);
        libxslt.linkLibrary(libxml2);

        // Options and defaults are the same as they are in libxslt's configure.ac.
        // TODO: --with-crypto
        // TODO: --with-python
        const with_xslt_debug = b.option(bool, "xslt-debug", "Enable libxslt debugging code") orelse with_debug;
        const with_xslt_mem_debug = b.option(bool, "xslt-mem-debug", "Enable libxslt memory debugging module") orelse with_mem_debug;
        const with_xslt_debugger = b.option(bool, "xslt-debugger", "Enable libxslt debugging support") orelse !minimal;
        const with_xslt_profiler = b.option(bool, "xslt-profiler", "Enable libxslt profiling support") orelse !minimal;

        libxslt.addIncludePath(libxslt_upstream.path("."));
        libxslt.installHeadersDirectory(libxslt_upstream.path("libxslt"), "libxslt", .{
            .include_extensions = &.{".h"},
        });
        // Using the the CMake version of config.h here is more convenient than
        // trying to figure out all the possible defines Autotools is trying to
        // populate, even though the Autotools build is used as the canonical
        // reference for this project.
        // TODO: some of these values will differ by system, especially for Windows.
        // The current configuration was established based on my Linux system.
        const libxslt_config_h = b.addConfigHeader(.{
            .style = .{ .cmake = libxslt_upstream.path("config.h.cmake.in") },
        }, .{
            .HAVE_CLOCK_GETTIME = true,
            .HAVE_FTIME = true,
            .HAVE_GCRYPT = false,
            .HAVE_GETTIMEOFDAY = true,
            .HAVE_GMTIME_R = true,
            .HAVE_LIBPTHREAD = false,
            .HAVE_LOCALE_H = true,
            .HAVE_LOCALTIME_R = true,
            .HAVE_PTHREAD_H = false,
            .HAVE_SNPRINTF = true,
            .HAVE_STAT = true,
            .HAVE_STRXFRM_L = true,
            .HAVE_SYS_SELECT_H = true,
            .HAVE_SYS_STAT_H = true,
            .HAVE_SYS_TIMEB_H = true,
            .HAVE_SYS_TIME_H = true,
            .HAVE_SYS_TYPES_H = true,
            .HAVE_UNISTD_H = true,
            .HAVE_VSNPRINTF = true,
            .HAVE_XLOCALE_H = false,
            .HAVE__STAT = false,
            .LT_OBJDIR = ".libs/",
            .PACKAGE = "libxslt",
            .PACKAGE_BUGREPORT = "xml@gnome.org",
            .PACKAGE_NAME = "libxslt",
            .PACKAGE_STRING = "libxslt " ++ versionString(libxslt_version),
            .PACKAGE_TARNAME = "libxslt",
            .PACKAGE_URL = "https://gitlab.gnome.org/GNOME/libxslt",
            .PACKAGE_VERSION = versionString(libxslt_version),
            .VERSION = versionString(libxslt_version),
        });
        libxslt.addConfigHeader(libxslt_config_h);
        const libxslt_xsltconfig_h = b.addConfigHeader(.{
            .style = .{ .cmake = libxslt_upstream.path("libxslt/xsltconfig.h.in") },
            .include_path = "libxslt/xsltconfig.h",
        }, .{
            .VERSION = versionString(libxslt_version),
            .LIBXSLT_VERSION_NUMBER = versionNumber(libxslt_version),
            .LIBXSLT_VERSION_EXTRA = versionExtra(libxslt_version),
            .WITH_XSLT_DEBUG = with_xslt_debug,
            .WITH_MEM_DEBUG = with_xslt_mem_debug,
            .WITH_TRIO = false,
            .WITH_DEBUGGER = with_xslt_debugger,
            .WITH_PROFILER = with_xslt_profiler,
            .WITH_MODULES = with_modules,
            .LIBXSLT_DEFAULT_PLUGINS_PATH = "",
        });
        libxslt.addConfigHeader(libxslt_xsltconfig_h);
        libxslt.installConfigHeader(libxslt_xsltconfig_h);

        // See libxslt's Makefile.am for which sources are included.
        const libxslt_cflags: []const []const u8 = &.{
            "-Wall",
            "-Wextra",
            "-Wshadow",
            "-Wpointer-arith",
            "-Wcast-align",
            "-Wwrite-strings",
            "-Waggregate-return",
            "-Wstrict-prototypes",
            "-Wmissing-prototypes",
            "-Wnested-externs",
            "-Winline",
            "-Wredundant-decls",
        };
        libxslt.addCSourceFiles(.{
            .root = libxslt_upstream.path("libxslt"),
            .files = &.{
                "attrvt.c",
                "xslt.c",
                "xsltlocale.c",
                "xsltutils.c",
                "pattern.c",
                "templates.c",
                "variables.c",
                "keys.c",
                "numbers.c",
                "extensions.c",
                "extra.c",
                "functions.c",
                "namespaces.c",
                "imports.c",
                "attributes.c",
                "documents.c",
                "preproc.c",
                "transform.c",
                "security.c",
            },
            .flags = libxslt_cflags,
        });

        const libexslt = b.addStaticLibrary(.{
            .name = "exslt",
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        b.installArtifact(libexslt);
        libexslt.linkLibrary(libxml2);
        libexslt.linkLibrary(libxslt);

        libexslt.addIncludePath(libxslt_upstream.path("."));
        libexslt.installHeadersDirectory(libxslt_upstream.path("libexslt"), "libexslt", .{
            .include_extensions = &.{".h"},
        });
        libexslt.addConfigHeader(libxslt_config_h);
        const libexslt_exsltconfig_h = b.addConfigHeader(.{
            .style = .{ .cmake = libxslt_upstream.path("libexslt/exsltconfig.h.in") },
            .include_path = "libexslt/exsltconfig.h",
        }, .{
            .LIBEXSLT_VERSION = versionString(libexslt_version),
            .LIBEXSLT_VERSION_NUMBER = versionNumber(libexslt_version),
            .LIBEXSLT_VERSION_EXTRA = versionExtra(libexslt_version),
            .WITH_CRYPTO = false,
        });
        libexslt.addConfigHeader(libexslt_exsltconfig_h);
        libexslt.installConfigHeader(libexslt_exsltconfig_h);

        // See libexslt's Makefile.am for which sources are included.
        libexslt.addCSourceFiles(.{
            .root = libxslt_upstream.path("libexslt"),
            .files = &.{
                "exslt.c",
                "common.c",
                "crypto.c",
                "math.c",
                "sets.c",
                "functions.c",
                "strings.c",
                "date.c",
                "saxon.c",
                "dynamic.c",
            },
            .flags = libxslt_cflags,
        });

        const xsltproc = b.addExecutable(.{
            .name = "xsltproc",
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        b.installArtifact(xsltproc);
        xsltproc.linkLibrary(libxml2);
        xsltproc.linkLibrary(libxslt);
        xsltproc.linkLibrary(libexslt);
        xsltproc.addConfigHeader(libxslt_config_h);
        xsltproc.addCSourceFile(.{
            .file = libxslt_upstream.path("xsltproc/xsltproc.c"),
            .flags = libxslt_cflags,
        });
    }
}

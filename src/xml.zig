const std = @import("std");

pub const Error = extern struct {
    domain: Domain,
    code: Code,
    message: [*:0]u8,
    level: Level,
    file: ?[*:0]u8,
    line: c_int,
    str1: ?[*:0]u8,
    str2: ?[*:0]u8,
    str3: ?[*:0]u8,
    int1: c_int,
    int2: c_int,
    ctxt: ?*anyopaque,
    node: ?*anyopaque,

    pub const Domain = enum(c_int) {
        // TODO
        _,
    };

    pub const Code = enum(c_int) {
        // TODO
        _,
    };

    pub const Level = enum(c_int) {
        none,
        warning,
        @"error",
        fatal,
    };
};

pub fn lastError() ?*const Error {
    return xmlGetLastError();
}
extern fn xmlGetLastError() ?*const Error;

pub const ParseOptions = packed struct(c_int) {
    recover: bool = false,
    substitute_entities: bool = false,
    dtd_load: bool = false,
    dtd_attributes: bool = false,
    dtd_validate: bool = false,
    no_errors: bool = false,
    no_warnings: bool = false,
    pedantic: bool = false,
    no_blanks: bool = false,
    sax1: bool = false,
    xinclude: bool = false,
    no_network: bool = false,
    no_dictionary: bool = false,
    clean_namespaces: bool = false,
    no_cdata: bool = false,
    no_xinclude_nodes: bool = false,
    compact: bool = false,
    old10: bool = false,
    no_base_fix: bool = false,
    huge: bool = false,
    old_sax: bool = false,
    ignore_encoding: bool = false,
    big_lines: bool = false,
    no_xxe: bool = false,
    _padding: @Type(.{ .Integer = .{ .bits = @bitSizeOf(c_int) - 24, .signedness = .unsigned } }) = 0,
};

pub const Reader = opaque {
    pub fn newForPath(path: [:0]const u8, encoding: ?[:0]const u8, options: ParseOptions) error{XmlError}!*Reader {
        return xmlReaderForFile(path, encoding orelse null, options) orelse error.XmlError;
    }
    extern fn xmlReaderForFile(uri: [*:0]const u8, encoding: ?[*:0]const u8, options: ParseOptions) ?*Reader;

    pub fn free(reader: *Reader) void {
        xmlFreeTextReader(reader);
    }
    extern fn xmlFreeTextReader(reader: *Reader) void;

    pub fn lastError(reader: *Reader) ?*const Error {
        return xmlTextReaderGetLastError(reader);
    }
    extern fn xmlTextReaderGetLastError(reader: *Reader) ?*const Error;

    pub fn read(reader: *Reader) error{XmlError}!bool {
        return try handle(xmlTextReaderRead(reader)) != 0;
    }
    extern fn xmlTextReaderRead(reader: *Reader) c_int;

    pub fn next(reader: *Reader) error{XmlError}!bool {
        return try handle(xmlTextReaderNext(reader)) != 0;
    }
    extern fn xmlTextReaderNext(reader: *Reader) c_int;

    pub fn nodeType(reader: *Reader) error{XmlError}!Node {
        return @enumFromInt(try handle(xmlTextReaderNodeType(reader)));
    }
    extern fn xmlTextReaderNodeType(reader: *Reader) c_int;

    pub const Node = enum(c_int) {
        none,
        element,
        attribute,
        text,
        cdata,
        entity_reference,
        entity,
        processing_instruction,
        comment,
        document,
        document_type,
        document_fragment,
        notation,
        whitespace,
        significant_whitespace,
        end_element,
        end_entity,
        xml_declaration,
    };
};

pub const Writer = opaque {
    pub fn newForPath(path: [:0]const u8) error{XmlError}!*Writer {
        return xmlNewTextWriterFilename(path, 0) orelse error.XmlError;
    }
    extern fn xmlNewTextWriterFilename(uri: [*:0]const u8, compression: c_int) ?*Writer;

    pub fn free(writer: *Writer) void {
        xmlFreeTextWriter(writer);
    }
    extern fn xmlFreeTextWriter(writer: *Writer) void;

    pub fn flush(writer: *Writer) error{XmlError}!void {
        _ = try handle(xmlTextWriterFlush(writer));
    }
    extern fn xmlTextWriterFlush(writer: *Writer) c_int;

    pub fn setIndent(writer: *Writer, indent: c_int) error{XmlError}!void {
        _ = try handle(xmlTextWriterSetIndent(writer, indent));
    }
    extern fn xmlTextWriterSetIndent(writer: *Writer, indent: c_int) c_int;

    pub fn startDocument(writer: *Writer, version: ?[:0]const u8, encoding: ?[:0]const u8, standalone: ?[:0]const u8) error{XmlError}!void {
        _ = try handle(xmlTextWriterStartDocument(writer, version orelse null, encoding orelse null, standalone orelse null));
    }
    extern fn xmlTextWriterStartDocument(writer: *Writer, version: ?[*:0]const u8, encoding: ?[*:0]const u8, standalone: ?[*:0]const u8) c_int;

    pub fn endDocument(writer: *Writer) error{XmlError}!void {
        _ = try handle(xmlTextWriterEndDocument(writer));
    }
    extern fn xmlTextWriterEndDocument(writer: *Writer) c_int;

    pub fn writeElement(writer: *Writer, name: [:0]const u8, content: [:0]const u8) error{XmlError}!void {
        _ = try handle(xmlTextWriterWriteElement(writer, name, content));
    }
    extern fn xmlTextWriterWriteElement(writer: *Writer, name: [*:0]const u8, content: [*:0]const u8) c_int;

    pub fn startElement(writer: *Writer, name: [:0]const u8) error{XmlError}!void {
        _ = try handle(xmlTextWriterStartElement(writer, name));
    }
    extern fn xmlTextWriterStartElement(writer: *Writer, name: [*:0]const u8) c_int;

    pub fn endElement(writer: *Writer) error{XmlError}!void {
        _ = try handle(xmlTextWriterEndElement(writer));
    }
    extern fn xmlTextWriterEndElement(writer: *Writer) c_int;

    pub fn endElementFull(writer: *Writer) error{XmlError}!void {
        _ = try handle(xmlTextWriterFullEndElement(writer));
    }
    extern fn xmlTextWriterFullEndElement(writer: *Writer) c_int;

    pub fn writeAttribute(writer: *Writer, name: [:0]const u8, content: [:0]const u8) error{XmlError}!void {
        _ = try handle(xmlTextWriterWriteAttribute(writer, name, content));
    }
    extern fn xmlTextWriterWriteAttribute(writer: *Writer, name: [*:0]const u8, content: [*:0]const u8) c_int;

    pub fn write(writer: *Writer, content: [:0]const u8) error{XmlError}!void {
        _ = try handle(xmlTextWriterWriteString(writer, content));
    }
    extern fn xmlTextWriterWriteString(writer: *Writer, content: [*:0]const u8) c_int;
};

fn handle(err: c_int) error{XmlError}!c_int {
    return if (err >= 0) err else error.XmlError;
}

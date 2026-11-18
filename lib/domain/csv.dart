/// Minimal CSV support for the task export and import (RFC 4180 shaped).
/// Pure functions, no Flutter, so the grammar is testable in isolation.
///
/// Cells are quoted only when they must be (comma, quote or newline inside),
/// quotes double themselves, and CRLF or LF line endings both read fine.
library;

/// Parses a whole CSV document into rows of cells. The BOM is stripped,
/// LF and CRLF endings both work, and a trailing newline does not create
/// a phantom row. Empty lines are kept as rows of one empty cell; the
/// importer decides what to skip.
List<List<String>> parseCsv(String text) {
  var input = text;
  if (input.startsWith('\uFEFF')) {
    input = input.substring(1);
  }
  final rows = <List<String>>[];
  var row = <String>[];
  var field = StringBuffer();
  var inQuotes = false;
  var i = 0;
  while (i < input.length) {
    final ch = input[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < input.length && input[i + 1] == '"') {
          field.write('"');
          i += 2;
          continue;
        }
        inQuotes = false;
        i += 1;
        continue;
      }
      field.write(ch);
      i += 1;
      continue;
    }
    if (ch == '"') {
      inQuotes = true;
      i += 1;
      continue;
    }
    if (ch == ',') {
      row.add(field.toString());
      field = StringBuffer();
      i += 1;
      continue;
    }
    if (ch == '\r') {
      i += 1;
      continue;
    }
    if (ch == '\n') {
      row.add(field.toString());
      rows.add(row);
      row = [];
      field = StringBuffer();
      i += 1;
      continue;
    }
    field.write(ch);
    i += 1;
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    rows.add(row);
  }
  return rows;
}

/// Escapes one cell, quoting only when the value requires it.
String escapeCsvCell(String value) {
  final needsQuotes = value.contains(',') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r');
  final escaped = value.replaceAll('"', '""');
  return needsQuotes ? '"$escaped"' : escaped;
}

/// One CSV line from cells, terminated with CRLF per RFC 4180.
String csvRow(List<String> cells) =>
    '${cells.map(escapeCsvCell).join(',')}\r\n';

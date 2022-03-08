import 'package:charcode/charcode.dart';
import 'package:markdown/markdown.dart';
import 'package:markdown_ansi_renderer/src/table/alignment.dart';
import 'package:markdown_ansi_renderer/src/table/border.dart';

/// A pattern which should never be used. It just satisfies non-nullability of
/// pattern fields.
final _dummyPattern = RegExp('');

/// A line of hyphens separated by at least one pipe.
final _tablePattern = RegExp(r'^[ ]{0,3}\|?( *:?\-+:? *\|)+( *:?\-+:? *)?$');

class TableElement extends Element {
  final AnsiTableBorder? border;

  TableElement(
    String tag,
    List<Node>? children, {
    this.border,
  }) : super(tag, children);
}

class CellElement extends Element {
  final AnsiTableBorder? border;

  bool _isFirst = false;
  bool _isLast = false;
  int _index = 0;
  AnsiTableAlignment? _alignment;

  bool get isFirst => _isFirst;
  bool get isLast => _isLast;
  int get index => _index;
  AnsiTableAlignment get alignment => _alignment ?? AnsiTableAlignment.left;

  CellElement(String tag, List<Node>? children, {this.border}) : super(tag, children);
}

class HeadElement extends Element {
  final AnsiTableBorder? border;

  HeadElement(
    String tag,
    List<Node>? children, {
    this.border,
  }) : super(tag, children);
}

class RowElement extends Element {
  final AnsiTableBorder? border;

  bool _isFirst = false;
  bool _isLast = false;

  bool get isFirst => _isFirst;
  bool get isLast => _isLast;

  RowElement(
    String tag,
    List<Node>? children, {
    this.border,
  }) : super(tag, children);
}

/// Parses tables.
class AnsiTableSyntax extends BlockSyntax {
  /// Table border style (ASCII, Pseudographics)
  final AnsiTableBorder? border;

  /// Table heading border style (ASCII, Pseudographics)
  final AnsiTableBorder? headingBorder;

  /// Column spacing
  final int colSpacing;

  @override
  bool canEndBlock(BlockParser parser) => false;

  @override
  RegExp get pattern => _dummyPattern;

  const AnsiTableSyntax({
    this.border,
    this.headingBorder,
    this.colSpacing = 0,
  });

  @override
  bool canParse(BlockParser parser) {
    // Note: matches *next* line, not the current one. We're looking for the
    // bar separating the head row from the body rows.
    return parser.matchesNext(_tablePattern);
  }

  /// Parses a table into its three parts:
  ///
  /// * a head row of head cells
  /// * a divider of hyphens and pipes (not rendered)
  /// * many body rows of body cells
  @override
  Node? parse(BlockParser parser) {
    var alignments = _parseAlignments(parser.next!);
    var columnCount = alignments.length;
    var headRow = _parseRow(parser, alignments, 'th');
    if (headRow.children!.length != columnCount) {
      return null;
    }
    (headRow as RowElement)._isFirst = true;
    var head = HeadElement('thead', [headRow], border: headingBorder);

    // Advance past the divider of hyphens.
    parser.advance();

    var rows = <Element>[];
    while (!parser.isDone && !BlockSyntax.isAtBlockEnd(parser)) {
      var row = _parseRow(parser, alignments, 'td');
      var children = row.children;
      if (children != null) {
        while (children.length < columnCount) {
          // Insert synthetic empty cells.
          children.add(Element.empty('td'));
        }
        while (children.length > columnCount) {
          children.removeLast();
        }
      }
      while (row.children!.length > columnCount) {
        row.children!.removeLast();
      }
      rows.add(row);
    }

    if (rows.isEmpty) {
      return TableElement(
        'table',
        [head],
        border: border,
      );
    } else {
      (rows.last as RowElement)._isLast = true;

      var body = Element('tbody', rows);
      return TableElement(
        'table',
        [head, body],
        border: border,
      );
    }
  }

  List<AnsiTableAlignment?> _parseAlignments(String line) {
    var startIndex = _walkPastOpeningPipe(line);

    var endIndex = line.length - 1;
    while (endIndex > 0) {
      var ch = line.codeUnitAt(endIndex);
      if (ch == $pipe) {
        endIndex--;
        break;
      }
      if (ch != $space && ch != $tab) {
        break;
      }
      endIndex--;
    }

    // Optimization: We walk [line] too many times. One lap should do it.
    return line.substring(startIndex, endIndex + 1).split('|').map((column) {
      column = column.trim();
      if (column.startsWith(':') && column.endsWith(':')) return AnsiTableAlignment.center;
      if (column.startsWith(':')) return AnsiTableAlignment.left;
      if (column.endsWith(':')) return AnsiTableAlignment.right;
      return null;
    }).toList();
  }

  /// Parses a table row at the current line into a table row element, with
  /// parsed table cells.
  ///
  /// [alignments] is used to annotate an alignment on each cell, and
  /// [cellType] is used to declare either "td" or "th" cells.
  Element _parseRow(BlockParser parser, List<AnsiTableAlignment?> alignments, String cellType,
      {AnsiTableBorder? rowBorder}) {
    var line = parser.current;
    var cells = <String>[];
    var index = _walkPastOpeningPipe(line);
    var cellBuffer = StringBuffer();

    while (true) {
      if (index >= line.length) {
        // This row ended without a trailing pipe, which is fine.
        cells.add(cellBuffer.toString().trimRight());
        cellBuffer.clear();
        break;
      }
      var ch = line.codeUnitAt(index);
      if (ch == $backslash) {
        if (index == line.length - 1) {
          // A table row ending in a backslash is not well-specified, but it
          // looks like GitHub just allows the character as part of the text of
          // the last cell.
          cellBuffer.writeCharCode(ch);
          cells.add(cellBuffer.toString().trimRight());
          cellBuffer.clear();
          break;
        }
        var escaped = line.codeUnitAt(index + 1);
        if (escaped == $pipe) {
          // GitHub Flavored Markdown has a strange bit here; the pipe is to be
          // escaped before any other inline processing. One consequence, for
          // example, is that "| `\|` |" should be parsed as a cell with a code
          // element with text "|", rather than "\|". Most parsers are not
          // compliant with this corner, but this is what is specified, and what
          // GitHub does in practice.
          cellBuffer.writeCharCode(escaped);
        } else {
          // The [InlineParser] will handle the escaping.
          cellBuffer.writeCharCode(ch);
          cellBuffer.writeCharCode(escaped);
        }
        index += 2;
      } else if (ch == $pipe) {
        cells.add(cellBuffer.toString().trimRight());
        cellBuffer.clear();
        // Walk forward past any whitespace which leads the next cell.
        index++;
        index = _walkPastWhitespace(line, index);
        if (index >= line.length) {
          // This row ended with a trailing pipe.
          break;
        }
      } else {
        cellBuffer.writeCharCode(ch);
        index++;
      }
    }
    parser.advance();

    var row = [
      for (var i = 0; i < cells.length; i++)
        CellElement(
          cellType,
          [UnparsedContent(_padCell(i, cells.length, cells[i]))],
          border: border,
        )
          .._isFirst = (i == 0)
          .._isLast = (i == cells.length - 1)
          .._index = i
          .._alignment = alignments[i],
    ];

    return RowElement(
      'tr',
      row,
      border: rowBorder ?? border,
    );
  }

  String _padCell(int index, int count, String content) {
    if (colSpacing == 0) return content;

    var result = content;
    var indent = ''.padLeft((colSpacing / 2).round());
    if (index > 0) {
      result = '$indent$result';
    }
    if (index < (count - 1)) {
      result = '$result$indent';
    }
    return result;
  }

  /// Walks past whitespace in [line] starting at [index].
  ///
  /// Returns the index of the first non-whitespace character.
  int _walkPastWhitespace(String line, int index) {
    while (index < line.length) {
      var ch = line.codeUnitAt(index);
      if (ch != $space && ch != $tab) {
        break;
      }
      index++;
    }
    return index;
  }

  /// Walks past the opening pipe (and any whitespace that surrounds it) in
  /// [line].
  ///
  /// Returns the index of the first non-whitespace character after the pipe.
  /// If no opening pipe is found, this just returns the index of the first
  /// non-whitespace character.
  int _walkPastOpeningPipe(String line) {
    var index = 0;
    while (index < line.length) {
      var ch = line.codeUnitAt(index);
      if (ch == $pipe) {
        index++;
        index = _walkPastWhitespace(line, index);
      }
      if (ch != $space && ch != $tab) {
        // No leading pipe.
        break;
      }
      index++;
    }
    return index;
  }
}

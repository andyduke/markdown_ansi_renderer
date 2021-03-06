import 'dart:math' as math;
import 'package:markdown/markdown.dart';
import 'package:markdown_ansi_renderer/markdown_ansi_renderer.dart';
import 'package:markdown_ansi_renderer/src/syntaxes/table_syntax.dart';
import 'package:markdown_ansi_renderer/src/table/alignment.dart';

/// Class for setting the table style.
class AnsiTableStyle extends AnsiBlockStyle {
  @override
  bool get isCompound => true;

  /// Table frame settings
  AnsiTableBorder? get border => _border;
  AnsiTableBorder? _border;

  @override
  String? renderBegin(Element element, bool ansiEnabled, {AnsiStyle? parentStyle}) {
    // Calc columns widths
    _border = (element is TableElement) ? element.border : null;
    _width = _calcWidth(element);
    return '';
  }

  @override
  String? renderEnd(Element element, bool ansiEnabled, {AnsiStyle? parentStyle}) {
    _border = null;
    _width = null;
    return '';
  }

  /// Table width in characters
  int get width => _width ?? 0;
  int? _width;

  /// Column width in characters
  int columnWidth(int index) => _columnWidth[index];
  final List<int> _columnWidth = [];

  /// Number of columns in the table
  int get columnCount => _columnCount;
  int _columnCount = 0;

  int _calcWidth(Element element) {
    int result = 0;
    for (var section in element.children!) {
      result = math.max(result, _calcSectionWidth((section as Element).children!));
    }
    return result;
  }

  int _calcSectionWidth(List<Node> nodes) {
    int result = 0;
    for (var row in nodes) {
      final nodes = (row as Element).children!;
      final borderWidth = (row is RowElement) ? (row.border?.vertical.length ?? 0) : 0;
      final borders = (borderWidth * 2) + ((nodes.length - 1) * borderWidth);
      result = math.max(result, _calcRowWidth(nodes) + borders);
    }
    return result;
  }

  int _calcRowWidth(List<Node> nodes) {
    int result = 0;

    _columnCount = math.max(_columnCount, nodes.length);

    if (_columnWidth.length < nodes.length) {
      for (var i = _columnWidth.length; i < nodes.length; i++) {
        _columnWidth.add(0);
      }
    }

    for (var i = 0; i < nodes.length; i++) {
      final int padding = (nodes[i] is CellElement) ? (nodes[i] as CellElement).cellPadding : 0;
      final int textSize = nodes[i].textContent.length + (padding * 2);
      _columnWidth[i] = math.max(_columnWidth[i], textSize);
      result += textSize;
    }
    return result;
  }
}

/// Class for setting the style of table column headings.
class AnsiTableHeadStyle extends AnsiStyle {
  /// Creates a table column header style object.
  AnsiTableHeadStyle() : super(style: '');

  @override
  String? renderEnd(Element element, bool ansiEnabled, {AnsiStyle? parentStyle}) {
    final AnsiTableStyle? tableStyle = parentStyle as AnsiTableStyle;
    final HeadElement head = element as HeadElement;

    if (tableStyle != null && head.border != null && (tableStyle.border == null || tableStyle.border!.isEmpty)) {
      if (head.border!.isEmpty) return '';

      final StringBuffer line = StringBuffer();
      line.write(head.border!.upAndRight);
      for (var i = 0; i < tableStyle.columnCount; i++) {
        line.write(head.border!.horizontal * tableStyle.columnWidth(i));
        if (i < (tableStyle.columnCount - 1)) {
          line.write(head.border!.upAndHorizontal);
        }
      }
      line.write(head.border!.upAndLeft);

      line.writeln();

      return line.toString();
    } else {
      return '';
    }
  }
}

/// Class for setting the table row style.
class AnsiTableRowStyle extends AnsiStyle {
  /// Creates a table row style object.
  AnsiTableRowStyle() : super(style: '');

  @override
  String? renderBegin(Element element, bool ansiEnabled, {AnsiStyle? parentStyle}) {
    final AnsiTableStyle? tableStyle = parentStyle as AnsiTableStyle;
    final RowElement row = element as RowElement;

    if (tableStyle != null && row.border != null) {
      if (row.border!.isEmpty) return '';

      // final width = tableStyle.width;
      final List<String> chars = (row.isFirst)
          ? [
              row.border!.downAndRight,
              row.border!.downAndHorizontal,
              row.border!.downAndLeft,
              row.border!.horizontal,
            ]
          : [
              row.border!.verticalAndRight,
              row.border!.verticalAndHorizontal,
              row.border!.verticalAndLeft,
              row.border!.horizontal,
            ];

      final StringBuffer line = StringBuffer();
      line.write(chars[0]);
      for (var i = 0; i < tableStyle.columnCount; i++) {
        line.write(chars[3] * tableStyle.columnWidth(i));
        if (i < (tableStyle.columnCount - 1)) {
          line.write(chars[1]);
        }
      }
      line.write(chars[2]);

      if (line.isNotEmpty) {
        line.writeln();
      }

      return line.toString();

      /*
      if (row.isFirst) {
        return ('-' * width) + '\n';
      } else if (row.isLast) {
        return '+${'-' * (width - 2)}+\n';
      } else {
        return '+${'-' * (width - 2)}+\n';
      }
      */
    } else {
      // return '\n';
      return '';
    }
  }

  @override
  String? renderEnd(Element element, bool ansiEnabled, {AnsiStyle? parentStyle}) {
    final AnsiTableStyle? tableStyle = parentStyle as AnsiTableStyle;
    final RowElement row = element as RowElement;

    if (tableStyle != null && row.border != null) {
      if (row.border!.isEmpty) return '\n';

      if (row.isFirst) {
        return '\n';
      } else if (row.isLast) {
        // final width = tableStyle.width;
        // return '\n' + ('-' * width);

        final StringBuffer line = StringBuffer();
        line.write(row.border!.upAndRight);
        for (var i = 0; i < tableStyle.columnCount; i++) {
          line.write(row.border!.horizontal * tableStyle.columnWidth(i));
          if (i < (tableStyle.columnCount - 1)) {
            line.write(row.border!.upAndHorizontal);
          }
        }
        line.write(row.border!.upAndLeft);

        return '\n' + line.toString();
      } else {
        return '\n';
      }
    } else {
      return '\n';
    }
  }
}

/// Class for setting the table cell style.
class AnsiTableCellStyle extends AnsiStyle {
  /// Creates a table cell style object.
  AnsiTableCellStyle() : super(style: '');

  @override
  String? renderBegin(Element element, bool ansiEnabled, {AnsiStyle? parentStyle}) {
    final AnsiTableStyle? tableStyle = parentStyle as AnsiTableStyle;
    final CellElement cell = element as CellElement;
    final emptyChar = cell.border?.empty ?? ' ';
    final vChar = cell.border?.vertical ?? '';

    if (tableStyle != null) {
      final width = tableStyle.columnWidth(cell.index);
      final String padding = ((cell.alignment == AnsiTableAlignment.right)
              ? (emptyChar * (width - (cell.cellPadding * 2) - cell.textContent.length))
              : '') +
          (emptyChar * cell.cellPadding);

      if (cell.isFirst) {
        return vChar + padding;
      } else {
        return padding;
      }
    } else {
      return '';
    }
  }

  @override
  String? renderEnd(Element element, bool ansiEnabled, {AnsiStyle? parentStyle}) {
    final AnsiTableStyle? tableStyle = parentStyle as AnsiTableStyle;
    final CellElement cell = element as CellElement;
    final emptyChar = cell.border?.empty ?? ' ';
    final vChar = cell.border?.vertical ?? '';

    if (tableStyle != null) {
      final width = tableStyle.columnWidth(cell.index);
      final String padding = ((cell.alignment == AnsiTableAlignment.left)
              ? (emptyChar * (width - (cell.cellPadding * 2) - cell.textContent.length))
              : '') +
          (emptyChar * cell.cellPadding);

      return padding + vChar;
    } else {
      return '';
    }
  }
}

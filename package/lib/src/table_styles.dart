import 'dart:math' as math;
import 'package:barbecue/barbecue.dart';
import 'package:markdown/markdown.dart';
import 'package:markdown_ansi_renderer/markdown_ansi_renderer.dart';
import 'package:markdown_ansi_renderer/src/syntaxes/table_syntax.dart';

class AnsiTableStyle extends AnsiBlockStyle {
  // static const int defaultCellPadding = 0;

  // final int cellPadding;

  // AnsiTableStyle({
  //   this.cellPadding = defaultCellPadding,
  // }) : super();

  @override
  bool get isCompound => true;

  // AnsiTableBorder? _border;
  // AnsiTableBorder get border => _border ?? AnsiTableBorder.DEFAULT;

  @override
  String? renderBegin(Element element, bool ansiEnabled, {AnsiStyle? parentStyle}) {
    // Calc columns widths
    // _border = (element is TableElement) ? element.border : null;
    _width = _calcWidth(element);
    return '';
  }

  @override
  String? renderEnd(Element element, bool ansiEnabled, {AnsiStyle? parentStyle}) {
    // _border = null;
    _width = null;
    return '';
  }

  int? _width;
  int get width => _width ?? 0;

  final List<int> _columnWidth = [];
  int columnWidth(int index) => _columnWidth[index];

  int _columnCount = 0;
  int get columnCount => _columnCount;

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
      result = math.max(result, _calcRowWidth(nodes) + 2 + (nodes.length - 1));
    }
    return result;
  }

  int _calcRowWidth(List<Node> nodes) {
    int result = 0;

    _columnCount = math.max(_columnCount, nodes.length);

    if (_columnWidth.length < nodes.length) {
      for (var i = _columnWidth.length; i <= nodes.length; i++) {
        _columnWidth.add(0);
      }
    }

    for (var i = 0; i < nodes.length; i++) {
      _columnWidth[i] = math.max(_columnWidth[i], nodes[i].textContent.length);
      result += nodes[i].textContent.length;
    }
    return result;
  }
}

class AnsiTableRowStyle extends AnsiStyle {
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
      return '\n';
    }
  }

  @override
  String? renderEnd(Element element, bool ansiEnabled, {AnsiStyle? parentStyle}) {
    final AnsiTableStyle? tableStyle = parentStyle as AnsiTableStyle;
    final RowElement row = element as RowElement;

    if (row.border != null && tableStyle != null) {
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

class AnsiTableCellStyle extends AnsiStyle {
  AnsiTableCellStyle() : super(style: '');

  @override
  String? renderBegin(Element element, bool ansiEnabled, {AnsiStyle? parentStyle}) {
    final AnsiTableStyle? tableStyle = parentStyle as AnsiTableStyle;
    final CellElement cell = element as CellElement;

    if (cell.border != null && tableStyle != null) {
      final width = tableStyle.columnWidth(cell.index);
      final String padding =
          (cell.alignment == TextAlignment.TopRight) ? (cell.border!.empty * (width - cell.textContent.length)) : '';

      if (cell.isFirst) {
        return cell.border!.vertical + padding;
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

    if (cell.border != null && tableStyle != null) {
      final width = tableStyle.columnWidth(cell.index);
      final String padding =
          (cell.alignment == TextAlignment.TopLeft) ? (cell.border!.empty * (width - cell.textContent.length)) : '';

      return padding + cell.border!.vertical;
    } else {
      return '';
    }
  }
}

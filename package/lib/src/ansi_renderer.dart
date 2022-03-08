import 'dart:convert';
import 'dart:io' as io;
import 'package:io/ansi.dart';
import 'package:markdown/markdown.dart';
import 'package:markdown_ansi_renderer/markdown_ansi_renderer.dart';
import 'package:markdown_ansi_renderer/src/styles.dart';
import 'package:markdown_ansi_renderer/src/table_styles.dart';

/// Translates a parsed AST to ANSI codes.
class AnsiRenderer implements NodeVisitor {
  /// Default styles for converting markdown to ANSI codes.
  static Map<String, AnsiStyle> defaultTagStyles = {
    'h1': AnsiHeadingStyle(style: lightCyan.escape, transform: (t, _, __) => t.toUpperCase()),
    'h2': AnsiHeadingStyle(style: lightGray.escape, transform: (t, _, __) => t.toUpperCase()),
    'h3': AnsiHeadingStyle(transform: (t, _, __) => t.toUpperCase()),
    'h4': AnsiHeadingStyle(transform: (t, _, __) => t.toUpperCase()),
    'h5': AnsiHeadingStyle(transform: (t, _, __) => t.toUpperCase()),
    'h6': AnsiHeadingStyle(transform: (t, _, __) => t.toUpperCase()),
    'p': AnsiBlockStyle(),
    'strong': AnsiStyle(style: styleBold.escape + white.escape),
    'em': AnsiStyle(style: styleItalic.escape + lightYellow.escape),
    'u': AnsiStyle(style: styleUnderlined.escape),
    'del': AnsiStyle(style: styleCrossedOut.escape),
    'a': AnsiLinkStyle(style: white.escape),
    'hr': AnsiHRStyle(),
    'code': AnsiCodeStyle(),
    'pre': AnsiPreStyle(),
    'ul': AnsiStyle(style: '', reset: ''),
    'li': AnsiListItemStyle(),
    'table': AnsiTableStyle(),
    'tr': AnsiTableRowStyle(),
    'th': AnsiTableCellStyle(),
    'td': AnsiTableCellStyle(),
  };

  late StringBuffer _buffer;

  final _elementStack = <Element>[];
  String? _lastVisitedTag;
  final List<String> _styleStack = [];
  final List<AnsiStyle> _tagStyleStack = [];
  final List<AnsiStyle> _tagCompoundStyleStack = [];

  /// Whether to use ANSI codes for converting markdown. If disabled, markdown will be converted into a plain test.
  final bool ansiEnabled;

  /// Styles for converting markdown to ANSI codes.
  final Map<String, AnsiStyle> tagStyles;

  /// Creates a render object for markdown to ANSI codes.
  AnsiRenderer({
    bool? ansiEnabled,
    Map<String, AnsiStyle>? tagStyles,
  })  : tagStyles = tagStyles ?? defaultTagStyles,
        ansiEnabled = ansiEnabled ?? io.stdout.supportsAnsiEscapes;

  /// Render the list of nodes to text with ANSI codes.
  String render(List<Node> nodes) {
    _buffer = StringBuffer();

    for (final node in nodes) {
      node.accept(this);
    }

    String result = _buffer.toString();

    // Remove html comments
    // result = result.replaceAll(RegExp(r'\<!-- (.*?) --\>\n{0,1}'), '');
    result = result.replaceAll(RegExp(r'\<!-- (.*?) --\>'), '');

    return result;
  }

  @override
  void visitText(Text text) {
    final isMultiline = const ['br', 'p', 'li'].contains(_lastVisitedTag);
    var content = text.text;
    if (isMultiline) {
      var lines = LineSplitter.split(content);
      content = content.contains('<pre>') ? lines.join('\n') : lines.map((line) => line.trimLeft()).join('\n');
      if (text.text.endsWith('\n')) {
        content = '$content\n';
      }
    }

    for (var tagStyle in _tagStyleStack) {
      content = tagStyle.transformText(content, ansiEnabled, isMultiline);
    }

    _buffer.write(content);

    _lastVisitedTag = null;
  }

  @override
  bool visitElementBefore(Element element) {
    // Hackish. Separate block-level elements with newlines.
    if (_buffer.isNotEmpty && _blockTags.contains(element.tag)) {
      _buffer.writeln();
    }

    // print('tag: ${element.tag}');

    if (tagStyles.containsKey(element.tag)) {
      final AnsiStyle? parentStyle = _tagCompoundStyleStack.isNotEmpty ? _tagCompoundStyleStack.last : null;
      if (tagStyles[element.tag]!.isCompound) {
        _tagCompoundStyleStack.add(tagStyles[element.tag]!);
      }

      _tagStyleStack.add(tagStyles[element.tag]!);

      if (ansiEnabled) {
        final style = tagStyles[element.tag]!.renderStyle(element);
        if (style != null) {
          _buffer.write(style);
          _styleStack.add(style);
        }
      }

      final begin = tagStyles[element.tag]!.renderBegin(element, ansiEnabled, parentStyle: parentStyle);
      if (begin != null) {
        _buffer.write(begin);
      }
    }

    _lastVisitedTag = element.tag;

    // if (element is TableElement) {
    //   _buffer.write(element.render());
    // }

    if (element.isEmpty) {
      // Empty element like <hr/>.
      _buffer.writeln();

      if (element.tag == 'br') {
        _buffer.writeln();
      }

      return false;
    } else {
      _elementStack.add(element);
      return true;

      // return (element is! CellElement);
    }
  }

  @override
  void visitElementAfter(Element element) {
    if (element.children != null &&
        element.children!.isNotEmpty &&
        _blockTags.contains(_lastVisitedTag) &&
        _blockTags.contains(element.tag)) {
      _buffer.writeln();
    } else if (element.tag == 'blockquote') {
      _buffer.writeln();
    }

    _lastVisitedTag = _elementStack.removeLast().tag;

    if (tagStyles.containsKey(element.tag)) {
      final AnsiStyle? parentStyle = _tagCompoundStyleStack.isNotEmpty ? _tagCompoundStyleStack.last : null;
      if (tagStyles[element.tag]!.isCompound) {
        _tagCompoundStyleStack.removeLast();
      }

      if (_tagStyleStack.isNotEmpty) _tagStyleStack.removeLast();

      final end = tagStyles[element.tag]!.renderEnd(element, ansiEnabled, parentStyle: parentStyle);
      if (end != null) {
        _buffer.write(end);
      }

      if (ansiEnabled) {
        final style = tagStyles[element.tag]!.renderReset(element);
        if (style != null) {
          _buffer.write(style);

          // Revert to previous styles
          if (_styleStack.isNotEmpty) _styleStack.removeLast();
          _buffer.write(_styleStack.join(''));
        }
      }

      if (tagStyles[element.tag]!.isBlock) {
        _buffer.writeln();
      }
    }

    // if (element is TableElement) {
    //   _buffer.write(element.render());
    // }
  }
}

const _blockTags = [
  'blockquote',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'hr',
  'li',
  // 'ul',
  // 'ol',
  'p',
  'pre',
  'address',
  'article',
  'aside',
  'details',
  'dd',
  'div',
  'dl',
  'dt',
  'figcaption',
  'figure',
  'footer',
  'header',
  'hgroup',
  'main',
  'nav',
  'section',
  'table'
];

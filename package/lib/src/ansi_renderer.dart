import 'dart:convert';
import 'dart:io' as io;
import 'package:io/ansi.dart';
import 'package:markdown/markdown.dart';
import 'package:markdown_ansi_renderer/src/styles.dart';

/// Translates a parsed AST to ANSI codes.
class AnsiRenderer implements NodeVisitor {
  /// Default styles for converting markdown to ANSI codes.
  static Map<String, AnsiStyle> defaultTagStyles = {
    'h1': AnsiBlockStyle(style: lightCyan.escape, transform: (t, _) => t.toUpperCase()),
    'h2': AnsiBlockStyle(style: lightGray.escape, transform: (t, _) => t.toUpperCase()),
    'h3': AnsiBlockStyle(transform: (t, _) => t.toUpperCase()),
    'h4': AnsiBlockStyle(transform: (t, _) => t.toUpperCase()),
    'h5': AnsiBlockStyle(transform: (t, _) => t.toUpperCase()),
    'h6': AnsiBlockStyle(transform: (t, _) => t.toUpperCase()),
    'p': AnsiBlockStyle(),
    'strong': AnsiStyle(style: styleBold.escape + white.escape),
    'em': AnsiStyle(style: styleItalic.escape + lightYellow.escape),
    'u': AnsiStyle(style: styleUnderlined.escape),
    'del': AnsiStyle(style: styleCrossedOut.escape),
    'a': AnsiLinkStyle(style: white.escape),
    'hr': AnsiHRStyle(),
    'code': AnsiCodeStyle(),
    'pre': AnsiPreStyle(),
  };

  late StringBuffer _buffer;

  final _elementStack = <Element>[];
  String? _lastVisitedTag;
  final List<String> _styleStack = [];
  final List<AnsiStyle> _tagStyleStack = [];

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
    var content = text.text;
    if (const ['br', 'p', 'li'].contains(_lastVisitedTag)) {
      var lines = LineSplitter.split(content);
      content = content.contains('<pre>') ? lines.join('\n') : lines.map((line) => line.trimLeft()).join('\n');
      if (text.text.endsWith('\n')) {
        content = '$content\n';
      }
    }

    for (var tagStyle in _tagStyleStack) {
      content = tagStyle.transformText(content, ansiEnabled);
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
      _tagStyleStack.add(tagStyles[element.tag]!);

      if (ansiEnabled) {
        final style = tagStyles[element.tag]!.renderStyle(element);
        if (style != null) {
          _buffer.write(style);
          _styleStack.add(style);
        }
      }

      final begin = tagStyles[element.tag]!.renderBegin(element);
      if (begin != null) {
        _buffer.write(begin);
      }
    }

    _lastVisitedTag = element.tag;

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
      if (_tagStyleStack.isNotEmpty) _tagStyleStack.removeLast();

      final end = tagStyles[element.tag]!.renderEnd(element);
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
  'ol',
  'p',
  'pre',
  'ul',
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

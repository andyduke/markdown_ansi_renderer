import 'dart:convert';
import 'dart:math' as Math;
import 'package:io/ansi.dart';
import 'package:markdown/markdown.dart';

/// Signature for transforming text inside a markdown format element.
typedef AnsiStyleTransform = String Function(String text, bool ansiEnabled);

/// A class for setting the style for a markdown format element.
class AnsiStyle {
  /// ANSI codes by default, to reset formatting.
  static String defaultReset = defaultForeground.escape + backgroundDefault.escape + resetAll.escape;

  /// The style for the markdown format element.
  final String? style;

  /// The ANSI code to reset the style for the given element.
  final String? reset;

  /// Is it a block element?
  final bool isBlock;

  /// Transform text within an element, such as converting all text to uppercase within a first-level heading.
  final AnsiStyleTransform? transform;

  /// Creates a style object for formatting a markdown element in ANSI codes.
  AnsiStyle({
    required this.style,
    this.reset,
    this.isBlock = false,
    this.transform,
  });

  /// Outputs the ANSI codes for the given markdown element style.
  String? renderStyle(Element element) {
    return style;
  }

  /// Outputs the ANSI codes for resetting the specified markdown element style.
  String? renderReset(Element element) {
    return reset ?? defaultReset;
  }

  /// Displays text at the beginning of a markdown element (can be used to display links, footnotes, etc.).
  String? renderBegin(Element element) {
    return null;
  }

  /// Displays text at the end of a markdown element (can be used to display links, footnotes, etc.).
  String? renderEnd(Element element) {
    return null;
  }

  /// Transforms text inside a markdown element.
  String transformText(String text, bool ansiEnabled) =>
      (transform != null) ? transform!.call(text, ansiEnabled) : text;
}

/// A class for setting the style for a block-level markdown formatting element, such as headings.
class AnsiBlockStyle extends AnsiStyle {
  /// Creates a style object for formatting a block-level markdown element in ANSI codes.
  AnsiBlockStyle({
    String? style,
    String? reset,
    AnsiStyleTransform? transform,
  }) : super(
          style: style,
          reset: reset,
          transform: transform,
          isBlock: true,
        );
}

/// Class for setting the style for links.
class AnsiLinkStyle extends AnsiStyle {
  /// Creates a style object for a link.
  AnsiLinkStyle({
    String? style,
    String? reset,
    AnsiStyleTransform? transform,
  }) : super(
          style: style,
          reset: reset,
          transform: transform,
        );

  @override
  String? renderEnd(Element element) {
    final prefix = element.textContent.trim().isNotEmpty ? ' ' : '';
    return '$prefix(${element.attributes['href']})';
  }
}

/// Class for setting the output style of the horizontal separator. The default is "------".
class AnsiHRStyle extends AnsiStyle {
  /// The default character that the delimiter consists of.
  static const String defaultCharacter = '-';

  /// The default separator size.
  static const int defaultSize = 6;

  /// The character that the delimiter will consist of (default is "-").
  final String character;

  /// Separator size in characters (default 6).
  final int size;

  /// Creates a style object for the horizontal separator.
  AnsiHRStyle({
    this.character = defaultCharacter,
    this.size = defaultSize,
  }) : super(style: '');

  @override
  String? renderBegin(Element element) {
    return ''.padLeft(defaultSize, character);
  }
}

/// Class for setting the output style of the code block.
class AnsiCodeStyle extends AnsiStyle {
  /// Creates a style object for the code block.
  AnsiCodeStyle() : super(style: white.escape + backgroundDarkGray.escape);
}

/// Class for setting the output style of the preformatted block.
class AnsiPreStyle extends AnsiBlockStyle {
  /// Creates a style object for the preformatted block.
  AnsiPreStyle() : super(style: '');

  @override
  String transformText(String text, bool ansiEnabled) {
    if (ansiEnabled) {
      final splitter = LineSplitter();
      List<String> lines = splitter.convert(text);

      // Find maximum lines width
      final maxWidth = lines.fold<int>(0, (max, line) => Math.max(max, line.length));

      // Fill lines to maximum width
      lines = lines.map((line) => line.padRight(maxWidth)).toList(growable: false);

      final padding = ' ';
      final result = padding + lines.join(padding + '\n' + padding) + padding;
      return result;
    } else {
      return text.trimRight();
    }
  }
}

class AnsiListItemStyle extends AnsiStyle {
  AnsiListItemStyle() : super(style: '');

  // @override
  // String? renderBegin(Element element) {
  //   return ' - ';
  // }

  @override
  String transformText(String text, bool ansiEnabled) {
    return '   $text';
  }
}

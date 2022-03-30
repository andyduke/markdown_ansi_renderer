import 'package:markdown/markdown.dart';
import 'package:markdown_ansi_renderer/src/ansi_renderer.dart';
import 'package:markdown_ansi_renderer/src/styles.dart';

/// Converts the given string of Markdown to ANSI codes.
///
/// In `tagStyles`, you can customize the rendering, for example, set the color of the top-level heading to light blue:
/// ```
/// markdownToAnsi('''
/// # Heading 1
/// Some text
/// ''',
///   tagStyles: [
///     AnsiRenderer.defaultTagStyles
///       ..['h1'] = AnsiHeadingStyle(style: lightBlue.escape)
///   ],
/// )
/// ```
///
/// With the `ansiEnabled` parameter, you can control the output,
/// whether to use ANSI codes or output everything as plain text.
///
/// See also:
/// - [markdownToHtml function](https://pub.dev/documentation/markdown/latest/markdown/markdownToHtml.html)
/// - [markdown package](https://pub.dev/documentation/markdown/latest/index.html)
///
String markdownToAnsi(
  String markdown, {
  Iterable<BlockSyntax> blockSyntaxes = const [],
  Iterable<InlineSyntax> inlineSyntaxes = const [],
  ExtensionSet? extensionSet,
  Resolver? linkResolver,
  Resolver? imageLinkResolver,
  bool inlineOnly = false,
  bool encodeHtml = false,
  Map<String, AnsiStyle>? tagStyles,
  bool? ansiEnabled,
}) {
  var document = Document(
    blockSyntaxes: blockSyntaxes,
    inlineSyntaxes: inlineSyntaxes,
    extensionSet: extensionSet,
    linkResolver: linkResolver,
    imageLinkResolver: imageLinkResolver,
    encodeHtml: encodeHtml,
  );

  if (inlineOnly) {
    return renderToAnsi(
      nodes: document.parseInline(markdown),
      tagStyles: tagStyles,
      ansiEnabled: ansiEnabled,
    );
  }

  // Replace windows line endings with unix line endings, and split.
  var lines = markdown.replaceAll('\r\n', '\n').split('\n');

  return renderToAnsi(
        nodes: document.parseLines(lines),
        tagStyles: tagStyles,
        ansiEnabled: ansiEnabled,
      ) +
      '\n';
}

/// Renders [nodes] to ANSI codes.
///
/// See also:
/// - [markdownToAnsi]
String renderToAnsi({
  required List<Node> nodes,
  Map<String, AnsiStyle>? tagStyles,
  bool? ansiEnabled,
}) =>
    AnsiRenderer(tagStyles: tagStyles, ansiEnabled: ansiEnabled).render(nodes);

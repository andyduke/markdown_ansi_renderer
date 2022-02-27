import 'package:markdown/markdown.dart';
import 'package:markdown_ansi_renderer/src/ansi_renderer.dart';
import 'package:markdown_ansi_renderer/src/styles.dart';

/// Converts the given string of Markdown to ANSI codes.
String markdownToAnsi(
  String markdown, {
  Iterable<BlockSyntax> blockSyntaxes = const [],
  Iterable<InlineSyntax> inlineSyntaxes = const [],
  ExtensionSet? extensionSet,
  Resolver? linkResolver,
  Resolver? imageLinkResolver,
  bool inlineOnly = false,
  Map<String, AnsiStyle>? tagStyles,
  bool? ansiEnabled,
}) {
  var document = Document(
    blockSyntaxes: blockSyntaxes,
    inlineSyntaxes: inlineSyntaxes,
    extensionSet: extensionSet,
    linkResolver: linkResolver,
    imageLinkResolver: imageLinkResolver,
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
String renderToAnsi({
  required List<Node> nodes,
  Map<String, AnsiStyle>? tagStyles,
  bool? ansiEnabled,
}) =>
    AnsiRenderer(tagStyles: tagStyles, ansiEnabled: ansiEnabled).render(nodes);

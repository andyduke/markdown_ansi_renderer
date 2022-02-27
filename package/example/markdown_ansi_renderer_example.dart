import 'package:io/ansi.dart';
import 'package:markdown/markdown.dart';
import 'package:markdown_ansi_renderer/markdown_ansi_renderer.dart';

void main() {
  final String mdText = '''
# Markdown *example* document

Lorem ipsum dolor sit **amet**, consectetuer adipiscing elit.

Example: **nested *style* text**.

Sed dapibus, [ante](https://google.com) ultricies adipiscing pulvinar, enim tellus volutpat odio, vel pretium ligula purus vel ligula.
In posuere justo eget libero. Cras consequat quam sit amet metus. Sed vitae nulla. Cras imperdiet sapien vitae ipsum. Curabitur tristique. Aliquam non tellus eget sem commodo tincidunt. Phasellus cursus nunc. Integer vel mi. Aenean rutrum libero sit amet enim. Nunc elementum, erat eu volutpat ultricies, eros justo scelerisque leo, quis sollicitudin purus ipsum at purus. Aenean ut nulla.

## Heading 2

Donec sit amet nisl in elit consequat vehicula. Ut leo ligula, lacinia vitae, tempor vel, eleifend vitae, odio.

---

Formatting **bold**, *italic*, <u>underline</u>, ~~strikethrough~~.

<!-- Formatting **bold**, *italic*, ___underline___, ~~strikethrough~~. -->

Text with <custom>custom</custom> tag.

Text with <undefined>undefined</undefined> tag.

''';

  final text = markdownToAnsi(
    mdText,
    inlineSyntaxes: [StrikethroughSyntax(), UnderlineSyntax(), AnyTagSyntax()],
    tagStyles: AnsiRenderer.defaultTagStyles
      ..['hr'] = AnsiHRStyle(character: '=')
      ..['custom'] = AnsiStyle(style: lightMagenta.escape),
  );
  print(text);
}

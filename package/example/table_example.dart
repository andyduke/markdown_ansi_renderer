import 'package:markdown/markdown.dart';
import 'package:markdown_ansi_renderer/markdown_ansi_renderer.dart';

void main() {
  final String mdText = '''
| Name            |  Price |
|-----------------|-------:|
| Morgran **Aero** 8  | 166944 |
| Morgran Plus 4  |  69980 |
''';

  final text = markdownToAnsi(
    mdText,
    inlineSyntaxes: [StrikethroughSyntax(), UnderlineSyntax(), AnyTagSyntax()],
    blockSyntaxes: [
      AnsiTableSyntax(
        border: AnsiTableBorder.empty(),
        colSpacing: 4,
      ),
    ],
  );
  print(text);
}

import 'package:markdown/markdown.dart';
import 'package:markdown_ansi_renderer/markdown_ansi_renderer.dart';
import 'package:test/test.dart';

void main() {
  test('Table renderer', () {
    final String mdText = '''
| Name            |  Price |
|-----------------|-------:|
| Morgran Aero 8  | 166944 |
| Morgran Plus 4  |  69980 |
| Morgran 4x4     |  35550 |
''';

    final text = markdownToAnsi(
      mdText,
      inlineSyntaxes: [StrikethroughSyntax(), UnderlineSyntax(), AnyTagSyntax()],
      blockSyntaxes: [
        AnsiTableSyntax(
          colSpacing: 4,
          // style: TableStyle(border: true),
          // border: TextBorder.ROUNDED,
          // cellStyle: CellStyle(
          //   borderRight: true,
          // ),
        ),
      ],
    );
    print(text);

    // expect(text, isTrue);
  });
}

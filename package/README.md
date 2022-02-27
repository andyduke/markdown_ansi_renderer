# MarkdownAnsiRenderer

ANSI markdown renderer.
Provides the ability to output markdown documents to the console using ANSI codes for document highlighting and formatting.
Colors and styles can be customized for each markup element.

## Usage

```dart
import 'package:markdown_ansi_renderer/markdown_ansi_renderer.dart';

void main() {
  print(markdownToAnsi('Hello **Markdown**'));
}
```
The text "Hello Markdown" will be printed to the console, with the word "Markdown" highlighted in bold and white.

## AnsiStyles

By default, some markdown elements have the following styles:

| | |
|---------------------------|---|
| First level heading       | Light Cyan and uppercase conversion |
| Second level heading      | Light Gray and uppercase conversion |
| Third level heading       | Uppercase conversion |
| Fourth level heading      | Uppercase conversion |
| Fifth level heading       | Uppercase conversion |
| Bold (strong)             | Bold and White |
| Italic (em)               | Italic and Light Yellow |
| Underline                 | Underline |
| Strikethrough             | Strikethrough |
| Horizontal rule           | ------ |
| Link                      | White |

You can customize these styles or set additional ones using the `tagStyles` parameter.

Default style customizing:

```dart
print(markdownToAnsi(
  'Markdown **bold** <custom>style</custom>',
  tagStyles: AnsiRenderer.defaultTagStyles
    ..['strong'] = AnsiStyle(style: styleBold.escape + ligthBlue.escape),
));
```

Setting a style for a custom element:

```dart
print(markdownToAnsi(
  'Markdown <custom>style</custom>',
  inlineSyntaxes: [AnyTagSyntax()],
  tagStyles: AnsiRenderer.defaultTagStyles
    ..['custom'] = AnsiStyle(style: lightGreen.escape),
));
```

> Note that to support custom tags, you must specify an additional inline syntax class: `AnyTagSyntax`.

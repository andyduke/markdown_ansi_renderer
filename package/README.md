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

## Additional information


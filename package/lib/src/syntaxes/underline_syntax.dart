import 'package:markdown/markdown.dart';

/// Matches underline tag syntax.
class UnderlineSyntax extends TagSyntax {
  UnderlineSyntax() : super(r'\<u\>(.*?)\<\/u\>', allowIntraWord: true);

  @override
  bool onMatch(InlineParser parser, Match match) {
    if (match.groupCount == 1) {
      var text = Element('u', [Text(match.group(1)!)]);
      parser.addNode(text);
    }
    return true;
  }
}

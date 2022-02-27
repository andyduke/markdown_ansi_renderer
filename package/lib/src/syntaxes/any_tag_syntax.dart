import 'package:markdown/markdown.dart';

/// Matches any tag syntax.
class AnyTagSyntax extends TagSyntax {
  AnyTagSyntax() : super(r'\<([a-z\-\_]+)\>(.*?)\<\/\1\>', allowIntraWord: true);

  @override
  bool onMatch(InlineParser parser, Match match) {
    if (match.groupCount > 1) {
      var text = Element(match.group(1)!, [Text(match.group(2)!)]);
      parser.addNode(text);
    }
    return true;
  }
}

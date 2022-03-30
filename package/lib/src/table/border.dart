import 'package:characters/characters.dart';

/// Class for customizing table borders.
class AnsiTableBorder {
  /// Character set for drawing a table.
  ///
  /// 16 characters that define the parts of the frame of the table in the following order:
  /// 1. empty - fills empty space inside the cell when aligned
  /// 2. down - not currently in use
  /// 3. up - not currently in use
  /// 4. vertical - vertical line that draws the vertical separation between cells
  /// 5. right - not currently in use
  /// 6. downAndRight - upper left corner symbol
  /// 7. upAndRight - lower left corner symbol
  /// 8. verticalAndRight - left T-connection symbol
  /// 9. left - not currently in use
  /// 10. downAndLeft - upper right corner symbol
  /// 11. upAndLeft - lower right corner symbol
  /// 12. verticalAndLeft - right T-connection symbol
  /// 13. horizontal - a horizontal line that draws a horizontal separator between cells
  /// 14. downAndHorizontal - upper T-connection symbol
  /// 15. upAndHorizontal - lower T-connection symbol
  /// 16. verticalAndHorizontal - cross-shaped connection symbol between cells
  final Characters characters;

  factory AnsiTableBorder(String string) {
    return AnsiTableBorder.fromCharacters(Characters(string));
  }

  AnsiTableBorder.custom({
    this.empty = ' ',
    this.down = '',
    this.up = '',
    this.vertical = '',
    this.right = '',
    this.downAndRight = '',
    this.upAndRight = '',
    this.verticalAndRight = '',
    this.left = '',
    this.downAndLeft = '',
    this.upAndLeft = '',
    this.verticalAndLeft = '',
    this.horizontal = '',
    this.downAndHorizontal = '',
    this.upAndHorizontal = '',
    this.verticalAndHorizontal = '',
  }) : characters = Characters(
          empty +
              down +
              up +
              vertical +
              right +
              downAndRight +
              upAndRight +
              verticalAndRight +
              left +
              downAndLeft +
              upAndLeft +
              verticalAndLeft +
              horizontal +
              downAndHorizontal +
              upAndHorizontal +
              verticalAndHorizontal,
        );

  AnsiTableBorder.empty()
      : characters = Characters(''),
        empty = ' ',
        down = '',
        up = '',
        vertical = '',
        right = '',
        downAndRight = '',
        upAndRight = '',
        verticalAndRight = '',
        left = '',
        downAndLeft = '',
        upAndLeft = '',
        verticalAndLeft = '',
        horizontal = '',
        downAndHorizontal = '',
        upAndHorizontal = '',
        verticalAndHorizontal = '';

  AnsiTableBorder.fromCharacters(this.characters)
      : assert(
            characters.length == 16, 'Border string must contain exactly 16 characters, but got ${characters.length}'),
        empty = characters.elementAt(0),
        down = characters.elementAt(1),
        up = characters.elementAt(2),
        vertical = characters.elementAt(3),
        right = characters.elementAt(4),
        downAndRight = characters.elementAt(5),
        upAndRight = characters.elementAt(6),
        verticalAndRight = characters.elementAt(7),
        left = characters.elementAt(8),
        downAndLeft = characters.elementAt(9),
        upAndLeft = characters.elementAt(10),
        verticalAndLeft = characters.elementAt(11),
        horizontal = characters.elementAt(12),
        downAndHorizontal = characters.elementAt(13),
        upAndHorizontal = characters.elementAt(14),
        verticalAndHorizontal = characters.elementAt(15);

  final String empty;
  final String down;
  final String up;

  final String vertical;
  final String right;

  final String downAndRight;
  final String upAndRight;

  final String verticalAndRight;
  final String left;

  final String downAndLeft;
  final String upAndLeft;

  final String verticalAndLeft;

  final String horizontal;

  final String downAndHorizontal;
  final String upAndHorizontal;

  final String verticalAndHorizontal;

  bool get isEmpty => characters.isEmpty;

  String get({
    bool down = false,
    bool up = false,
    bool right = false,
    bool left = false,
  }) {
    return characters.elementAt(
      (down ? 1 : 0) | (up ? 2 : 0) | (right ? 4 : 0) | (left ? 8 : 0),
    );
  }

  static final DEFAULT = AnsiTableBorder(' ╷╵│╶┌└├╴┐┘┤─┬┴┼');

  static final ROUNDED = AnsiTableBorder(' ╷╵│╶╭╰├╴╮╯┤─┬┴┼');

  static final ASCII = AnsiTableBorder('   | +++ +++-+++');

  static final HEAVY = AnsiTableBorder(' ╹╹┃╺┏┗┣╸┓┛┫━┳┻╋');

  // static final HORIZ = AnsiTableBorder('    ╶╶╶╶╴╴╴╴────');
  static final HORIZ = AnsiTableBorder('    ────────────');
}

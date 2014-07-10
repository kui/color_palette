library color_pallette.color_pallete_cell;

import 'package:polymer/polymer.dart';

@CustomTag('color-palette-cell')
class ColorPaletteCellElement extends PolymerElement {
  @published
  String color;

  @published
  bool selected = false;

  ColorPaletteCellElement.created() : super.created() {
    onClick.listen((event) {
      selected = true;
    });
  }
}

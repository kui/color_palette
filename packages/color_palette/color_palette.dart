library color_pallette.color_pallete;

import 'package:polymer/polymer.dart';
import 'color_palette_cell.dart';
import 'dart:html';
import 'dart:async';

@CustomTag('color-palette')
class ColorPaletteElement extends PolymerElement {

  final StreamController<ColorChangeEvent> _colorChangeController =
      new StreamController.broadcast();
  Stream<ColorChangeEvent> get onColorChange => _colorChangeController.stream;

  List<ColorPaletteCellElement> get cells =>
      querySelectorAll('color-palette-cell');
  ColorPaletteCellElement get selectedCell =>
      querySelector('color-palette-cell[selected]');
  String get color => (selectedCell == null) ? null : selectedCell.color;

  ColorPaletteElement.created() : super.created() {
    _initCellEvents();
  }

  void _initCellEvents() {
    cells.forEach((cell) {
      onPropertyChange(cell, #selected, () {
        if (!cell.selected) return;

        ColorPaletteCellElement oldCell = null;
        cells.forEach((otherCell) {
          if (otherCell == cell) return;
          if (otherCell.selected) oldCell = otherCell;
          otherCell.selected = false;
        });

        _colorChangeController.add(new ColorChangeEvent(oldCell, cell));
      });
    });
  }
}

class ColorChangeEvent {
  ColorPaletteCellElement oldCell;
  ColorPaletteCellElement newCell;
  String get oldColor => (oldCell == null) ? null : oldCell.color;
  String get newColor => newCell.color;
  ColorChangeEvent(this.oldCell, this.newCell);
  @override
  String toString() =>
      'ColorChangeEvent(${oldColor} => ${newColor})';
}

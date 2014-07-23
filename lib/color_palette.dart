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
      this.querySelectorAll('color-palette-cell');

  @reflectable
  ColorPaletteCellElement get selectedCell =>
      cells.firstWhere((ColorPaletteCellElement e) => e.selected);

  @reflectable
  String get color {
    var c = selectedCell;
    return (c == null) ? null : c.color;
  }

  List<ColorPaletteCellElement> get _selectedCells =>
      cells.where((ColorPaletteCellElement e) => e.selected)
        .toList(growable: false);

  ColorPaletteElement.created() : super.created();

  @override
  attached() {
    super.attached();
    _initInputElements();
    _initCells();
    _initEvents();
  }

  void _initInputElements() =>
    this.querySelectorAll('input').forEach(_initInputElement);

  void _initInputElement(InputElement e) {
    var attrs = e.attributes;
    if (!attrs.containsKey('type') || attrs['type'].isEmpty) e.type = 'radio';
    if (e.type != 'radio') return;

    e.style.display = 'none';
    ColorPaletteCellElement cell = new Element.tag('color-palette-cell');
    cell.color = e.value;
    cell.selected = e.checked;
    cell.title = e.title;
    e.parent.insertBefore(cell, e);

    e.onChange.listen((_) => cell.selected = e.checked);
    cell.onSelectedChange.listen((_) => e.checked = cell.selected);
  }

  void _initCells() => cells.forEach(_initCell);

  void _initCell(ColorPaletteCellElement cell) {
    cell.onSelectedChange.listen((event) {
      var target = event.element;
      if (!target.selected) return;

      // find and de-select the old selected cell
      ColorPaletteCellElement oldSelectedCell;
      _selectedCells.where((e) => e != target).forEach((e){
        oldSelectedCell = e;
        e.selected = false;
      });

      notifyPropertyChange(#selectedCell, oldSelectedCell, target);
    });
  }

  void _initEvents() {
    changes.listen((records) {
      records
        .where((r) => (r is PropertyChangeRecord) && (r.name == #selectedCell))
        .forEach((PropertyChangeRecord r) {
          String oldColor = (r.oldValue == null) ? null : r.oldValue.color;
          String newColor = (r.newValue == null) ? null : r.newValue.color;
          notifyPropertyChange(#color, oldColor, newColor);
          _colorChangeController.add(new ColorChangeEvent(r.oldValue, r.newValue));
        });
    });
  }
}

class ColorChangeEvent {
  ColorPaletteCellElement oldCell;
  ColorPaletteCellElement newCell;
  String get oldColor => (oldCell == null) ? null : oldCell.color;
  String get newColor => (newCell == null) ? null : newCell.color;
  ColorChangeEvent(this.oldCell, this.newCell);
  @override
  String toString() => 'ColorChangeEvent(${oldColor} => ${newColor})';
}

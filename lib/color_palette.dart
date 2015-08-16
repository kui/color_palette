@HtmlImport('color_palette.html')
library color_palette;

import 'package:polymer/polymer.dart';
import 'color_palette_cell.dart';
import 'dart:html';
import 'dart:async';

@CustomTag('color-palette')
class ColorPaletteElement extends PolymerElement {

  MutationObserver _cellObserver;

  final Map<RadioButtonInputElement, ColorPaletteCellElement> _radioToPalleteCell = new Map();

  final StreamController<ColorChangeEvent> _colorChangeController =
      new StreamController.broadcast();
  Stream<ColorChangeEvent> get onColorChange => _colorChangeController.stream;

  List<ColorPaletteCellElement> get cells =>
      this.querySelectorAll('color-palette-cell');

  @published
  ColorPaletteCellElement get selectedCell => readValue(#selectedCell, () => null);
  set selectedCell(ColorPaletteCellElement cell) => writeValue(#selectedCell, cell);

  String get color {
    final c = selectedCell;
    return (c == null) ? null : c.color;
  }

  ColorPaletteElement.created() : super.created();

  @override
  attached() {
    super.attached();
    _startCellObserver();
  }

  @override
  domReady() {
    super.domReady();
    _initCells();
    _initInputs();
  }

  @override
  detached() {
    super.detached();
    if (_cellObserver != null) {
      _cellObserver.disconnect();
      _cellObserver = null;
    }
  }

  void _select(ColorPaletteCellElement cell) {
    if (cell == null || !contains(cell)) {
      cells.forEach((ColorPaletteCellElement e) => e.selected = false);
    } else {
      cell.select();
    }
  }

  void _startCellObserver() {
    if (_cellObserver != null) return;

    _cellObserver = new MutationObserver(_onAddCells)
        ..observe(this, subtree: true, childList: true);
  }

  void _onAddCells(List<MutationRecord> recs, _) {
    final addedNodes = recs
      .expand((r) => r.addedNodes)
      .where((n) => n is Element)
      .toList(growable: false);

    // DO NOT swap initCells and initInputs.
    // Because initInputs add cells, if initInputs was first,
    // the added cells will be initialize twice.
    addedNodes
      .expand((Element e) => (e is ColorPaletteCellElement) ?
              [e] : e.querySelectorAll('color-palette-cell'))
      .forEach(_initCell);
    addedNodes
      .expand((Element e) =>
          (e is InputElement) ? [e] : e.querySelectorAll('input'))
      .forEach(_initInput);
  }

  void _initInputs() =>
    this.querySelectorAll('input').forEach(_initInput);

  void _initInput(InputElement e) {
    final attrs = e.attributes;
    if (!attrs.containsKey('type') || attrs['type'].isEmpty) e.type = 'radio';
    if (e.type != 'radio') return;
    if (_radioToPalleteCell.containsKey(e)) return;

    e.style.display = 'none';
    ColorPaletteCellElement cell = new Element.tag('color-palette-cell');
    cell
        ..color = e.value
        ..selected = e.checked
        ..title = e.title;
    e.parent.insertBefore(cell, e);

    e.onChange.listen((_) => cell.selected = e.checked);
    cell.onSelectedChange.listen((_) => e.checked = cell.selected);

    _radioToPalleteCell.putIfAbsent(e, () => cell);
  }

  void _initCells() {
    cells.forEach(_initCell);
    selectedCell = cells.firstWhere((e) => e.selected, orElse: () => null);
  }

  void _initCell(ColorPaletteCellElement cell) {
    cell.onSelectedChange
      .map((e) => e.element)
      .where((ColorPaletteCellElement e) => e.selected)
      .listen((ColorPaletteCellElement e) => selectedCell = e);
  }

  selectedCellChanged(ColorPaletteCellElement oldSelectedCell) {
    if (selectedCell != null) {
      selectedCell.selected = true;
    }
    cells
      .where((e) => e != selectedCell)
      .where((e) => e.selected)
      .forEach((e) => e.selected = false);
    _colorChangeController.add(new ColorChangeEvent(oldSelectedCell, selectedCell));
  }
}

class ColorChangeEvent {
  final ColorPaletteCellElement oldCell;
  final ColorPaletteCellElement newCell;
  String get oldColor => (oldCell == null) ? null : oldCell.color;
  String get newColor => (newCell == null) ? null : newCell.color;
  ColorChangeEvent(this.oldCell, this.newCell);
  @override
  String toString() => 'ColorChangeEvent(${oldColor} => ${newColor})';
}

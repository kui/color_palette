library color_pallette.color_pallete_cell;

import 'package:polymer/polymer.dart';
import 'dart:async';

@CustomTag('color-palette-cell')
class ColorPaletteCellElement extends PolymerElement {

  @published
  String color = '';

  @published
  bool selected = false;

  @published
  String checkMark = '✓';

  @reflectable
  String get title =>
    (super.title == null || super.title.isEmpty) ? color : super.title;

  @reflectable
  void set title(String t) {
    var oldTitle = title;
    super.title = t;
    notifyPropertyChange(#title, oldTitle, t);
  }

  StreamController<ColorPaletteCellChangeEvent> _changeEventsController =
      new StreamController.broadcast();
  Stream<ColorPaletteCellChangeEvent> get onSelectedChange =>
      _changeEventsController.stream;

  ColorPaletteCellElement.created() : super.created();

  @override
  attached() {
    super.attached();
    notifyPropertyChange(#title, null, title);
    onPropertyChange(this, #selected, () => _changeEventsController.add(
        new ColorPaletteCellChangeEvent(this)));
  }

  /// on-click callback
  select() => selected = true;
}

class ColorPaletteCellChangeEvent {
  final ColorPaletteCellElement element;
  ColorPaletteCellChangeEvent(this.element);
}

library color_pallette.color_pallete_cell;

import 'package:polymer/polymer.dart';
import 'dart:async';

@CustomTag('color-palette-cell')
class ColorPaletteCellElement extends PolymerElement {
  static const DEFAULT_CHECK_MARK = '✓';

  @published
  String get color => readValue(#color, () => '');
  set color(String c) => writeValue(#color, c);

  @published
  bool get selected => readValue(#selected, () => false);
  set selected(bool b) => writeValue(#selected, b);

  @published
  String get checkMark => readValue(#checkMark, () => DEFAULT_CHECK_MARK);
  set checkMark(String s) => writeValue(#checkMark, s);

  @reflectable
  String get title =>
    (super.title == null || super.title.isEmpty) ? color : super.title;
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
  domReady() {
    super.domReady();
    notifyPropertyChange(#title, null, title);
  }

  selectedChanged(old) {
    _changeEventsController.add(
            new ColorPaletteCellChangeEvent(this));
  }

  /// on-click callback
  select() => selected = true;
}

class ColorPaletteCellChangeEvent {
  final ColorPaletteCellElement element;
  ColorPaletteCellChangeEvent(this.element);
}

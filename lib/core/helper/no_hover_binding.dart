/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: no_hover_binding.dart
/// Purpose: The app's Flutter binding, with the mouse "hover" dropped.
/// Author: Knowticed Plus team
/// Created at: 23/10/2026
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Rule R-36 (Moataz, 23/10/2026): nothing in the app reacts to the mouse
/// resting on it — no hover colour, no hover tooltip, in any button, arrow,
/// menu row or custom component.
///
/// Turning hover off widget by widget did not hold: the theme, the custom
/// components, the date picker and the popup menus each had their own, and a
/// new one appeared every time. A mouse that is only MOVING (no button down)
/// reaches Flutter as a [PointerHoverEvent]; this binding drops those events,
/// so no widget can ever be told the pointer is over it. Pressing, dragging,
/// scrolling and touch are different events and are untouched. The cost: the
/// mouse cursor stays an arrow instead of turning into a hand over a button.
class NoHoverBinding extends WidgetsFlutterBinding {
  static WidgetsBinding ensureInitialized() {
    NoHoverBinding();
    return WidgetsBinding.instance;
  }

  @override
  void handlePointerEvent(PointerEvent event) {
    if (event is PointerHoverEvent) return;
    super.handlePointerEvent(event);
  }
}

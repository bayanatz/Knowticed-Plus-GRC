# App Animations – Integration Guide

All reusable widgets live in `lib/core/animation/app_animations.dart`.
They are **purely visual wrappers** – they wrap an existing `child` and never
change business logic. Import once per file:

```dart
import 'package:knowticed/core/animation/app_animations.dart';
```

## The mapping

| Role | Widget | Where to use |
|------|--------|--------------|
| Slide | `SlideInContent` | Page components – wrap a page body so it slides in on open |
| Bounce | `BounceSwitcher` / `BounceTap` | Switching list ⇄ grid view on the main screen |
| Shake (once) | `ShakeOnce` | "Are you sure" dialogs: delete / remove / logout / login errors |
| Scale | `ScaleInContent` / `showScaleDialog` | All other dialogs (NOT delete/remove) |
| Size | `AnimatedSizeWrap` | Tables |
| Shrink | `ShrinkOnTap` | Yellow buttons (get smaller on press) |
| Implicit expand | `ImplicitExpand` | Expand/collapse with a button |

## Copy‑paste patterns

### 1. Slide – page body
Wrap the body content (the part below the app bar):
```dart
body: SlideInContent(
  from: SlideFrom.bottom, // or .left / .right / .top
  child: /* existing body widget */,
),
```

### 2. Bounce – list/grid toggle
Wrap the widget that swaps between list and grid, keyed to the toggle flag:
```dart
BounceSwitcher(
  triggerValue: isGridViewChoose, // any value that flips on toggle
  child: /* the grid or table view */,
)
```
For bouncing the toggle icon itself on tap, use `BounceTap(onTap: ..., child: icon)`.

### 3. Shake – confirm dialogs (shake once)
Wrap the dialog's returned widget:
```dart
return ShakeOnce(child: Dialog( ... ));
```
`ShakeOnce` shakes a single time when shown. To trigger a shake on demand
(e.g. on a failed login), give it a key and call `shake()`:
```dart
final shakeKey = GlobalKey<ShakeOnceState>();
// ...
ShakeOnce(key: shakeKey, autoPlay: false, child: loginCard);
// on error:
shakeKey.currentState?.shake();
```

### 4. Scale – other dialogs
Either wrap the dialog widget:
```dart
return ScaleInContent(child: Dialog( ... ));
```
or use the drop‑in dialog opener:
```dart
showScaleDialog(context: context, builder: (_) => MyDialog());
```

### 5. Size – tables
Wrap the table's root widget:
```dart
return AnimatedSizeWrap(child: Directionality( /* Table */ ));
```

### 6. Shrink – yellow buttons
`ShrinkOnTap` uses pointer events, so it does **not** steal the button's own
`onTap`/`onPressed`:
```dart
ShrinkOnTap(child: myYellowButton)
```

### 7. Implicit – button expand
```dart
ImplicitExpand(
  expanded: isExpanded, // toggled by a button
  child: /* collapsible content */,
)
```

## Already wired in

| Animation | File |
|-----------|------|
| Slide | `settings/presentation/ui/pages/settings_layout.dart` |
| Slide | `services_management_module/.../s1_home_page_services/ui/pages/home_page_services.dart` |
| Bounce | `services_management_module/.../s1_home_page_services/ui/widgets/management_widget.dart` |
| Size | `services_management_module/.../s1_home_page_services/ui/widgets/table_widget.dart` |
| Shake (once) | `core/local_widgets/dialogs/delete_dialog.dart` (shared – covers all delete/remove/attention dialogs) |
| Scale | `services_management_module/.../s2_create_single_services/ui/widgets/dialogs.dart` |
| Shrink | `settings/presentation/ui/widgets/custom_black_button.dart` (when `isYellow == true`) |

## Notes
- These wrappers add their own `AnimationController`s and dispose them
  automatically; no changes to existing controllers are needed.
- Nothing here changes state, data flow, navigation, or callbacks.
- Flutter could not be compiled in the authoring environment – run
  `flutter analyze` and a debug build to confirm before shipping.

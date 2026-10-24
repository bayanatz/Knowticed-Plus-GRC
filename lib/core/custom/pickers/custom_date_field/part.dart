/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: part.dart
/// Description: `_kPickerDialogWidthTablet` constant, `_kPickerCalendarHeight` constant — split out of `3-custom_dropdown_calander.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_date_field.dart';

// Split from 3-custom_dropdown_calander.dart to keep every file under 700 lines.

/// ── Picker dialog geometry ──────────────────────────────────────────────────
///
/// ADDED 30/8/2026, all RAW (the ScreenUtil suffix is applied at each point of
/// use — and note WHICH suffix: the tablet numbers are `.sp`, the phone ones
/// `.w` / `.h`, matching `DatePicker` below).
///
/// REVISED 30/8/2026: these were a single 320 square. `DatePicker`
/// (core/custom/53-custom_date_pic) — the app's other calendar, the one the
/// Knowledge Hub schedule fields open — is 520 × 380 on tablet and 360 × 380 on
/// phone, so the same seven columns had appreciably more room there and the two
/// pickers read as two different components. The numbers below are that
/// widget's, so the two now open at the same size.
///
/// The action buttons are measured FROM the dialog width, which is the only way
/// to get one button against each edge: `calendar_date_picker2` lays its
/// actions out as `Row(mainAxisAlignment: end, children: [cancel, ok])` with no
/// alignment or spacer of its own, so two content-sized buttons always huddle
/// on the trailing side. Give each one a slot of exactly half the dialog and
/// the row is full — the leftover space that would have pushed them together is
/// now inside the slots, and each button sits at its own outer edge.
///
/// The two slots must therefore add up to the dialog width EXACTLY: short, and
/// the pair drifts back toward the trailing edge; long, and the Row overflows.
/// That is why both come from [_pickerDialogSize] rather than from two
/// constants that could drift apart.
const double _kPickerDialogWidthTablet = 520;

/// Dialog height — DERIVED, not a constant (9/9/2026).
///
/// It used to be a flat 380 scaled by `.sp` / `.h`, which the package then
/// FLOORED at 410 logical pixels (`max(dialogSize.height, 410)` in
/// `showCalendarDatePicker2Dialog`) — so on a phone the number asked for was
/// inert and the dialog was always exactly as tall as the content needed, with
/// nothing to spare. That is why [buttonPadding] at the call below had to be
/// zero on the vertical axis.
///
/// The action row now carries [_kPickerButtonMargin] above and below it, to
/// match the margin it already has on the left and right, so the height is
/// built from its parts instead. Note WHICH parts scale: the calendar's own
/// height is raw logical pixels straight out of the package, while the button
/// and its margins are `.sp` — a single scaled constant would shrink below the
/// 410 floor on a small phone and clip the row again.
///
/// Calendar block, all raw: `controlsHeight` (52, the month/year header) plus
/// `_dayPickerRowHeight` (42) for each of the six week rows and the weekday
/// header — 52 + 42 × 7.
const double _kPickerCalendarHeight = 346; // 52 + 42 * 7

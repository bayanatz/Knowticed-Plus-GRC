/// Module: core/custom/inputs
/// Description: THE single-line field height. ADDED 17/10/2026 — rule D-18
///              ("field and filter boxes are 36 high, text centred"; Moataz
///              17 Oct: "the height is fixed … why does it take more?").
///              CustomTextField, CustomDropdown and CustomDateField use it
///              when a screen passes no height; multi-line boxes still grow.
library;

abstract final class FieldSizing {
  static const double height = 36;
}

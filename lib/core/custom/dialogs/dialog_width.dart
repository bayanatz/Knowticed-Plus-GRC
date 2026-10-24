/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: dialog_width.dart
/// Purpose: The ONE place dialog widths are defined.
/// Author: Knowticed Plus team
/// Created at: 23/10/2026
library;

/// Moataz 23/10/2026 (option 1): dialogs had eleven different widths
/// (300 … 820) — "are you sure" 300/410/411/500, success 500, request 539,
/// input 500, upload 560, filters 300/450/600/820. There are two now:
///
///  * [small] — messages with no fields: "are you sure", success, message,
///    download complete.
///  * [form] — anything with fields or lists: filters, requests / reasons,
///    input, export, upload.
///
/// Unscaled (callers apply `.sp` / `.w` as before). On a phone the dialog
/// shell clamps either one to the screen.
abstract final class DialogWidth {
  const DialogWidth._();

  static const double small = 411;
  static const double form = 600;
}

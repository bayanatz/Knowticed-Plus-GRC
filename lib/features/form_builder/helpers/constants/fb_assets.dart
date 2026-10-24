/// Module: form_builder_module/helpers
///
///*************************** FILE INFO ****************************///
/// File Name: fb_assets.dart
/// Description: `FormBuilderAssets`, the Form Builder asset paths that have
///              no `AppAssets` constant (Home rule 8: no inline paths).
/// Author: Amr Mesbah
/// Created at: 23/10/2026
library;

/// Asset paths used only by the Form Builder screens.
abstract class FormBuilderAssets {
  /// The Form Builder module icon (form cover placeholder).
  static const String moduleIcon =
      'assets/icons_assets/main_icons_assets/ic_module_form_builder.svg';

  /// The upload / export arrow on the Upload Watermark button.
  static const String uploadIcon =
      'assets/icons_assets/main_icons_assets/ic_action_export.svg';

  /// The red warning animation (structure locked notice).
  static const String warningRedLottie =
      'assets/lottie_assets/main_lottie_assets/lot_status_warning_red.json';
}

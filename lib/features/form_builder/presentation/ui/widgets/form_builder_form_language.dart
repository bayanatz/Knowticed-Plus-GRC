/// Module: form_builder_module/presentation
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_form_language.dart
/// Description: `FormLanguageScope` — the language a FORM was written in, as
///          opposed to the language the APP is running in.
/// Author: Amr Mesbah
/// Created at: 13/10/2026
///
///
/// "When I create a form in English and switch the app to Arabic, don't switch
/// the form to Arabic — an English form stays an English form in Arabic mode",
/// and "the calendar must be the same language as the form".
///
/// The app enforces one language per form while it is being built (field
/// titles are Arabic-only in the Arabic app and English-only in the English
/// app — see `text_field_widget.dart`), but the language is not stored on the
/// form. It is therefore read back from the content: whichever script has
/// more letters across the form's field titles and hints wins. A form with no
/// letters at all falls back to the app language.
///
/// Wrap the A4 page(s) of a form in [FormLanguageScope]. Everything inside
/// then lays out in the form's direction, and widgets that draw their own
/// chrome (the date picker, the time picker, AM/PM) ask
/// [FormLanguageScope.isArabicOf] instead of the app locale.
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/page_controller_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/core/helper/content_language_scope.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

export 'package:knowticed_plus/core/helper/content_language_scope.dart';

/// The form's language scope — the shared [ContentLanguageScope] (moved to core
/// 17/10/2026 so core no longer imports Form Builder).
typedef FormLanguageScope = ContentLanguageScope;

/// Form Builder's own language detectors (they read Form Builder models).
abstract final class FormLanguageDetect {
  /// Language of a saved form (details, fill out, requests, submissions).
  static bool? detectFromEntity(FormEntity? form) {
    if (form == null) return null;
    final List<String?> texts = <String?>[];
    for (final page in form.pages) {
      for (final row in page.rows) {
        for (final field in row.fields) {
          texts.add(field.fieldTitle);
        }
      }
    }
    return ContentLanguageScope.detect(texts);
  }

  /// Language of a form still being built (create / edit / preview).
  static bool? detectFromPages(List<PageControllerModel> pages) {
    final List<String?> texts = <String?>[];
    for (final page in pages) {
      for (final row in page.rows) {
        for (final controller in row.controllers) {
          for (final FieldText c in controller.textControllers) {
            texts.add(c.text);
          }
        }
      }
    }
    return ContentLanguageScope.detect(texts);
  }
}

/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: form_demo_data.dart
/// Description: `FormDemoData` — sample content for the "Fill demo data"
///          button on the Create Form screen. Fills the form header and builds
///          pages that contain ALL 18 field types, each with a title, hints
///          and options already typed in, so a full form can be published and
///          tested (fill out, submissions, PDF, preview) in one tap.
/// Author: Amr Mesbah
/// Created at: 13/10/2026
///
/// Header images (cover / watermark) are left empty on purpose: they are local
/// file paths that get uploaded on publish, and there is no file to point at.
library;

import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/address_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/attachment_digital_signature_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/attachment_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/date_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/description_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/email_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/image_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/link_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/phone_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/terms_conditions_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/page_controller_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/row_controller_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class FormDemoData {
  FormDemoData._();

  // ── Header ────────────────────────────────────────────────────────────────

  static String title() => 'Demo Form ${_stamp()}';
  static String arTitle() => 'نموذج تجريبي ${_stamp()}';

  static const String description =
      'Auto-generated demo form that contains every field type. '
      'Use it to test publishing, filling out, submissions and PDF export.';
  static const String arDescription =
      'نموذج تجريبي تم إنشاؤه تلقائيًا ويحتوي على جميع أنواع الحقول. '
      'استخدمه لاختبار النشر والتعبئة والردود وتصدير PDF.';

  static const String horizontalPadding = '16';
  static const String verticalPadding = '16';
  static const String watermarkOpacity = '50';
  static const String watermarkSize = '100';

  /// dd/MM HH:mm — keeps each demo form's title unique in the home list.
  static String _stamp() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(now.day)}/${two(now.month)} ${two(now.hour)}:${two(now.minute)}';
  }

  // ── Pages ─────────────────────────────────────────────────────────────────

  /// Two pages, 18 field types between them.
  static List<PageControllerModel> buildPages() {
    return [
      PageControllerModel(
        rows: [
          _row([_title()]),
          _row([_textField(), _email()]),
          _row([_phone(), _link()]),
          _row([_date(), _time()]),
          _row([_description()]),
          _row([_dropDown(), _radio()]),
          _row([_checkBox()]),
          _row([_radioTextField()]),
        ],
      ),
      PageControllerModel(
        rows: [
          _row([_location()]),
          _row([_address()]),
          _row([_image()]),
          _row([_attachment(), _signature()]),
          _row([_terms()]),
        ],
      ),
    ];
  }

  static RowControllerModel _row(List<FieldController> fields) {
    final row = RowControllerModel(controllers: fields);
    row.numOfColumn!.text = FormDateTimeHelper.formatInt(fields.length);
    return row;
  }

  static void _setOptions(List<FieldText> target, List<String> values) {
    for (final c in target) {
      c.dispose();
    }
    target
      ..clear()
      ..addAll(values.map((v) => FieldText(text: v)));
  }

  static TitleFieldController _title() {
    final c = TitleFieldController();
    c.title!.text = 'Employee Information Survey';
    c.isBold = true;
    return c;
  }

  static TextFieldController _textField() {
    final c = TextFieldController();
    c.title!.text = 'Full Name';
    c.hint!.text = 'Enter your full name';
    c.isRequired = true;
    return c;
  }

  static EmailFieldController _email() {
    final c = EmailFieldController();
    c.title!.text = 'Work Email';
    c.hint!.text = 'name@company.com';
    c.isRequired = true;
    return c;
  }

  static PhoneFieldController _phone() {
    final c = PhoneFieldController();
    c.title!.text = 'Mobile Number';
    c.isRequired = true;
    return c;
  }

  static LinkFieldController _link() {
    final c = LinkFieldController();
    c.title!.text = 'LinkedIn Profile';
    c.hint!.text = 'https://linkedin.com/in/…';
    return c;
  }

  static DateFieldController _date() {
    final c = DateFieldController();
    c.title!.text = 'Joining Date';
    c.hint!.text = 'Select a date';
    return c;
  }

  static TimeSelectorFieldController _time() {
    final c = TimeSelectorFieldController();
    c.title!.text = 'Preferred Meeting Time';
    return c;
  }

  static DescriptionFieldController _description() {
    final c = DescriptionFieldController();
    c.title!.text = 'Comments';
    c.hint!.text = 'Write any notes or feedback here';
    c.limitation!.text = FormDateTimeHelper.formatInt(500);
    return c;
  }

  static DropDownFieldController _dropDown() {
    final c = DropDownFieldController();
    c.title!.text = 'Department';
    _setOptions(c.hints, ['Human Resources', 'Finance', 'IT', 'Operations']);
    c.isRequired = true;
    return c;
  }

  static RadioFieldController _radio() {
    final c = RadioFieldController();
    c.title!.text = 'Work Mode';
    _setOptions(c.hints, ['On-site', 'Remote', 'Hybrid']);
    return c;
  }

  static CheckBoxFieldController _checkBox() {
    final c = CheckBoxFieldController();
    c.title!.text = 'Skills';
    for (final o in c.options) {
      o.option.dispose();
    }
    c.options = [
      'Flutter',
      'Dart',
      'Firebase',
      'UI / UX',
    ].map((v) => CheckboxOptions(option: FieldText(text: v))).toList();
    c.maximumSelection!.text = FormDateTimeHelper.formatInt(3);
    return c;
  }

  static RadioTextFieldController _radioTextField() {
    final c = RadioTextFieldController();
    _setOptions(c.hints, [
      'I agree to be contacted',
      'I prefer not to be contacted',
    ]);
    return c;
  }

  static LocationFieldController _location() {
    final c = LocationFieldController();
    c.title!.text = 'Office Location';
    return c;
  }

  static AddressFieldController _address() {
    // Comes with its six address hints (Country … Building) already set.
    final c = AddressFieldController();
    c.title!.text = 'Home Address';
    return c;
  }

  static ImageFieldController _image() {
    final c = ImageFieldController();
    c.title!.text = 'Profile Photo';
    c.limitation!.text = FormDateTimeHelper.formatInt(2);
    c.insertImagesList(c.limitation!.text);
    return c;
  }

  static AttachmentFieldController _attachment() {
    final c = AttachmentFieldController();
    c.title!.text = 'CV / Resume';
    return c;
  }

  static AttachmentDigitalSignatureFieldController _signature() {
    final c = AttachmentDigitalSignatureFieldController();
    c.title!.text = 'Signature';
    return c;
  }

  static TermsConditionsFieldController _terms() {
    final c = TermsConditionsFieldController();
    c.title!.text = 'Terms and Conditions';
    c.termsEn!.text =
        'I confirm that the information provided in this form is accurate '
        'and I agree that it may be used for internal HR purposes.';
    c.termsAr!.text =
        'أؤكد أن المعلومات المقدمة في هذا النموذج صحيحة '
        'وأوافق على استخدامها لأغراض الموارد البشرية الداخلية.';
    return c;
  }
}

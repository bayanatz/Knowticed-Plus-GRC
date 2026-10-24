/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: edit_page_request.dart
/// Description: The personal-information edit form that feeds the preview page.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE6-N02/N06/N12: the seven try/catch blocks left presentation/ui
///          (four of them were dead — they wrapped `tryParse`); raw colours
///          route through AppColors; `Get.locale` replaced with
///          `Localizations.localeOf(context)`.
///
/// REMAINING (N05, N13): still ~1,300 LOC, and it hands the preview page live
/// TextEditingControllers.
library;

///*************************** FILE INFO ****************************///
/// Description: Edit page for personal information change requests with Arabic support
/// Updated At: 07/11/2025
/// Using CustomValidatedTextField and CustomDropdownFormField
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/inputs/phone_code_box.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/stored_value_ar.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/preview_changes_page.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/employee_date_formatter.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_image_picker.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/phone_country_lookup.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/flexible_date_parser.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/drop_down.dart' hide CustomDropdownFormFieldFinal;
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import '../../../../../external/knowledge_hub_module/core/custom_drop_down.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_country_picker.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:knowticed_plus/core/helper/arabic_number_format.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/helper/location_data_service.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

part '../widgets/edit_page_request/edit_page_request_logic.dart';
part '../widgets/edit_page_request/edit_page_request_builders.dart';
part '../widgets/edit_page_request/edit_page_request_builders_2.dart';

class EditPageRequest extends StatefulWidget {
  const EditPageRequest(
      {super.key, this.resendChanges = const <FieldChange>[]});

  /// 21/10/2026 (Moataz) "Edit And Resend": the changes of a REJECTED request.
  /// The form opens with these new values already filled in (and counted as
  /// changes), so the employee corrects them and sends a new request. Empty
  /// for a normal edit.
  final List<FieldChange> resendChanges;

  @override
  State<EditPageRequest> createState() => _EditPageRequestState();
}

class _EditPageRequestState extends State<EditPageRequest> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  // Controllers for all fields
  // NAMES 24/8/2026 — six controllers, not three.
  //
  // Each name used to be ONE controller pointed at whichever spelling matched
  // the UI language: in Arabic it edited `firstNameInArabic`, in English it
  // edited `firstName`. So an employee could only ever maintain one of the two,
  // and which one depended on the language they happened to be using. Both are
  // edited together now, side by side.
  late TextEditingController firstNameController; // English spelling
  late TextEditingController firstNameArController; // Arabic spelling
  late TextEditingController middleNameController;
  late TextEditingController middleNameArController;
  late TextEditingController lastNameController;
  late TextEditingController lastNameArController;

  // Labels for the name boxes. Deliberately NOT localized: they name the SCRIPT
  // of the value, not the UI. Localizing them would print the same word above
  // both boxes in a given language and make the pair ambiguous.
  static const String _labelFirstNameEn = 'First Name';
  static const String _labelMiddleNameEn = 'Middle Name';
  static const String _labelLastNameEn = 'Last Name';
  static const String _labelFirstNameAr = 'الاسم الأول';
  static const String _labelMiddleNameAr = 'الاسم الأوسط';
  static const String _labelLastNameAr = 'اسم العائلة';
  // REMOVED 24/8/2026: the email field is gone from this form. The address is
  // not populated for every employee, so the row rendered blank (and
  // `employee!.email!.last` below threw outright when the list was null),
  // which is why it did not show "all the time".
  late TextEditingController phoneController;
  late TextEditingController nationalityController;
  late TextEditingController countryController;
  late TextEditingController provinceController;
  late TextEditingController cityController;
  late TextEditingController streetController;
  late TextEditingController dateOfBirthController;

  // LOCATION 24/8/2026: Country / State / City are dropdowns now, not free text.
  //
  // The three TextEditingControllers above stay — PreviewChangesPage reads their
  // `.text`, and the change payload is still plain strings, so nothing
  // downstream had to learn about codes. These two only remember WHICH row is
  // selected, which is what lets the cascade reset the levels below it.
  String? _selectedCountryIso;
  String? _selectedStateCode;

  /// The state/city data is an asset, so it arrives one frame late. Until it
  /// does, `statesOf` returns empty; the country dropdown works either way
  /// because that list comes from country_picker, not from the file.
  bool _locationDataReady = false;

  // Selected values
  String? selectedGender;
  String? selectedMaritalStatus;
  DateTime? selectedDateOfBirth;
  String? selectedCountryCode;

  File? _selectedImage;

  // Form validation
  bool submitted = false;

  // Change tracking
  Map<String, dynamic> changes = {};

  /// Edit And Resend: the changes as the form opened (the rejected
  /// request's values). Empty for a normal edit.
  Map<String, String> _resendSnapshot = <String, String>{};

  // Dropdown items - will be initialized with localized values
  List<Map<String, String>> genderItems = [];
  List<Map<String, String>> maritalStatusItems = [];

  /// Guards the one-time init below: didChangeDependencies fires again whenever
  /// an inherited widget changes (locale switch, theme change, …).
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;

    // Both of these read S.of(context), which depends on the Localizations
    // inherited widget — that is not available yet during initState(), so the
    // work has to happen here instead. _initializeControllers() must run second
    // because it looks up the current gender / marital status inside the lists
    // built by _initializeDropdownItems().
    _initializeDropdownItems();
    _initializeControllers();
    _applyResendChanges();
    _loadLocationData();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    firstNameArController.dispose();
    middleNameController.dispose();
    middleNameArController.dispose();
    lastNameController.dispose();
    lastNameArController.dispose();
    phoneController.dispose();
    nationalityController.dispose();
    countryController.dispose();
    provinceController.dispose();
    cityController.dispose();
    streetController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }

  // Country flag / dial code lookups moved to
  // se1_profile/data/utils/phone_country_lookup.dart — each held a try/catch
  // (CR-SKEL-SE6-N02).

  Set<String> touchedFields = {};

  @override
  Widget build(BuildContext context) => _buildView(context);

  // ── One field box for the whole page (28/9/2026) ─────────────────────────
  // Settings bug report p.8: Gender / Birthday / Marital Status (and the name
  // fields above them) each sized themselves — the dropdown around a 20.sp
  // chevron, the date box around an 18.sp calendar icon, the text fields
  // around a line of text — so the boxes came out at different heights with
  // different space above and below their values, and the dropdowns drew
  // their value at 12 while the text fields and the date drew it at 14.
  // Every CustomTextField / CustomDropdown / CustomDateField on this
  // page now takes this one height (each widget then zeroes its vertical
  // padding and centres the value, with the same 12.sp side padding), and
  // the dropdowns draw their value in the same style as the text fields.
  static const double _kFieldHeight = 40;
}

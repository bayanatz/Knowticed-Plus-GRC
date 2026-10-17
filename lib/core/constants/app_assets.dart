/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: app_assets.dart
/// Purpose: Declares `AppAssets`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

// Objectives: This file is responsible for providing the app assets.

// assets
abstract class AppAssets {
  //***************************** IMAGES ***************************************

  //****************************************************************************

//******************************* VECTORS ************************************
  /// Brand marks used by the splash screen. Were literals in
  /// `splash_screen.dart` (§15, CR-SKEL-O1-N07).
  static const String logo =
      'assets/icons_assets/main_icons_assets/logo_knowticed.svg';
  static const String logoDark =
      'assets/icons_assets/main_icons_assets/logo_knowticed_dark.svg';

  /// Calendar-with-star mark for the day view's "Up Comings" header
  /// (Figma MESBAH 4717-39883).
  static const String upcome =
      'assets/icons_assets/main_icons_assets/ic_calendar_event_star_white.svg';

  static const String add =
      'assets/icons_assets/main_icons_assets/ic_action_plus.svg';
  static const String sort =
      'assets/icons_assets/main_icons_assets/ic_action_sort.svg';
  static const String arrowDown =
      'assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg';
  static const String arrowLeft =
      'assets/icons_assets/main_icons_assets/ic_nav_chevron_left.svg';
  static const String calendar =
      'assets/icons_assets/main_icons_assets/ic_time_calendar.svg';
  static const String camera =
      'assets/icons_assets/main_icons_assets/ic_media_camera_teal.svg';
  static const String cancel =
      'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg';
  static const String chat =
      'assets/icons_assets/main_icons_assets/ic_comms_chat_double.svg';
  static const String close =
      'assets/icons_assets/main_icons_assets/ic_action_close_circle.svg';
  static const String copy =
      'assets/icons_assets/main_icons_assets/ic_action_copy.svg';
  static const String defaultIcon =
      'assets/icons_assets/main_icons_assets/ic_create_form.svg';
  static const String delete =
      'assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg';
  static const String department =
      'assets/icons_assets/main_icons_assets/ic_org_department_people_yellow.svg';
  static const String download =
      'assets/icons_assets/main_icons_assets/ic_action_download.svg';

  static const String edit =
      'assets/icons_assets/main_icons_assets/ic_action_edit.svg';
  static const String email =
      'assets/icons_assets/main_icons_assets/ic_comms_email.svg';
  static const String fillOut =
      'assets/icons_assets/main_icons_assets/ic_results_checklist_clipboard.svg';
  static const String filter =
      'assets/icons_assets/main_icons_assets/ic_action_filter.svg';
  static const String grid = 'assets/icons_assets/main_icons_assets/ic_nav_grid.svg';
  static const String image =
      'assets/icons_assets/main_icons_assets/ic_media_image.svg';
  static const String imageWatermark =
      'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg';
  static const String link =
      'assets/icons_assets/main_icons_assets/ic_editor_link.svg';
  static const String listView =
      'assets/icons_assets/main_icons_assets/ic_list_lines.svg';
  static const String menu =
      'assets/icons_assets/main_icons_assets/ic_nav_menu.svg';

  /// Three-dot "more" glyph. ADDED 19/8/2026 for the Form Builder home cards,
  /// which were falling back to [menu] — a hamburger, not three dots.
  ///
  /// The artwork draws the dots VERTICALLY in a square 24×24 viewBox. Callers
  /// that want the horizontal ⋯ (the card menus, per Figma node 7444-37332)
  /// wrap it in `RotatedBox(quarterTurns: 1)`; because the viewBox is square,
  /// that rotation neither clips nor changes the icon's footprint.
  static const String more =
      'assets/icons_assets/main_icons_assets/ic_nav_more_vertical.svg';

  static const String network =
      'assets/icons_assets/main_icons_assets/ic_org_people_network.svg';
  static const String phone =
      'assets/icons_assets/main_icons_assets/ic_comms_phone_rounded.svg';
  static const String results =
      'assets/icons_assets/main_icons_assets/ic_results_checklist_clipboard.svg';
  static const String ring =
      'assets/icons_assets/main_icons_assets/ic_time_reminder_bell.svg';
  static const String search =
      'assets/icons_assets/main_icons_assets/ic_action_search_thin.svg';
  static const String selectAll =
      'assets/icons_assets/main_icons_assets/ic_action_select_all.svg';
  static const String share =
      'assets/icons_assets/main_icons_assets/ic_share_arrow.svg';
  static const String success =
      'assets/icons_assets/main_icons_assets/ic_status_success_small.svg';
  static const String text =
      'assets/icons_assets/main_icons_assets/ic_form_field_text.svg';
  static const String title =
      'assets/icons_assets/main_icons_assets/ic_form_field_text.svg';
  static const String upload =
      'assets/icons_assets/main_icons_assets/ic_action_upload.svg';
  static const String warning =
      'assets/icons_assets/main_icons_assets/ic_warning_triangle_red.svg';
  static const String addressIcon =
      'assets/icons_assets/main_icons_assets/ic_place_pin.svg';
  static const String attachedDigitalSignatureIcon =
      'assets/icons_assets/main_icons_assets/ic_editor_signature.svg';
  static const String attachmentIcon =
      'assets/icons_assets/main_icons_assets/ic_media_attach_square.svg';
  static const String checkBoxIcon =
      'assets/icons_assets/main_icons_assets/ic_form_checkbox_empty.svg';
  static const String descriptionIcon =
      'assets/icons_assets/main_icons_assets/ic_form_field_description.svg';
  static const String dropDownIcon =
      'assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg';
  static const String downloadPdf =
      'assets/icons_assets/main_icons_assets/ic_action_cloud_download.svg';
  static const String emailIcon =
      'assets/icons_assets/main_icons_assets/ic_comms_email.svg';
  static const String imageIcon =
      'assets/icons_assets/main_icons_assets/ic_form_field_image.svg';
  static const String linkIcon =
      'assets/icons_assets/main_icons_assets/ic_editor_link.svg';
  static const String locationIcon =
      'assets/icons_assets/main_icons_assets/ic_place_pin.svg';
  static const String phoneIcon =
      'assets/icons_assets/main_icons_assets/ic_comms_phone_rounded.svg';
  static const String radioIcon =
      'assets/icons_assets/main_icons_assets/ic_form_radio_unselected.svg';
  static const String timeSelectorIcon =
      'assets/icons_assets/main_icons_assets/ic_time_clock.svg';
  static const String downloadLinear =
      'assets/icons_assets/main_icons_assets/ic_action_cloud_download.svg';
  static const String bold =
      'assets/icons_assets/main_icons_assets/ic_editor_bold.svg';
  static const String italic =
      'assets/icons_assets/main_icons_assets/ic_editor_italic.svg';
  static const String underLine =
      'assets/icons_assets/main_icons_assets/ic_editor_underline.svg';
  static const String colorIcon =
      'assets/icons_assets/main_icons_assets/ic_module_branding_theme.svg';
  static const String arrowDownBold =
      'assets/icons_assets/main_icons_assets/ic_nav_chevron_down_gray.svg';
  static const String minus =
      'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg';
  static const String addOption =
      'assets/icons_assets/main_icons_assets/ic_action_plus.svg';
  static const String radioOption =
      'assets/icons_assets/main_icons_assets/ic_form_radio_empty.svg';
  static const String arrowUp =
      'assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg';
  static const String save =
      'assets/icons_assets/main_icons_assets/ic_action_bookmark.svg';
  static const String message =
      'assets/icons_assets/main_icons_assets/ic_messages_new.svg';
  static const String radio =
      'assets/icons_assets/main_icons_assets/ic_form_radio_empty.svg';
  static const String radioSelected =
      'assets/icons_assets/main_icons_assets/ic_form_radio_selected_gray.svg';
  static const String checkbox =
      'assets/icons_assets/main_icons_assets/ic_form_checkbox_empty.svg';
  static const String checkboxSelected =
      'assets/icons_assets/main_icons_assets/ic_form_checkbox_checked.svg';
  static const String summary =
      'assets/icons_assets/main_icons_assets/ic_summary_document_list.svg';
  // CHANGED 17/10/2026 (Moataz: "some export buttons come with this icon and
  // there is the export icon we used in the time tracker"): ONE export icon —
  // the Time Tracker one — for every Export button and dialog header.
  static const String export =
      'assets/icons_assets/main_icons_assets/ic_export.svg';
  static const String group =
      'assets/icons_assets/main_icons_assets/ic_org_people_network.svg';
  static const String checkboxFill =
      'assets/icons_assets/main_icons_assets/ic_form_checkbox_checked.svg';
  static const String pdf =
      'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
  static const String excel =
      'assets/icons_assets/main_icons_assets/ic_file_excel.svg';
  static const String powerPoint =
      'assets/icons_assets/main_icons_assets/ic_file_powerpoint.svg';
  static const String vedio =
      'assets/icons_assets/main_icons_assets/ic_file_video.svg';
  static const String word =
      'assets/icons_assets/main_icons_assets/ic_file_doc.svg';
  static const String attachmentPdf =
      'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
  static const String female =
      "assets/icons_assets/main_icons_assets/ic_user_avatar_female.png";
  static const String male =
      "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png";
  static const String minusCircle =
      'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg';

  //****************************************************************************

  //***************************** LOTTIE FILES *********************************

  static const String successful =
      'assets/lottie_assets/main_lottie_assets/lot_status_success.json';

  /// The confirm step of `CustomDialogManager.showDialogFlow`. ADDED
  /// 26/8/2026 — the file was already in assets/, just never named here.
  static const String lottieConfirmation =
      'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json';
  static const String trash =
      'assets/lottie_assets/main_lottie_assets/lot_action_delete.json';

  /// Green tick that draws in — the "Approve …?" confirm step. ADDED
  /// 13/10/2026 (Time Tracker owner I6: [lottieConfirmation] starts as a
  /// small "+" dot and is a "create document" animation).
  static const String lottieApproved =
      'assets/lottie_assets/main_lottie_assets/lot_status_success.json';

  /// The "editing an existing record" confirm step. ADDED 13/9/2026; the file
  /// was already in assets/ and already inlined as a raw path string by
  /// app_dialogs.dart and two services screens — named here so the GRC module
  /// does not add a fourth copy of it.
  ///
  /// The SPACE and the capital E in the filename are real. Do not "tidy" them
  /// without renaming the asset itself.
  static const String lottieEditDocument =
      'assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json';

  /// The "restoring a removed record" confirm step. ADDED 13/9/2026.
  static const String restore =
      'assets/lottie_assets/main_lottie_assets/lot_action_restore.json';

  /// The To-Do "Restoring To Do" confirm step: a yellow circular arrow that
  /// draws in and turns once (120 x 120, 60 frames). ADDED 7/10/2026 — the
  /// owner rejected both [restore] (e-commerce returns box) and
  /// [lottieConfirmation] (document + plus = "create") for restoring.
  static const String todoRestore =
      'assets/lottie_assets/main_lottie_assets/lot_todo_restore.json';
  static const String noData =
      'assets/lottie_assets/main_lottie_assets/lot_empty_no_data.json';

  /// The empty state used by `CustomEmptyState` — every list, table and
  /// filter result with nothing in it. ADDED 16/8/2026.
  ///
  /// NOT [noData], which is a different file in the same folder. Go through
  /// the widget rather than this constant: the point of having one animation
  /// is that no screen gets to size or caption it differently.
  static const String lottieEmpty =
      'assets/lottie_assets/main_lottie_assets/lot_empty_state.json';

  /// Failure/warning step of `CustomDialogManager.showMessage` — used by the
  /// form-builder submit flow when the response could not be sent. ADDED
  /// 1/9/2026; the file was already in assets/, just never named here.
  static const String lottieWarning =
      'assets/lottie_assets/main_lottie_assets/lot_action_delete_role.json';

//****************************************************************************

  /// champion/owner/request detail pages.
  static const String defaultEmployeeAvatar =
      'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png';

  // CRM

  static const String crmBlacklist =
      'assets/icons_assets/main_icons_assets/ic_blacklist.svg';
  static const String crmDeal = 'assets/icons_assets/crm_assets/ic_deals.svg';
  static const String crmClients =
      'assets/icons_assets/main_icons_assets/ic_clients.svg';
  static const String crmGroup =
      'assets/icons_assets/main_icons_assets/ic_iconoir_group.svg';
  static const String crmMerge = 'assets/icons_assets/crm_assets/ic_merge.svg';
  static const String crmProducts =
      'assets/icons_assets/main_icons_assets/ic_products.svg';
  static const String crmQuotes =
      'assets/icons_assets/main_icons_assets/ic_quotes.svg';
  static const String crmQuote = 'assets/icons_assets/crm_assets/ic_quote.svg';
  static const String crmCompare =
      'assets/icons_assets/main_icons_assets/ic_compare.svg';
  static const String crmVersion =
      'assets/icons_assets/main_icons_assets/ic_version.svg';
  static const String crmRequestQuote =
      'assets/icons_assets/main_icons_assets/ic_request_quote.svg';
  static const String crmServices =
      'assets/icons_assets/main_icons_assets/ic_services.svg';
  static const String crmTablerContract =
      'assets/icons_assets/main_icons_assets/ic_tabler_contract.svg';
  static const String crmGovernment =
      'assets/icons_assets/main_icons_assets/ic_government.svg';
  static const String crmPerson =
      'assets/icons_assets/main_icons_assets/ic_user_profile.svg';
  static const String crmCompanies =
      'assets/icons_assets/main_icons_assets/ic_companies.svg';
  static const String crmTemplate =
      'assets/icons_assets/main_icons_assets/ic_template.svg';
  static const String crmTemplateEmpty =
      'assets/icons_assets/main_icons_assets/ic_template_empty.svg';
  static const String crmPlusBold =
      'assets/icons_assets/main_icons_assets/ic_action_plus.svg';
  static const String crmInfo = 'assets/icons_assets/crm_assets/ic_info.svg';
  static const String crmWarning =
      'assets/icons_assets/main_icons_assets/ic_warning.svg';
  static const String crmMinus =
      'assets/icons_assets/main_icons_assets/ic_editor_decrease.svg';
  static const String crmArrowRight =
      'assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg';
  static const String crmArrowLeft =
      'assets/icons_assets/main_icons_assets/ic_nav_chevron_left.svg';
  static const String crmControl =
      'assets/icons_assets/main_icons_assets/ic_control.svg';
  static const String crmGuide = 'assets/icons_assets/crm_assets/ic_guide.svg';
  static const String crmClientsType =
      'assets/icons_assets/main_icons_assets/ic_clients.svg';
  static const String crmDiscount =
      'assets/icons_assets/main_icons_assets/ic_discount.svg';
  static const String crmPermissions =
      'assets/icons_assets/main_icons_assets/ic_permissions.svg';
  static const String crmRelationship =
      'assets/icons_assets/main_icons_assets/ic_relationship.svg';
  static const String crmTrush = 'assets/icons_assets/crm_assets/ic_trush.svg';
  static const String crmSaveSvgDialog =
      'assets/icons_assets/main_icons_assets/ic_dialog_save.svg';
  static const String crmSuccessfulSvgDialog =
      'assets/icons_assets/main_icons_assets/ic_dialog_success.svg';
  static const String crmMinusSolid =
      'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg';
  static const String crmCheckBoxField =
      'assets/icons_assets/main_icons_assets/ic_nav_checklist.svg';
  static const String crmCompanySizeField =
      'assets/icons_assets/main_icons_assets/ic_compony_size.svg';
  static const String crmDescriptionField =
      'assets/icons_assets/main_icons_assets/ic_form_field_description.svg';
  static const String crmImageField =
      'assets/icons_assets/main_icons_assets/ic_media_add_picture.svg';
  static const String crmIndustryField =
      'assets/icons_assets/main_icons_assets/ic_field_industry.svg';
  static const String crmLinkField =
      'assets/icons_assets/main_icons_assets/ic_editor_link.svg';
  static const String crmRadioField =
      'assets/icons_assets/main_icons_assets/ic_form_radio_selected_gray.svg';
  static const String crmSectorField =
      'assets/icons_assets/main_icons_assets/ic_field_sector.svg';
  static const String crmSignatureField =
      'assets/icons_assets/main_icons_assets/ic_field_signature.svg';
  static const String crmSwitchField =
      'assets/icons_assets/main_icons_assets/ic_field_switch.svg';
  static const String crmTagField =
      'assets/icons_assets/main_icons_assets/ic_field_tag.svg';
  static const String crmTextField =
      'assets/icons_assets/main_icons_assets/ic_editor_text.svg';
  static const String crmDropdownField =
      'assets/icons_assets/main_icons_assets/ic_dropdown_field_type.svg';
  static const String crmSections =
      'assets/icons_assets/main_icons_assets/ic_sections.svg';
  static const String crmStatus =
      'assets/icons_assets/main_icons_assets/ic_status_ring.svg';

  static const String crmHint = 'assets/icons_assets/crm_assets/ic_hint.svg';
  static const String crmAddView =
      'assets/icons_assets/main_icons_assets/ic_add_view.svg';

  static const String crmRelationshipEmpty =
      'assets/icons_assets/main_icons_assets/ic_crm_empty_state.svg';

  static const String crmHash = 'assets/icons_assets/main_icons_assets/ic_hash.svg';
  static const String crmPrice = 'assets/icons_assets/crm_assets/ic_price.svg';
  static const String crmCategoryIcon =
      'assets/icons_assets/main_icons_assets/ic_category.svg';
  static const String crmTax = 'assets/icons_assets/crm_assets/ic_tax.svg';
  static const String crmTeamsEmpty =
      'assets/icons_assets/main_icons_assets/ic_teams_empty.svg';

  static const String crmMergeEmptyPage =
      'assets/icons_assets/main_icons_assets/ic_merge_empty_page.svg';
  static const String crmConfidence =
      'assets/icons_assets/main_icons_assets/ic_confidence.svg';
  static const String crmHistory =
      'assets/icons_assets/main_icons_assets/ic_time_history_akar.svg';
  static const String crmHowItWork =
      'assets/icons_assets/main_icons_assets/ic_how_it_work.svg';
  static const String crmRecord =
      'assets/icons_assets/main_icons_assets/ic_record.svg';
  static const String crmUndo = 'assets/icons_assets/crm_assets/ic_undo.svg';

  // Database module (Amr, 16/10/2026)
  static const String databaseSelect =
      'assets/icons_assets/main_icons_assets/ic_status_all_agree.svg';
  static const String databaseCreate =
      'assets/icons_assets/main_icons_assets/ic_create_data_base.svg';

  static const String imagePhotoRounded =
      'assets/icons_assets/main_icons_assets/ic_media_photo_rounded.svg';

  static const String removed =
      'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg';

  static const String dotsHorizontal =
      'assets/icons_assets/main_icons_assets/ic_nav_more_horizontal.svg';
}

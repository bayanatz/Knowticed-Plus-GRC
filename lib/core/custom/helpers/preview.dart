/// Module: Core · Custom · Preview All Custom
/// Description: Single scrollable gallery page that instantiates every
///              reusable widget/helper found in lib/core/custom/, grouped
///              into labeled sections (one per source file) so the whole
///              custom widget library can be eyeballed in one place.
/// Author: Amr Mesbah
/// Created at: 01/07/2026
/// Dependencies: every file in lib/core/custom/
/// Revision History:
///   - 01/07/2026: Initial creation.
library;

import 'package:grc_module/core/custom/feedback/circle_progress.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:grc_module/core/extensions/calendar_package/src/models/calendar_date_picker2_config.dart'
    as local_cal;

import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/pickers/custom_date_range_fields.dart';
import 'package:grc_module/core/custom/cards/custom_person_chips.dart';
import 'package:grc_module/core/custom/navigation/custom_segmented_toggle.dart';
import 'package:grc_module/core/custom/buttons/custom_view_mode_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';

import 'package:grc_module/core/custom/dropdowns/custom_dropdown.dart';
import 'package:grc_module/core/custom/inputs/custom_textfield.dart';
import 'package:grc_module/core/custom/pickers/custom_date_field.dart';
import 'package:grc_module/core/custom/pickers/custom_range_calendar.dart';
import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/core/custom/buttons/custom_button_with_svg.dart';
import 'package:grc_module/core/custom/navigation/custom_filter_app.dart';
import 'package:grc_module/core/custom/navigation/filter_tab_with_container.dart';
import 'package:grc_module/core/custom/navigation/custom_tabs.dart';
import 'package:grc_module/core/custom/pickers/custom_upload_document.dart';
// 11's own showUploadDialog is a near-duplicate of 10's — hidden here to
// avoid an ambiguous-import error; section 10 already demos the dedicated one.
import 'package:grc_module/core/custom/dialogs/custom_confirm_dialog.dart'
    hide showUploadDialog;
import 'package:grc_module/core/custom/buttons/custom_delete_icon.dart';
import 'package:grc_module/core/custom/buttons/custom_edit_icon.dart';
import 'package:grc_module/core/custom/buttons/custom_filter_icon.dart';
import 'package:grc_module/core/custom/cards/custom_card_styles.dart';
import 'package:grc_module/core/custom/cards/custom_service_summary_card.dart';
import 'package:grc_module/core/custom/cards/custom_service_request_card.dart';
import 'package:grc_module/core/custom/cards/custom_employee_card.dart';
import 'package:grc_module/core/custom/cards/custom_personal_info_card.dart';
import 'package:grc_module/core/custom/cards/custom_contact_card.dart';
import 'package:grc_module/core/custom/cards/custom_uploaded_document_card.dart';
import 'package:grc_module/core/custom/inputs/custom_check_box.dart';
import 'package:grc_module/core/custom/charts/custom_chart_card.dart';
import 'package:grc_module/core/custom/charts/custom_overall_stats_card.dart';
import 'package:grc_module/core/custom/charts/custom_bar_chart_card.dart';
import 'package:grc_module/core/custom/charts/custom_donut_chart_card.dart';
import 'package:grc_module/core/custom/charts/custom_horizontal_bar_chart_card.dart';
import 'package:grc_module/core/custom/charts/custom_grouped_bar_chart_card.dart';
import 'package:grc_module/core/custom/charts/custom_attendance_tiles_card.dart';
import 'package:grc_module/core/custom/dropdowns/custom_multi_select_dropdown.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/core/custom/helpers/custom_haptic.dart';
import 'package:grc_module/core/custom/layout/custom_gridview_with_animation.dart';
import 'package:grc_module/core/custom/pickers/custom_date_pic.dart';
import 'package:grc_module/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:grc_module/core/custom/inputs/custom_comment_widget.dart';
import 'package:grc_module/core/custom/navigation/custom_navigate.dart';
import 'package:grc_module/core/custom/layout/custom_responsive.dart';
import 'package:grc_module/core/custom/cards/custom_approval_cycle.dart';
import 'package:grc_module/core/custom/cards/custom_module_info_card.dart';
import 'package:grc_module/core/custom/buttons/custom_button_sizing.dart';
import 'package:grc_module/core/custom/inputs/custom_validated_textfield.dart';
import 'package:grc_module/core/custom/dropdowns/custom_app_dropdown.dart';
import 'package:grc_module/core/custom/pickers/custom_image_picker.dart';
import 'package:grc_module/core/custom/buttons/custom_sort_button.dart';
import 'package:grc_module/core/custom/cards/custom_approval_shape.dart';
import 'package:grc_module/core/custom/dropdowns/custom_view_multi_select_dropdown.dart';
import 'package:grc_module/core/custom/navigation/custom_side_frame_master.dart';
import 'package:grc_module/core/custom/dialogs/custom_pop_up.dart';
import 'package:grc_module/core/custom/layout/custom_grid_view.dart';
import 'package:grc_module/core/custom/layout/custom_responsive_fields.dart';
import 'package:grc_module/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:grc_module/core/custom/inputs/default_switch_button.dart';
import 'package:grc_module/core/custom/pickers/custom_intl_phone_field.dart';
import 'package:grc_module/core/custom/pickers/custom_country_picker.dart';
import 'package:grc_module/core/custom/pickers/custom_color_picker.dart';
import 'package:grc_module/core/custom/helpers/custom_date_time_helper.dart';
import 'package:grc_module/core/custom/dialogs/custom_response_dialog.dart';
import 'package:grc_module/core/custom/dropdowns/custom_dropdown_button2.dart';
import 'package:grc_module/core/custom/layout/column_request_data.dart';
import 'package:grc_module/core/custom/dialogs/confirm_dialog.dart';
import 'package:grc_module/core/custom/layout/cross_axis_count_helper.dart';
import 'package:grc_module/core/custom/navigation/custom_appbar_mobile.dart';
import 'package:grc_module/core/custom/pickers/custom_calendar_picker.dart';
import 'package:grc_module/core/custom/cards/custom_stacked_avatars.dart';
import 'package:grc_module/core/custom/cards/custom_title_value_widget.dart';
import 'package:grc_module/core/custom/helpers/date_time_in_arabic.dart';
import 'package:grc_module/core/custom/dialogs/default_dialog.dart';
import 'package:grc_module/core/custom/layout/expanded_content.dart';
import 'package:grc_module/core/custom/navigation/filter_bar_item.dart';
import 'package:grc_module/core/custom/navigation/filters_appbar.dart';
import 'package:grc_module/core/custom/layout/hover_example.dart';
import 'package:grc_module/core/custom/cards/image_grid_card.dart';
import 'package:grc_module/core/custom/feedback/module_page_stubs.dart'
    as stubs;
import 'package:grc_module/core/custom/feedback/removed_module_placeholder.dart';
import 'package:grc_module/core/custom/layout/responsive_card_grid.dart';
import 'package:grc_module/core/custom/cards/stacked_avatars.dart';

import 'package:grc_module/core/theme/app_animations.dart';

part 'preview/preview_all_custom_page_builders.dart';
part 'preview/preview_all_custom_page_builders_2.dart';
part 'preview/preview_sections.dart';
part 'preview/preview_helper_sections.dart';
part 'preview/preview_keep_or_remove.dart';

///*************************** FILE INFO ****************************///
/// File Name: preview_all_custom.dart
/// Purpose: Gallery page demoing every widget in lib/core/custom/.

class PreviewAllCustomPage extends StatefulWidget {
  const PreviewAllCustomPage({super.key, this.keepOrRemove = false});

  /// true = only the unused customs and duplicate groups (decision page).
  final bool keepOrRemove;

  @override
  State<PreviewAllCustomPage> createState() => _PreviewAllCustomPageState();
}

class _PreviewAllCustomPageState extends State<PreviewAllCustomPage> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  // --- Demo state for the interactive widgets below ---
  String? _dropdownValue;
  DateTime? _dobValue;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  List<int> _multiSelectValues = [];
  bool _checkboxSelected = false;
  bool _checkboxSelected2 = true;
  String _filterSelectedKey = 'all';
  int _segmentedIndex = 0;
  int _pageTabIndex = 0;
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // --- state for the extended sections ---
  bool _switchOn = false;
  String? _dd2Value;
  String? _sortValue = 'name';
  List<String> _multiSelMaster = [];
  List<DateTime?> _calendarDates = [];
  Color _pickedColor = AppColors.primary;
  bool _filterBarSelected = true;
  final TextEditingController _validatedCtrl = TextEditingController();

  @override
  void dispose() {
    _textFieldController.dispose();
    _searchController.dispose();
    _validatedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _buildView(context);
}

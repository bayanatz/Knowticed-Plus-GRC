/// Module: knowledge_hub/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: filter_search_dialog.dart
/// Description: `FilterSearchDialog` widget, state and UI of the `FilterSearchDialog` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/filter_search_dialog_widgets/header.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/filter_search_dialog_widgets/action_buttons.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/filter_search_dialog_widgets/dropdowns.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/filter_publish_date_range.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

class FilterSearchDialog extends StatefulWidget {
  final List<DepartmentModelPro> departments;
  final bool isAdmin;

  const FilterSearchDialog({
    super.key,
    required this.departments,
    this.isAdmin = false,
  });

  @override
  State<FilterSearchDialog> createState() => _FilterSearchDialogState();
}

class _FilterSearchDialogState extends State<FilterSearchDialog> {
  String? owningDepartmentText;
  String? docType;

  // KH report p.5: one "Published Date" (a single day)
  // replaces the From/To pair, and Owning Status is removed.
  DateTime? publishedDate;

  List<Map<String, String>> departmentItems = const [];

  // Document type keys match your database exactly
  List<Map<String, String>> get docTypeItems {
    final items = [
      {'key': 'presentation', 'value': S.of(context).presentation},
      {'key': 'form', 'value': S.of(context).form},
      {'key': 'report', 'value': S.of(context).report},
      {'key': 'booklet', 'value': S.of(context).booklet},
      {'key': 'video_recording', 'value': S.of(context).video_recording},
      {'key': 'letter', 'value': S.of(context).letter},
      {'key': 'mandate', 'value': S.of(context).mandate},
      {'key': 'policy', 'value': S.of(context).policy},
      {'key': 'frame_work', 'value': S.of(context).framework},
      {'key': 'workshop', 'value': S.of(context).workshop},
      {'key': 'guidelines', 'value': S.of(context).guidelines},
      {'key': 'other', 'value': S.of(context).other},
    ];

    khLog(
      '📋 [FILTER DIALOG] Document type items: ${items.map((e) => e['key']).toList()}',
    );
    return items;
  }

  @override
  void initState() {
    super.initState();

    khLog('═══════════════════════════════════════');
    khLog('🔍 [FILTER DIALOG] Initializing');
    khLog('═══════════════════════════════════════');

    final cubit = context.read<CreateKnowledgeCubit>();

    // ✅ Get current filter values
    // Only a department applied FROM this dialog prefills it; a department
    // tab is not a dialog criterion (18/10/2026), so it is not shown here and
    // is not re-applied as one.
    owningDepartmentText = cubit.owningDepartmentFromFilterDialog
        ? cubit.selectedOwningDepartment
        : null;
    docType = cubit.selectedDocumentType;
    // Reopening the dialog shows the day that is actually applied.
    publishedDate = cubit.selectedPublishFromDate;

    khLog('📌 Initial Document Type: $docType');
    khLog('📌 Initial Department: $owningDepartmentText');
    khLog('📌 Initial Published Date: $publishedDate');

    khLog('═══════════════════════════════════════');
  }

  /// `Localizations.localeOf(context)` inside
  /// [_buildDepartmentItems] is an inherited-widget lookup, and doing one in
  /// `initState` throws ("dependOnInheritedWidgetOfExactType… was called
  /// before initState completed"). The throw was swallowed by the try/catch in
  /// [_buildDepartmentItems], which returned `[]` — so the Owning Department
  /// dropdown silently came up EMPTY on every open.
  ///
  /// `didChangeDependencies` runs right after `initState` with the inherited
  /// widgets available, and again whenever the locale changes — which is also
  /// what the department names need in order to follow an in-app language
  /// switch. Guarded so a rebuild for any other dependency does not rebuild
  /// the list for nothing.
  bool _departmentItemsBuilt = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_departmentItemsBuilt) return;
    _departmentItemsBuilt = true;

    departmentItems = _buildDepartmentItems();

    khLog('📊 Department Items Count: ${departmentItems.length}');
    khLog('📋 Department Items: $departmentItems');
    khLog('═══════════════════════════════════════');
  }

  /// {key: stored English name, value: name in the UI language}.
  List<Map<String, String>> _buildDepartmentItems() {
    return widget.departments.map((dept) {
      final String key = dept.departmentName ?? '';
      return {
        'key': key,
        'value': KhLocale.pick(
          context,
          en: key,
          ar: dept.departmentNameInArabic ?? '',
        ),
      };
    }).toList();
  }

  void _resetFilters() {
    khLog('🔄 [FILTER DIALOG] Reset filters');

    setState(() {
      owningDepartmentText = null;
      docType = null;
      publishedDate = null;
    });

    context.read<CreateKnowledgeCubit>().resetFilters();
    Navigator.of(context).pop();

    khLog('✅ [FILTER DIALOG] Filters reset and dialog closed');
  }

  void _applyFilters() {
    khLog('═══════════════════════════════════════');
    khLog('✅ [FILTER DIALOG] Applying filters');
    khLog('📌 Document Type: $docType');
    khLog('📌 Department: $owningDepartmentText');
    khLog('📌 Published Date: $publishedDate');
    khLog('═══════════════════════════════════════');

    context.read<CreateKnowledgeCubit>().applyFilters(
      documentType: docType,
      owningDepartment: owningDepartmentText,
      owningStatus: null,
      // One day: both ends of the cubit's range are that day (the cubit
      // widens `publishTo` to the end of the day).
      publishFrom: publishedDate,
      publishTo: publishedDate,
    );

    Navigator.of(context).pop();

    khLog('✅ [FILTER DIALOG] Filters applied and dialog closed');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    khLog(
      '🎨 [FILTER DIALOG] Building UI - isMobile: $isMobile, lightMode: $lightMode',
    );

    return Material(
      color: AppColors.transparent,
      child: Container(
        width: isMobile ? 350.w : 655.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.card,
        ),
        // Phones get 24.sp of breathing room on the
        // left/right so the dropdowns and the date fields stop running into
        // the dialog edge. Vertical padding and the tablet/desktop case are
        // unchanged.
        padding: isMobile
            ? EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.w)
            : EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildHeader(context, lightMode),
            SizedBox(height: 15.h),
            buildDropdowns(
              context,
              isMobile: isMobile,
              lightMode: lightMode,
              docType: docType,
              docTypeItems: docTypeItems,
              onDocTypeChanged: (val) {
                khLog(
                  '📄 [FILTER DIALOG] Document type changed: $docType → $val',
                );
                setState(() => docType = val);
              },
              publishedDateField: FilterPublishedDate(
                lightMode: lightMode,
                value: publishedDate,
                onChanged: (val) {
                  khLog(
                    '📅 [FILTER DIALOG] Published date changed: $publishedDate → $val',
                  );
                  setState(() => publishedDate = val);
                },
              ),
            ),
            SizedBox(height: 20.h),
            buildActionButtons(
              context,
              isMobile: isMobile,
              function: _resetFilters,
              onApplyClicked: _applyFilters,
            ),
          ],
        ),
      ),
    );
  }
}

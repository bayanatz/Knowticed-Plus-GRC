import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'dart:ui' as ui;

import 'package:knowticed_plus/core/custom/layout/fill_width_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:intl/intl.dart' as intl;
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/cards/custom_title_value_widget.dart';
import 'package:knowticed_plus/core/custom/navigation/filter_bar_item.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/utils/task_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/champions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions_sections.dart';

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/csv_helper.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/export_dialog.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/presentation/controller/qiyas_create_champion_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/control_core_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_core/presentation/controller/user_details_tasks_controller.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_pic.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class UserTasksSection extends StatefulWidget {
  const UserTasksSection({required this.isOwner, super.key});
  final bool isOwner;

  @override
  State<UserTasksSection> createState() => _UserTasksSectionState();
}

class _UserTasksSectionState extends State<UserTasksSection> {
  final List<EvidenceSubmissionStatus> statuses =
      EvidenceSubmissionStatus.values.toSet().toList();
  late QiyasCreateChampionControllerCubit controller;
  late bool isTablet;

  // ─── Table Style Helpers ───────────────────────────────────────────

  TextStyle get _headerStyle => StyleText.fontSize16Weight400;

  TextStyle get _cellStyle => StyleText.fontSize12Weight400;

  Widget _cell(Widget child, {EdgeInsets? padding}) {
    return Container(
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(
        style: _cellStyle,
        child: child,
      ),
    );
  }

  Widget _textCell(String text, {int maxLines = 2, TextStyle? style}) {
    return _cell(
      Text(
        text.isEmpty ? '-' : text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style ?? _cellStyle,
      ),
    );
  }

  /// Safely wraps a DataCell child — if the child is a Text widget
  /// with empty content, replaces it with '-'.
  Widget _safeCell(Widget child) {
    if (child is Text) {
      final content = child.data ?? '';
      if (content.trim().isEmpty) {
        return _textCell('-', maxLines: 2);
      }
    }
    return _cell(child);
  }

  // ─── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    isTablet = !kpIsPhoneLayout(context);
    controller =
        context.read<ControlCoreCubit>() as QiyasCreateChampionControllerCubit;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 15.sp,
        children: [
          // ── Filter Bar ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 30.sp,
              children: [
                for (EvidenceSubmissionStatus status in statuses)
                  FilterBarItem(
                    isSelected: controller.selectedStatus == status,
                    title: status.value,
                    color: status.color,
                    numberOfItems: (controller.selectedDocument == null)
                        ? (controller.tasks[status]?.length ?? 0)
                        : ((controller.tasks[status]?.length ?? 0) +
                            ((status == EvidenceSubmissionStatus.all ||
                                    status ==
                                        EvidenceSubmissionStatus.unCompleted)
                                ? 1
                                : 0)),
                    onTap: () {
                      controller.updateSelectedUserTaskStatus(status);
                    },
                  ),
              ],
            ),
          ),

          // ── Search + Filter + Export Row ──
          Row(
            spacing: ButtonSizing.toolbarGap(context),
            children: [
              AppSearchTextField(
                hintText: "بحث",
                controller: controller.tasksSearchController,
                onChanged: (value) {
                  controller.filterTasks();
                },
              ),
              customButtonWithSvg(
                width: isTablet ? 100 : 38,
                image:
                    "assets/icons_assets/main_icons_assets/ic_action_filter.svg",
                svgColor: AppColors.secondaryText,
                function: () {
                  showAppDialog<void>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return Dialog(
                        child: _filterContent(dialogContext),
                      );
                    },
                  );
                },
                title: isTablet ? 'الفرز' : '',
                color: AppColors.card,
                textStyle: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.blackButton)
                    .copyWith(
                      color: AppColors.secondaryText,
                    ),
                colorBorder: AppColors.transparent,
                widthImage: 20.sp,
                heightImage: 20.sp,
              ),
              if (Get.find<MainCoreEmployeeController>().isHasPermission(
                module: Modules.qiyas,
                permission: Champions.exportChampionTable,
                section: QiyasPermissionsSections.champions,
              ))
                customButtonWithSvg(
                  width: isTablet ? 100 : 38,
                  function: () {
                    showAppDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: ExportDialog(
                            onDownloadFile: (String fileName) {
                              showLoadingIndicator();
                              CSVHelper()
                                  .exportToCSV(
                                      controller.exportTasksToExcel(), fileName)
                                  .then((_) {
                                hideLoadingIndicator();
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                  title: isTablet ? "تصدير" : '',
                  image:
                      "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                  color: AppColors.primary,
                  colorBorder: AppColors.transparent,
                  widthImage: 20.sp,
                  heightImage: 20.sp,
                  svgColor: AppColors.textButton,
                  // 22/10/2026 — Owner: toolbar text is 14 medium (500) in every module.
                  textStyle: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.textButton),
                ),
            ],
          ),

          // ── Tablet: Raw Table ──
          if (isTablet) _buildRawTable(context),

          // ── Mobile: Card Layout ──
          if (!isTablet) _buildMobileCards(context),
        ],
      ),
    );
  }

  // ─── Raw Table (replaces CustomTable / DataTable) ──────────────────

  Widget _buildRawTable(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    bool isArabic = Get.locale?.languageCode == 'ar';

    // ── Extract columns & rows from existing controller methods ──
    final dataColumns = controller.getUserDetailsTasksColumns(widget.isOwner);
    final dataRows = controller.getUserDetailsTasksRows(widget.isOwner);

    // Total columns = 1 (No. column) + dataColumns.length
    final totalColumns = 1 + dataColumns.length;

    // ── Column Widths ──
    final Map<int, TableColumnWidth> columnWidths = {};
    columnWidths[0] = FixedColumnWidth(60.sp); // رقم
    for (int i = 1; i < totalColumns; i++) {
      columnWidths[i] = const IntrinsicColumnWidth(flex: 1);
    }

    // ── Header labels ──
    final headerWidgets = <Widget>[
      Padding(
        padding: EdgeInsets.all(10.sp),
        child: Text(
          isArabic ? 'رقم' : 'رقم',
          style: _headerStyle,
          maxLines: 1,
          textAlign: TextAlign.start,
        ),
      ),
      ...dataColumns.map(
        (dc) => Padding(
          padding: EdgeInsets.all(10.sp),
          child: DefaultTextStyle.merge(
            style: _headerStyle,
            child: dc.label,
          ),
        ),
      ),
    ];

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      // Owner 21/10/2026: full width, equal column shares (No stays narrow); scrolls when the columns cannot fit.
      child: FillWidthHorizontalScroll(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: AnimatedSizeWrap(
              child: Table(
            border: TableBorder.all(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: fillColumnWidths(columnWidths),
            children: [
              // ── Header Row ──
              TableRow(
                decoration: BoxDecoration(
                  color: isLight ? Colors.black : Colors.black45,
                ),
                children: headerWidgets,
              ),

              // ── Data Rows ──
              ...List.generate(dataRows.length, (index) {
                final dataRow = dataRows[index];
                final isEven = index.isEven;
                final rowColor = isLight
                    ? (isEven ? const Color(0xFFF7F8FA) : Colors.white)
                    : (isEven ? const Color(0xFF1E1F24) : Colors.black);

                // Build cells: No. column + extracted DataCell children
                final cells = <Widget>[
                  _textCell(
                    isArabic
                        ? '${index + 1}'.replaceAllMapped(
                            RegExp(r'[0-9]'),
                            (m) => String.fromCharCode(
                                m[0]!.codeUnitAt(0) + 0x0630),
                          )
                        : '${index + 1}',
                    maxLines: 1,
                  ),
                  ...dataRow.cells.map(
                    (dataCell) => _safeCell(dataCell.child),
                  ),
                ];

                return TableRow(
                  decoration: BoxDecoration(color: rowColor),
                  children: cells,
                );
              }),
            ],
          )),
        ),
      ),
    );
  }

  // ─── Mobile Cards ──────────────────────────────────────────────────

  Widget _buildMobileCards(BuildContext context) {
    return Column(
      spacing: 15.sp,
      children: [
        for (int index = 0; index < controller.filteredTasks.length; index++)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.all(15.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15.sp,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTitleValueWidget(
                      titleStyle: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.secondaryBlack),
                      valueStyle: StyleText.fontSize12Weight400,
                      title: 'معرف التقديم',
                      value: '-',
                    ),
                    if (controller.selectedStatus ==
                        EvidenceSubmissionStatus.all)
                      CustomTitleValueWidget(
                        titleStyle: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.secondaryBlack),
                        valueStyle: StyleText.fontSize12Weight400.copyWith(
                          color: controller
                              .filteredTasks[index].submissionStatus.color,
                        ),
                        title: 'حالة الإعتماد',
                        value: controller
                            .filteredTasks[index].submissionStatus.value,
                      ),
                  ],
                ),
                CustomTitleValueWidget(
                  titleStyle: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryBlack),
                  valueStyle: StyleText.fontSize12Weight400,
                  title: 'تاريخ تقديم المستند',
                  value: controller.filteredTasks[index].submissionDate != null
                      ? intl.DateFormat('dd MMM yyyy', 'ar').format(
                          controller.filteredTasks[index].submissionDate!
                              .toDate(),
                        )
                      : '-',
                ),
                Row(
                  spacing: 6.sp,
                  children: [
                    Text(
                      'مالك المعيار:',
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.secondaryBlack),
                    ),
                    if (controller.filteredTasks[index].approvedBy != null)
                      CircleAvatar(
                        radius: 15.sp,
                        backgroundImage: !TaskHelper()
                                .getChampionImage(
                                    controller.filteredTasks[index].approvedBy!)
                                .contains('http')
                            ? appImageProvider(TaskHelper().getChampionImage(
                                controller.filteredTasks[index].approvedBy!))
                            : NetworkImage(TaskHelper().getChampionImage(
                                controller.filteredTasks[index]
                                    .approvedBy!)) as ImageProvider,
                      ),
                    Text(
                      controller.filteredTasks[index].approvedBy != null
                          ? TaskHelper().getChampionName(
                              controller.filteredTasks[index].submittedBy!)
                          : '-',
                      style: StyleText.fontSize12Weight400,
                    ),
                  ],
                ),
                CustomTitleValueWidget(
                  titleStyle: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryBlack),
                  valueStyle: StyleText.fontSize12Weight400,
                  title: 'تاريخ مراجعة المستند',
                  value: controller.filteredTasks[index].approvedDate != null
                      ? intl.DateFormat('dd MMM yyyy', 'ar').format(
                          controller.filteredTasks[index].approvedDate!
                              .toDate(),
                        )
                      : '-',
                ),
              ],
            ),
          ),
        SizedBox(height: 15.sp),
      ],
    );
  }

  // ─── Filter Dialog Content ─────────────────────────────────────────

  Widget _filterContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.sp),
      width: isTablet ? 360.w : 300.w,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          spacing: 20.sp,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title) — was a hand-rolled 18./16./16. row.
            CustomDialogHeader(
                title: "فرز",
                icon:
                    "assets/icons_assets/main_icons_assets/ic_action_sort.svg"),
            CustomTextField(
              controller: controller.filterDateTextController,
              readOnly: true,
              onTap: () async {
                List<DateTime?> selectedDates = [];
                final List<DateTime?>? picked =
                    await DatePicker().showDatePicker(
                  context,
                  selectedDates,
                  DateTime.now(),
                  CalendarDatePicker2Type.single,
                );
                if (picked != null) {
                  selectedDates = picked;
                  controller.filterDate = picked[0];
                  controller.filterDateTextController.text =
                      intl.DateFormat('d MMMM y', 'ar').format(picked[0]!);
                }
              },
              suffixIcon: SvgPicture.asset(
                "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
                height: 20.sp,
                width: 20.sp,
              ),
              label: 'الوقت',
              hint: 'اختار الوقت',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customButton(
                  title: 'إعادة',
                  color: AppColors.secondaryButton,
                  function: () {
                    Navigator.pop(context);
                    controller.filterDate = null;
                    controller.filterDateTextController.clear();
                    controller.filterTasks();
                  },
                  textStyle: StyleText.fontSize16Weight500,
                  width: isTablet ? 150 : 130,
                ),
                customButton(
                  title: 'تطبيق',
                  function: () {
                    controller.filterTasks();
                    Navigator.pop(context);
                  },
                  width: isTablet ? 150 : 130,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

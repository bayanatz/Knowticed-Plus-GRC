/// Module: GRC Policy Management
/// Description: Read-only "view mode" body of the Policy Details page —
///              info card, owner section, documents, and the Controls list
///              with its status filter bar, search box, and add/bulk-upload
///              menu.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-18
/// Dependencies: Flutter SDK, AppColors, AppTheme, CardStyles, ControlEntity,
///               GrcOwnerSection, ControlCardWidget, FilterBarItem
library;

import 'package:demo_app/core/custom/22-custom_uploaded_document_card.dart';
import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/custom/5-custom_button.dart';
import 'package:demo_app/core/custom/6_custom_button_with_svg.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/add_edit_control_page.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_details_page.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_page.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/control_card_widget.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_document_info.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_document_preview_widget.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/widgets/policy_details_widget/grc_owner_badge.dart';
import 'package:demo_app/features/roles/widgets/filter_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// class name: [PolicyViewModeWidget]
///
/// purpose: renders the "Policy Details" read-only view — info rows, owner
///          section, documents, and the filterable/searchable Controls
///          list. Owns the controls-toolbar UI state (status filter, search
///          text, add/bulk-upload dropdown) since none of it is needed
///          outside view mode.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 18/7/2026
class PolicyViewModeWidget extends StatefulWidget {
  final PolicyEntity policy;
  final GRCModuleEntity module;
  final List<ControlEntity> controls;
  final bool isArabic;
  final DateFormat dateFormat;
  final ValueChanged<ControlEntity?> onControlTap;
  final VoidCallback onBulkUpload;
  final VoidCallback onControlsChanged;

  const PolicyViewModeWidget({
    super.key,
    required this.policy,
    required this.module,
    required this.controls,
    required this.isArabic,
    required this.dateFormat,
    required this.onControlTap,
    required this.onBulkUpload,
    required this.onControlsChanged,
  });

  @override
  State<PolicyViewModeWidget> createState() => _PolicyViewModeWidgetState();
}

class _PolicyViewModeWidgetState extends State<PolicyViewModeWidget> {
  String _selectedControlStatusFilter = 'all';
  final _controlSearchController = TextEditingController();
  bool _showControlMenu = false;

  @override
  void dispose() {
    _controlSearchController.dispose();
    super.dispose();
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text.rich(
        TextSpan(
          text: '$label ',
          style: CardStyles.label(14),
          children: [TextSpan(text: value, style: CardStyles.value(14))],
        ),
      ),
    );
  }

  ControlStatus? _statusForControlKey(String key) {
    switch (key) {
      case 'Active':
        return ControlStatus.active;
      case 'Inactive':
        return ControlStatus.inactive;
      case 'Scheduled':
        return ControlStatus.scheduled;
      case 'Expired':
        return ControlStatus.expired;
      case 'Unassigned':
        return ControlStatus.unassigned;
      case 'Draft':
        return ControlStatus.draft;
      default:
        return null;
    }
  }

  List<ControlEntity> _applyControlStatusFilter(List<ControlEntity> controls) {
    final status = _statusForControlKey(_selectedControlStatusFilter);
    if (status == null) return controls;
    return controls.where((c) => c.status == status).toList();
  }

  /// Applies both the status chip filter and the search box text on top of
  /// the raw controls list. Kept as a single entry point so the rest of the
  /// UI never has to call two filter functions in the right order.
  ///
  /// NOTE: this assumes [ControlEntity] exposes `controlNameEn` /
  /// `controlNameAr`, mirroring the `policyNameEn` / `policyNameAr` naming
  /// convention used everywhere else in this codebase. If the real field
  /// names differ, update the two references below.
  List<ControlEntity> _visibleControls() {
    final byStatus = _applyControlStatusFilter(widget.controls);
    final query = _controlSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return byStatus;
    return byStatus.where((c) {
      final nameEn = c.controlsNameEn.toLowerCase();
      final nameAr = c.controlsNameAr.toLowerCase();
      return nameEn.contains(query) || nameAr.contains(query);
    }).toList();
  }

  Map<String, int> _countControlsByStatus(List<ControlEntity> controls) {
    return {
      'all': controls.length,
      'Active': controls.where((c) => c.status == ControlStatus.active).length,
      'Inactive':
          controls.where((c) => c.status == ControlStatus.inactive).length,
      'Scheduled':
          controls.where((c) => c.status == ControlStatus.scheduled).length,
      'Expired':
          controls.where((c) => c.status == ControlStatus.expired).length,
      'Unassigned':
          controls.where((c) => c.status == ControlStatus.unassigned).length,
      'Draft': controls.where((c) => c.status == ControlStatus.draft).length,
    };
  }

  List<MapEntry<String, Map<String, dynamic>>> _controlStatusEntries(
      List<ControlEntity> controls) {
    final counts = _countControlsByStatus(controls);
    return [
      MapEntry('all', {'num': counts['all'] ?? 0, 'color': AppColors.text}),
      MapEntry(
          'Active', {'num': counts['Active'] ?? 0, 'color': AppColors.green}),
      MapEntry('Inactive',
          {'num': counts['Inactive'] ?? 0, 'color': AppColors.orange}),
      MapEntry('Scheduled',
          {'num': counts['Scheduled'] ?? 0, 'color': AppColors.primary}),
      MapEntry(
          'Expired', {'num': counts['Expired'] ?? 0, 'color': AppColors.red}),
      MapEntry('Unassigned',
          {'num': counts['Unassigned'] ?? 0, 'color': AppColors.blue}),
      MapEntry(
          'Draft', {'num': counts['Draft'] ?? 0, 'color': AppColors.colorGrey}),
    ];
  }

  /// Sum of every non-Draft control's weight — Draft controls haven't been
  /// published yet, so they don't count toward the total. Shown next to
  /// the "Control Weight Issue" banner so an out-of-balance policy
  /// (controls that don't add up to 100) is obvious at a glance.
  ///
  /// NOTE: assumes [ControlEntity.controlWeight] exists, mirroring
  /// [PolicyEntity.policyWeight]. Adjust the field name if different.
  double _totalControlWeight(List<ControlEntity> controls) => controls
      .where((c) => c.status != ControlStatus.draft)
      .fold<double>(0, (sum, c) => sum + c.controlsWeight);

  bool _hasControlWeightIssue(List<ControlEntity> controls) {
    final counted = controls.where((c) => c.status != ControlStatus.draft);
    return counted.isNotEmpty && _totalControlWeight(controls) != 100;
  }

  /// Policy Number on the left, Last Edit date on the right — matches the
  /// top row of the "Policy Details" card in the design.
  Widget _buildNumberAndLastEditRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _infoRow(
            'Policy Number:'.tr,
            widget.isArabic
                ? widget.policy.policyNumberAr
                : widget.policy.policyNumberEn,
          ),
        ),
        _infoRow(
          'Last Edit:'.tr,
          widget.dateFormat.format(widget.policy.lastModifiedDate),
        ),
      ],
    );
  }

  /// Weight / Start Date / End Date shown together on one row.
  Widget _buildWeightAndDatesRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _infoRow(
            'Policy Weight:'.tr,
            widget.policy.policyWeight.toStringAsFixed(0),
          ),
        ),
        Expanded(
          child: _infoRow(
            'Start Date:'.tr,
            widget.dateFormat.format(widget.policy.startDate),
          ),
        ),
        Expanded(
          child: _infoRow(
            'End Date:'.tr,
            // Falls back to "-" if the policy has no end date, matching
            // the design mock.
            widget.dateFormat.format(widget.policy.endDate),
          ),
        ),
      ],
    );
  }

  /// English/Arabic policy documents rendered as two side-by-side cards.
  Widget _buildDocumentsRow() {
    final hasEn = widget.policy.policyDocumentEn != null;
    final hasAr = widget.policy.policyDocumentAr != null;
    if (!hasEn && !hasAr) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasEn)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.border),
              ),
              child: ProductWarrantyCard(
                fileName: widget.policy.policyDocumentEn!.split('/').last,
                date: widget.dateFormat.format(widget.policy.lastModifiedDate),
              ),
            ),
          ),
        if (hasEn && hasAr) SizedBox(width: 12.w),
        if (hasAr)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.border),
              ),
              child: ProductWarrantyCard(
                fileName: widget.policy.policyDocumentAr!.split('/').last,
                date: widget.dateFormat.format(widget.policy.lastModifiedDate),
              ),
            ),
          ),
      ],
    );
  }

  /// Search box + the "Control" button. The button toggles a small dropdown
  /// with "Add Control" and "Bulk Upload" actions, per the design.
  Widget _buildControlsToolbar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppSearchTextField(
            onChanged: (v) {
              setState(() {
                _controlSearchController.text = v;
              });
            },
            hintText: "Search".tr,
            controller: _controlSearchController,
          ),
        ),
        SizedBox(width: 12.w),
        _buildControlAddButton(),
      ],
    );
  }

  Widget _buildControlAddButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        customButtonWithSvg(
          colorBorder: AppColors.primary,
          space: 10.w,
          radius: 8.r,
          widthImage: 16.w,
          heightImage: 16.h,
          function: () => setState(() => _showControlMenu = !_showControlMenu),
          title: 'Control'.tr,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
          image: 'assets/icons_assets/database_builder_assets/plus_head.svg',
          color: AppColors.primary,
          svgColor: AppColors.textButton,
        ),
        if (_showControlMenu)
          Container(
            margin: EdgeInsets.only(top: 4.h),
            width: 160.w,
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _controlMenuItem(
                  'Add Control'.tr,
                  () {
                    setState(() => _showControlMenu = false);
                    widget.onControlTap(null);
                  },
                ),
                Divider(height: 1, color: AppColors.border),
                _controlMenuItem(
                  'Bulk Upload'.tr,
                  () {
                    setState(() => _showControlMenu = false);
                    widget.onBulkUpload();
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _controlMenuItem(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
      ),
    );
  }

  Widget _buildWeightIssueBanner(List<ControlEntity> controls) {
    if (!_hasControlWeightIssue(controls)) return const SizedBox.shrink();
    return customButton(
      title: 'Control Weight Issue'.tr,
      function: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ControlWeightIssuePage(
            module: widget.module,
            policy: widget.policy,
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      height: 38.h,
      color: AppColors.primary,
      textStyle:
          StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
    );
  }

  Future<void> _openControlDetails(ControlEntity control) async {
    if (control.status == ControlStatus.draft) {
      await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => AddEditControlPage(
            moduleId: widget.module.moduleId,
            policyId: widget.policy.id,
            existingControl: control,
            siblingControls: widget.controls,
            policyStartDate: widget.policy.startDate,
            policyEndDate: widget.policy.endDate,
            policyHasArabic: widget.policy.policyNameAr.trim().isNotEmpty ||
                widget.policy.policyNumberAr.trim().isNotEmpty ||
                widget.policy.policyDescriptionAr.trim().isNotEmpty,
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ControlDetailsPage(
            module: widget.module,
            policy: widget.policy,
            control: control,
            siblingControls: widget.controls,
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
    widget.onControlsChanged();
  }

  /// Renders the visible controls as a single column on phones, and as a
  /// 2-column grid on tablets/desktop — matching the design mock.
  Widget _buildControlsList(List<ControlEntity> controls) {
    if (controls.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(
            'No Controls found'.tr,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    final isWide = MediaQuery.of(context).size.shortestSide >= 600;
    if (!isWide) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controls.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, index) => ControlCardWidget(
          control: controls[index],
          onTap: () => _openControlDetails(controls[index]),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < controls.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ControlCardWidget(
                    control: controls[i],
                    onTap: () => _openControlDetails(controls[i]),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: i + 1 < controls.length
                      ? ControlCardWidget(
                          control: controls[i + 1],
                          onTap: () => _openControlDetails(controls[i + 1]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleControls = _visibleControls();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
     
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNumberAndLastEditRow(),
              Text(
                'Policy Description'.tr,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.secondaryText),
              ),
              Text(
                widget.isArabic
                    ? widget.policy.policyDescriptionAr
                    : widget.policy.policyDescriptionEn,
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.secondaryText),
              ),
              SizedBox(height: 10.h),
              GrcOwnerBadge(
                ownerEmails: widget.module.moduleOwners,
                onMessageTap: (owner) {},
              ),
              SizedBox(height: 10.h),
              _buildWeightAndDatesRow(),
              if (widget.policy.policyDocumentEn != null ||
                  widget.policy.policyDocumentAr != null)
                SizedBox(height: 10.h),
              _buildDocumentsRow(),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 24.sp,
              children: [
                for (final entry in _controlStatusEntries(widget.controls))
                  FilterBarItem(
                    title: entry.key,
                    numberOfItems: entry.value['num'],
                    color: entry.value['color'],
                    isSelected: entry.key == _selectedControlStatusFilter,
                    onTap: () => setState(
                        () => _selectedControlStatusFilter = entry.key),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        _buildControlsToolbar(),
        SizedBox(height: 12.h),
        _buildWeightIssueBanner(widget.controls),
        SizedBox(height: 12.h),
        _buildControlsList(visibleControls),
      ],
    );
  }
}

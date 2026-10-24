/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_sections_list.dart
/// Purpose: The left-hand list of Notification Control, split into titled
///          section cards (Figma: "Request Status", "Module Status", …).
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Owner 22/10/2026: "every category has its own notifications" — one card
/// per `NotificationEvent.group`, its title above it. Cards are 16 apart
/// (R-4) and the space inside a card is equal on every side (R-11).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/notification_control.dart';

class NotificationSectionsList extends StatefulWidget {
  const NotificationSectionsList({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    this.shrinkWrap = false,
    this.firstTitleHeight,
    this.showStatus = true,
  });

  final List<NotificationItem> items;
  final int? selectedIndex;

  /// Called with the row's index in [items].
  final ValueChanged<int> onSelect;

  /// Phone: the list sits inside a page that scrolls.
  final bool shrinkWrap;

  /// Tablet: the first title sits at the bottom of a box this tall — the
  /// Edit row's height — so the first card lines up with the editor.
  final double? firstTitleHeight;

  /// Figma edit mode lists names only: no status dot, no channel icons.
  final bool showStatus;

  @override
  State<NotificationSectionsList> createState() =>
      _NotificationSectionsListState();
}

class _NotificationSectionsListState extends State<NotificationSectionsList> {
  /// Sections the user hid (by group key). Each section's title row carries a
  /// blue underlined Hide / Show link (Moataz 23/10/2026, every module).
  final Set<String> _hidden = <String>{};

  List<NotificationItem> get items => widget.items;
  int? get selectedIndex => widget.selectedIndex;
  ValueChanged<int> get onSelect => widget.onSelect;
  bool get shrinkWrap => widget.shrinkWrap;
  double? get firstTitleHeight => widget.firstTitleHeight;
  bool get showStatus => widget.showStatus;

  /// The section title with its Hide / Show link at the end of the same row.
  Widget _titleRow(String key, bool isArabic) {
    final S s = S.of(context);
    final bool hidden = _hidden.contains(key);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            notificationGroupLabel(key, isArabic: isArabic),
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => HapticController.low(),
          onTap: () => setState(() {
            if (!_hidden.remove(key)) _hidden.add(key);
          }),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2.sp),
            // Blue text with its own 1-high line 3 below it: the same look as
            // the page's "Hide Toggle Panel" link.
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    hidden ? s.show : s.hide,
                    // 23/10/2026 (Moataz): smaller than the section title (14)
                    // beside it, so the link reads as secondary.
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: AppColors.blue),
                  ),
                  SizedBox(height: 1.5.h),
                  Container(height: 1.h, color: AppColors.blue),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Sections in order of first appearance; each keeps its rows' indices.
    final Map<String, List<int>> sections = <String, List<int>>{};
    for (int i = 0; i < items.length; i++) {
      sections.putIfAbsent(items[i].group, () => <int>[]).add(i);
    }
    final List<MapEntry<String, List<int>>> entries = sections.entries.toList();

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      itemCount: entries.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.sp),
      itemBuilder: (BuildContext context, int s) {
        final MapEntry<String, List<int>> section = entries[s];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (s == 0 && firstTitleHeight != null)
              SizedBox(
                height: firstTitleHeight,
                child: Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: _titleRow(section.key, isArabic),
                ),
              )
            else if (section.key.isNotEmpty)
              _titleRow(section.key, isArabic),
            if (section.key.isNotEmpty || (s == 0 && firstTitleHeight != null))
              SizedBox(height: 8.sp),
            if (!_hidden.contains(section.key))
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: <Widget>[
                    for (int k = 0; k < section.value.length; k++) ...<Widget>[
                      if (k > 0) SizedBox(height: 4.sp),
                      _NotificationRow(
                        showStatus: showStatus,
                        item: items[section.value[k]],
                        selected: selectedIndex == section.value[k],
                        onTap: () {
                          HapticController
                              .low(); // list row: on the tap (X-117)
                          onSelect(section.value[k]);
                        },
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.showStatus,
  });

  final bool showStatus;
  final NotificationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 23/10/2026 (Moataz): the selected row is a translucent primary, so text
    // and icons keep their normal colours (they read on it in both themes).
    final Color? iconColor = null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                item.title,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
            ),
            if (showStatus) ...<Widget>[
              SizedBox(width: 12.sp),
              Container(
                width: 12.sp,
                height: 12.sp,
                decoration: BoxDecoration(
                  color:
                      item.isEnabled ? AppColors.statusApproved : AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.sp),
              // Fixed slots, so the icons line up from row to row (R-11).
              SizedBox(
                width: 20.sp,
                child: item.hasEmail
                    ? CustomSvgImage(
                        assetPath:
                            "assets/icons_assets/notification_assets/ic_comms_email_at.svg",
                        width: 20.sp,
                        height: 20.sp,
                        color: iconColor,
                      )
                    : null,
              ),
              SizedBox(width: 8.sp),
              SizedBox(
                width: 20.sp,
                child: item.hasPush
                    ? CustomSvgImage(
                        assetPath:
                            "assets/icons_assets/notification_assets/ic_comms_notification_phone.svg",
                        width: 20.sp,
                        height: 20.sp,
                        color: iconColor,
                      )
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Section title in the viewer's language. The group names are the English
/// keys stored on each event; a name missing here shows in English.
String notificationGroupLabel(String group, {required bool isArabic}) {
  if (!isArabic) return group;
  return _groupArabic[group] ?? group;
}

const Map<String, String> _groupArabic = <String, String>{
  // Knowledge Hub
  'Review & Approval': 'المراجعة والاعتماد',
  'Publishing & Validity': 'النشر والصلاحية',
  'Inquiries': 'الاستفسارات',
  // Database
  'Databases & Tables': 'قواعد البيانات والجداول',
  'Access & Permissions': 'الوصول والصلاحيات',
  'Comments': 'التعليقات',
  // Messages
  'Messages': 'الرسائل',
  'Groups': 'المجموعات',
  'Polls': 'التصويت',
  // Notification Control
  'Status & Templates': 'الحالة والقوالب',
  'Channels': 'القنوات',
  // To-Do
  'Reminders': 'التذكيرات',
  'Due & Overdue': 'الاستحقاق والتأخير',
  // Qiyas
  'Setup': 'الإعداد',
  'Champions': 'الأبطال',
  'Evidence & Review': 'الأدلة والمراجعة',
  // Services
  'Request Status': 'حالة الطلب',
  'Approver': 'المعتمِد',
  'Service Provider': 'مقدم الخدمة',
  // Time Tracker
  'Attendance': 'الحضور',
  'Breaks': 'الاستراحات',
  'Shifts & Locations': 'الورديات والمواقع',
  'Requests & Approvals': 'الطلبات والموافقات',
  // User Access / User Management
  'Activation': 'التفعيل',
  'Scheduled Changes': 'التغييرات المجدولة',
  'Lock & Unlock': 'القفل وفك القفل',
  'Access': 'الوصول',
  // Role Management
  'Roles': 'الأدوار',
  // GRC
  'Modules': 'الوحدات',
  'Policy & Control': 'السياسات والضوابط',
  'Assignment Controls & Approvals & Audit':
      'إسناد الضوابط والموافقات والتدقيق',
  'Add Champion Officers & Assign Controls To Their Compliance Officers':
      'تعيين الأبطال وإسناد الضوابط لمسؤولي الامتثال',
  // Settings
  'Comment & Feedback': 'التعليقات والملاحظات',
  'Company Information': 'معلومات الشركة',
  'Emergency Contact': 'جهة اتصال الطوارئ',
  'Health Insurance': 'التأمين الصحي',
  'Personal Information': 'المعلومات الشخصية',
  'Social Information': 'المعلومات الاجتماعية',
  // Form Builder
  'Form Access': 'الوصول إلى النماذج',
  'Form Updates': 'تحديثات النماذج',
  'Responses': 'الردود',
};

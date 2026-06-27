import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/features/notification/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/features/notification/core_widgets/grc/custom_button_with_image.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/grc/core/widgets/svg_custom.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:demo_app/features/notification/data/repository/notification_template_service.dart';

import 'package:demo_app/features/notification/core_widgets/main_widget/text_single_field.dart';
import '../../../generated/l10n.dart';
// REMOVED_MODULE: import '../../../external/qiyas/core/widgets/multi_select_dropdown_widget.dart';
// REMOVED_MODULE: import '../../../external/grc/core/widgets/custom_botton.dart';
import 'package:demo_app/features/notification/core_widgets/main_widget/custom_button_widget.dart';
import '../../../core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
// REMOVED_MODULE: import '../../../external/todo_module/core/components/other_components/flutter_switch.dart';
import '../data/models/notification_modle.dart';
import '../notification_control.dart';

class NotificationEditPage extends StatefulWidget {
  final NotificationItem notificationItem;
  final String moduleName;
  final NotificationTab currentTab;

  const NotificationEditPage({
    super.key,
    required this.notificationItem,
    required this.moduleName,
    required this.currentTab,
  });

  @override
  State<NotificationEditPage> createState() => _NotificationEditPageState();
}

class _NotificationEditPageState extends State<NotificationEditPage> {
  bool isSaving = false;
  bool isLoadingTemplate = true;
  bool isNotificationEnabled = true;

  List<String> selectedNotificationTypes = [];

  TextEditingController subjectEn = TextEditingController();
  TextEditingController subjectAr = TextEditingController();
  TextEditingController bodyArController = TextEditingController();
  TextEditingController bodyEnController = TextEditingController();

  NotificationTemplateModel? currentTemplate;
  final NotificationTemplateService _templateService = NotificationTemplateService();

  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }

  @override
  void dispose() {
    subjectEn.dispose();
    subjectAr.dispose();
    bodyArController.dispose();
    bodyEnController.dispose();
    super.dispose();
  }

  // ✅ Load template from Firebase
  Future<void> _loadTemplate() async {
    setState(() {
      isLoadingTemplate = true;
    });

    print('');
    print('═══════════════════════════════════════════════════');
    print('🔍 Loading template: ${widget.moduleName} - ${widget.notificationItem.eventType}');
    print('═══════════════════════════════════════════════════');

    NotificationTemplateModel? template = await _templateService.getTemplate(
      module: widget.moduleName,
      eventType: widget.notificationItem.eventType,
    );

    if (template != null) {
      print('✅ Template loaded from Firebase');

      setState(() {
        currentTemplate = template;
        isNotificationEnabled = template.isEnabled;
        selectedNotificationTypes = List.from(template.selectedNotificationTypes);

        subjectEn.text = template.subjectEnglish;
        subjectAr.text = template.subjectArabic;
        bodyEnController.text = template.bodyEnglish;
        bodyArController.text = template.bodyArabic;

        isLoadingTemplate = false;
      });
    } else {
      print('⚠️ No template found, using defaults');
      setState(() {
        isNotificationEnabled = widget.notificationItem.isEnabled;
        if (widget.notificationItem.hasEmail) {
          selectedNotificationTypes.add('email');
        }
        if (widget.notificationItem.hasPush) {
          selectedNotificationTypes.add('push');
        }
        isLoadingTemplate = false;
      });
    }

    print('═══════════════════════════════════════════════════');
    print('');
  }

  // ✅ Save template to Firestore
  Future<void> _saveTemplate() async {
    if (subjectEn.text.trim().isEmpty ||
        subjectAr.text.trim().isEmpty ||
        bodyEnController.text.trim().isEmpty ||
        bodyArController.text.trim().isEmpty) {
      final isRTL = Directionality.of(context) == TextDirection.rtl;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL
                ? "يرجى ملء جميع الحقول"
                : "Please fill all fields",
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final templateToSave = currentTemplate?.copyWith(
      subjectEnglish: subjectEn.text.trim(),
      subjectArabic: subjectAr.text.trim(),
      bodyEnglish: bodyEnController.text.trim(),
      bodyArabic: bodyArController.text.trim(),
      isEnabled: isNotificationEnabled,
      selectedNotificationTypes: selectedNotificationTypes,
      updatedAt: DateTime.now(),
    ) ?? NotificationTemplateModel(
      id: '${widget.moduleName}_${widget.notificationItem.eventType}',
      module: widget.moduleName,
      eventType: widget.notificationItem.eventType,
      subjectEnglish: subjectEn.text.trim(),
      subjectArabic: subjectAr.text.trim(),
      bodyEnglish: bodyEnController.text.trim(),
      bodyArabic: bodyArController.text.trim(),
      isEnabled: isNotificationEnabled,
      selectedNotificationTypes: selectedNotificationTypes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await _templateService.saveTemplate(templateToSave);

    setState(() {
      isSaving = false;
    });

    final isRTL = Directionality.of(context) == TextDirection.rtl;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL ? "تم الحفظ بنجاح" : "Saved successfully",
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL ? "فشل الحفظ" : "Failed to save",
          ),
        ),
      );
    }
  }

  // ✅ Reset to default
  Future<void> _resetToDefault() async {
    final success = await _templateService.resetToDefault(
      module: widget.moduleName,
      eventType: widget.notificationItem.eventType,
    );

    final isRTL = Directionality.of(context) == TextDirection.rtl;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL ? "تم إعادة التعيين بنجاح" : "Reset successfully",
          ),
        ),
      );
      await _loadTemplate();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL ? "فشل إعادة التعيين" : "Failed to reset",
          ),
        ),
      );
    }
  }

  // ✅ Show preview dialog
  void _showPreviewDialog(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? "معاينة الإشعار" : "Notification Preview"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? "العنوان:" : "Subject:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(isArabic ? subjectAr.text : subjectEn.text),
            SizedBox(height: 16),
            Text(
              isArabic ? "النص:" : "Body:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(isArabic ? bodyArController.text : bodyEnController.text),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isArabic
                    ? "ملاحظة: سيتم استبدال المتغيرات مثل {{serviceName}} بالقيم الفعلية عند إرسال الإشعار"
                    : "Note: Variables like {{serviceName}} will be replaced with actual values when sending notifications",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? "إغلاق" : "Close"),
          ),
        ],
      ),
    );
  }

  // ✅ Get variables hint text for ALL modules
  String _getVariablesHintText(bool isRTL) {
    switch (widget.currentTab) {
      // case NotificationTab.home:
      //   return isRTL
      //       ? "المتغيرات المتاحة: {{systemName}}, {{updateVersion}}"
      //       : "Available variables: {{systemName}}, {{updateVersion}}";

      case NotificationTab.employees:
        return isRTL
            ? "المتغيرات المتاحة: {{employeeName}}, {{departmentName}}, {{jobTitle}}"
            : "Available variables: {{employeeName}}, {{departmentName}}, {{jobTitle}}";

      case NotificationTab.services:
        switch (widget.notificationItem.eventType) {
          case 'request_submitted':
            return isRTL
                ? "المتغيرات المتاحة: {{serviceName}}"
                : "Available variables: {{serviceName}}";
          case 'needs_approval':
            return isRTL
                ? "المتغيرات المتاحة: {{serviceName}}, {{requesterName}}"
                : "Available variables: {{serviceName}}, {{requesterName}}";
          case 'request_approved':
          case 'request_rejected':
            return isRTL
                ? "المتغيرات المتاحة: {{serviceName}}, {{approverName}}, {{rejectionReason}}"
                : "Available variables: {{serviceName}}, {{approverName}}, {{rejectionReason}}";
          case 'request_cancelled':
            return isRTL
                ? "المتغيرات المتاحة: {{serviceName}}, {{cancelledBy}}"
                : "Available variables: {{serviceName}}, {{cancelledBy}}";
          default:
            return isRTL
                ? "المتغيرات المتاحة: {{serviceName}}"
                : "Available variables: {{serviceName}}";
        }

      case NotificationTab.tasks:
        return isRTL
            ? "المتغيرات المتاحة: {{taskName}}, {{assignedTo}}, {{dueDate}}"
            : "Available variables: {{taskName}}, {{assignedTo}}, {{dueDate}}";

      case NotificationTab.todo:
        return isRTL
            ? "المتغيرات المتاحة: {{todoItem}}, {{assignerName}}, {{completedBy}}"
            : "Available variables: {{todoItem}}, {{assignerName}}, {{completedBy}}";

      case NotificationTab.events:
        return isRTL
            ? "المتغيرات المتاحة: {{eventName}}, {{eventDate}}, {{location}}"
            : "Available variables: {{eventName}}, {{eventDate}}, {{location}}";

      case NotificationTab.notes:
        return isRTL
            ? "المتغيرات المتاحة: {{noteTitle}}, {{createdBy}}, {{sharedWith}}"
            : "Available variables: {{noteTitle}}, {{createdBy}}, {{sharedWith}}";

      case NotificationTab.requests:
        return isRTL
            ? "المتغيرات المتاحة: {{requestType}}, {{requesterName}}, {{status}}"
            : "Available variables: {{requestType}}, {{requesterName}}, {{status}}";

      case NotificationTab.qiyas:
        switch (widget.notificationItem.eventType) {
          case 'perspectives_axes_created':
            return isRTL
                ? "المتغيرات المتاحة: {{FrameworkName}}, {{EmployeeName}}"
                : "Available variables: {{FrameworkName}}, {{EmployeeName}}";
          case 'champion_assigned_to_evidence':
          case 'evidence_submitted_for_review':
          case 'evidence_status_approved':
          case 'evidence_status_rejected':
          case 'evidence_overdue':
          case 'champion_reassigned':
            return isRTL
                ? "المتغيرات المتاحة: {{DocumentName}}"
                : "Available variables: {{DocumentName}}";
          default:
            return isRTL
                ? "المتغيرات المتاحة: {{DocumentName}}"
                : "Available variables: {{DocumentName}}";
        }

      case NotificationTab.inventory:
        return isRTL
            ? "المتغيرات المتاحة: {{itemName}}, {{quantity}}, {{location}}"
            : "Available variables: {{itemName}}, {{quantity}}, {{location}}";

      case NotificationTab.knowledgeHub:
        return isRTL
            ? "المتغيرات المتاحة: {{articleTitle}}, {{authorName}}, {{category}}"
            : "Available variables: {{articleTitle}}, {{authorName}}, {{category}}";

      case NotificationTab.messages:
        return isRTL
            ? "المتغيرات المتاحة: {{senderName}}, {{messagePreview}}"
            : "Available variables: {{senderName}}, {{messagePreview}}";

      case NotificationTab.tracking:
        return isRTL
            ? "المتغيرات المتاحة: {{employeeName}}, {{location}}, {{timestamp}}"
            : "Available variables: {{employeeName}}, {{location}}, {{timestamp}}";

      case NotificationTab.database:
        return isRTL
            ? "المتغيرات المتاحة: {{recordName}}, {{tableName}}, {{modifiedBy}}"
            : "Available variables: {{recordName}}, {{tableName}}, {{modifiedBy}}";

      case NotificationTab.formBuilder:
        return isRTL
            ? "المتغيرات المتاحة: {{formName}}, {{submittedBy}}, {{status}}"
            : "Available variables: {{formName}}, {{submittedBy}}, {{status}}";

      case NotificationTab.roles:
        return isRTL
            ? "المتغيرات المتاحة: {{roleName}}, {{employeeName}}, {{permissionChanged}}"
            : "Available variables: {{roleName}}, {{employeeName}}, {{permissionChanged}}";

      case NotificationTab.settings:
        return isRTL
            ? "المتغيرات المتاحة: {{settingName}}, {{changedBy}}, {{oldValue}}, {{newValue}}"
            : "Available variables: {{settingName}}, {{changedBy}}, {{oldValue}}, {{newValue}}";

      case NotificationTab.grc:
        return isRTL
            ? "المتغيرات المتاحة: {{riskName}}, {{complianceStatus}}, {{auditDate}}"
            : "Available variables: {{riskName}}, {{complianceStatus}}, {{auditDate}}";

      case NotificationTab.hr:
        return isRTL
            ? "المتغيرات المتاحة: {{employeeName}}, {{leaveType}}, {{startDate}}, {{endDate}}"
            : "Available variables: {{employeeName}}, {{leaveType}}, {{startDate}}, {{endDate}}";

      default:
        return isRTL
            ? "المتغيرات المتاحة: {{name}}, {{date}}"
            : "Available variables: {{name}}, {{date}}";
    }
  }

  // ✅ Helper method to get display text for selected items
  String _getSelectedNotificationTypesText(bool isRTL) {
    if (selectedNotificationTypes.isEmpty) {
      return isRTL ? "اختر نوع الإشعار" : "Select Notification Type";
    }

    List<String> displayNames = selectedNotificationTypes.map((type) {
      if (isRTL) {
        return type == "email" ? "البريد الإلكتروني" : "إشعار الهاتف";
      } else {
        return type == "email" ? "Email" : "Push Notification";
      }
    }).toList();

    return displayNames.join(", ");
  }

  // ✅ Helper to convert display name to key
  String _getNotificationTypeKey(String displayName, bool isRTL) {
    if (isRTL) {
      return displayName == "البريد الإلكتروني" ? "email" : "push";
    } else {
      return displayName == "Email" ? "email" : "push";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App bar row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(S.of(context).notificationControl,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(widget.notificationItem.title,
                      style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText)),
                ],
              ),
            ),
            Expanded(
              child: isLoadingTemplate
              ? Center(child: CircleProgressMaster())
              : ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                children: [
                  // Status & Notification Type Container
                  Container(
                    padding: EdgeInsets.all(15.r),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Row
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/status.svg",
                              width: 16.w,
                              height: 16.h,
                              fit: BoxFit.fill,
                              colorFilter: ColorFilter.mode(AppColors.secondaryText, BlendMode.srcIn),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              isRTL ? "حالة الإشعار" : "Notification Status",
                              style: StyleText.fontSize18Weight500.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            FlutterSwitch(
                              activeColor: AppColors.secondaryPrimary,
                              height: 22.sp,
                              width: 38.sp,
                              padding: 3.sp,
                              borderRadius: 20.sp,
                              toggleSize: 16.sp,
                              toggleColor: Colors.white,
                              inactiveColor: Color(0xFF787880).withOpacity(0.16),
                              value: isNotificationEnabled,
                              onToggle: (newValue) {
                                setState(() {
                                  isNotificationEnabled = newValue;
                                });
                              },
                            ),
                            Spacer(),
                            customButton(
                              title: isRTL ? "إعادة تعيين الافتراضي" : "Reset Default",
                              function: _resetToDefault,
                              color: AppColors.primary,
                              radius: 4.r,
                              width: 190.w,
                              height: 30.h,
                              textStyle: StyleText.fontSize14Weight500.copyWith(
                                color: AppColors.textButton,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 15.h),

                        // Notification Type Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Text(
                                isRTL ? "نوع الإشعار" : "Notification Type",
                                style: StyleText.fontSize12Weight400.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                            // Multi-select: Email and Push
                            Column(
                              children: ['email', 'push'].map((key) {
                                final label = key == 'email'
                                    ? (isRTL ? 'البريد الإلكتروني' : 'Email')
                                    : (isRTL ? 'إشعار الهاتف' : 'Push Notification');
                                return CheckboxListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(label, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text)),
                                  value: selectedNotificationTypes.contains(key),
                                  activeColor: AppColors.secondaryPrimary,
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        selectedNotificationTypes.add(key);
                                      } else {
                                        selectedNotificationTypes.remove(key);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15.h),

                  // Form Fields Container
                  Container(
                    padding: EdgeInsets.all(15.r),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subject Fields
                        TextSingleField(
                          typeName: "Subject",
                          hintText: "Text Here",
                          maxLines: 1,
                          height: 36.h,
                          isArabic: false,
                          controller: subjectEn,
                          onChange: (_) => setState(() {}),
                        ),

                        SizedBox(height: 15.h),

                        TextSingleField(
                          typeName: "عنوان",
                          hintText: "اكتب هنا",
                          maxLines: 1,
                          height: 36.h,
                          isArabic: true,
                          controller: subjectAr,
                          onChange: (_) => setState(() {}),
                        ),

                        SizedBox(height: 15.h),

                        // Helper text for variables
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16.sp,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  _getVariablesHintText(isRTL),
                                  style: StyleText.fontSize12Weight400.copyWith(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 15.h),

                        // Body Field EN
                        TextSingleField(
                          typeName: "Body",
                          hintText: "Text Here",
                          maxLines: 7,
                          minLines: 7,
                          height: 150.h,
                          maxLength: 500,
                          showCounter: true,
                          isArabic: false,
                          controller: bodyEnController,
                          onChange: (_) => setState(() {}),
                        ),

                        SizedBox(height: 15.h),

                        // Body Field AR
                        TextSingleField(
                          typeName: "نص الرسالة",
                          hintText: "اكتب هنا",
                          maxLines: 7,
                          minLines: 7,
                          height: 150.h,
                          maxLength: 500,
                          showCounter: true,
                          isArabic: true,
                          controller: bodyArController,
                          onChange: (_) => setState(() {}),
                        ),

                        SizedBox(height: 15.h),

                        // Bottom Buttons Row
                        Row(
                          children: [
                            customButton(
                              title: S.of(context).preview,
                              textStyle: StyleText.fontSize16Weight500.copyWith(
                                color: lightMode ? Colors.black : Colors.white,
                              ),
                              function: () {
                                _showPreviewDialog(context);
                              },
                              height: 38.h,
                              width: 150.w,
                              color: lightMode ? Colors.grey[400] : Colors.grey[700],
                              radius: 8.r,
                            ),
                            Spacer(),
                            customButton(
                              title: isSaving
                                  ? (isRTL ? "جاري الحفظ..." : "Saving...")
                                  : S.of(context).save,
                              textStyle: StyleText.fontSize16Weight500.copyWith(
                                color: AppColors.textButton,
                              ),
                              function: () {
                                if (!isSaving) {
                                  _saveTemplate();
                                }
                              },
                              height: 38.h,
                              width: 150.w,
                              color: AppColors.primary,
                              radius: 8.r,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
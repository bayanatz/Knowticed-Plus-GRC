/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: template_variable_label.dart
/// Purpose: The readable name of every `{{variable}}` — the text on the
///          variable chips in Notification Control.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026 (Owner: "add all the variables that could be inside")
library;

import 'package:knowticed_plus/core/enums/template_variable.dart';

extension TemplateVariableLabel on TemplateVariable {
  /// "documentName" → "Document Name" in English; the Arabic name from
  /// [_arabic], falling back to the English one for a variable added later.
  String label({required bool isArabic}) {
    if (isArabic) {
      final String? ar = _arabic[this];
      if (ar != null) return ar;
    }
    final String spaced =
        key.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}

const Map<TemplateVariable, String> _arabic = <TemplateVariable, String>{
  TemplateVariable.approverName: 'اسم المعتمِد',
  TemplateVariable.departmentName: 'اسم القسم',
  TemplateVariable.documentName: 'اسم المستند',
  TemplateVariable.dueDate: 'تاريخ الاستحقاق',
  TemplateVariable.employeeName: 'اسم الموظف',
  TemplateVariable.endDate: 'تاريخ الانتهاء',
  TemplateVariable.groupName: 'اسم المجموعة',
  TemplateVariable.moduleName: 'اسم الوحدة',
  TemplateVariable.newActivationDate: 'تاريخ التفعيل الجديد',
  TemplateVariable.oldActivationDate: 'تاريخ التفعيل السابق',
  TemplateVariable.rejectionReason: 'سبب الرفض',
  TemplateVariable.requesterName: 'اسم مقدم الطلب',
  TemplateVariable.scheduledDate: 'التاريخ المجدول',
  TemplateVariable.startDate: 'تاريخ البدء',
  TemplateVariable.status: 'الحالة',
  TemplateVariable.userName: 'اسم المستخدم',
  TemplateVariable.serviceName: 'اسم الخدمة',
  TemplateVariable.toDoName: 'اسم المهمة',
  TemplateVariable.accessGrantedDate: 'تاريخ منح الوصول',
  TemplateVariable.accessRevokedDate: 'تاريخ سحب الوصول',
  TemplateVariable.newStatus: 'الحالة الجديدة',
  TemplateVariable.oldStatus: 'الحالة السابقة',
  TemplateVariable.roleName: 'اسم الدور',
  TemplateVariable.newDeactivationDate: 'تاريخ الإيقاف الجديد',
  TemplateVariable.oldDeactivationDate: 'تاريخ الإيقاف السابق',
  TemplateVariable.count: 'العدد',
  TemplateVariable.countedRequests: 'عدد الطلبات',
  TemplateVariable.minutes: 'الدقائق',
  TemplateVariable.requestType: 'نوع الطلب',
  TemplateVariable.time: 'الوقت',
  TemplateVariable.columnName: 'اسم العمود',
  TemplateVariable.databaseName: 'اسم قاعدة البيانات',
  TemplateVariable.permissionLevel: 'مستوى الصلاحية',
  TemplateVariable.tableName: 'اسم الجدول',
  TemplateVariable.fileName: 'اسم الملف',
  TemplateVariable.frameworkName: 'اسم الإطار',
  TemplateVariable.activationDate: 'تاريخ التفعيل',
  TemplateVariable.controlChampionName: 'اسم بطل الضابط',
  TemplateVariable.controlName: 'اسم الضابط',
  TemplateVariable.controlOwnerName: 'اسم مالك الضابط',
  TemplateVariable.controlScore: 'درجة الضابط',
  TemplateVariable.currentChampionName: 'اسم البطل الحالي',
  TemplateVariable.departmentManagerName: 'اسم مدير القسم',
  TemplateVariable.newChampionName: 'اسم البطل الجديد',
  TemplateVariable.newControlName: 'اسم الضابط الجديد',
  TemplateVariable.newControlScore: 'درجة الضابط الجديدة',
  TemplateVariable.newDate: 'التاريخ الجديد',
  TemplateVariable.newEndDate: 'تاريخ الانتهاء الجديد',
  TemplateVariable.newOwnerName: 'اسم المالك الجديد',
  TemplateVariable.newStartDate: 'تاريخ البدء الجديد',
  TemplateVariable.newWeight: 'الوزن الجديد',
  TemplateVariable.oldControlName: 'اسم الضابط السابق',
  TemplateVariable.oldControlScore: 'درجة الضابط السابقة',
  TemplateVariable.oldDate: 'التاريخ السابق',
  TemplateVariable.oldEndDate: 'تاريخ الانتهاء السابق',
  TemplateVariable.oldStartDate: 'تاريخ البدء السابق',
  TemplateVariable.oldWeight: 'الوزن السابق',
  TemplateVariable.policyName: 'اسم السياسة',
  TemplateVariable.uploadedByUserName: 'رفع بواسطة',
  TemplateVariable.companyName: 'اسم الشركة',
  TemplateVariable.feedbackType: 'نوع الملاحظة',
  TemplateVariable.permissionName: 'اسم الصلاحية',
  TemplateVariable.addedByName: 'أضيف بواسطة',
  TemplateVariable.chatName: 'اسم المحادثة',
  TemplateVariable.createdByName: 'أنشئ بواسطة',
  TemplateVariable.deletedByName: 'حُذف بواسطة',
  TemplateVariable.messagePreview: 'معاينة الرسالة',
  TemplateVariable.optionName: 'اسم الخيار',
  TemplateVariable.pollQuestion: 'سؤال التصويت',
  TemplateVariable.recipientName: 'اسم المستلم',
  TemplateVariable.removedByName: 'أزيل بواسطة',
  TemplateVariable.senderName: 'اسم المرسل',
  TemplateVariable.unreadMessageCount: 'عدد الرسائل غير المقروءة',
  TemplateVariable.voterName: 'اسم المصوّت',
  TemplateVariable.accessEndDate: 'تاريخ انتهاء الوصول',
  TemplateVariable.formName: 'اسم النموذج',
  TemplateVariable.newAccessEndDate: 'تاريخ انتهاء الوصول الجديد',
  TemplateVariable.newGroupName: 'اسم المجموعة الجديد',
  TemplateVariable.oldGroupName: 'اسم المجموعة السابق',
  TemplateVariable.ownerName: 'اسم المالك',
  TemplateVariable.previousAccessEndDate: 'تاريخ انتهاء الوصول السابق',
  TemplateVariable.submissionDate: 'تاريخ الإرسال',
  TemplateVariable.date: 'التاريخ',
  TemplateVariable.channel: 'القناة',
  TemplateVariable.requestStatus: 'حالة الطلب',
};

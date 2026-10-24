/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/document_info/document_details_section.dart
/// ************************* FILE INFO *************************** ///
/// File Name: document_details_section.dart
/// Description: Contains the document details screen in view_knowledge_details.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/core/helper/phone_display.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_people.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/format_helper.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/ui/widgets/document_info/build_action_buttons.dart';

import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/ui/widgets/document_info/document_info_card.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/main_helper/messaging_interface_implementation.dart';

Widget buildDocumentDetailsSection(
  BuildContext context, {
  required String knowledgeId,
  required String documentName,
  required String documentType,
  required String owningDepartment,
  required String publishDate,
  required String documentDescription,
  required String fileUrl,
  required String fileType,
  required String documentExtension,
  required String createdByEmail, // creator's email
  required KhPeople people, // employee lookups, injected by the page
}) {
  final bool isMobile = ContextExtension(context).isPhone;
  final employeeController = people.employees;

  // 14/10/2026 — KH large-screen report p.9: "when the owner open document
  // details don't show his profile". The creator card is for OTHER people's
  // documents; on your own it only repeats your own name and contacts.
  final String signedInEmail =
      (employeeController.employeeEntity?.email ?? '').toLowerCase().trim();
  final bool isOwnDocument = signedInEmail.isNotEmpty &&
      signedInEmail == createdByEmail.toLowerCase().trim();
  final bool hideCreatorCard = isMobile || isOwnDocument;

  return SingleChildScrollView(
    child: Column(
      children: [
        buildActionButtons(
          createdByEmail: createdByEmail,
          knowledgeId: knowledgeId,
          createdBy: createdByEmail,
          fileName: documentName,
          fileType: fileType,
          fileUrl: fileUrl,
          department: owningDepartment,
          documentExtension: documentExtension,
        ),
        SizedBox(height: 15.h),
        if (!hideCreatorCard) ...[
          _buildCreatorCard(
            context,
            _CreatorInfo.of(
              context,
              people: people,
              createdByEmail: createdByEmail,
              isOwnDocument: isOwnDocument,
            ),
          ),
          SizedBox(height: 15.h),
        ],
        Stack(
          alignment: Alignment.topLeft,
          children: [
            buildDocumentInfoCard(
              context,
              publishDate: publishDate,
              documentDescription: documentDescription,
              documentName: documentName,
              documentType: documentType,
              owningDepartment: owningDepartment,
              documentExtension: documentExtension,
            ),
            PositionedDirectional(
              top: 8.sp,
              end: 10.sp,
              child: buildPublishDate(context, publishDate: publishDate),
            ),
          ],
        ),
        // 14/10/2026 — KH report p.9 "Equalize Padding": the page's own 15.h
        // is the only gap above the Analytics/Statistics/Comments tabs.
      ],
    ),
  );
}

/// What the contributor card shows, with '-' for anything not known.
class _CreatorInfo {
  const _CreatorInfo({
    required this.name,
    required this.title,
    required this.department,
    required this.phone,
    required this.email,
    required this.canMessage,
  });

  final String name;
  final String title;
  final String department;
  final String phone;
  final String email;
  final bool canMessage;

  factory _CreatorInfo.of(
    BuildContext context, {
    required KhPeople people,
    required String createdByEmail,
    required bool isOwnDocument,
  }) {
    final employeeController = people.employees;
    final EmployeeEntityPro? creator = employeeController.getLocaleEmployee(
      createdByEmail,
    );
    final String email = creator?.email ?? createdByEmail;
    return _CreatorInfo(
      name: creator != null
          ? employeeController.getEmployeeName(createdByEmail)
          : S.of(context).khUnknownUser,
      title: creator != null
          ? employeeController.getEmployeeJobTitle(createdByEmail)
          : '-',
      department: creator != null
          ? employeeController.getEmployeeDepartmentName(createdByEmail)
          : '-',
      phone: _creatorPhone(creator),
      email: email,
      // You cannot message yourself; an empty/invalid address has no chat.
      canMessage: !isOwnDocument && email.contains('@'),
    );
  }

  /// KH-CREATE-27: '-' when the employee or the number is missing (it used
  /// to read "null null"). The country code is joined only when both exist,
  /// kept left-to-right in both languages by a Unicode LTR isolate.
  static String _creatorPhone(EmployeeEntityPro? creator) {
    // 22/10/2026: the shared phone display (Latin digits in both languages, R-39).
    final String phone = kpPhoneDisplay(
      creator?.mobilePhone?.countryCode,
      creator?.mobilePhone?.phone,
    );
    if (creator == null || phone.isEmpty) return '-';
    return '\u2066${phone.replaceAll(RegExp(r'[\[\]]'), '')}\u2069';
  }
}

/// ✅ CREATOR INFORMATION CARD
Widget _buildCreatorCard(BuildContext context, _CreatorInfo info) {
  final bool isDesktop = MediaQuery.of(context).size.width > 900;
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color: AppColors.card,
    ),
    child: Padding(
      padding: EdgeInsets.all(15.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40.r),
              child: CustomSvgImage(
                assetPath:
                    "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                width: 75.w,
                height: 80.h,
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(width: 14.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCreatorNameRow(context, info),
                SizedBox(height: 16.sp),
                isDesktop
                    ? _buildCreatorDetailsWide(context, info)
                    : _buildCreatorDetailsNarrow(context, info),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// Name — and, at the end of the same row, the "Message" button (15/10/2026,
/// KH large-screen report "add message button in contributor details").
Widget _buildCreatorNameRow(BuildContext context, _CreatorInfo info) {
  return Row(
    children: [
      Expanded(
        child: Text(
          FormatHelper.capitalize(info.name),
          style: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.blackButton,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (info.canMessage) ...[
        SizedBox(width: 10.sp),
        _messageCreatorButton(context, info.email),
      ],
    ],
  );
}

/// Title, department, phone and e-mail stacked (phone / tablet).
Widget _buildCreatorDetailsNarrow(BuildContext context, _CreatorInfo info) {
  final bool lightMode = Theme.of(context).brightness == Brightness.light;
  final Color textColor = lightMode ? AppColors.secondaryText : AppColors.grey;
  final S s = S.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      _creatorDetailRow(
        icon: "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
        iconSize: 16.w,
        label: s.title,
        value: FormatHelper.capitalize(info.title),
        labelColor: textColor,
        valueColor: textColor,
      ),
      SizedBox(height: 5.h),
      _creatorDetailRow(
        icon: "assets/icons_assets/main_icons_assets/ic_building_office.svg",
        iconSize: 11,
        label: s.department,
        value: FormatHelper.capitalize(info.department),
        labelColor: textColor,
        valueColor: textColor,
      ),
      SizedBox(height: 5.h),
      _creatorDetailRow(
        icon: "assets/icons_assets/main_icons_assets/ic_comms_phone.svg",
        iconSize: 11,
        label: s.phoneNumber,
        value: info.phone,
        labelColor: textColor,
        valueColor: textColor,
        iconFit: BoxFit.scaleDown,
      ),
      SizedBox(height: 5.h),
      _creatorDetailRow(
        icon: "assets/icons_assets/main_icons_assets/ic_comms_sms.svg",
        iconSize: 11,
        label: s.email,
        value: info.email,
        labelColor: textColor,
        valueColor: textColor,
        iconFit: BoxFit.scaleDown,
      ),
    ],
  );
}

/// Title / department on the left, phone / e-mail on the right (desktop).
Widget _buildCreatorDetailsWide(BuildContext context, _CreatorInfo info) {
  final S s = S.of(context);
  Widget row(String icon, String label, String value) => _creatorDetailRow(
        icon: icon,
        iconSize: 16.w,
        iconColor: AppColors.infoIcon,
        label: label,
        value: value,
        labelColor: AppColors.secondaryText,
        valueColor: AppColors.text,
      );
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row(
              "assets/icons_assets/main_icons_assets/ic_org_briefcase.svg",
              s.title,
              FormatHelper.capitalize(info.title),
            ),
            SizedBox(height: 18.h),
            row(
              "assets/icons_assets/main_icons_assets/ic_building_office.svg",
              s.department,
              FormatHelper.capitalize(info.department),
            ),
          ],
        ),
      ),
      SizedBox(width: 24.sp),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row(
              "assets/icons_assets/main_icons_assets/ic_comms_phone.svg",
              s.phoneNumber,
              info.phone,
            ),
            SizedBox(height: 18.h),
            row(
              "assets/icons_assets/main_icons_assets/ic_comms_sms.svg",
              s.email,
              info.email,
            ),
          ],
        ),
      ),
    ],
  );
}

/// One "icon  Label: value" line of the contributor card.
Widget _creatorDetailRow({
  required String icon,
  required double iconSize,
  required String label,
  required String value,
  required Color labelColor,
  required Color valueColor,
  Color? iconColor,
  BoxFit iconFit = BoxFit.fill,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      CustomSvgImage(
        assetPath: icon,
        width: iconSize,
        height: iconSize,
        color: iconColor,
        fit: iconFit,
      ),
      SizedBox(width: 8.sp),
      Text(
        "$label: ",
        style: StyleText.fontSize14Weight500.copyWith(color: labelColor),
      ),
      Flexible(
        child: Text(
          value,
          style: StyleText.fontSize14Weight500.copyWith(color: valueColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

/// "Message" button for the contributor card — the same button and flow as
/// the role details page (Role QA p.26): spinner while the chat is prepared,
/// closed right before the chat is pushed, a localized reason on failure.
Widget _messageCreatorButton(BuildContext context, String creatorEmail) {
  return customButtonWithSvg(
    title: S.of(context).message,
    function: () => _openChatWithCreator(context, creatorEmail),
    color: AppColors.primary,
    space: 8.sp,
    heightImage: 20.sp,
    widthImage: 20.sp,
    colorBorder: AppColors.transparent,
    image: 'assets/icons_assets/main_icons_assets/ic_comms_chat_double.svg',
    svgColor: AppColors.textButton,
    textStyle: StyleText.fontSize14Weight400.copyWith(
      color: AppColors.textButton,
    ),
  );
}

Future<void> _openChatWithCreator(
  BuildContext context,
  String creatorEmail,
) async {
  showLoadingIndicator();
  bool loading = true;
  void stopLoading() {
    if (!loading) return;
    loading = false;
    hideLoadingIndicator();
  }

  final OpenChatResult result =
      await MessagingInterfaceImplementation().tryOpenChatWithUser(
    context: context,
    userEmail: creatorEmail,
    beforeNavigate: stopLoading,
  );
  stopLoading();
  if (context.mounted) await showOpenChatFailure(context, result);
}

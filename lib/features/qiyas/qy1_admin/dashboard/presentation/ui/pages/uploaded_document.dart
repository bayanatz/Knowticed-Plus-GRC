import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/dialogs/confirm_dialog.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/features/roles/r4_active_directory/presentation/controller/add_department_controller.dart';
import 'package:knowticed_plus/core/helper/extensions.dart'
    hide ContextExtension;
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/controller/qiyas_dashboard_controller_cubit.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/dashboard/presentation/controller/uploaded_document_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/bubble_text.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_app_dropdown.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';

class UploadedDocument extends StatefulWidget {
  const UploadedDocument({super.key});

  @override
  State<UploadedDocument> createState() => _UploadedDocumentState();
}

class _UploadedDocumentState extends State<UploadedDocument> {
  late QiyasDashboardControllerCubit cubit;
  @override
  initState() {
    super.initState();
    cubit = context.read<QiyasDashboardControllerCubit>();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsetsDirectional.only(
            start: isTablet ? 30.sp : 15.sp, end: 15.sp),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(screensTitles: [
                'قياس التحول الرقمي',
                'لوحة المعلومات',
                'تحميل المستندات الداعمة'
              ]),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          padding: EdgeInsets.all(15.sp),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: (isTablet)
                              ? Column(
                                  spacing: 15.sp,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      spacing: 10.sp,
                                      children: [
                                        Expanded(
                                            child: _departmentDropDownStatus()),
                                        Expanded(child: _departmentDropDown()),
                                      ],
                                    ),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 10.sp,
                                        children: [
                                          Expanded(child: _yearDropDown()),
                                          Expanded(child: _visionDropDown()),
                                        ]),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        spacing: 10.sp,
                                        children: [
                                          Expanded(child: _topicDropDown()),
                                          Expanded(child: _criteriaDropDown()),
                                        ])
                                  ],
                                )
                              : Column(
                                  spacing: 15.sp,
                                  children: [
                                    _departmentDropDownStatus(),
                                    _departmentDropDown(),
                                    _yearDropDown(),
                                    _visionDropDown(),
                                    _topicDropDown(),
                                    _criteriaDropDown(),
                                  ],
                                )),
                      SizedBox(height: 20.sp),
                      Row(
                        textDirection: TextDirection
                            .ltr, // X-73: Cancel left, action right in both languages

                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          customButton(
                              function: () {
                                Navigator.pop(context);
                              },
                              title: 'إلغاء',
                              width: 150,
                              color: AppColors.secondaryButton,
                              textStyle: StyleText.fontSize14Weight400),
                          customButtonWithSvg(
                            function: () {
                              ConfirmDialog().show(
                                context,
                                title: 'تنزيل الملفات',
                                subtitle: 'هل انت متاكد من تنزيل الملفات',
                                icon:
                                    'assets/lottie_assets/main_lottie_assets/lot_media_loading.json',
                                onConfirmText: 'نعم',
                                onCancelText: 'لا',
                                onConfirm: () async {
                                  showLoadingIndicator();
                                  await cubit.downloadDocuments();
                                  hideLoadingIndicator();
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                },
                                onCancel: () {},
                              );
                            },
                            image:
                                'assets/icons_assets/main_icons_assets/ic_action_cloud_download.svg',
                            title: 'تحميل',
                            width: 150,
                            textStyle: StyleText.fontSize14Weight400
                                .copyWith(color: AppColors.textButton),
                            color: AppColors.primary,
                            colorBorder: AppColors.transparent,
                            widthImage: 20.sp,
                            heightImage: 20.sp,
                            svgColor: AppColors.textButton,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _yearDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.sp,
      children: [
        Text(
          'السنوات',
          style: StyleText.fontSize14Weight400.copyWith(height: 1.2),
        ),
        AppDropdown(
            value: null,
            height: 38.sp,
            fillColor: AppColors.background,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء اختيار السنة';
              }
              return null;
            },
            onChanged: (value) {
              cubit.toggleYearSelection(value);
              setState(() {});
            },
            items: cubit.getYears().map((int year) {
              return DropdownMenuItem<int>(
                value: year,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      Text(
                        year.toString().toArabicNumbers(),
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.secondaryBlack),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            hintText: 'اختر السنة',
            textButton: null),
        Wrap(
          spacing: 10.sp,
          runSpacing: 10.sp,
          children: [
            for (int year in cubit.yearSubmissions.keys)
              BubbleText(
                text: year.toString().toArabicNumbers(),
                onTap: () {
                  cubit.toggleYearSelection(year);
                  setState(() {});
                },
              )
          ],
        )
      ],
    );
  }

  Widget _visionDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.sp,
      children: [
        Text(
          'المنظور',
          style: StyleText.fontSize14Weight400.copyWith(height: 1.2),
        ),
        AppDropdown(
            value: null,
            height: 38.sp,
            fillColor: AppColors.background,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء اختيار المنظور';
              }
              return null;
            },
            onChanged: (value) {
              cubit.toggleVisionSelection(value);
              setState(() {});
            },
            items: cubit.getVisions().map((String vision) {
              return DropdownMenuItem<String>(
                value: vision,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      Text(
                        cubit.getVisionNameFromVisionId(vision),
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.secondaryBlack),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            hintText: 'اختر المنظور',
            textButton: null),
        Wrap(
          spacing: 10.sp,
          runSpacing: 10.sp,
          children: [
            for (String vision in cubit.visionSubmissions.keys)
              BubbleText(
                text: cubit.getVisionNameFromVisionId(vision),
                onTap: () {
                  cubit.toggleVisionSelection(vision);
                  setState(() {});
                },
              )
          ],
        )
      ],
    );
  }

  Widget _topicDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.sp,
      children: [
        Text(
          'المحور',
          style: StyleText.fontSize14Weight400.copyWith(height: 1.2),
        ),
        AppDropdown(
            value: null,
            height: 38.sp,
            fillColor: AppColors.background,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء اختيار المحور';
              }
              return null;
            },
            onChanged: (value) {
              cubit.toggleTopicSelection(value);
              setState(() {});
            },
            items: cubit.getTopics().map((String topic) {
              return DropdownMenuItem<String>(
                value: topic,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      Text(
                        cubit.getTopicName(topic),
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.secondaryBlack),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            hintText: 'اختر المحور',
            textButton: null),
        Wrap(
          spacing: 10.sp,
          runSpacing: 10.sp,
          children: [
            for (String topic in cubit.topicSubmissions.keys)
              BubbleText(
                text: cubit.getTopicName(topic),
                onTap: () {
                  cubit.toggleTopicSelection(topic);
                  setState(() {});
                },
              )
          ],
        )
      ],
    );
  }

  Widget _criteriaDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.sp,
      children: [
        Text(
          'المعيار',
          style: StyleText.fontSize14Weight400.copyWith(height: 1.2),
        ),
        AppDropdown(
            value: null,
            height: 38.sp,
            fillColor: AppColors.background,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء اختيار المعيار';
              }
              return null;
            },
            onChanged: (value) {
              cubit.toggleCriteriaSelection(value);
              setState(() {});
            },
            items: cubit.getCriteria().map((String criteria) {
              return DropdownMenuItem<String>(
                value: criteria,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      Text(
                        cubit.getCriteriaName(criteria),
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.secondaryBlack),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            hintText: 'اختر المعيار',
            textButton: null),
        Wrap(
          spacing: 10.sp,
          runSpacing: 10.sp,
          children: [
            for (String topic in cubit.criteriaSubmissions.keys)
              BubbleText(
                text: cubit.getCriteriaName(topic),
                onTap: () {
                  cubit.toggleCriteriaSelection(topic);
                  setState(() {});
                },
              )
          ],
        )
      ],
    );
  }

  Widget _departmentDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.sp,
      children: [
        Text(
          'الاقسام',
          style: StyleText.fontSize14Weight400.copyWith(height: 1.2),
        ),
        AppDropdown(
            value: null,
            height: 38.sp,
            fillColor: AppColors.background,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء اختيار القسم';
              }
              return null;
            },
            onChanged: (value) {
              cubit.toggleDepartmentSelection(value);
              setState(() {});
            },
            items: Get.find<MainCoreDepartmentController>()
                .departmentIds
                .map((String department) {
              return DropdownMenuItem<String>(
                value: department,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      Text(
                        Get.find<MainCoreDepartmentController>()
                            .getArabicDepartmentNameFromDepartmentId(
                                departmentId: department)!,
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.secondaryBlack),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            hintText: 'اختر القسم',
            textButton: null),
        Wrap(
          spacing: 10.sp,
          runSpacing: 10.sp,
          children: [
            for (String departmentId in cubit.departmentIds)
              BubbleText(
                text: Get.find<MainCoreDepartmentController>()
                    .getArabicDepartmentNameFromDepartmentId(
                        departmentId: departmentId)!,
                onTap: () {
                  cubit.toggleDepartmentSelection(departmentId);
                  setState(() {});
                },
              )
          ],
        )
      ],
    );
  }

  Widget _departmentDropDownStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.sp,
      children: [
        Text(
          'حالة المستند',
          style: StyleText.fontSize14Weight400.copyWith(height: 1.2),
        ),
        AppDropdown(
          value: cubit.selectedStatus,
          height: 38.sp,
          fillColor: AppColors.background,
          onChanged: (value) {
            cubit.selectedStatus = value;
            setState(() {});
          },
          items: [
            EvidenceSubmissionStatus.late,
            EvidenceSubmissionStatus.approved,
            EvidenceSubmissionStatus.rejected
          ].map((EvidenceSubmissionStatus status) {
            return DropdownMenuItem<EvidenceSubmissionStatus>(
              value: status,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    Text(
                      (status == EvidenceSubmissionStatus.late)
                          ? 'معتمد و مرفوض'
                          : status.value,
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.secondaryBlack),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          textButton: (cubit.selectedStatus == EvidenceSubmissionStatus.late)
              ? 'معتمد و مرفوض'
              : cubit.selectedStatus.value,
        ),
      ],
    );
  }
}

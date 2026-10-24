/// Module: settings/se3_company
///
///*************************** FILE INFO ****************************///
/// File Name: company_info.dart
/// Purpose: The company-information section — the fields plus the update
///          button — rendered inside the settings pane.
/// Author: Amr Mesbah
/// Created at: 11/12/2024
/// Updated: 11/8/2026 - CR-SKEL-SE3-N04/N17/N25: renamed from the misspelled
///          `comapny_info.dart`; the four commented-out debug prints and the
///          REMOVED_MODULE import comments deleted; standard header added.
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/section_change_request_page.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';
// REMOVED: import '../../../../settings_screen/views/owner_screens/company_info_update_dialog/update_company_info_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/phone_country_lookup.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/ui/widgets/fields/company_information_fields.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class CompanyScreenInfo extends StatefulWidget {
  const CompanyScreenInfo({super.key});

  @override
  State<CompanyScreenInfo> createState() => _CompanyScreenInfoState();
}

class _CompanyScreenInfoState extends State<CompanyScreenInfo> {
  /// A saved size such as "To 1000 500" (words and numbers in any order) back
  /// to the admin's spelling "500 To 1000", so it matches the list.
  static String _normalizedSize(String raw) {
    final List<int> n = RegExp(r'\d+')
        .allMatches(raw)
        .map((Match m) => int.parse(m.group(0)!))
        .toList()
      ..sort();
    if (n.length == 2) return '${n[0]} To ${n[1]}';
    return raw;
  }

  CompanyCubit get companyController => context.read<CompanyCubit>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  // ✅ NEW METHOD: Load company data on screen init
  Future<void> _loadCompanyData() async {
    if (companyController.state.company == null) {
      await companyController.getCompany(shouldRestart: false);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    MediaQuery.of(context).orientation == Orientation.portrait;

    // ✅ Show loading indicator while data is loading
    if (_isLoading) {
      return const CircleProgressMaster();
    }

    // ✅ Show error message if company data failed to load
    if (context.watch<CompanyCubit>().state.company == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: AppColors.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              S.of(context).error,
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 16.h),
            customButton(
              title: S.of(context).retry,
              function: () {
                setState(() {
                  _isLoading = true;
                });
                _loadCompanyData();
              },
              wrapContent: true,
            ),
          ],
        ),
      );
    }

    return !isMobile
        ? Column(
            children: [
              // isMobile ? SizedBox(height: 35.h) : SizedBox() ,
              // CHANGED 18/10/2026 (Moataz: big empty area under the button on
              // iPad / desktop): the card is Expanded instead of a fixed height,
              // so it fills the right-hand pane and it ends 15 above the bottom
              // edge. The inner scroll view keeps every field reachable.
              // D-183 (18/10/2026): the card ends after its last field (D-146
              // inset) — Flexible, not Expanded; it still scrolls when longer.
              Expanded(
                // D-202 (20/10/2026): the card keeps its own height (D-183) and the
                // Request Change button below is PINNED to the bottom of the pane.
                child: Column(
                  children: <Widget>[
                    // 21/10/2026: the fields draw one card per section and
                    // scroll themselves — no outer card or second scroll.
                    const Expanded(child: CompanyInformationFields()),
                  ],
                ),
              ),
              SizedBox(height: 16.sp),
              // 18/10/2026 (Moataz): Company Information is changed through a
              // request, like Personal Information.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customButtonWithSvg(
                    fixedWidth: 250.w,
                    title: S.of(context).requestToChange,
                    function: () => _openCompanyRequest(context),
                    color: AppColors.primary,
                    colorBorder: AppColors.transparent,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton),
                    image:
                        'assets/icons_assets/main_icons_assets/ic_module_request_change.svg',
                    svgColor: AppColors.textButton,
                    widthImage: 16,
                    heightImage: 23,
                  ),
                ],
              ),
              SizedBox(height: 16.sp),

              // SizedBox(height: 16.h),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     customButton(
              //       title: S.of(context).update,
              //       function: () async {
              //
              //         hapticController.triggerHapticFeedback(
              //             vibration: VibrateType.mediumImpact,
              //             hapticFeedback: HapticFeedback.mediumImpact
              //         );
              //
              //         // ✅ Add your update logic here
              //         // For example:
              //         // await companyController.updateCompanyInfo();
              //
              //       },
              //       radius: 4.r,
              //       color: AppColors.primary,
              //       width: 300.w,
              //       height: 36,
              //       textStyle: StyleText.fontSize16Weight500.copyWith(
              //           color: AppColors.textButton
              //       ),
              //     ),
              //   ],
              // ),
            ],
          )
        : SideFrameMasterServices(
            titleText: S.of(context).settings,
            // 21/10/2026: the phone title is the menu label, "Company Information".
            secondTitle: S.of(context).companyInformation,
            onSecondTap: () {
              Navigator.pop(context);
            },
            onFirstTap: () {
              Navigator.pop(context);
            },
            // D-202 (21/10/2026): the phone had NO Request Change button
            // (the tablet had one). Same pinned action as Personal
            // Information and Health Insurance: the section cards scroll
            // above it, the button never moves.
            child: SideFrameBoundedBody(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      // The gap under the header, not a page inset: each
                      // section card supplies its own 16.sp inset (8/9/2026).
                      padding: EdgeInsets.only(top: 16.sp),
                      child: const CompanyInformationFields(),
                    ),
                  ),
                  SizedBox(height: 16.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      customButtonWithSvg(
                        fixedWidth: 200.sp,
                        title: S.of(context).requestToChange,
                        function: () => _openCompanyRequest(context),
                        color: AppColors.primary,
                        colorBorder: AppColors.transparent,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                        image:
                            'assets/icons_assets/main_icons_assets/ic_module_request_change.svg',
                        svgColor: AppColors.textButton,
                        widthImage: 16.w,
                        heightImage: 23.h,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.sp),
                ],
              ),
            ),
          );
  }

  void _openCompanyRequest(BuildContext context) {
    final c = context.read<CompanyCubit>().state.company;
    String v(List<Object?>? h) => h?.lastOrNull?.toString() ?? '';
    final S l = S.of(context);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SectionChangeRequestPage(
        section: 'Company Information',
        sectionTitle: l.companyInformation,
        // 20/10/2026 (Moataz): "Settings › Editing Company Information", the
        // fields in the view page's groups.
        pageTitle: l.editingCompanyInformation,
        // D-224: Edit → Preview → Submit.
        previewTitle: l.previewCompanyInformation,
        groups: <RequestableGroup>[
          RequestableGroup(
            title: l.company,
            iconPath:
                // 21/10/2026: the same icons as the view page's sections.
                'assets/icons_assets/main_icons_assets/ic_org_company_building.svg',
            fields: <RequestableField>[
              RequestableField(
                  key: 'companyName',
                  label: l.companyName,
                  currentValue: v(c?.companyName?.companyName)),
              RequestableField(
                  key: 'taxNumber',
                  label: l.taxNumber,
                  currentValue: v(c?.taxNumber?.taxNumber)),
              RequestableField(
                  key: 'country',
                  label: l.country,
                  currentValue: v(c?.country?.country),
                  kind: RequestableFieldKind.country),
              RequestableField(
                  key: 'province',
                  label: l.stateOrProvince,
                  currentValue: v(c?.province?.province),
                  kind: RequestableFieldKind.province),
              RequestableField(
                  key: 'city',
                  label: l.city,
                  currentValue: v(c?.city?.city),
                  kind: RequestableFieldKind.city),
              RequestableField(
                  key: 'address',
                  label: l.street,
                  currentValue: v(c?.companyAddress?.address)),
            ],
          ),
          RequestableGroup(
            title: l.service,
            iconPath:
                'assets/icons_assets/main_icons_assets/ic_module_services.svg',
            fields: <RequestableField>[
              // 23/10/2026 (Moataz): the industry is a dropdown, not free text,
              // with the SAME list the admin's company-details dropdown uses
              // (Knowticed-Plus-Admin core/enums/enum.dart IndustryType).
              RequestableField(
                key: 'industry',
                label: l.industry,
                currentValue: v(c?.companyIndustry?.companyIndustry),
                kind: RequestableFieldKind.dropdown,
                options: const <String>[
                  'Entertainment',
                  'Food Services',
                  'Government',
                  'Utilities',
                  'Administration',
                  'Business',
                  'Transportation',
                  'Education',
                  'Real Estate',
                  'Construction',
                  'Healthcare',
                  'Manufacturing',
                  'Engineering',
                  'Financial Services',
                  'Online Retail',
                  'Hospitality',
                  'Other',
                ],
                optionLabelsAr: const <String, String>{
                  'Entertainment': 'الترفيه',
                  'Food Services': 'خدمات الأغذية',
                  'Government': 'حكومي',
                  'Utilities': 'المرافق',
                  'Administration': 'الإدارة',
                  'Business': 'الأعمال',
                  'Transportation': 'النقل',
                  'Education': 'التعليم',
                  'Real Estate': 'العقارات',
                  'Construction': 'الإنشاءات',
                  'Healthcare': 'الرعاية الصحية',
                  'Manufacturing': 'التصنيع',
                  'Engineering': 'الهندسة',
                  'Financial Services': 'الخدمات المالية',
                  'Online Retail': 'التجزئة عبر الإنترنت',
                  'Hospitality': 'الضيافة',
                  'Other': 'أخرى',
                },
              ),
              // Same list as the admin's company-size dropdown
              // (core/constants/company_size_list.dart).
              RequestableField(
                key: 'companySize',
                label: l.companySize,
                currentValue: _normalizedSize(v(c?.companySize?.companySize)),
                kind: RequestableFieldKind.dropdown,
                options: const <String>[
                  '5 To 10',
                  '10 To 100',
                  '100 To 500',
                  '500 To 1000',
                  '1000 To 5000',
                  '5000 To 10000',
                  '10000+',
                ],
                optionLabelsAr: const <String, String>{
                  '5 To 10': '5 إلى 10',
                  '10 To 100': '10 إلى 100',
                  '100 To 500': '100 إلى 500',
                  '500 To 1000': '500 إلى 1000',
                  '1000 To 5000': '1000 إلى 5000',
                  '5000 To 10000': '5000 إلى 10000',
                  '10000+': '+10000',
                },
              ),
            ],
          ),
          RequestableGroup(
            title: l.contact,
            iconPath:
                'assets/icons_assets/settings_assets/ic_comms_phone_call.svg',
            fields: <RequestableField>[
              RequestableField(
                  key: 'contactFirstName',
                  label: l.firstName,
                  currentValue: v(c?.firstName?.firstNames)),
              RequestableField(
                  key: 'contactLastName',
                  label: l.lastName,
                  currentValue: v(c?.lastName?.lastNames)),
              RequestableField(
                  key: 'contactEmail',
                  label: l.email,
                  // Emails always read lowercase (18/10/2026).
                  currentValue: v(c?.email?.emails).trim().toLowerCase()),
              RequestableField(
                  key: 'contactPhone',
                  label: l.phoneNumber,
                  // Owner 21/10/2026: "<dial code> <number>" from the stored
                  // Country_Code, so the request form opens on the right country.
                  currentValue: _phoneWithDialCode(
                      v(c?.phone?.phones), c?.phone?.countryCode?.lastOrNull),
                  kind: RequestableFieldKind.phone),
            ],
          ),
        ],
      ),
    ));
  }

  /// "+20 1501503767" when the company has a stored country code; the bare
  /// number otherwise (the request form then falls back to its default).
  static String _phoneWithDialCode(String number, String? iso) {
    final String n = number.trim();
    if (n.isEmpty || n.startsWith('+') || iso == null || iso.trim().isEmpty) {
      return n;
    }
    return '${PhoneCountryLookup.dialCodeOf(iso)} $n';
  }
}

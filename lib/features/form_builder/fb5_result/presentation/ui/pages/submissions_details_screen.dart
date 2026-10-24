/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: submissions_details_screen.dart
/// Description: `SubmissionsDetailsScreen` page, state and UI of the `SubmissionsDetailsScreen` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/ui/widgets/pdf_download_actions.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/utils/pdf_page_keys.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder/helpers/breadcrumb_nav.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/presentation/ui/pages/submitted_page_details_viewer.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_title_padding.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/page_controller_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller_mapper.dart';

/// One person's submitted answers (read-only), with Download.
class SubmissionsDetailsScreen extends StatefulWidget {
  const SubmissionsDetailsScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<SubmissionsDetailsScreen> createState() =>
      _SubmissionsDetailsScreenState();
}

class _SubmissionsDetailsScreenState extends State<SubmissionsDetailsScreen> {
  /// Read-only controllers of the opened submission. Built and disposed by
  /// this page (they used to live in the cubit state).
  List<PageControllerModel> _pages = const [];

  @override
  void initState() {
    super.initState();
    final state = context.read<ResultCubit>().state;
    if (state is ResultLoaded) {
      _pages = (state.selectedUser?.page ?? const [])
          .map((page) => page.toController(isSetData: true))
          .toList();
    }
    // Initialize pdf cubit with the number of services_management_module
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) preparePdfPages(context, widget.form.pages.length);
    });
  }

  /// The download file name; owned by the page, not the cubit.
  final TextEditingController _fileName = TextEditingController();

  @override
  void dispose() {
    _fileName.dispose();
    for (final page in _pages) {
      for (final row in page.rows) {
        row.numOfColumn?.dispose();
        for (final controller in row.controllers) {
          controller.dispose();
        }
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);

    // Header is SideFrameMasterServices now, not
    // PaginationAppBar. The crumbs also move out of the ResultLoaded branch,
    // so the page has a header (and a way back) while it is still loading.
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).detailsOfTitle(widget.form.getTitle),
        thirdTitle: S.of(context).result,
        fourthTitle: S.of(context).submissions,
        onFirstTap: breadcrumbPop(context, 3),
        onSecondTap: breadcrumbPop(context, 2),
        onThirdTap: breadcrumbPop(context, 1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: BlocBuilder<ResultCubit, ResultState>(
              builder: (context, state) {
                if (state is! ResultLoaded || state.selectedUser == null) {
                  return const CircleProgressMaster();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 0 on a vertical tablet — see formBuilderTopGap.
                    verticalSpace(formBuilderTopGap(context, 30)),
                    Container(
                      height: ContextExtension(context).isTablett ? 110 : null,
                      padding: const EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: isTablet
                          ? _tabletUserOverview(context, state)
                          : _mobileUserOverview(context, state),
                    ),
                    verticalSpace(20),
                    // This downloads the submission itself,
                    // so it is "Download Submissions"; it was gated by "Download
                    // Form Digital Assets", which is the uploaded-files page.
                    if (FormBuilderAccess.canDownloadSubmissions)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          customButtonWithSvg(
                            // Was the literal 'Download'.
                            title: S.of(context).download,
                            image: AppAssets.downloadPdf,
                            function: () => PdfDownloadActions.download(
                              context,
                              widget.form,
                              _fileName,
                            ),
                            textStyle: StyleText.fontSize14Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            color: AppColors.primary,
                            colorBorder: AppColors.primary,
                            svgColor: AppColors.textButton,
                            widthImage: 16,
                            heightImage: 16,
                          ),
                        ],
                      ),
                    verticalSpace(20),
                    Text(
                      S.of(context).submissionForm,
                      style: StyleText.fontSize16Weight600,
                    ),
                    verticalSpace(8),
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: SubmittedPageDetailsViewer(
                        model: state.formEntity!,
                        pages: _pages,
                        isReadOnly: true,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Row _tabletUserOverview(BuildContext context, ResultLoaded state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          foregroundColor: AppColors.primary,
          radius: 60.r,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50.r),
            child: SizedBox(
              child: CustomSvgImage(
                assetPath: AppAssets.male,
                width: 80.w,
                height: 70.h,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        horizontalSpace(15),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FormatHelper.capitalize(state.selectedUser!.person.name),
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.fullBlack,
                ),
              ),
              _buildTitleAndDepartment(context, state),
              _buildEmailAndPhone(context, state),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${S.of(context).submissionDate}: ',
                    style: StyleText.fontSize12Weight500.copyWith(
                      color: AppColors.spanText,
                    ),
                  ),
                  TextSpan(
                    text: DateFormat('dd MMM yyyy')
                        .format(state.selectedUser!.submissionTime!),
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.fullBlack,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            customButtonWithSvg(
              title: S.of(context).message,
              function: () {},
              textStyle: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.blackButton,
              ),
              color: AppColors.primary,
              image: AppAssets.chat,
              widthImage: 20,
              heightImage: 20,
              colorBorder: AppColors.transparent,
              svgColor: AppColors.black,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailAndPhone(BuildContext context, ResultLoaded state) {
    bool isTablet = !kpIsPhoneLayout(context);
    return isTablet
        ? Row(
            children: [
              _rowItem(
                context: context,
                icon: AppAssets.email,
                title: '${S.of(context).email}: ',
                value: state.selectedUser!.person.id,
              ),
              _rowItem(
                context: context,
                icon: AppAssets.phone,
                title: '${S.of(context).phone}: ',
                value: state.selectedUser!.person.phone,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _rowItem(
                context: context,
                icon: AppAssets.email,
                title: '${S.of(context).email}: ',
                value: state.selectedUser!.person.id,
              ),
              _rowItem(
                context: context,
                icon: AppAssets.phone,
                title: '${S.of(context).phone}: ',
                value: state.selectedUser!.person.phone,
              ),
            ],
          );
  }

  Widget _buildTitleAndDepartment(BuildContext context, ResultLoaded state) {
    bool isTablet = !kpIsPhoneLayout(context);
    return isTablet
        ? Row(
            children: [
              _rowItem(
                context: context,
                icon: AppAssets.title,
                title: '${S.of(context).jobTitle}: ',
                value: state.selectedUser!.person.title,
              ),
              _rowItem(
                context: context,
                icon: AppAssets.department,
                title: '${S.of(context).department}: ',
                value: state.selectedUser!.person.departmentName,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _rowItem(
                context: context,
                icon: AppAssets.title,
                title: '${S.of(context).jobTitle}: ',
                value: state.selectedUser!.person.title,
              ),
              _rowItem(
                context: context,
                icon: AppAssets.department,
                title: '${S.of(context).department}: ',
                value: state.selectedUser!.person.departmentName,
              ),
            ],
          );
  }

  Widget _rowItem({
    required BuildContext context,
    required String icon,
    required String title,
    required String value,
  }) {
    Widget row = Row(
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CustomSvgImage.natural(
            assetPath: icon,
            colorFilter: ColorFilter.mode(AppColors.spanText, BlendMode.srcIn),
          ),
        ),
        horizontalSpace(3),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.spanText,
                  ),
                ),
                TextSpan(
                  text: FormatHelper.capitalize(value),
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.fullBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    bool isTablet = !kpIsPhoneLayout(context);
    return isTablet ? Expanded(child: row) : row;
  }

  Widget _mobileUserOverview(BuildContext context, ResultLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          foregroundColor: AppColors.primary,
          radius: 30.r,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.r),
            child: SizedBox(
              child: CustomSvgImage(
                assetPath: AppAssets.male,
                width: 40.w,
                height: 40.h,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        horizontalSpace(15),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        FormatHelper.capitalize(
                          state.selectedUser!.person.name,
                        ),
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.fullBlack,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomSvgImage.natural(
                      assetPath: AppAssets.chat,
                      width: 19.sp,
                      height: 19.sp,
                    ),
                  ),
                ],
              ),
              _buildTitleAndDepartment(context, state),
              _buildEmailAndPhone(context, state),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${S.of(context).submissionDate}: ',
                          style: StyleText.fontSize12Weight500.copyWith(
                            color: AppColors.spanText,
                          ),
                        ),
                        TextSpan(
                          text: DateFormat('dd MMM yyyy')
                              .format(state.selectedUser!.submissionTime!),
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.fullBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

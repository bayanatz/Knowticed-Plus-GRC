/// Module: form_builder_module/f3_form_details
///
///*************************** FILE INFO ****************************///
/// File Name: form_details_screen.dart
/// Description: `FormDetailsScreen` page, state and UI of the `FormDetailsScreen` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Reads its own FormDetailsCubit; the route provides
///                       the cubits.
/// Updated: 23/10/2026 - No HomeCubit listener here (Details rule 1).
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder/helpers/breadcrumb_nav.dart';
import 'package:knowticed_plus/features/form_builder/helpers/submitted_page_viewer.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/orientation.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller_mapper.dart';
import 'package:knowticed_plus/features/form_builder/fb3_form_details/presentation/controller/form_details_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb3_form_details/presentation/controller/form_details_state.dart';
import 'package:knowticed_plus/features/form_builder/fb3_form_details/presentation/ui/widgets/form_details_actions.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_title_padding.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_assets.dart';

/// The details of a published form: actions, head data and a read-only
/// preview. Its route provides [FormDetailsCubit] and the PdfCubit.
class FormDetailsScreen extends StatefulWidget {
  const FormDetailsScreen({super.key, required this.model});
  final FormEntity model;

  @override
  State<FormDetailsScreen> createState() => _FormDetailsScreenState();
}

class _FormDetailsScreenState extends State<FormDetailsScreen> {
  static const double a4PortraitWidth = 794.0;
  static const double a4LandscapeWidth = 1123.0;

  // Calculate A4 width based on orientation
  double _getA4Width() {
    final orientation = _model.formHeadModel.orientation.toLowerCase();
    final isLandscape = orientation.contains('landscape');
    return isLandscape ? a4LandscapeWidth : a4PortraitWidth;
  }

  /// The newest copy of this form, kept by [FormDetailsCubit].
  FormEntity get _model => context.read<FormDetailsCubit>().state.form;

  @override
  Widget build(BuildContext context) {
    // Saving an edit reloads the home lists with NEW FormEntity objects;
    // FormDetailsCubit swaps in the newest copy (vertical bug report p.20).
    return BlocBuilder<FormDetailsCubit, FormDetailsState>(
      builder: (context, _) => _buildScreen(context),
    );
  }

  Widget _buildScreen(BuildContext context) {
    // The route provides this screen's PdfCubit (see FormBuilderRouter).
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S
            .of(context)
            .detailsOfTitle(_getTitle(_model.formHeadModel, context)),
        onFirstTap: breadcrumbPop(context, 1),
        child: _buildScrollableContent(context),
      ),
    );
  }

  /// The frame scrolls the content itself on mobile; on tablet it hands the
  /// child a bounded height, so the scroll view stays here.
  Widget _buildScrollableContent(BuildContext context) {
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0 on a vertical tablet — see formBuilderTopGap.
        verticalSpace(formBuilderTopGap(context, 15)),
        FormDetailsActions(model: _model),
        verticalSpace(15),
        Container(
          padding: EdgeInsets.only(
            top: 15.h,
            bottom: 15.h,
            right: 15.w,
            left: 15.w,
          ),
          decoration: ShapeDecoration(
            color: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.background,
                    radius: 32.5,
                    backgroundImage:
                        _model.formHeadModel.cover != null &&
                            _model.formHeadModel.cover!.isNotEmpty
                        ? NetworkImage(_model.formHeadModel.cover!)
                        : null,
                    child:
                        _model.formHeadModel.cover != null &&
                            _model.formHeadModel.cover!.isNotEmpty
                        ? null
                        : Transform.scale(
                            scale: ContextExtension(context).isTablett
                                ? 1.5
                                : ContextExtension(context).isTablett
                                ? 1.2
                                : 1,
                            child: CustomSvgImage.natural(
                              assetPath: FormBuilderAssets.moduleIcon,
                              colorFilter: ColorFilter.mode(
                                AppColors.text,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                  ),
                  horizontalSpace(10),
                  // At 23 the title
                  // ran off the card on a phone ("QA Bug Report
                  // Submissio|"). Phones use 18, and the text is
                  // Flexible so a long title wraps to two lines and then
                  // ends in "…" instead of overflowing.
                  Flexible(
                    child: Text(
                      _getTitle(_model.formHeadModel, context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize23Weight400.copyWith(
                        fontSize: ContextExtension(context).isPhone
                            ? 18.sp
                            : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpace(15),
              _getDescriptionWidget(_model.formHeadModel, context),
              verticalSpace(15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropDown(context),
                  verticalSpace(5.h),
                  buildPadding(context),
                ],
              ),
            ],
          ),
        ),
        verticalSpace(15),
        // Added A4 width to SubmittedPageViewer
        // The A4 page is
        // a fixed width (landscape A4 is wider than an iPad in portrait),
        // so when it doesn't fit it now sits in a horizontal scroll view
        // instead of being cut off. When it fits it stays centred as before.
        LayoutBuilder(
          builder: (context, constraints) {
            final double a4Width = _getA4Width();
            final Widget viewer = SubmittedPageViewer(
              // A new entity (after an edit) gets a fresh viewer state.
              key: ObjectKey(_model),
              model: _model,
              isReadOnly: true,
              isSubmitted: false,
              pages: List.generate(
                _model.pages.length,
                (index) => _model.pages[index].toController(),
              ),
              // A4 width for the form's orientation.
              width: a4Width,
            );

            if (a4Width <= constraints.maxWidth) {
              return Align(alignment: Alignment.center, child: viewer);
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(width: a4Width, child: viewer),
            );
          },
        ),
      ],
    );

    // The scroll view used to be keyed off `isTablett`
    // (shortestSide >= 600), but the frame picks its layout by WIDTH, so the
    // two could disagree and leave the page with no scroll view at all.
    // SideFrameScrollableBody adds one exactly where the frame doesn't.
    return SideFrameScrollableBody(
      physics: const AlwaysScrollableScrollPhysics(),
      child: content,
    );
  }

  Widget buildPadding(BuildContext context) {
    return ContextExtension(context).isTablett
        ? Row(
            children: [
              Expanded(child: _buildHorizontalPadding()),
              horizontalSpace(15),
              Expanded(child: _buildVerticalPadding()),
            ],
          )
        : Column(
            children: [
              _buildHorizontalPadding(),
              verticalSpace(15),
              _buildVerticalPadding(),
            ],
          );
  }

  CustomTextField _buildVerticalPadding() {
    return CustomTextField(
      height: 36,
      label: S.of(context).verticalPadding,
      hint: FormDateTimeHelper.formatInt(
        _model.formHeadModel.verticalPadding?.toInt() ?? 0,
      ),
      readOnly: true,
    );
  }

  CustomTextField _buildHorizontalPadding() {
    return CustomTextField(
      height: 36,
      label: S.of(context).horizontalPadding,
      hint: FormDateTimeHelper.formatInt(
        _model.formHeadModel.horizontalPadding?.toInt() ?? 0,
      ),
      readOnly: true,
    );
  }

  Widget _buildDropDown(BuildContext context) {
    return ContextExtension(context).isTablett
        ? Row(
            children: [
              Expanded(child: _buildAccessManagement()),
              horizontalSpace(15),
              Expanded(child: _buildOrientation()),
            ],
          )
        : Column(
            children: [
              _buildAccessManagement(),
              verticalSpace(10),
              _buildOrientation(),
            ],
          );
  }

  CustomTextField _buildOrientation() {
    // The old body branched on 'Portrait' / 'Landscape' and
    // then assigned the SAME English word back, so `translatedOrientation` was
    // never translated at all. `labelFor` does the real lookup.
    final translatedOrientation = OrientationExtension.labelFor(
      _model.formHeadModel.orientation,
    );

    return CustomTextField(
      height: 36,
      hint: translatedOrientation,
      label: S.of(context).orientation,
      readOnly: true,
    );
  }

  CustomTextField _buildAccessManagement() {
    // Same no-op as _buildOrientation: every branch handed
    // back the English string it had just matched on.
    final translatedAccess = AccessManagementExtension.labelFor(
      _model.formHeadModel.accessManagement,
    );

    return CustomTextField(
      height: 36,
      hint: translatedAccess,
      label: S.of(context).accessManagement,
      readOnly: true,
    );
  }

  String _getTitle(FormHeadData formHeadModel, BuildContext context) =>
      formHeadModel.titleFor(arabic: context.isArabic);

  Widget _getDescriptionWidget(
    FormHeadData formHeadModel,
    BuildContext context,
  ) {
    // The label follows the app language; the text is the Arabic description
    // in an Arabic UI when there is one (FormHeadData.descriptionFor).
    return CustomTextField(
      minLines: 4,
      maxLines: 10,
      readOnly: true,
      label: S.of(context).description,
      hint: formHeadModel.descriptionFor(arabic: context.isArabic),
    );
  }
}

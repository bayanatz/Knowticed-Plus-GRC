/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: card_form_preview.dart
/// Description: `CardFormPreview` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/helper/extensions.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_form_language.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/a4_container.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/card_preview_actions.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/card_preview_field_builder.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

// Updated: 10/01/2026
class CardFormPreview extends StatelessWidget {
  const CardFormPreview({super.key, this.formModel});

  final FormEntity? formModel;

  static const double a4PortraitWidth = 794.0;
  static const double a4PortraitHeight = 1123.0;
  static const double a4LandscapeWidth = 1123.0;
  static const double a4LandscapeHeight = 794.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, dataState) {
        if (dataState is! CreateFormDataLoaded) {
          return const CircleProgressMaster();
        }

        return BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
          builder: (context, headState) {
            if (headState is! CreateFormHeadLoaded) {
              return const CircleProgressMaster();
            }

            // The paddings typed in the header are in the state, so the
            // preview follows them as they are typed.
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPreviewPages(context, dataState, headState),
                verticalSpace(20),
                CardPreviewActions(
                  formModel: formModel,
                  dataState: dataState,
                  headState: headState,
                ),
                verticalSpace(15),
              ],
            );
          },
        );
      },
    );
  }

  /// Builds all preview services_management_module
  Widget _buildPreviewPages(
    BuildContext context,
    CreateFormDataLoaded dataState,
    CreateFormHeadLoaded headState,
  ) {
    final String horizontalPaddingText = headState.horizontalPadding.trim();
    final String verticalPaddingText = headState.verticalPadding.trim();

    final String horizontalPaddingWestern = (horizontalPaddingText)
        .toEnglishDigits();
    final String verticalPaddingWestern = (verticalPaddingText)
        .toEnglishDigits();

    final double horizontalPadding = horizontalPaddingWestern.isEmpty
        ? 16.0
        : (double.tryParse(horizontalPaddingWestern) ?? 16.0);

    final double verticalPadding = verticalPaddingWestern.isEmpty
        ? 16.0
        : (double.tryParse(verticalPaddingWestern) ?? 16.0);

    // The A4 preview shows the
    // form in ITS language and direction, not the app's.
    final bool formIsArabic =
        FormLanguageDetect.detectFromPages(dataState.pages) ?? context.isArabic;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (
          int pageIndex = 0;
          pageIndex < dataState.pages.length;
          pageIndex++
        ) ...[
          // (large-screen bug report p.2 — "when press hide,
          // page 1 goes down and the hidden pages go up"): a hidden page
          // used to vanish from this list and reappear in a separate block
          // above the editor, so hiding Page 1 moved it below every other
          // page. Each page now keeps its header (with Hide / Expand) in its
          // own position; hiding only collapses its body.
          if (dataState.pages.length > 1) ...[
            verticalSpace(15),
            _buildPageHeader(context, dataState, pageIndex),
            verticalSpace(15),
          ],
          if (dataState.pages[pageIndex].isPageExpanded) ...[
            A4Container(
              key: ValueKey(
                'a4_${pageIndex}_${horizontalPadding}_$verticalPadding',
              ),
              horizontalPadding: horizontalPadding,
              verticalPadding: verticalPadding,
              orientation: headState.orientation,
              onOverflow: (isOverflowing) async {
                if (isOverflowing) {
                  await Future.delayed(const Duration(milliseconds: 1));
                  if (!context.mounted) return;
                  context.read<CreateFormDataCubit>().addPageWithRow(pageIndex);
                }
              },
              watermarkImage: headState.watermark,
              watermarkSize:
                  double.tryParse(headState.watermarkSize.toEnglishDigits()) ??
                  100.0,
              watermarkOpacity:
                  double.tryParse(
                    headState.watermarkOpacity.toEnglishDigits(),
                  ) ??
                  50.0,
              child: FormLanguageScope(
                isArabic: formIsArabic,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (
                      int indexRow = 0;
                      indexRow < dataState.pages[pageIndex].rows.length;
                      indexRow++
                    ) ...[
                      _buildPageRow(
                        context: context,
                        dataState: dataState,
                        pageIndex: pageIndex,
                        rowIndex: indexRow,
                      ),
                      if (indexRow < dataState.pages[pageIndex].rows.length - 1)
                        verticalSpace(15),
                    ],
                  ],
                ),
              ),
            ),
            if (pageIndex < dataState.pages.length - 1) verticalSpace(30),
          ],
        ],
      ],
    );
  }

  /// Builds a single row with all its field controllers
  Widget _buildPageRow({
    required BuildContext context,
    required CreateFormDataLoaded dataState,
    required int pageIndex,
    required int rowIndex,
  }) {
    final row = dataState.pages[pageIndex].rows[rowIndex];
    final controllers = row.controllers;

    final bool hasMultipleColumns =
        row.numOfColumn?.text != '1' && row.numOfColumn?.text != '١';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int index = 0; index < controllers.length; index++) ...[
          if (index != 0) horizontalSpace(15),
          Expanded(
            child: buildPreviewFieldWidget(
              controllers[index].type,
              index,
              rowIndex,
              pageIndex,
              controllers[index],
              hasMultipleColumns,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds page header with hide/expand functionality
  Widget _buildPageHeader(
    BuildContext context,
    CreateFormDataLoaded dataState,
    int pageIndex,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${S.of(context).page} ${pageIndex + 1}',
          style: StyleText.fontSize14Weight500,
        ),
        InkWell(
          onTap: withHaptic(
            () => context.read<CreateFormDataCubit>().expandedPage(pageIndex),
            HapticLevel.low,
          ),
          child: Text(
            dataState.pages[pageIndex].isPageExpanded
                ? S.of(context).hide
                : S.of(context).expand,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.blue,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.blue,
              decorationThickness: 1.0,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: watermark_widget.dart
/// Description: `WatermarkWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:io';


import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/image_uploaded_widget.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/form_builder/form_builder_get_it.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_assets.dart';

class WatermarkWidget extends StatelessWidget {
  const WatermarkWidget({super.key});

  /// Picks the watermark here, in the widget, with the injected picker; the
  /// cubit only stores the result (Home rule 3).
  Future<void> _pickWatermark(BuildContext context) async {
    final CreateFormHeadCubit cubit = context.read<CreateFormHeadCubit>();
    final File? file = await FormBuilderCubits.mediaPicker.pickImageFile();
    if (file != null) cubit.setWatermarkImage(file);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
      builder: (context, state) {
        if (state is! CreateFormHeadLoaded) {
          return const SizedBox.shrink();
        }

        return ContextExtension(context).isTablett
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      S.of(context).watermark,
                      style: StyleText.fontSize14Weight400,
                    ),
                  ),
                  horizontalSpace(20),
                  Expanded(
                    child: state.watermark == null
                        ? Row(
                            children: [
                              customButtonWithSvg(
                                title: S.of(context).uploadWatermark,
                                function: () => _pickWatermark(context),
                                textStyle: StyleText.fontSize14Weight500
                                    .copyWith(color: AppColors.textButton),
                                color: AppColors.primary,
                                image: FormBuilderAssets.uploadIcon,
                                widthImage: 20,
                                heightImage: 20,
                                colorBorder: AppColors.transparent,
                                svgColor: AppColors.textButton,
                              ),
                              const Spacer(),
                            ],
                          )
                        : ImageUploadedWidget(
                            file: state.watermark!,
                            onCloseTap: () => context
                                .read<CreateFormHeadCubit>()
                                .removeWatermarkImage(),
                          ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).watermark,
                    style: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.textButton,
                    ),
                  ),
                  verticalSpace(15),
                  state.watermark == null
                      ? customButtonWithSvg(
                          title: S.of(context).uploadWatermark,
                          function: () => _pickWatermark(context),
                          textStyle: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                          color: AppColors.primary,
                          image: FormBuilderAssets.uploadIcon,
                          widthImage: 20,
                          heightImage: 20,
                          colorBorder: AppColors.transparent,
                          svgColor: AppColors.textButton,
                        )
                      : ImageUploadedWidget(
                          file: state.watermark!,
                          onCloseTap: () => context
                              .read<CreateFormHeadCubit>()
                              .removeWatermarkImage(),
                        ),
                ],
              );
      },
    );
  }
}

/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: fill_demo_form_button.dart
/// Description: `FillDemoFormButton` — "Fill demo data" button on the Create
///          Form screen. One tap fills every header field and replaces the
///          editor with a demo form that uses all 18 field types, so a
///          complete form can be published and tested right away.
/// Author: Amr Mesbah
/// Created at: 13/10/2026
///
/// Visible in debug builds and to the demo accounts only (the same rule as
/// the home screen's FormBuilderTestButton), and only when creating — never
/// while editing or restoring an existing form.
library;

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/ui/widgets/form_builder_test_button.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';

class FillDemoFormButton extends StatelessWidget {
  const FillDemoFormButton({super.key});

  static bool get isVisible => FormBuilderTestButton.isVisible;

  void _fill(BuildContext context) {
    final bool isTablet = ContextExtension(context).isTablett;

    context.read<CreateFormHeadCubit>().fillDemoData();
    context.read<CreateFormDataCubit>().fillDemoData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isTablet
              ? S.of(context).fbDemoFilledTablet
              : S.of(context).fbDemoFilledPhone,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return customButtonWithSvg(
      title: S.of(context).fbFillDemoData,
      function: () => _fill(context),
      textStyle: StyleText.fontSize14Weight500.copyWith(
        color: AppColors.primary,
      ),
      color: AppColors.card,
      colorBorder: AppColors.primary,
      image: '',
      widthImage: 0,
      heightImage: 0,
    );
  }
}

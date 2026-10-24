/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: create_head_form_screen.dart
/// Description: `CreateHeadFormScreen` page, state and UI of the `CreateHeadFormScreen` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Phone header step only; FormEditorScreen prepares
///                       the cubits.
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder/helpers/breadcrumb_nav.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_title_padding.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/head_screen_body.dart';

/// Phone header step of the form editor. [FormEditorScreen] prepares the
/// cubits; Next opens the pages step (`CreateFormDataScreen`).
class CreateHeadFormScreen extends StatelessWidget {
  const CreateHeadFormScreen({
    super.key,
    this.formModel,
    required this.formKey,
  });
  final FormEntity? formModel;

  /// The header Form key of the editor screen this step belongs to.
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    // The frame supplies the phone back-chevron.
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).createNewForm,
        onFirstTap: breadcrumbPop(context, 1),
        child: Padding(
          // Top is 0 on a vertical tablet — see formBuilderTopGap.
          padding: EdgeInsets.only(
            top: formBuilderTopGap(context, 20.h),
            left: 15.w,
            right: 15.w,
          ),
          child: BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
            buildWhen: (previous, current) =>
                previous.runtimeType != current.runtimeType,
            builder: (context, state) {
              // FB-HOME-18: one Form key per editor screen (a new GlobalKey
              // on every rebuild meant the header was never validated).
              return Form(
                key: formKey,
                child: HeadScreenBody(formModel: formModel),
              );
            },
          ),
        ),
      ),
    );
  }
}

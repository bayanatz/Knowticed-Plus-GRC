/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: create_form_data_screen.dart
/// Description: `CreateFormDataScreen` page, state and UI of the `CreateFormDataScreen` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Phone pages step only; keeps the pages prepared by
///                       FormEditorScreen.
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder/helpers/breadcrumb_nav.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_title_padding.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/form_editor_keys.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/create_data_screen_body.dart';

/// Phone pages step of the form editor, opened by Next on the header step.
/// [FormEditorScreen] already prepared the cubits, so the pages typed here
/// survive going back to the header and on again.
class CreateFormDataScreen extends StatefulWidget {
  const CreateFormDataScreen({super.key, this.formModel});

  final FormEntity? formModel;

  @override
  State<CreateFormDataScreen> createState() => _CreateFormDataScreenState();
}

class _CreateFormDataScreenState extends State<CreateFormDataScreen> {
  /// This page's Form key (kept, so a closing page never shares one).
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = context.read<FormEditorKeys>().renewData();
  }

  @override
  Widget build(BuildContext context) {
    // The frame supplies the phone back-chevron. FormEditorScreen, under
    // this page, tells the user when a structure change is refused.
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).createNewForm,
        onFirstTap: breadcrumbPop(context, 1),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 15.w, right: 15.w),
            child: Form(
              key: _formKey,
              child: CreateDataScreenBody(formModel: widget.formModel),
            ),
          ),
        ),
      ),
    );
  }
}

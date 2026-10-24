/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: form_editor_screen.dart
/// Description: `FormEditorScreen`, the one entry to the form editor
///              (create, edit, deleted form). It prepares both editor
///              cubits once; tablets show the header, pages and preview
///              side by side, phones show the header step
///              (`CreateHeadFormScreen`), whose Next opens the pages step.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - One editor entry for phone and tablet (Home rule 9).
library;

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/create_data_screen_body.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/head_screen_body.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/card_form_preview.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/pages/create_head_form_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/form_editor_keys.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/structure_locked_listener.dart';

/// The one entry to the form editor, on every screen size.
class FormEditorScreen extends StatefulWidget {
  const FormEditorScreen({super.key, this.formModel});

  /// The form being edited, or null for a new form.
  final FormEntity? formModel;

  @override
  State<FormEditorScreen> createState() => _FormEditorScreenState();
}

class _FormEditorScreenState extends State<FormEditorScreen> {
  /// This screen's header Form key (a closing editor keeps its own).
  late final GlobalKey<FormState> _headKey;

  @override
  void initState() {
    super.initState();
    // Initialize both Cubits
    final headCubit = context.read<CreateFormHeadCubit>();
    final dataCubit = context.read<CreateFormDataCubit>();

    // Fresh Form keys, so this screen never shares one with a closing one.
    final FormEditorKeys keys = context.read<FormEditorKeys>();
    _headKey = keys.renewHead();
    keys.renewData();
    headCubit.resetController();
    dataCubit.resetController();

    headCubit.init(editFormModel: widget.formModel);
    dataCubit.init(editFormModel: widget.formModel);
  }

  @override
  Widget build(BuildContext context) {
    return StructureLockedListener(
      child: ContextExtension(context).isTablett
          ? _buildSideBySide(context)
          : CreateHeadFormScreen(
              formModel: widget.formModel,
              formKey: _headKey,
            ),
    );
  }

  /// Tablet / desktop: header, pages and preview on one screen.
  Widget _buildSideBySide(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
        // Only the loaded / not-loaded switch matters here; the header,
        // pages and preview listen for their own changes.
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        builder: (context, headState) {
          if (headState is! CreateFormHeadLoaded) {
            return const CircleProgressMaster();
          }

          return Form(
            key: _headKey,
            child: ListView(
              // Bug report #6: 20.sp horizontal, same as every other form
              // builder page (formBuilderTitlePadding).
              padding: EdgeInsetsDirectional.only(
                start: 20.sp,
                end: 20.sp,
                top: 0.h,
              ),
              children: [
                _buildAppBar(context),
                //head Section
                HeadScreenBody(formModel: widget.formModel),
                verticalSpace(20),
                // Hidden pages stay in their own place in CardFormPreview /
                // CreateDataPagesList, each with its own Expand link.
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 284.w,
                      child: CreateDataScreenBody(formModel: widget.formModel),
                    ),
                    horizontalSpace(15),
                    Expanded(
                      child: CardFormPreview(formModel: widget.formModel),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return PaginationAppBar(
      // The
      // breadcrumb was hard-coded English.
      screensTitles: [S.of(context).formBuilder, _getTextAppBar()],
      // 20.sp from the top, flush with the content's start edge (#6).
      padding: EdgeInsetsDirectional.only(top: 20.sp, bottom: 20.sp),
    );
  }

  String _getTextAppBar() {
    if (widget.formModel == null) {
      return S.of(context).creatingForm;
    }
    if (widget.formModel!.status == FormStatus.deleted) {
      return S.of(context).fbDeletingFormDetails;
    }
    return S.of(context).fbEditingFormDetails;
  }
}

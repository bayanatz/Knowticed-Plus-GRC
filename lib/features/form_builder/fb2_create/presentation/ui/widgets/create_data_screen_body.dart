/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: create_data_screen_body.dart
/// Description: `CreateDataScreenBody` widget, `MaxValueTextInputFormatter`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/create_data_action_buttons.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/create_data_pages_list.dart';

class CreateDataScreenBody extends StatelessWidget {
  const CreateDataScreenBody({super.key, this.formModel});
  final FormEntity? formModel;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, state) {
        // FB-HOME-16: show the error instead of spinning forever.
        if (state is CreateFormDataError) {
          return Center(
            child: Text(state.message, style: StyleText.fontSize14Weight400),
          );
        }
        if (state is! CreateFormDataLoaded) {
          return const CircleProgressMaster();
        }

        final isReadOnly = _isReadOnly();
        return _buildBody(context, state, isReadOnly);
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateDataPagesList(state: state, isReadOnly: isReadOnly),
        CreateDataActionButtons(formModel: formModel),
      ],
    );
  }

  bool _isReadOnly() {
    if (formModel == null) {
      return false;
    }
    if (formModel!.status == FormStatus.deleted) {
      return true;
    }
    if (formModel!.submissions?.isNotEmpty ?? false) {
      return true;
    }
    return false;
  }
}

class MaxValueTextInputFormatter extends TextInputFormatter {
  final int maxValue;

  MaxValueTextInputFormatter({required this.maxValue});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final intValue = int.tryParse(newValue.text);
    if (intValue == null) {
      return oldValue;
    }

    if (intValue > maxValue) {
      return oldValue;
    }

    return newValue;
  }
}

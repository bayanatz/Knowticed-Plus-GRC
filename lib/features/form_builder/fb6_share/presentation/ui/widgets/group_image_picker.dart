/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: group_image_picker.dart
/// Description: Connects the shared [AddImageWidget] to [FormsGroupCubit].
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/form_builder/helpers/add_image_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_state.dart';

/// The group's image: a newly picked file first, else the saved image URL.
class GroupImagePicker extends StatelessWidget {
  const GroupImagePicker({super.key, this.isPickerEnabled = true});

  /// False shows the image without letting the user change it.
  final bool isPickerEnabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormsGroupCubit, FormsGroupState>(
      builder: (context, state) {
        final FormsGroupLoaded? loaded =
            state is FormsGroupLoaded ? state : null;
        return AddImageWidget(
          image: loaded?.groupImage?.path ?? loaded?.selectedGroup?.groupImage,
          readOnly: loaded == null || !isPickerEnabled,
          onImagePicked: (file) =>
              context.read<FormsGroupCubit>().setGroupImage(file),
        );
      },
    );
  }
}

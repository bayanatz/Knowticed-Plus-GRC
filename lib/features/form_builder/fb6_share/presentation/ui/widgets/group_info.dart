/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: group_info.dart
/// Description: `GroupInfo` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Keep for .tr translations
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_state.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';

/// The group name and description fields. Owns their text controllers
/// (Share rule 2); typing goes to [FormsGroupCubit], and the texts the
/// cubit replaces (new group, open a group) are copied back in.
class GroupInfo extends StatefulWidget {
  const GroupInfo({this.isReadOnly = false, super.key});

  final bool isReadOnly;

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  int _fieldsVersion = -1;

  bool get isReadOnly => widget.isReadOnly;

  @override
  void initState() {
    super.initState();
    final FormsGroupState state = context.read<FormsGroupCubit>().state;
    if (state is FormsGroupLoaded) _sync(state);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  /// Copies the cubit's texts in when it replaced them.
  void _sync(FormsGroupLoaded state) {
    if (state.fieldsVersion == _fieldsVersion) return;
    _fieldsVersion = state.fieldsVersion;
    if (_name.text != state.groupName) _name.text = state.groupName;
    if (_description.text != state.groupDescription) {
      _description.text = state.groupDescription;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FormsGroupCubit, FormsGroupState>(
      listener: (context, state) {
        if (state is FormsGroupLoaded) _sync(state);
      },
      builder: (context, state) {
        if (state is! FormsGroupLoaded) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            _buildGroupNameFields(context, state),
            verticalSpace(15),
            _buildDescriptionField(context, state),
          ],
        );
      },
    );
  }

  /// "This field is required" once a Save / Create was attempted with the
  /// field empty; null otherwise.
  String? _requiredError(
    BuildContext context,
    FormsGroupLoaded state,
    String value,
  ) {
    if (isReadOnly || !state.submitted) return null;
    return value.trim().isEmpty ? S.of(context).thisFieldIsRequired : null;
  }

  Widget _buildDescriptionField(BuildContext context, FormsGroupLoaded state) {
    return CustomTextField(
      minLines: 4,
      maxLines: 10,
      maxLength: 500,
      showCharCount: true,
      readOnly: isReadOnly,
      controller: _description,
      onChanged: (value) =>
          context.read<FormsGroupCubit>().updateGroupDescription(value),
      // Large-screen bug report p.11: required (red * + error after Save).
      required: !isReadOnly,
      errorText: _requiredError(context, state, state.groupDescription),
      // Bug report p.47 / p.49 / p.55: localized label + a hint.
      label: S.of(context).description,
      // Shown on the read-only details page too (p.47 asks for it there).
      hint: S.of(context).enterDescription,
    );
  }

  Widget _buildGroupNameField(BuildContext context, FormsGroupLoaded state) {
    return CustomTextField(
      controller: _name,
      onChanged: (value) =>
          context.read<FormsGroupCubit>().updateGroupName(value),
      height: 36,
      readOnly: isReadOnly,
      required: !isReadOnly,
      errorText: _requiredError(context, state, state.groupName),
      // Bug report p.49 / p.55: localized label + a hint.
      label: S.of(context).groupName,
      hint: isReadOnly ? null : S.of(context).fbEnterGroupName,
    );
  }

  Widget _buildGroupNameFields(BuildContext context, FormsGroupLoaded state) {
    return !ContextExtension(context).isTablett
        ? _buildGroupNameField(context, state)
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: _buildGroupNameField(context, state)),
              const Expanded(child: SizedBox.shrink()),
            ],
          );
  }
}

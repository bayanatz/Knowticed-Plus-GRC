// by : Mohamed Ashraf

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/messaging/helpers/constants/messaging_assets.dart';
import 'package:knowticed_plus/features/messaging/helpers/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/controller/groups_controller.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/widgets/switch_button/switch_button_title.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/widgets/switch_button/switch_button_title_subtitle.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class AboutGroupProfile extends StatelessWidget {
  const AboutGroupProfile({
    super.key,
    required this.groupDescription,
    required this.groupName,
  });

  final TextEditingController groupDescription;
  final TextEditingController groupName;

  @override
  Widget build(BuildContext context) {
    var isTablet = ContextExtension(context).isTablett;

    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, state) {
        if (state is! GroupsLoaded) {
          return const SizedBox();
        }

        final controller = context.read<GroupsCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpace(isTablet ? 40 : 32),
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: AppColors.grey,
                  backgroundImage: state.groupImage != null
                      ? FileImage(state.groupImage!.absolute)
                      : null,
                ),
                GestureDetector(
                  onTapDown: (_) => HapticController.high(),
                  onTap: () async {
                    // Picker lives in the page/service now — cubit only stores
                    // the result (§16/§20). Old pickGroupImage() was removed.
                    final picked =
                        await MediaPickerService().pickImage(fromCamera: false);
                    if (picked?.path != null) {
                      controller.setGroupImage(File(picked!.path!));
                    }
                  },
                  child: CircleAvatar(
                    radius: 12.r,
                    backgroundColor: AppColors.primary,
                    child: CustomSvgImage.natural(
                      assetPath: AppAssets.camera,
                      width: 16.w,
                      height: 16.h,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
              ],
            ),
            verticalSpace(24),
            Text(
              S.of(context).groupName,
              style: ContextExtension(context).isTablett
                  ? StyleText.fontSize16Weight500
                  : StyleText.fontSize14Weight600,
            ),
            verticalSpace(8),
            CustomTextField(
              hint: S.of(context).Texthere,
              maxLength: 100,
              controller: groupName,
            ),
            verticalSpace(23),
            Text(
              S.of(context).description,
              style: ContextExtension(context).isTablett
                  ? StyleText.fontSize16Weight500
                  : StyleText.fontSize14Weight600,
            ),
            verticalSpace(8),
            CustomTextField(
              hint: S.of(context).Texthere,
              maxLength: 300,
              maxLines: 4,
              controller: groupDescription,
            ),
            verticalSpace(28),
            SwitchButtonTitleSubTitle(
              title: S.of(context).makePrivate,
              subTitle: S.of(context).itCanViewOrJoinWithInvite,
              value: state.isMakePrivateEnabled,
              onChanged: controller.onChangedMakePrivate,
            ),
            verticalSpace(17),
            SwitchButtonTitleSubTitle(
              title: S.of(context).adminOnly,
              subTitle: S.of(context).onlyAdminsCanShareContent,
              value: state.isAdminEnabled,
              onChanged: controller.onChangedAdmin,
            ),
            verticalSpace(17),
            SwitchButtonTitle(
              title: S.of(context).disappearingMessages,
              value: state.isDisappearingMessagesEnabled,
              onChanged: controller.onChangedDisappearingMessages,
            ),
            verticalSpace(17),
            SwitchButtonTitle(
              title: S.of(context).muteNotifications,
              value: state.isMuteEnabled,
              onChanged: controller.onChangMuteMessages,
            ),
            verticalSpace(24),
            Align(
              alignment:
                  isTablet ? Alignment.bottomRight : Alignment.bottomCenter,
              child: customButton(
                width: isTablet ? 105.w : double.infinity,
                textColor: AppColors.base,
                color: AppColors.primary,
                title: S.of(context).Save,
                textStyle: isTablet
                    ? StyleText.fontSize18Weight500
                        .copyWith(color: AppColors.textButton)
                    : StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.textButton),
                function: () async {
                  await controller.updateGroupData();
                },
              ),
            ),
            verticalSpace(24),
          ],
        );
      },
    );
  }
}

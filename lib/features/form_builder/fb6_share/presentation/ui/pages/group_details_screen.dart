/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: group_details_screen.dart
/// Description: `GroupDetailsScreen` page, state and UI of the `GroupDetailsScreen` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder/helpers/breadcrumb_nav.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Keep for .tr translations
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_state.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/group_info.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/get_dialog_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';

import 'package:flutter/services.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/dialogs/default_dialog.dart';
import 'package:knowticed_plus/features/form_builder/helpers/person_state_view.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/pages/edit_group_screen.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/group_image_picker.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_haptic.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_title_padding.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/share_actions.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _gridAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start animation after a brief delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _gridAnimationController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);

    // Bug report p.47: the last crumb is the group's own name, not the
    // generic "Group Details".
    final FormsGroupState groupState = context.watch<FormsGroupCubit>().state;
    final String? groupName = groupState is FormsGroupLoaded
        ? groupState.selectedGroup?.groupName
        : null;

    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).detailsOfTitle(widget.form.getTitle),
        thirdTitle: S.of(context).group,
        fourthTitle: (groupName != null && groupName.trim().isNotEmpty)
            ? groupName
            : S.of(context).groupDetails,
        onFirstTap: breadcrumbPop(context, 3),
        onSecondTap: breadcrumbPop(context, 2),
        onThirdTap: breadcrumbPop(context, 1),
        child: BlocBuilder<FormsGroupCubit, FormsGroupState>(
          builder: (context, state) {
            if (state is! FormsGroupLoaded) {
              return const CircleProgressMaster();
            }

            // The frame scrolls the content itself on mobile; on tablet it hands
            // the child a bounded height, so the scroll view stays here.
            final Widget content = Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 0 on a vertical tablet — see formBuilderTopGap.
                  verticalSpace(formBuilderTopGap(context, 30)),
                  // Editing / deleting a group is group
                  // management: Role Management's "Create Group Permissions".
                  if (FormBuilderAccess.canCreateGroup)
                    _buildManageRow(context),
                  verticalSpace(15),
                  // No Expanded: the frame scrolls this content on mobile, so
                  // children have to size themselves.
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const GroupImagePicker(),
                          verticalSpace(15),
                          const GroupInfo(isReadOnly: true),
                          if (isTablet) ...[
                            verticalSpace(15),
                            Text(
                              S.of(context).EmployeeInformation,
                              style: StyleText.fontSize18Weight500,
                            ),
                          ],
                          verticalSpace(8),
                          _buildDataWidget(context, state),
                        ],
                      ),
                    ),
                  ),
                  verticalSpace(15),
                ],
              ),
            );

            return isTablet ? SingleChildScrollView(child: content) : content;
          },
        ),
      ),
    );
  }

  /// Edit and Delete (group management).
  Widget _buildManageRow(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        customButtonWithSvg(
          // Bug report p.47 ("edit button color"): the primary
          // yellow, like the app's other Edit actions.
          title: S.of(context).edit,
          image: AppAssets.edit,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.textButton,
          ),
          color: AppColors.primary,
          colorBorder: AppColors.primary,
          svgColor: AppColors.textButton,
          widthImage: 16,
          heightImage: 16,
          width: 100,
          function: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  return EditGroupScreen(form: widget.form);
                },
              ),
            );
          },
        ),
        horizontalSpace(10),
        customButtonWithSvg(
          title: S.of(context).delete,
          image: AppAssets.delete,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.white,
          ),
          color: AppColors.red,
          colorBorder: AppColors.red,
          svgColor: AppColors.white,
          widthImage: 16,
          heightImage: 16,
          width: 100,
          function: () {
            hapticController.triggerHapticFeedback(
              vibration: VibrateType.heavyImpact,
              hapticFeedback: HapticFeedback.heavyImpact,
            );
            GetDialogHelper.generalDialog(
              context: context,
              child: DefaultDialog(
                title: S.of(context).fbDeleteGroup,
                subTitle: S.of(context).areYouSureDeleteGroup,
                autoClose: false,
                lottieAsset: AppAssets.trash,
                showButtons: true,
                onConfirm: () async {
                  context.pop();
                  await ShareActions.deleteGroup(
                    context,
                    context.read<FormsGroupCubit>(),
                  );
                  if (context.mounted) {
                    context.pop();
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataWidget(BuildContext context, FormsGroupLoaded state) {
    if (state.selectedGroup == null) {
      return Center(child: Text(S.of(context).fbNoGroupSelected));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
          context,
        ),
        mainAxisSpacing: 16.sp,
        crossAxisSpacing: 16.sp,
        mainAxisExtent: 73.h,
      ),
      itemCount: state.selectedGroup!.members.length,
      itemBuilder: (context, index) {
        return _buildAnimatedGridItem(
          index: index,
          child: FormPersonStateView(
            color: AppColors.background,
            person: state.selectedGroup!.members[index],
            onTap: null,
          ),
        );
      },
    );
  }

  /// Builds an animated grid item with slide-in animation
  Widget _buildAnimatedGridItem({required int index, required Widget child}) {
    // Stagger the animation based on index
    final delay = index * 0.05; // 50ms delay between items

    final slideAnimation =
        Tween<Offset>(
          begin: const Offset(-1.0, 0.0), // Slide from left
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _gridAnimationController,
            curve: Interval(
              delay.clamp(0.0, 1.0),
              (delay + 0.5).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        );

    final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _gridAnimationController,
        curve: Interval(
          delay.clamp(0.0, 1.0),
          (delay + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeIn,
        ),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(opacity: opacityAnimation, child: child),
    );
  }
}

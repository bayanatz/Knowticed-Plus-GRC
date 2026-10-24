/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: group_screen.dart
/// Description: `GroupScreen` page, state and UI of the `GroupScreen` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder/helpers/breadcrumb_nav.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_state.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/pages/group_details_screen.dart';

import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_check_box.dart';
import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/entities/group_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/avatar_stack_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/search_bar_group_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/helper_format.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_title_padding.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/share_actions.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _gridAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _gridAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
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

  void _restartAnimation() {
    _gridAnimationController.reset();
    _gridAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).detailsOfTitle(widget.form.getTitle),
        thirdTitle: S.of(context).share,
        fourthTitle: S.of(context).group,
        onFirstTap: breadcrumbPop(context, 3),
        onSecondTap: breadcrumbPop(context, 2),
        onThirdTap: breadcrumbPop(context, 1),
        child: BlocConsumer<FormsGroupCubit, FormsGroupState>(
          listener: (context, state) {
            // Restart animation when groups are loaded or filtered
            if (state is FormsGroupLoaded && state.groups.isNotEmpty) {
              _restartAnimation();
            }
          },
          builder: (context, state) {
            if (state is FormsGroupLoading) {
              return const CircleProgressMaster();
            }

            if (state is! FormsGroupLoaded) {
              return const CircleProgressMaster();
            }

            // The frame scrolls the content itself on mobile; on tablet it hands
            // the child a bounded height, so the scroll view stays here.
            final Widget content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).groupInformation,
                  style: StyleText.fontSize18Weight500,
                ),
                verticalSpace(8),
                SearchFormGroupTablet(form: widget.form),
                verticalSpace(15),
                // No Expanded: the frame scrolls this content on mobile, so
                // children have to size themselves.
                state.groups.isNotEmpty
                    ? _buildDataWidget(context, state)
                    : _buildEmptyState(context),
                verticalSpace(15),
                if (state.groups.isNotEmpty)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: customButtonWithSvg(
                      title: S.of(context).review,
                      function: () => _review(context),
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                      // Bug report p.52: same width as "Create Group" above
                      // it (150.w), so the two line up vertically.
                      fixedWidth: ContextExtension(context).isPhone
                          ? null
                          : 150.w,
                      color: AppColors.primary,
                      image: '',
                      widthImage: 0,
                      heightImage: 0,
                      colorBorder: AppColors.transparent,
                    ),
                  ),
                verticalSpace(15),
              ],
            );

            return ContextExtension(context).isTablett
                ? SingleChildScrollView(child: content)
                : content;
          },
        ),
      ),
    );
  }

  /// "No Group Found".
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Bug report p.60: smaller, so the "No Group
          // Found" label sits right under the art.
          CustomEmptyState(
            lottiePath: AppAssets.noData,
            size: 260,
            verticalPadding: 0,
          ),
          Text(
            S.of(context).noGroupFound,
            style: StyleText.fontSize14Weight500,
          ),
        ],
      ),
    );
  }

  /// Review: selects the members of the picked groups, then opens the
  /// share dialog.
  Future<void> _review(BuildContext context) async {
    final shareCubit = context.read<ShareCubit>();

    // 1. FIRST: Add the members of the picked groups.
    shareCubit.clearSelectedPersons();
    for (final PersonEntity person
        in context.read<FormsGroupCubit>().selectedGroupMembers()) {
      shareCubit.selectPerson(person, includeExisting: true);
    }

    // 2. THEN: Refresh filtered list
    shareCubit.newSelectedSearch("");

    // 3. WAIT: Allow state to propagate
    await Future.microtask(() {});

    // 4. FINALLY: Show dialog WITH the cubit instance
    if (context.mounted) {
      AppDialogs.shareAccessDialog(
        context,
        () {
          ShareActions.grantAccess(context, shareCubit);
        },
        shareCubit: shareCubit, // PASS THE CUBIT
      );
    }
  }

  Widget _buildDataWidget(BuildContext context, FormsGroupLoaded state) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
          context,
        ),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 101,
      ),
      // #36: the searched/sorted view.
      itemCount: state.filteredGroups.length,
      itemBuilder: (context, index) {
        return _buildAnimatedGridItem(
          index: index,
          child: _getGridViewItem(
            context: context,
            group: state.filteredGroups[index],
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

  Widget _getGridViewItem({
    required BuildContext context,
    required GroupEntity group,
  }) {
    return GestureDetector(
      onTap: () {
        HapticController.low(); // list row: on the tap (X-117)
        context.read<FormsGroupCubit>().initGroupDetails(group);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupDetailsScreen(form: widget.form),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsetsDirectional.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: AppColors.disabledGrey,
                borderRadius: BorderRadius.circular(8.r),
              ),
              // Bug report p.52 ("add default image for groups"): a group
              // saved with an empty image URL hit `Image.network('')`, which
              // fails and leaves a blank square. Empty and broken URLs now
              // fall back to the default image icon too.
              child: Center(
                child: (group.groupImage ?? '').trim().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          group.groupImage!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _defaultGroupImage(),
                        ),
                      )
                    : _defaultGroupImage(),
              ),
            ),
            horizontalSpace(10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  FormatHelper.capitalize(group.groupName),
                  style: StyleText.fontSize16Weight500,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticController.low(); // list row: on the tap (X-117)
                    context.read<FormsGroupCubit>().selectGroup(group);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: CustomCheckBox(
                      isSelected: group.isSelected,
                      borderColor: AppColors.borderGrey,
                    ),
                  ),
                ),
                const Spacer(),
                AvatarStack(
                  imageUrls: () {
                    final urls = group.getUsersAvatar();

                    return urls;
                  }(),
                  maxVisible: 3,
                  avatarSize: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The placeholder shown when a group has no usable image.
  ///
  /// `AppAssets.image` is a PNG. The card used to draw it with
  /// `SvgPicture.asset`, which cannot decode a PNG and painted nothing — the
  /// real reason the squares in bug report p.52 were blank.
  Widget _defaultGroupImage() {
    return Image.asset(
      AppAssets.image,
      height: 24,
      width: 24,
      fit: BoxFit.contain,
    );
  }
}

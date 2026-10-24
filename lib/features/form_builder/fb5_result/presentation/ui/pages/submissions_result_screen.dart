/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: submissions_result_screen.dart
/// Description: `SubmissionsResultScreen` page, state and UI of the `SubmissionsResultScreen` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_view_mode_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/user_grid_item.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/table/result_table_builder.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/pages/submissions_details_screen.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/table/default_data_table.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/search_bar_submissions_widget.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// The Submissions tab: people who answered, as a grid or a table, with Export.
class SubmissionsResultScreen extends StatefulWidget {
  const SubmissionsResultScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<SubmissionsResultScreen> createState() =>
      _SubmissionsResultScreenState();
}

class _SubmissionsResultScreenState extends State<SubmissionsResultScreen>
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

  /// The export file name typed in the download dialog (owned here, not
  /// in the cubit state).
  final TextEditingController _fileNameController = TextEditingController();

  @override
  void dispose() {
    _gridAnimationController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  // Restart animation when filtered list changes or view switches
  void _restartAnimation() {
    _gridAnimationController.reset();
    _gridAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResultCubit, ResultState>(
      listener: (context, state) {
        // Restart animation when filtered list changes or view switches
        if (state is ResultLoaded) {
          _restartAnimation();
        }
      },
      builder: (context, state) {
        if (state is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<ResultCubit>();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SearchBarSubmissionsWidget(),
            verticalSpace(15),
            if (ContextExtension(context).isTablett) ...[
              Align(
                alignment: Alignment.centerRight,
                child: _actionButtons(context, cubit, state),
              ),
              verticalSpace(15),
            ],
            _buildDataWidget(context, cubit, state),
          ],
        );
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Large-screen bug report p.12: 4 cards a row on a large screen (was 3
    // up to 2400). Exactly 1200 also fell through every branch to 1.
    if (screenWidth > 3600) return 6;
    if (screenWidth > 2400) return 5;
    if (screenWidth >= 1200) return 4;
    if (screenWidth > 600) return 2;
    return 1;
  }

  Widget _getGridViewItem({
    required bool isPhone,
    required BuildContext context,
    required UserGridItem model,
    required ResultCubit cubit,
  }) {
    return MouseRegion(
      child: GestureDetector(
        onTapDown: (_) => HapticController.low(),
        onTap: () {
          // Opening a response is "View Submissions".
          if (!FormBuilderAccess.canViewSubmissions) return;
          cubit.selectUser(model);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SubmissionsDetailsScreen(form: widget.form),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
          ),
          // Large-screen bug report p.12: tighter padding (was 13 / 10).
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.r),
                  child: SizedBox(
                    child: CustomSvgImage(
                      assetPath:
                          "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                      width: 45.w,
                      height: 45.h,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              horizontalSpace(8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ellipsised: four cards a row on a large screen
                    // leaves less room for long names and job titles.
                    Text(
                      FormatHelper.capitalize(model.person.name),
                      style: StyleText.fontSize14Weight500,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${FormatHelper.capitalize(model.person.departmentName)} ',
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.spanText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            FormatHelper.capitalize(model.person.title),
                            style: StyleText.fontSize12Weight500
                                .copyWith(color: AppColors.spanText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        horizontalSpace(4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: S.of(context).date,
                                style: StyleText.fontSize10Weight400
                                    .copyWith(color: AppColors.spanText),
                              ),
                              TextSpan(
                                text:
                                    ' ${FormDateTimeHelper.formatDate(model.submissionTime!)}',
                                style: StyleText.fontSize10Weight400
                                    .copyWith(color: AppColors.fullBlack),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButtons(
      BuildContext context, ResultCubit cubit, ResultLoaded state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (FormBuilderAccess.canExportSubmissionData)
          _buildIconWidget(
            onTap: () {
              AppDialogs.downloadFile(
                _fileNameController,
                context,
                // The file-name dialog closes itself; ResultScreen shows the
                // outcome from the cubit's notice.
                () => cubit.exportToCSV(_fileNameController.text.trim()),
              );
            },
            asset: AppAssets.export,
            text: S.of(context).export,
            showText: ContextExtension(context).isTablett,
            isPrime: true,
          ),
        _buildSpace(context),
        // 22/10/2026 — Owner: the list icon was the three-lines glyph that
        // looks like Sort. The app's one list / grid switch instead.
        customViewModeButton(
          mode: ViewMode.list,
          isSelected: !state.isGridView,
          function: () => cubit.changeDataView(false),
        ),
        _buildSpace(context),
        customViewModeButton(
          mode: ViewMode.grid,
          isSelected: state.isGridView,
          function: () => cubit.changeDataView(true),
        ),
      ],
    );
  }

  Widget _buildSpace(BuildContext context) {
    double space = ContextExtension(context).isPhone ? 10 : 15;
    return horizontalSpace(space);
  }

  Widget _buildIconWidget({
    required String asset,
    required String text,
    Function()? onTap,
    required bool showText,
    bool isPrime = false,
  }) {
    return GestureDetector(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      child: Container(
        height: 38,
        width: showText ? 100 : 38,
        decoration: BoxDecoration(
          color: isPrime ? AppColors.primary : AppColors.card,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          shape: BoxShape.rectangle,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Same glyph box and colours as every other list / grid toggle
              // (inventory, services): 20.sp, scaled down inside the button,
              // textButton when selected, black / white when not.
              CustomSvgImage.natural(
                assetPath: asset,
                width: 20.sp,
                height: 20.sp,
                fit: BoxFit.scaleDown,
                color: isPrime
                    ? AppColors.textButton
                    : (Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white),
              ),
              if (showText) ...[
                horizontalSpace(8),
                Text(
                  text,
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: isPrime ? AppColors.black : AppColors.secondaryBlack,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an animated grid item with slide-in animation
  Widget _buildAnimatedGridItem({
    required int index,
    required Widget child,
  }) {
    // Stagger the animation based on index
    final delay = index * 0.05; // 50ms delay between items

    final slideAnimation = Tween<Offset>(
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

    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
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
      child: FadeTransition(
        opacity: opacityAnimation,
        child: child,
      ),
    );
  }

  Widget _buildDataWidget(
      BuildContext context, ResultCubit cubit, ResultLoaded state) {
    // Empty state when the
    // search / department filter leaves nothing to show.
    // Loading circle while the users load; the empty
    // state only when loading is done and nothing matches.
    if (state.isLoadingUsers) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: const Center(child: CircleProgressMaster()),
      );
    }
    if (state.filteredSubmittedUsers.isEmpty) {
      return const CustomEmptyState();
    }
    if (state.isGridView || !ContextExtension(context).isTablett) {
      return BounceSwitcher(
        // Bounce when switching list <-> grid view.
        triggerValue: state.isGridView,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(context),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 66.h,
          ),
          itemCount: state.filteredSubmittedUsers.length,
          itemBuilder: (context, index) {
            var width = MediaQuery.of(context).size.width;
            var isPhone = width <= 600;
            return _buildAnimatedGridItem(
              index: index,
              child: _getGridViewItem(
                context: context,
                isPhone: isPhone,
                model: state.filteredSubmittedUsers[index],
                cubit: cubit,
              ),
            );
          },
        ),
      );
    } else {
      return BounceSwitcher(
        // Bounce when switching list <-> grid view.
        triggerValue: state.isGridView,
        child: DefaultDataTable(
          columns: buildResultTableColumns(state),
          rows: buildResultTableRows(state),
        ),
      );
    }
  }
}

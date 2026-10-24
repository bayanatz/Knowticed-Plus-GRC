/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: search_bar_submissions_widget.dart
/// Description: `SearchBarSubmissionsWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/results_department_filter.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Search box, Department filter and (phone) Export of the Submissions tab.
class SearchBarSubmissionsWidget extends StatefulWidget {
  const SearchBarSubmissionsWidget({super.key});

  @override
  State<SearchBarSubmissionsWidget> createState() =>
      _SearchBarSubmissionsWidgetState();
}

class _SearchBarSubmissionsWidgetState
    extends State<SearchBarSubmissionsWidget> {
  /// The search box text. Owned by this widget, not the cubit.
  late final TextEditingController _searchController;

  /// The export file name typed in the download dialog.
  final TextEditingController _fileNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<ResultCubit>().state;
    _searchController = TextEditingController(
        text: state is ResultLoaded ? state.searchQuery : '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    bool showText = widthScreen > 1200;

    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, state) {
        if (state is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<ResultCubit>();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildSearchBar(context, widthScreen, cubit, state),
            if (ContextExtension(context).isTablett) ...[
              _buildSpace(context),
              const ResultsDepartmentFilter(),
            ],
            if (!ContextExtension(context).isTablett &&
                FormBuilderAccess.canExportSubmissionData) ...[
              _buildSpace(context),
              _buildIconWidget(
                asset: AppAssets.export,
                text: '',
                onTap: () {
                  AppDialogs.downloadFile(
                    _fileNameController,
                    context,
                    // The file-name dialog closes itself; the result is
                    // shown by ResultScreen from the cubit's notice.
                    () => cubit.exportToCSV(_fileNameController.text.trim()),
                  );
                },
                showText: showText,
                isPrime: true,
              ),
            ]
          ],
        );
      },
    );
  }

  Widget _buildSpace(BuildContext context) {
    double space = ContextExtension(context).isPhone ? 10 : 15;
    return horizontalSpace(space);
  }

  Widget _buildSearchBar(
    BuildContext context,
    double widthScreen,
    ResultCubit cubit,
    ResultLoaded state,
  ) {
    return Expanded(
      child: CustomTextField(
        height: 38,
        // 8.r like every other search bar (and the Department filter beside it).
        borderRadius: BorderRadius.circular(8.r),
        hint: S.of(context).search,
        maxLines: 1,
        fillColor: AppColors.card,
        hintStyle: StyleText.fontSize16Weight500
            .copyWith(color: AppColors.secondaryBlack),
        prefixIcon: CustomSvgImage.natural(
          assetPath: AppAssets.search,
          colorFilter:
              ColorFilter.mode(AppColors.secondaryBlack, BlendMode.srcIn),
        ),
        controller: _searchController,
        onChanged: cubit.search,
      ),
    );
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
        width: showText ? (isPrime ? 150 : 100) : 38,
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
              SizedBox(
                width: 20,
                height: 20,
                child: CustomSvgImage.natural(
                  assetPath: asset,
                  colorFilter: ColorFilter.mode(
                    isPrime ? AppColors.black : AppColors.secondaryText,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (showText) ...[
                horizontalSpace(8),
                Text(
                  text,
                  // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.secondaryText)
                      .copyWith(
                        color: isPrime ? AppColors.black : null,
                      ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

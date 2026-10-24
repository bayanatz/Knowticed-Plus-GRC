/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: uploaded_media_page.dart
/// Description: `UploadedMediaPage` page, state and UI of the `UploadedMediaPage` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/helpers/department_display_name.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/selected_person_avatar.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/upload_media_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/upload_media_state.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/result_constants.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_app_dropdown.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/dropdown/multi_drop_down_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/dropdown/small_drop_down.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder/helpers/breadcrumb_nav.dart';
import 'package:knowticed_plus/features/form_builder/helpers/person_state_view.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_title_padding.dart';
import 'package:collection/collection.dart';

/// The Uploaded Documents page: pick people and file types, then download.
class UploadedMediaPage extends StatefulWidget {
  const UploadedMediaPage({super.key});

  @override
  State<UploadedMediaPage> createState() => _UploadedMediaPageState();
}

class _UploadedMediaPageState extends State<UploadedMediaPage> {
  /// The search box text. Owned by this page, not the cubit.
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final state = context.read<UploadMediaCubit>().state;
    _searchController = TextEditingController(
      text: state is UploadMediaLoaded ? state.searchQuery : '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Header is SideFrameMasterServices now, not
    // PaginationAppBar. The form title crumb still needs ResultLoaded, so it
    // resolves through `_getTitle`, which now falls back to an empty string
    // instead of the whole header disappearing while the state loads.
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).detailsOfTitle(_getTitleOrEmpty(context)),
        thirdTitle: S.of(context).result,
        fourthTitle: S.of(context).uploadedMedia,
        onFirstTap: breadcrumbPop(context, 3),
        onSecondTap: breadcrumbPop(context, 2),
        onThirdTap: breadcrumbPop(context, 1),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsetsDirectional.only(start: 16.w, end: 16.w),
                child: BlocBuilder<UploadMediaCubit, UploadMediaState>(
                  builder: (context, state) {
                    if (state is! UploadMediaLoaded) {
                      return const CircleProgressMaster();
                    }

                    final cubit = context.read<UploadMediaCubit>();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 0 on a vertical tablet — see formBuilderTopGap.
                        verticalSpace(
                          formBuilderTopGap(context, isTablet ? 30 : 12),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10.h,
                          children: [
                            Text(
                              S.of(context).documentDetails,
                              style: StyleText.fontSize16Weight500,
                            ),
                            _buildDocumentCard(
                              context,
                              cubit,
                              state,
                              isTablet,
                              isPortrait,
                            ),
                          ],
                        ),
                        verticalSpace(20),
                        // "Download Form Digital Assets".
                        if (FormBuilderAccess.canDownloadFormDigitalAssets)
                          _buildDownloadRow(context, cubit),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The filters, the picked people and the people grid.
  Widget _buildDocumentCard(
    BuildContext context,
    UploadMediaCubit cubit,
    UploadMediaLoaded state,
    bool isTablet,
    bool isPortrait,
  ) {
    return Container(
      width: double.infinity,
      height: isPortrait ? 550.h : 500.h,
      padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTablet)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _mediaDropDown(context, cubit, state),
                horizontalSpace(10),
                _employeeDropDown(context, cubit, state),
              ],
            ),
          if (!isTablet) _mediaDropDown(context, cubit, state),
          if (!isTablet) verticalSpace(10),
          if (!isTablet) _employeeDropDown(context, cubit, state),
          if (!isTablet) verticalSpace(10),
          verticalSpace(15.sp),
          Row(
            children: [
              AppSearchTextField(
                fillColor: AppColors.background,
                controller: _searchController,
                onChanged: cubit.applyFilter,
              ),
              horizontalSpace(10),
              _departmentDropDown(context, cubit, state),
            ],
          ),
          verticalSpace(16),
          Wrap(
            children: [
              for (int i = 0; i < state.filteredUserGridItems.length; i++)
                if (state.filteredUserGridItems[i].person.isSelected)
                  SelectedPersonAvatar(
                    personEntity: state.filteredUserGridItems[i].person,
                    onTap: () {
                      cubit.togglePersonSelection(
                        state.filteredUserGridItems[i],
                      );
                    },
                  ),
            ],
          ),
          verticalSpace(16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
                    context,
                  ),
              mainAxisSpacing: 16.sp,
              crossAxisSpacing: 16.sp,
              mainAxisExtent: 75.h,
            ),
            itemCount: state.filteredUserGridItems.length,
            itemBuilder: (_, index) {
              return FormPersonStateView(
                color: AppColors.background,
                person: state.filteredUserGridItems[index].person,
                onTap: () {
                  cubit.togglePersonSelection(
                    state.filteredUserGridItems[index],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// "Download Form Digital Assets" with its loading and result messages.
  Widget _buildDownloadRow(BuildContext context, UploadMediaCubit cubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        customButtonWithSvg(
          title: S.of(context).download,
          image: AppAssets.downloadPdf,
          // FB-RESULT-03: loading while it runs, then a
          // success or failure message.
          function: () async {
            final String? error =
                await CustomDialogManager.runWithLoading<String?>(
                  context,
                  cubit.downloadMedia,
                );
            if (!context.mounted) return;
            if (error != null) {
              await AppDialogs.showError(context, error);
            } else {
              await CustomDialogManager.showSuccess(
                context: context,
                lottiePath: AppAssets.successful,
                title: S.of(context).mediaDownloaded,
              );
            }
          },
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.textButton,
          ),
          color: AppColors.primary,
          colorBorder: AppColors.primary,
          svgColor: AppColors.textButton,
          widthImage: 16,
          heightImage: 16,
        ),
      ],
    );
  }

  /// The form title for the breadcrumb.
  ///
  /// With the SideFrameMasterServices conversion. The header
  /// is built outside the `BlocBuilder`, so it can run before `ResultCubit`
  /// has emitted `ResultLoaded`. Returning '' then is what keeps the crumb
  /// row (and its back navigation) on screen during the load — previously the
  /// whole `PaginationAppBar` collapsed to a `SizedBox.shrink()`.
  String _getTitleOrEmpty(BuildContext context) {
    final state = context.read<ResultCubit>().state;
    if (state is! ResultLoaded || state.formEntity == null) return '';
    return _getTitle(context, state);
  }

  String _getTitle(BuildContext context, ResultLoaded state) =>
      state.formEntity!.getTitle;

  Widget _mediaDropDown(
    BuildContext context,
    UploadMediaCubit cubit,
    UploadMediaLoaded state,
  ) {
    List<String> items = [];
    items.addAll(ResultConstants.mediaTypeFilter);

    if (!cubit.hasSignature()) {
      items.remove(ResultConstants.mediaTypeFilter[2]);
    }
    if (!cubit.hasAttachment()) {
      items.remove(ResultConstants.mediaTypeFilter[1]);
    }
    if (!cubit.hasImage()) {
      items.remove(ResultConstants.mediaTypeFilter[0]);
    }

    if (ContextExtension(context).isPhone) {
      return SizedBox(
        width: double.infinity,
        child: MultiDropDownWidget(
          isReadOnly: false,
          itemLabel: ResultConstants.mediaTypeLabel,
          selectedItems: state.mediaType,
          onChanged: (value) {
            cubit.selectMediaType(value);
          },
          title: S.of(context).fbTypeOfDocument,
          hint: S.of(context).fbSelectDocument,
          items: items,
          currentValue: null,
        ),
      );
    }

    return Expanded(
      child: MultiDropDownWidget(
        isReadOnly: false,
        itemLabel: ResultConstants.mediaTypeLabel,
        selectedItems: state.mediaType,
        onChanged: (value) {
          cubit.selectMediaType(value);
        },
        title: S.of(context).fbTypeOfDocument,
        hint: S.of(context).fbSelectDocument,
        items: items,
        currentValue: null,
      ),
    );
  }

  Widget _employeeDropDown(
    BuildContext context,
    UploadMediaCubit cubit,
    UploadMediaLoaded state,
  ) {
    List<DropdownMenuItem> items = [];
    items.addAll(
      ResultConstants.employeeFilter
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                ResultConstants.employeeFilterLabel(e),
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.secondaryBlack,
                ),
              ),
            ),
          )
          .toList(),
    );

    if (ContextExtension(context).isPhone) {
      return SizedBox(
        width: double.infinity,
        child: DropDownWidget(
          isReadOnly: false,
          onChanged: (value) {
            cubit.updateSelectedEmployeeType(value);
          },
          title: S.of(context).employees,
          hint: S.of(context).employees,
          items: items,
          currentValue: state.employeeType, // Provide default
        ),
      );
    }

    return Expanded(
      child: DropDownWidget(
        isReadOnly: false,
        onChanged: (value) {
          cubit.updateSelectedEmployeeType(value);
        },
        title: S.of(context).employees,
        hint: S.of(context).employees,
        items: items,
        currentValue: state.employeeType, // Provide default
      ),
    );
  }

  /// The shown name of the picked department ([departmentId] null = all).
  String _departmentLabel(BuildContext context, String? departmentId) {
    if (departmentId == null) return S.of(context).department;
    final department = context
        .read<MainCoreDepartmentCubit>()
        .departmentModels
        .firstWhereOrNull((d) => d.departmentID == departmentId);
    return department?.displayName() ?? S.of(context).department;
  }

  Widget _departmentDropDown(
    BuildContext context,
    UploadMediaCubit cubit,
    UploadMediaLoaded state,
  ) {
    List<DropdownMenuItem> items = [
      DropdownMenuItem(
        value: ResultConstants.allDepartments,
        child: Text(
          S.of(context).all,
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryBlack,
          ),
        ),
      ),
    ];

    items.addAll(
      context
          .read<MainCoreDepartmentCubit>()
          .departmentModels
          .map(
            (e) => DropdownMenuItem(
              value: e.departmentID,
              child: Text(
                e.displayName(),
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.secondaryBlack,
                ),
              ),
            ),
          )
          .toList(),
    );

    if (ContextExtension(context).isPhone) {
      return SizedBox(
        width: 36.sp,
        child: SmallDropdown(
          menuWidth: 300.sp,
          onChanged: (value) {
            cubit.updateDepartmentType(value);
          },
          textButton: S.of(context).department,
          items: items,
        ),
      );
    }

    return SizedBox(
      height: 36,
      width: 150.w,
      child: AppDropdown(
        borderRadius: 8.r, // form bug report #8/#35: 8.r dropdowns
        width: 150.w,
        fillColor: AppColors.background,
        menuItemHeight: 35.sp,
        showErrorBorder: false,
        value: state.departmentType ?? ResultConstants.allDepartments,
        items: items,
        onChanged: (value) {
          cubit.updateDepartmentType(value);
        },
        hintText: S.of(context).department,
        textButton: _departmentLabel(context, state.departmentType),
      ),
    );
  }
}

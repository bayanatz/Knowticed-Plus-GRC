part of '../pages/custom_csv_table_page.dart';

extension CsvTableBuilders1 on CustomCsvTable {
  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(
      ActiveDirectoryController controller,
      BuildContext context,
      bool isVertical,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
        bloc: Get.find<ActiveDirectoryController>(),
        builder: (context, state) {
          final controller = Get.find<ActiveDirectoryController>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabBar(controller),
              SizedBox(height: 15.h),
              _buildToolbar(controller, context, isVertical),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (controller.selectedIndex == 1)
                    _actionButton(
                      icon: controller.isEditMode
                          ? 'assets/icons_assets/messaging_assets/close_x_teal.svg'
                          : 'assets/icons_assets/main_icons_assets/edit_pencil_square.svg',
                      label: controller.isEditMode ? 'Cancel' : 'Edit',
                      isActive: controller.isEditMode,
                      onTap: () => controller.toggleEditMode(),
                    ),
                  if (controller.selectedIndex == 0)
                    _actionButton(
                      icon: 'assets/icons_assets/main_icons_assets/edit_pencil_square.svg',
                      label: 'Edit',
                      onTap: () => controller.toggleEditMode(),
                    ),
                  const Spacer(),
                  _actionButton(
                    icon: 'assets/icons_assets/main_icons_assets/export_arrow.svg',
                    label: 'Export',
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (context) => const _ExportDialog(),
                      );
                    },
                  ),
                  SizedBox(width: 0.008.w),
                  _actionButton(
                    icon: 'assets/icons_assets/main_icons_assets/clock_circle.svg',
                    label: 'Restore',
                    onTap: () async {
                      await CustomDialogManager.showMessage(
                        context: context,
                        title: "Successful",
                        subtitle: "The backup has been restored successfully",
                        lottiePath: "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
                      );
                    },
                  ),
                ],
              ),
              if (controller.selectedIndex == 1) ...[
                SizedBox(height: 0.012.h),
                _buildErrorChips(controller),
              ],
            ],
          );
        },
      ),
    );
  }

  // ─── Tab bar ─────────────────────────────────────────────────────────────

  Widget _buildTabBar(ActiveDirectoryController controller) {
    return Row(
      children: [
        _tabItem(
          // Show filtered count when a filter is active, raw count otherwise
          count: controller.hasActiveFilters
              ? controller.filteredUsersData.length
              : controller.usersData.length,
          label: 'Users Data',
          isSelected: controller.selectedIndex == 0,
          onTap: () => controller.toggleIndex(0),
        ),
        SizedBox(width: 0.03.w),
        _tabItem(
          count: controller.rowInvalid.length,
          label: 'Invalid Data',
          isSelected: controller.selectedIndex == 1,
          onTap: () => controller.toggleIndex(1),
        ),
      ],
    );
  }

  Widget _tabItem({
    required int count,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 35.sp,
            height: 35.sp,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.greyDark,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize014.w,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: FontConstants.fontSize016.w,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Toolbar ──────────────────────────────────────────────────────────────

  Widget _buildToolbar(
      ActiveDirectoryController controller,
      BuildContext context,
      bool isVertical,
      ) {
    return Row(
      children: [
        Expanded(child: _buildSearchBar(controller)),
        SizedBox(width: 0.008.w),
        // Filter button turns yellow + shows count badge when filters active
        _filterButton(context, controller),
        if (controller.selectedIndex == 0) ...[
          SizedBox(width: 0.008.w),
          _actionButton(
            icon: 'assets/icons_assets/form_builder_assets/upload_arrow.svg',
            label: 'Upload',
            onTap: () async {
              await controller.uploadExcelFile(
                length: controller.usersData.length,
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _filterButton(
      BuildContext context, ActiveDirectoryController controller) {
    final bool active = controller.hasActiveFilters;
    return InkWell(
      onTap: () => _showFilterPanel(context),
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100.sp,
            height: 38.sp,
            decoration: BoxDecoration(
              color: active ? AppColors.primary.withOpacity(0.15) : AppColors.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons_assets/main_icons_assets/filter_sliders.svg',
                    width: 14.w,
                    height: 14.h,
                    colorFilter: ColorFilter.mode(
                      active ? AppColors.primary : AppColors.textButton,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    S.of(context).Filter,
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: FontConstants.fontSize013.w,
                      fontWeight: FontWeight.w600,
                      color: active ? AppColors.primary : AppColors.textButton,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Active-filter badge
          if (active)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 16.r,
                height: 16.r,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    controller.activeFilterCount.toString(),
                    style: AppFontStyle.cairoRegularStyle.copyWith(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ActiveDirectoryController controller) {
    return Container(
      height: 38.h,
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons_assets/main_icons_assets/search_magnifier_alt.svg',
            width: 16.w,
            height: 16.h,
            colorFilter:
            ColorFilter.mode(AppColors.secondaryText, BlendMode.srcIn),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              onChanged: (v) => controller.onSearchChanged(v),
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize014.w,
                color: AppColors.text,
              ),
              decoration: InputDecoration(
                hintText: S.current.search,
                hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize014.w,
                  color: AppColors.secondaryText,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isOutlined = false,
    bool isActive = false,
  }) {
    final Color bgColor = isActive
        ? AppColors.red
        : isOutlined
        ? Colors.transparent
        : AppColors.primary;
    final Color iconColor = AppColors.textButton;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100.sp,
        height: 38.sp,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.r),
          border: isOutlined ? Border.all(color: AppColors.border) : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                width: 14.w,
                height: 14.h,
                colorFilter: ColorFilter.mode(
                  isActive ? Colors.white : iconColor,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                label,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize013.w,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? Colors.white
                      : isOutlined
                      ? AppColors.text
                      : AppColors.textButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Edit mode bottom bar ─────────────────────────────────────────────────

}

/// ************************* FILE INFO *************************** ///
/// File Name: grc_owner_section.dart
/// Purpose: This file contains the implementation of the GrcOwnerSection widget, which displays the owner section for GRC modules.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 2026-06-29

import 'package:demo_app/core/custom/19-custom_person_chip_card.dart';
import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/grc/presentation/controller/grc_owner_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GrcOwnerSection extends StatefulWidget {
  final bool isViewMode;
  final void Function(List<OwnerData> selected)? onOwnersChanged;

  const GrcOwnerSection({
    super.key,
    this.isViewMode = false,
    this.onOwnersChanged,
  });

  @override
  State<GrcOwnerSection> createState() => _GrcOwnerSectionState();
}

class _GrcOwnerSectionState extends State<GrcOwnerSection> {
  late final GrcOwnerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GrcOwnerCubit();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _cubit.loadOwners(context),
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  ImageProvider _buildAvatar(String photo) {
    if (photo.startsWith('http')) return NetworkImage(photo);
    return AssetImage(photo);
  }

  void _onToggle(int index) {
    _cubit.toggleOwner(index);
    widget.onOwnersChanged?.call(_cubit.selectedOwners);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<GrcOwnerCubit, GrcOwnerState>(
        builder: (context, state) {
          final owners = _cubit.filteredOwners;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Module Owner',
                style: AppTextStyles.font16BlackRegularCairo
                    .copyWith(fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),

              if (!widget.isViewMode) ...[
                Row(
                  children: [
                    AppSearchTextField(
                      controller: _cubit.searchController,
                      onChanged: _cubit.search,
                      hintText: 'Search People',
                      fillColor: AppColors.background,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ],

              if (owners.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: Text(
                      'No people found',
                      style: AppTextStyles.font16BlackRegularCairo.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(
                  (owners.length / 2).ceil(),
                  (i) {
                    final left = owners[i * 2];
                    final rightIdx = i * 2 + 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: PersonChipCard(
                              name: left.name,
                              subtitle1: left.department,
                              subtitle2: left.jobTitle,
                              avatar: _buildAvatar(left.photo),
                              isSelected:
                                  widget.isViewMode ? false : left.isSelected,
                              showCheckBox: !widget.isViewMode,
                              width: double.infinity,
                              backgroundColor: AppColors.background,
                              onTap: widget.isViewMode
                                  ? null
                                  : () => _onToggle(i * 2),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          if (rightIdx < owners.length)
                            Expanded(
                              child: PersonChipCard(
                                name: owners[rightIdx].name,
                                subtitle1: owners[rightIdx].department,
                                subtitle2: owners[rightIdx].jobTitle,
                                avatar: _buildAvatar(owners[rightIdx].photo),
                                isSelected: widget.isViewMode
                                    ? false
                                    : owners[rightIdx].isSelected,
                                showCheckBox: !widget.isViewMode,
                                width: double.infinity,
                                backgroundColor: AppColors.background,
                                onTap: widget.isViewMode
                                    ? null
                                    : () => _onToggle(rightIdx),
                              ),
                            )
                          else
                            const Expanded(child: SizedBox()),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

/// ************************* FILE INFO *************************** ///
/// File Name: grc_owner_section.dart
/// Purpose: This file contains the implementation of the GrcOwnerSection widget, which displays the owner section for GRC modules.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 2026-06-29

import 'package:demo_app/core/custom/19-custom_person_chip_card.dart';
import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/grc_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GrcOwnerSection extends StatelessWidget {
  final TextEditingController searchController;
  final List<OwnerData> owners;
  final void Function(int index)? onOwnerTap;
  final bool isViewMode;

  const GrcOwnerSection({
    super.key,
    required this.searchController,
    required this.owners,
    this.onOwnerTap,
    this.isViewMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Module Owner',
          style:
              AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),

        if (!isViewMode) ...[
          Row(
            children: [
              AppSearchTextField(
                controller: searchController,
                onChanged: (_) {},
                hintText: 'Search People',
                fillColor: AppColors.background,
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],

        // ── Owner cards ───────────────────────────────
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
                      avatar: NetworkImage(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/3840px-Image_created_with_a_mobile_phone.png'),
                      subtitle2: left.jobTitle,
                      isSelected: isViewMode ? false : left.isSelected,
                      showCheckBox: isViewMode ? false : true,
                      width: double.infinity,
                      backgroundColor: AppColors.background,
                      onTap: isViewMode ? null : () => onOwnerTap?.call(i * 2),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  if (rightIdx < owners.length)
                    Expanded(
                      child: PersonChipCard(
                        name: owners[rightIdx].name,
                        subtitle1: owners[rightIdx].department,
                        subtitle2: owners[rightIdx].jobTitle,
                        avatar: NetworkImage(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/3840px-Image_created_with_a_mobile_phone.png'),
                        isSelected:
                            isViewMode ? false : owners[rightIdx].isSelected,
                        width: double.infinity,
                        backgroundColor: AppColors.background,
                        showCheckBox: isViewMode ? false : true,
                        onTap: isViewMode
                            ? null
                            : () => onOwnerTap?.call(rightIdx),
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
  }
}

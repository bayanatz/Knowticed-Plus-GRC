/// Module: services / sv10_services_provider / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: provider_status_chips.dart
/// Purpose: The status chips above the provider's list with their counts.
///          Pending and Rejected have chips now, so the chips add up to
///          "All" (suggestion 5).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/controller/employee_services_cubit.dart';
import 'package:knowticed_plus/features/services/sv10_services_provider/presentation/ui/widgets/services_table_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Class Name: [ProviderStatusChips]
///
/// Purpose: "All" plus one chip per status of [ProviderListKeys.statuses].
class ProviderStatusChips extends StatelessWidget {
  const ProviderStatusChips({
    required this.counts,
    required this.selectedKey,
    required this.onSelected,
    super.key,
  });

  /// Requests per status key, including [ProviderListKeys.all].
  final Map<String, int> counts;
  final String selectedKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(
            context,
            ProviderListKeys.all,
            S.of(context).all,
            AppColors.secondaryText,
          ),
          for (final key in ProviderListKeys.statuses)
            _chip(
              context,
              key,
              context.svcStatus(key),
              ServicesTableWidget.statusColor(key),
            ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String key, String label, Color color) {
    final light = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;
    final isSelected = selectedKey == key;
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () => onSelected(key),
      child: Row(
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (light ? AppColors.white : AppColors.chatBackground),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                context.svcNumber(counts[key] ?? 0),
                style: (isMobile
                        ? StyleText.fontSize14Weight400
                        : StyleText.fontSize20Weight500)
                    .copyWith(
                  color: isSelected
                      ? AppColors.textButton
                      : (light ? AppColors.secondaryText : AppColors.grey),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          Text(
            label,
            style: (isMobile
                    ? StyleText.fontSize14Weight600
                    : StyleText.fontSize16Weight600)
                .copyWith(color: color),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}

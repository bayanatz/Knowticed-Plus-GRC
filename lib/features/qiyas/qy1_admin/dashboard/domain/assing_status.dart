import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

enum AssignStatus {
  unassigned,
  assigned,
  inProgress,
  approved;

  String get value {
    switch (this) {
      case AssignStatus.unassigned:
        return 'لم يعين';
      case AssignStatus.assigned:
        return 'تم تعيين';
      case AssignStatus.inProgress:
        return 'تعيين جزئي';
      case AssignStatus.approved:
        return 'معتمد';
    }
  }

  Color get color {
    switch (this) {
      case AssignStatus.unassigned:
        return AppColors.secondaryText;
      case AssignStatus.assigned:
        return AppColors.secondaryPrimary;
      case AssignStatus.inProgress:
        return Colors.orange;
      case AssignStatus.approved:
        return Colors.green;
    }
  }
}

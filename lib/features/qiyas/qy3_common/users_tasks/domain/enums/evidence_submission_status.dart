import 'dart:ui';

import 'package:knowticed_plus/core/theme/app_colors.dart';

enum EvidenceSubmissionStatus {
  all,
  approved,
  pending,
  submitted,
  unCompleted,
  rejected,
  late;

  String get value {
    switch (this) {
      case EvidenceSubmissionStatus.all:
        return 'الكل';
      case EvidenceSubmissionStatus.unCompleted:
        return 'لم يتم التقديم';
      case EvidenceSubmissionStatus.submitted:
        return 'بانتظار موافقة المدير';
      case EvidenceSubmissionStatus.approved:
        return 'معتمد';
      case EvidenceSubmissionStatus.pending:
        return 'بانتظار المسؤول';
      case EvidenceSubmissionStatus.rejected:
        return 'مرفوض';
      case EvidenceSubmissionStatus.late:
        return 'متأخر';
    }
  }

  Color get color {
    switch (this) {
      case EvidenceSubmissionStatus.all:
        return AppColors.text;
      case EvidenceSubmissionStatus.unCompleted:
        return AppColors.secondaryText.withValues(alpha: .5);
      case EvidenceSubmissionStatus.submitted:
        return Color(0xFFD1693C);
      case EvidenceSubmissionStatus.approved:
        return AppColors.green;
      case EvidenceSubmissionStatus.pending:
        return const Color(0xFFFF814A);
      case EvidenceSubmissionStatus.rejected:
        return const Color(0xFFDF1C1C);
      case EvidenceSubmissionStatus.late:
        return const Color(0xFFA51515);
    }
  }

  String get icon {
    switch (this) {
      case EvidenceSubmissionStatus.all:
        return "";
      case EvidenceSubmissionStatus.unCompleted:
        return 'assets/icons_assets/main_icons_assets/ic_status_in_progress.svg';
      case EvidenceSubmissionStatus.submitted:
        return 'assets/icons_assets/main_icons_assets/ic_status_published.svg';
      case EvidenceSubmissionStatus.approved:
        return 'assets/icons_assets/main_icons_assets/ic_status_approved_circle.svg';
      case EvidenceSubmissionStatus.pending:
        return 'assets/icons_assets/main_icons_assets/ic_status_pending.svg';
      case EvidenceSubmissionStatus.rejected:
        return 'assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg';
      case EvidenceSubmissionStatus.late:
        return 'assets/icons_assets/main_icons_assets/ic_tt_overall_late.svg';
    }
  }
}

/// Module: time_tracker / tt3_attendance / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_tab.dart
/// Purpose: Declares `AttendanceTab` — the "Attendance" tab: status tiles ·
///          Search · Filter · Export · + Transaction · the attendance table
///          (cards on phone).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma `661:14182`. Permission gates (FINAL SPEC §1 section 3): the tab
/// itself needs `View_Attendance`; Export needs `Export_Attendance`;
/// + Transaction needs `Request_Transaction` (switch OFF → button hidden).
/// Tiles are the core `AttendanceTilesCard` (two rows per card, three
/// cards). Toolbar: `TtSearchField` (core search, self-Expanded),
/// `TtFilterButton`, `TtExportButton`, `customButtonWithSvg`.
/// The table resizes with `AnimatedSizeWrap`; sections slide in.
/// Updated: 9/10/2026 - UI fix round 1: Filter and Export are ICON-ONLY
/// (Figma iPad portrait `661:19747`: white Tuning square, yellow tray-arrow
/// square) and the search text is centred — `TtSearchField`,
/// `TtFilterButton`, `TtExportButton` (finding 3, 4).
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/charts/custom_attendance_tiles_card.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_table_filter.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_csv_export.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/controller/attendance_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/ui/widgets/attendance_filter_dialog.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/ui/widgets/attendance_table.dart';
import 'package:knowticed_plus/features/time_tracker/tt4_transaction_form/presentation/ui/pages/transaction_form_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({super.key});

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  final TextEditingController _search = TextEditingController();

  TimeTrackerAccess get _access => GetIt.instance<TimeTrackerAccess>();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openFilter() async {
    final AttendanceCubit cubit = context.read<AttendanceCubit>();
    final AttendanceFilter? picked =
        await CustomDialogManager.showContent<AttendanceFilter>(
      context: context,
      width: TtDialogWidth.standard,
      child: AttendanceFilterDialog(initial: cubit.state.filter),
    );
    if (picked == null) return;
    picked.isActive ? cubit.applyFilter(picked) : cubit.resetFilter();
  }

  Future<void> _export(List<AttendanceDay> rows) async {
    final S s = S.of(context);
    if (rows.isEmpty) {
      await CustomDialogManager.showMessage(
        width: TtDialogWidth.status,
        context: context,
        lottiePath: AppAssets.lottieWarning,
        title: s.export,
        subtitle: s.timeTrackerExportEmpty,
      );
      return;
    }
    await exportTimeTrackerCsv(
      context: context,
      defaultFileName: s.timeTrackerAttendanceExportName,
      // 13/10/2026 (owner): whose report it is, in the file name.
      subject: context.isArabic && _access.identity.nameAr.isNotEmpty
          ? _access.identity.nameAr
          : _access.identity.nameEn,
      header: AttendanceRowText.headers(context),
      rows: <List<String>>[
        for (int i = 0; i < rows.length; i++)
          <String>['${i + 1}', ...AttendanceRowText.cells(context, rows[i])],
      ],
    );
  }

  void _openTransaction() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const TransactionFormPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (BuildContext context, AttendanceState state) {
        final List<AttendanceDay> rows = state.rows(
          (AttendanceDay d) => AttendanceRowText.describe(context, d),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SlideInContent(child: _Tiles(counts: state.tiles)),
            SizedBox(height: 15.h),
            SlideInContent(
              delay: const Duration(milliseconds: 80),
              child: _toolbar(context, state, rows),
            ),
            SizedBox(height: 15.h),
            SlideInContent(
              delay: const Duration(milliseconds: 160),
              child: _body(context, state, rows),
            ),
            SizedBox(height: 15.h),
          ],
        );
      },
    );
  }

  Widget _toolbar(
    BuildContext context,
    AttendanceState state,
    List<AttendanceDay> rows,
  ) {
    final S s = S.of(context);
    final TimeTrackerAccess access = _access;
    // 13/10/2026 (Figma phone): "+ Transaction" full width under the row.
    return TtToolbarWithPrimary(
      tools: <Widget>[
        // 13/10/2026 (owner): the hint says what the search matches — the
        // row's date, status and times (`AttendanceRowText.describe`).
        TtSearchField(
          controller: _search,
          hint: s.timeTrackerSearchAttendanceHint,
          onChanged: context.read<AttendanceCubit>().searchChanged,
        ),
        SizedBox(width: 15.w),
        CustomFilterIcon(
          iconOnly: true,
          key: const ValueKey<String>('attendanceFilterButton'),
          active: state.filter.isActive,
          onTap: _openFilter,
        ),
        if (access.canExportAttendance) ...<Widget>[
          SizedBox(width: 15.w),
          TtExportButton(
            key: const ValueKey<String>('attendanceExportButton'),
            onTap: () => _export(rows),
          ),
        ],
      ],
      // 12/10/2026 (owner R7 / O2): the shared toolbar button.
      primary: access.canRequestTransaction
          ? TtToolbarButton(
              key: const ValueKey<String>('attendanceTransactionButton'),
              title: s.timeTrackerTransactionButton,
              icon: TtAssets.add,
              wide: context.isPhone,
              onTap: _openTransaction,
            )
          : null,
    );
  }

  Widget _body(
      BuildContext context, AttendanceState state, List<AttendanceDay> rows) {
    switch (state.status) {
      case AttendanceLoadStatus.initial:
      case AttendanceLoadStatus.loading:
        return Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
          child: const Center(child: CircleProgressMaster()),
        );
      case AttendanceLoadStatus.failure:
        return Padding(
          padding: EdgeInsetsDirectional.symmetric(vertical: 60.h),
          child: Text(
            S.of(context).timeTrackerLoadError,
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight400.copyWith(color: AppColors.red),
          ),
        );
      case AttendanceLoadStatus.loaded:
        if (rows.isEmpty) return const CustomEmptyState();
        return context.isPhone
            ? AttendanceCardList(days: rows)
            : AttendanceTableView(days: rows);
    }
  }
}

/// Present · Absent | Late · Vacation | Sick Leave · Excuse Leave.
class _Tiles extends StatelessWidget {
  const _Tiles({required this.counts});

  final AttendanceTileCounts counts;

  AttendanceItem _item(BuildContext context, String label, int value,
          String icon, Color color,
          {Widget? badge}) =>
      AttendanceItem(
        label: label,
        count: TimeTrackerFormat.count(context, value)
            .padLeft(2, TimeTrackerFormat.count(context, 0)),
        color: color,
        // 13/10/2026 (owner F1): the Figma badges (coloured circle + white icon).
        // Owner 21/10/2026: badges now from Figma `661:74949` (TtAssets.tile*).
        icon: badge ??
            CustomSvgImage(
                assetPath: icon,
                width: 32.r,
                height: 32.r,
                fit: BoxFit.contain),
        iconIsBadge: true,
      );

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return AttendanceTilesCard(
      key: const ValueKey<String>('attendanceTiles'),
      // 22/10/2026 (Moataz): on a phone it is TWO cards with THREE rows each
      // (Present · Absent · Late | Vacation · Sick Leave · Excuse Leave), not
      // three cards of two rows. Tablet and desktop keep three cards of two.
      itemsPerCard: context.isPhone ? 3 : 2,
      columns: context.isPhone ? 2 : 3,
      items: <AttendanceItem>[
        _item(
            context,
            s.timeTrackerPresent,
            counts.present,
            TtAssets.tilePresent,
            TimeTrackerFormat.statusColor(AttendanceStatus.present)),
        _item(context, s.timeTrackerAbsent, counts.absent, TtAssets.tileAbsent,
            TimeTrackerFormat.statusColor(AttendanceStatus.absent)),
        _item(context, s.timeTrackerLate, counts.late, TtAssets.tileLate,
            TimeTrackerFormat.statusColor(AttendanceStatus.late)),
        _item(
            context,
            s.timeTrackerVacation,
            counts.vacation,
            TtAssets.tileVacation,
            TimeTrackerFormat.statusColor(AttendanceStatus.vacation)),
        _item(
            context,
            s.timeTrackerSickLeave,
            counts.sickLeave,
            TtAssets.tileSickCircle,
            TimeTrackerFormat.statusColor(AttendanceStatus.sickLeave),
            // Owner 21/10/2026: Figma circle + folder are sibling layers.
            badge: _SickBadge(size: 32.r)),
        _item(
            context,
            s.timeTrackerExcuseLeave,
            counts.excused,
            TtAssets.tileExcuse,
            TimeTrackerFormat.statusColor(AttendanceStatus.excused)),
      ],
    );
  }
}

/// Owner 21/10/2026: the Sick Leave badge of Figma `661:74949` — circle
/// `661:75221` (35×35) with the 20×20 folder `661:75226` placed at (8, 7.54),
/// both drawn from the exported SVGs and scaled to [size].
class _SickBadge extends StatelessWidget {
  const _SickBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final double k = size / 35;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CustomSvgImage(
                assetPath: TtAssets.tileSickCircle,
                width: size,
                height: size,
                fit: BoxFit.contain),
          ),
          Positioned(
            left: 8 * k,
            top: 7.54 * k,
            width: 20 * k,
            height: 20 * k,
            child: CustomSvgImage(
                assetPath: TtAssets.tileSickFolder,
                width: 20 * k,
                height: 20 * k,
                fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

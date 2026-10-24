/// Module: roles/shared_mobile_export
///
///*************************** FILE INFO ****************************///
/// File Name: mobile_export_card.dart
/// Description: `MobileExportCard` widget — split out of `mobile_export_widgets.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../mobile_export_widgets.dart';

// Split from mobile_export_widgets.dart to keep every file under 700 lines.

// ═══════════════════════════════════════════════════════════════════════════
// HEADERS
// ═══════════════════════════════════════════════════════════════════════════

// REMOVED 9/9/2026: `MobileExportHeader`.
//
// It drew the "Controls and Management" title and the Active Directory /
// System Logs tab row from the frame. Those belong to `RoleScreen`, which
// already draws both above whichever tab is selected — the frame simply shows
// them because it is a picture of the whole phone screen, not of the tab body
// alone. Rendering them again inside the tab put a second title and a second
// tab row under the real ones.
//
// REMOVED 9/9/2026: `MobileExportBackHeader`.
//
// Both pushed screens now wear `SideFrameMasterServices`
// (core/custom/50-custom_side_frame_master.dart), the same frame Adding New
// Access and User Access Details wear. It draws the back chevron, the
// breadcrumb title, the Scaffold and the 15.sp horizontal page padding, so a
// hand-rolled header here was a second, slightly different version of all four.

// ═══════════════════════════════════════════════════════════════════════════
// CARD + FIELDS
// ═══════════════════════════════════════════════════════════════════════════

/// The white panel the export fields sit in — Figma 6975:23549 (345x705) and
/// 6976:24655 (345x688). Height is left to the content: the two frames differ
/// only by how many fields they hold.
class MobileExportCard extends StatelessWidget {
  const MobileExportCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MobileExportMetrics.cardPadding.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(MobileExportMetrics.cardRadius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

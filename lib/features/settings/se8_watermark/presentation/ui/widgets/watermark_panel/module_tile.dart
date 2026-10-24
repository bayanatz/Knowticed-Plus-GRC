/// Module: settings/se8_watermark
///
///*************************** FILE INFO ****************************///
/// File Name: module_tile.dart
/// Description: `_ModuleTile` widget — split out of `watermark_panel.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../watermark_panel.dart';

// Split from watermark_panel.dart to keep every file under 700 lines.

/// One module tile: a square holding the icon, with the name UNDER it.
///
/// CHANGED 31/8/2026 (second pass). The first build drew one bordered box
/// around the icon AND the label, and outlined every tile whether selected or
/// not — fifteen boxes competing for attention, which is not what Figma shows.
///
/// Figma's tile is two separate pieces: a rounded square that holds only the
/// icon and carries the selection colour, and the label sitting below it on the
/// card background with no box of its own. Unselected tiles have NO border at
/// all — the icon and its name simply sit there in grey. That is what makes the
/// selected ones actually stand out at a glance.
class _ModuleTile extends StatelessWidget {
  final Modules module;
  final bool selected;
  final VoidCallback onTap;

  /// Measured by [_ModulesCard] so six land in a row at the panel's real width.
  final double width;

  const _ModuleTile({
    required this.module,
    required this.selected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    // A selected tile is a solid brand square, so its icon has to flip to the
    // dark on-primary colour to stay visible — the same pairing the selected
    // field chip and the Save button use.
    final Color iconTint = selected ? AppColors.black : AppColors.secondaryText;

    return InkWell(
      onTap: withHaptic(onTap, HapticLevel.low),
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // The icon square. Kept square via AspectRatio rather than a fixed
            // height so it tracks the measured tile width instead of drifting
            // out of proportion when the panel resizes.
            // Owner 21/10/2026: compact tile — a fixed 40 square with a 24 icon
            // (was a full-width square with a ~48 glyph), so the left column fits.
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomSvgImage.natural(
                assetPath: // `iconPath`, not `iconPathRole`: the two differ only for
                    // `qiyas`, and this screen is not the roles permission matrix.
                    module.iconPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(iconTint, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              // Localised by `modules_enum.dart` itself, so a tile's name here
              // always matches that module's name everywhere else in the app.
              module.getModuleName,
              textAlign: TextAlign.center,
              // Two lines, and NO ellipsis: "Knowledge Hub" and "Time Tracker"
              // both need the second line, and a module the admin cannot read
              // is a module they cannot decide about.
              maxLines: 2,
              style: StyleText.fontSize16Weight500.copyWith(
                fontSize: _Type.moduleTile,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.text : AppColors.secondaryText,
                // Tightened: 9px Cairo at the default height leaves too much
                // air between the two lines of "Knowledge Hub".
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Module: roles/shared_mobile_export
///
///*************************** FILE INFO ****************************///
/// File Name: mobile_export_selected_avatars.dart
/// Description: `MobileExportSelectedAvatars` widget — split out of `mobile_export_widgets.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../mobile_export_widgets.dart';

// Split from mobile_export_widgets.dart to keep every file under 700 lines.

/// The picked employees, drawn as a wrapping row of avatars under the search
/// box — each one carrying a remove badge stacked on its top trailing corner.
///
/// ADDED 10/9/2026. The export form can now be narrowed to named people, and a
/// list of names would cost a line each; a 40 avatar is the same identity in
/// one row-height, which is how the rest of the module shows a set of people.
///
/// The avatar itself is [MobileExportAvatar], the same http-or-gender-SVG rule
/// `MobileExportPersonCard` follows, so a picked person looks identical here
/// and on the next step.
///
/// `Wrap`, not a scrolling `Row`: an off-screen pick is a pick the user cannot
/// remove, and there is no count on screen to tell them it is there. Wrapping
/// grows the block downward instead and keeps every badge reachable.
///
/// Draws NOTHING at all when nothing is picked — no empty band, no placeholder
/// — so the form looks exactly as it did before the first pick.
class MobileExportSelectedAvatars extends StatelessWidget {
  const MobileExportSelectedAvatars({
    super.key,
    required this.people,
    required this.onRemove,
  });

  final List<MobileExportPerson> people;

  /// Fires with the id of the person whose badge was tapped.
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Wrap(
        spacing: MobileExportMetrics.personCardGap.w,
        runSpacing: MobileExportMetrics.personCardGap.h,
        children: [
          for (final MobileExportPerson person in people)
            // `Clip.none` so the badge may sit half outside the avatar's box,
            // which is what puts it ON the rim rather than inside the photo.
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Padded by the badge's overhang so the Wrap reserves room for
                // it: an unclipped child does not enlarge its parent, so
                // without this the badge of one avatar would be painted over by
                // the next avatar in the row.
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    top: MobileExportMetrics.removeBadgeSize.sp / 3,
                    end: MobileExportMetrics.removeBadgeSize.sp / 3,
                  ),
                  child: MobileExportAvatar(person: person),
                ),
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: GestureDetector(
                    onTapDown: (_) => HapticController.high(),
                    onTap: () => onRemove(person.id),
                    // The glyph is 16 but the finger target must not be: an
                    // opaque transparent pad around it takes the taps that land
                    // just off the badge, which on a 16 target is most of them.
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(4.sp),
                      child: CustomSvgImage(
                        assetPath: AppAssets.cancel,
                        width: 14.sp,
                        height: 14.sp,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

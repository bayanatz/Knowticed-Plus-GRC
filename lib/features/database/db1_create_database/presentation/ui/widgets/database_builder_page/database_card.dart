/// Module: database / db1_create_database / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: database_card.dart
/// Description: Declares `DatabaseCard`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
///
/// One card of the Database Builder list. Its own library rather than a
/// `part` of `database_builder_page.dart`, so the page and the card each stay
/// under the 800-line limit.
library;

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_pop_up.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/layout/responsive_card_grid.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_strings.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/database_enum_labels.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/widgets/database_date_format.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// One database card — thumbnail, title, table count, creation date, access,
/// and the "..." menu (Figma "3 Dots": Edit, then Delete in red).
class DatabaseCard extends StatelessWidget {
  /// Function Name: [DatabaseCard]
  ///
  /// Purpose: One record of the list, with the menu actions the viewer may use.
  const DatabaseCard({
    super.key,
    required this.database,
    required this.strings,
    required this.isArabic,
    required this.canEdit,
    required this.canManage,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onRestore,
  });

  final DatabaseEntity database;
  final CreateDatabaseStrings strings;
  final bool isArabic;

  /// Offer Edit. From `DatabaseAccess.canEdit` (DB-CREATE-01).
  final bool canEdit;

  /// Offer Delete and Restore. From `DatabaseAccess.canManage`.
  final bool canManage;

  /// Opens the details screen. The "..." button sits in a `Stack` ABOVE the
  /// card, so it swallows its own taps and the menu cannot be triggered by
  /// this — which is what lets the whole card be tappable without the two
  /// gestures competing.
  final VoidCallback onTap;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Puts a soft-deleted record back. Only reachable while the card IS
  /// deleted — see [_menu].
  final VoidCallback onRestore;

  /// Menu values. Local strings rather than an enum because
  /// `CustomPopupMenuButton` is a `PopupMenuButton<String>` — the shared
  /// widget's contract, not a choice made here.
  static const String _actionEdit = 'edit';
  static const String _actionDelete = 'delete';
  static const String _actionRestore = 'restore';

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        GestureDetector(
          onTap: withHaptic(onTap, HapticLevel.low),
          // Opaque so the taps that land on the card's padding and on the gaps
          // between its text rows open the record too — without it only the
          // glyphs themselves would be hittable.
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: CardStyles.shadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // The phone card is 343 x 100 with an 80pt thumbnail (Figma
                // 7398:12797); the tablet card is narrower per column, so its
                // thumbnail stays at 60. One card, two sizes — the rest of the
                // layout is identical, which is why this is not a second widget.
                Builder(
                  builder: (BuildContext context) {
                    final double thumb = context.isPhone ? 70.sp : 60.sp;
                    return Container(
                      width: thumb,
                      height: thumb,
                      decoration: BoxDecoration(
                        color: AppTheme.isDark
                            ? AppColors.colorBlack
                            : AppColors.fieldFillLight,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      alignment: Alignment.center,
                      child: CustomSvgImage(
                        assetPath: AppAssets.databaseCreate,
                        width: thumb * 0.625,
                        fit: BoxFit.fill,
                        height: thumb * 0.625,
                        color: AppColors.secondaryText,
                      ),
                    );
                  },
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ResponsiveCardContent(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          FormatHelper.capitalize(
                            database.localizedTitle(isArabic: isArabic),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                        // SizedBox(height: 2.h),
                        _line(strings.noOfTables, '${database.tablesCount}'),
                        _line(strings.creation, _date(database.createdAt)),
                        _line(
                          strings.access,
                          database.accessType.label(S.current),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(bottom: 45.sp, child: _menu()),
      ],
    );
  }

  /// The card's "..." button.
  ///
  /// `CustomPopupMenuButton` (custom 51) with an empty title, which is the
  /// widget's own icon-only mode — a 38.sp square that carries the app's
  /// hover highlight and corner radius. Nothing about the menu is rebuilt
  /// here; Delete is red purely through `PopupOption.labelColor`.
  ///
  /// TWO MENUS, ONE BUTTON. A deleted record offers Restore and
  /// nothing else — Edit would open the editor on a record that is not in the
  /// list, and Delete on something already deleted has nothing to do. Swapping
  /// the rows rather than disabling them keeps the menu to what is actually
  /// possible from the chip the user is standing in.
  Widget _menu() {
    final bool isDeleted = database.isDeleted;
    final List<PopupOption> options = isDeleted
        ? <PopupOption>[
            if (canManage)
              PopupOption(value: _actionRestore, label: strings.restore),
          ]
        : <PopupOption>[
            if (canEdit) PopupOption(value: _actionEdit, label: strings.edit),
            if (canManage)
              PopupOption(
                value: _actionDelete,
                label: strings.delete,
                labelColor: AppColors.red,
              ),
          ];
    // Nothing this viewer may do: no "..." button at all.
    if (options.isEmpty) return const SizedBox.shrink();

    return CustomPopupMenuButton(
      title: '',
      iconPath: AppAssets.dotsHorizontal,
      backgroundColor: AppColors.transparent,
      iconColor: AppColors.secondaryText,
      options: options,
      onSelected: (String value) {
        if (value == _actionRestore) {
          onRestore();
        } else if (value == _actionDelete) {
          onDelete();
        } else if (value == _actionEdit) {
          onEdit();
        }
      },
    );
  }

  Widget _line(String label, String value) => Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: Text.rich(
          TextSpan(
            text: '$label ',
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
            children: <InlineSpan>[
              TextSpan(
                text: value,
                style: StyleText.fontSize12Weight600.copyWith(
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );

  /// "28 Nov 2025", the month name from intl (rule 14), shared with the
  /// details screens.
  String _date(DateTime? date) =>
      DatabaseDateFormat.short(date, isArabic: isArabic);
}

/// Module: settings / se8_watermark / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: watermark_screen.dart
/// Description: Declares `WatermarkScreen` — Settings › Home Layout › Watermark.
/// Author: Amr Mesbah
/// Created at: 25/8/2026
///
/// Source: Figma BuJXLizpGcK5eHVBqQomXc, ROLE MANAGEMENT > Watermark >
/// "Settings Home Page" (node 7524:14303). The controls panel is 7524:14371,
/// the preview pane 7524:14443.
///
/// RESPONSIVE — WHAT IS DESIGNED AND WHAT IS DERIVED
/// -------------------------------------------------
/// Figma has ONE layout for this screen, at 1024 (desktop / iPad horizontal):
/// a fixed 280-wide controls column on the left, the preview filling the rest,
/// and the Reset / Discard / Save bar pinned at the bottom. The iPhone and iPad
/// Vertical frames in that group are Calendar and Notification leftovers from
/// the duplicated template — there is no watermark mockup at 375 or 768.
///
/// So tablet and phone here are DERIVED, following the same rules the rest of
/// this app's settings screens use rather than anything drawn:
///   * ≥ 900 — Figma's two-column layout, verbatim.
///   * 600..900 — same two columns, controls widened to 320 so the sliders and
///     their value chips do not crowd; the preview keeps the remainder.
///   * < 600 — one column: controls first, then the preview as a 16:10 card
///     underneath, and the action bar becomes full-width stacked buttons. A
///     280-wide fixed column inside a 375 phone would leave a dead gutter.
/// If those breakpoints are ever designed, this is the only file to change.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/embedded_home_page.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/domain/entities/watermark_settings.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/controller/watermark_cubit.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_panel.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_preview.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Width below which the screen switches to a single column.
const double kWatermarkPhoneBreakpoint = 600;

/// Width at or above which the controls column takes Figma's 280.
const double kWatermarkDesktopBreakpoint = 900;

class WatermarkScreen extends StatelessWidget {
  const WatermarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // CHANGED 25/8/2026 — this used to create its own WatermarkCubit. It now
    // uses the root-level one from main.dart, which is what makes Save take
    // effect everywhere at once: the editor and every `WatermarkLayer` read and
    // write the same instance. A private cubit here would have persisted the
    // change and left every visible stamp stale until the next launch.
    context.read<WatermarkCubit>().ensureLoaded();

    // CHANGED: the page frame is SideFrameMasterServices now — the same
    // breadcrumb frame every other pushed settings page uses — in place of the
    // hand-built Scaffold > SafeArea > Padding > PaginationAppBar stack.
    //
    // TWO breadcrumb entries, not three, and this is load-bearing rather than
    // cosmetic. The Watermark card in the settings list pushes exactly ONE
    // route, so `onFirstTap` pops exactly once. A "Settings > Home Layout >
    // Watermark" trail would read better but would need two pops on
    // "Settings", tearing down SettingsLayout itself.
    //
    // The Scaffold wrapper stays because SideFrameMasterServices only supplies
    // one on phone; on tablet it returns a bare Row. Same shape
    // edit_page_request.dart uses.
    //
    // NoWatermark — ADDED 2/9/2026. THE EDITOR IS NEVER STAMPED.
    //
    // Unwrapping this screen's own route was not enough: on tablet and desktop
    // `custom_drawer.dart` wraps the ENTIRE shell body in a WatermarkLayer, and
    // this page is pushed into the settings module's nested Navigator INSIDE
    // that body. So the stamp came from an ancestor mounted long before this
    // screen existed, and no change to this route could reach it.
    //
    // [NoWatermark] is the signal that travels upwards: while it is mounted
    // every WatermarkLayer in the app hands its child back untouched. See
    // watermark_layer.dart.
    //
    // The preview pane is this screen's watermark, and it shows the DRAFT —
    // which is the point. A second stamp from the SAVED settings sat over the
    // very sliders being dragged and contradicted it.
    return NoWatermark(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.of(context).settings,
          onFirstTap: () => Navigator.of(context).maybePop(),
          secondTitle: S.of(context).watermark,
          child: const _WatermarkView(),
        ),
      ),
    );
  }
}

class _WatermarkView extends StatelessWidget {
  const _WatermarkView();

  @override
  Widget build(BuildContext context) {
    // CHANGED 25/8/2026 — this listener used to raise a SnackBar. Everything
    // here now goes through `CustomDialogManager`, like the rest of the app.
    //
    // Only FAILURES are announced from here. Success is announced by the
    // confirm→success flow the button itself runs (see `_confirmSave`), so a
    // listener that also fired on success would stack a second dialog on top of
    // the first.
    //
    // `showMessage`, not `showSuccess`: it stays until dismissed. A failure is
    // something the user has to read, and showSuccess auto-closes after ~1.5s.
    return BlocConsumer<WatermarkCubit, WatermarkState>(
      listenWhen: (_, current) => current.error != null,
      listener: (BuildContext context, WatermarkState state) {
        final String? message = state.error;
        if (message == null) return;
        CustomDialogManager.showMessage(
          context: context,
          lottiePath:
              'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
          title: S.of(context).error,
          subtitle: message,
        );
      },
      builder: (BuildContext context, WatermarkState state) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            // D-245 (21/10/2026): iPad PORTRAIT stacks the sections full
            // width like the phone (Content → Modules → Style → Preview).
            final bool isPortrait =
                MediaQuery.of(context).orientation == Orientation.portrait;
            final bool isPhone =
                width < kWatermarkPhoneBreakpoint || kpIsPhoneLayout(context);
            final bool stacked = isPhone || isPortrait;
            final bool isDesktop = width >= kWatermarkDesktopBreakpoint;

            // REMOVED 2/9/2026 — the "Active" switch row that used to sit here
            // (`_buildEnableRow`) and the confirm dialog behind it. The
            // watermark's on/off is the module grid now: clearing every tile in
            // "Watermark Modules" is what switches the stamp off, so a second,
            // higher-priority master switch was a duplicate control that could
            // disagree with the tiles underneath it. `WatermarkSettings.enabled`
            // went with it — see that class's header.
            // PHONE: no Expanded, and the content does not scroll itself.
            //
            // SideFrameMasterServices hands its child UNBOUNDED height on
            // phone — it is already inside the frame's own
            // SingleChildScrollView — so an Expanded here would throw, and a
            // nested scroll view would fight the outer one. The action bar
            // therefore scrolls with the page instead of being pinned; there
            // is nothing to pin it against in a scrolling frame.
            if (isPhone) {
              // Own review 21/10/2026 (D-202): on the phone Discard | Save are
              // PINNED above the navigation bar like every other Settings
              // page — SideFrameBoundedBody bounds the frame's unbounded
              // height so the sections scroll above the buttons.
              return SideFrameBoundedBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: _buildStacked(context, state, scrollable: false),
                      ),
                    ),
                    SizedBox(height: 16.sp),
                    _buildActions(context, state, isPhone: true),
                    SizedBox(height: 16.sp),
                  ],
                ),
              );
            }

            if (stacked) {
              // iPad portrait: the frame bounds the height, so the sections
              // scroll and Discard / Save stay pinned (D-245).
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: _buildStacked(context, state)),
                  _buildActions(context, state, isPhone: false),
                ],
              );
            }

            // TABLET / DESKTOP: the frame gives the child a bounded height
            // (`Expanded(child: child)`), so the action bar stays pinned to
            // the bottom exactly as before.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _buildTwoColumn(
                    context,
                    state,
                    isDesktop: isDesktop,
                    // Minus the SingleChildScrollView's own padding.
                    available: width - 32,
                  ),
                ),
                _buildActions(context, state, isPhone: false),
              ],
            );
          },
        );
      },
    );
  }

  // ── Confirm flow ──────────────────────────────────────────────────────────
  //
  // `CustomDialogManager.showDialogFlow` runs confirm → onConfirm → success and
  // only reaches the success step when onConfirm returns true. That is why
  // `save` returns a bool: a failed Firestore write must not be reported as a
  // success.
  //
  // There used to be a second flow here, `_confirmToggle`, behind the "Active"
  // master switch. Both switch and flow were removed on 2/9/2026.

  /// Function Name: [_confirmSave]
  ///
  /// Purpose: Confirm, write the draft, then confirm it landed.
  Future<void> _confirmSave(BuildContext context) async {
    final S l = S.of(context);
    final WatermarkCubit cubit = context.read<WatermarkCubit>();

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json',
      confirmTitle: l.saveChanges,
      confirmSubtitle: l.watermarkSaveConfirm,
      confirmYesText: l.confirm,
      confirmNoText: l.cancel,
      onConfirm: cubit.save,
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      successTitle: l.Successful,
      successSubtitle: l.watermarkSaved,
    );
  }

  // ── Layouts ───────────────────────────────────────────────────────────────

  /// Figma's layout: fixed controls column, preview takes the rest.
  ///
  /// SIZES HERE ARE RAW LOGICAL PIXELS, NOT `.w`/`.h`.
  ///
  /// FIXED 25/8/2026 — this column was `SizedBox(width: panelWidth.w)`, which
  /// overflowed the row by ~451,000 pixels and pushed the preview off screen
  /// entirely. `12.sp` in this codebase is `0.014`, i.e.
  /// the scale extensions here are applied to FRACTIONS of the screen, not to
  /// design-pixel counts — so `280.w` does not mean "280 logical pixels", it
  /// means 280 screen-widths. Figma's numbers are already logical pixels, so
  /// they are used unscaled, and the whole file follows that rule.
  Widget _buildTwoColumn(
    BuildContext context,
    WatermarkState state, {
    required bool isDesktop,
    required double available,
  }) {
    // 40 / 60 split with no page scroll (Moataz 18/10/2026): controls take 40%
    // of the width, the preview the other 60% and the full height. Nothing
    // scrolls (see the Owner 21/10/2026 note below).
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 4,
          // Owner 21/10/2026: NO scroll on the large view — compact panel (sliders 2 per row); if a very short window still can't hold it, it scales down to fit instead of scrolling.
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.topStart,
                child: SizedBox(
                  width: box.maxWidth,
                  child: WatermarkPanel(state: state, compact: true),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: _PreviewCard(
            settings: state.draft,
            text: watermarkStampText(state.draft, preview: true),
          ),
        ),
      ],
    );
  }

  /// Phone: one column, preview under the controls.
  ///
  /// [scrollable] false when the caller is already inside a scroll view —
  /// which it is under SideFrameMasterServices on phone. Nesting two scroll
  /// views on the same axis makes the inner one swallow the drag.
  Widget _buildStacked(
    BuildContext context,
    WatermarkState state, {
    bool scrollable = true,
  }) {
    // No padding of its own when the caller is the page frame.
    //
    // SideFrameMasterServices already applies 16.sp on each side and 20.sp
    // above the child, so this `EdgeInsets.all(12)` was stacking on top of it:
    // the cards sat 27 from the edge and 12 below the breadcrumb, out of line
    // with every other settings page. `scrollable` marks exactly that caller,
    // so it decides the padding too — the standalone/tablet path keeps its 12.
    // Item 181 (21/10/2026): no inset of its own on iPad portrait either —
    // the Settings pane already gives 16, and the 12 here pushed the cards
    // in while the Discard / Save row stayed on the pane edge.
    final Widget body = Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Moataz 23/10/2026: iPad portrait puts the sliders two per row and
          // the colour in the corner; the phone keeps one column.
          WatermarkPanel(state: state, compact: !kpIsPhoneLayout(context)),
          SizedBox(height: 16.sp),
          _PreviewCard(
            settings: state.draft,
            text: watermarkStampText(state.draft, preview: true),
          ),
        ],
      ),
    );

    return scrollable ? SingleChildScrollView(child: body) : body;
  }

  // ── Action bar ────────────────────────────────────────────────────────────

  Widget _buildActions(
    BuildContext context,
    WatermarkState state, {
    required bool isPhone,
  }) {
    final S l = S.of(context);
    final WatermarkCubit cubit = context.read<WatermarkCubit>();

    _ActionButton(
      label: l.resetToDefault,
      onTap: state.busy ? null : cubit.resetToDefault,
      fullWidth: isPhone,
    );

    // Discard is dead unless there is something to discard — the design draws
    // it as a plain grey button, so disabling reads correctly without a
    // separate style.
    final Widget discard = _ActionButton(
      label: l.discardChanges,
      // Moataz 23/10/2026: like Discard on Personal Information — it throws
      // the changes away and takes you back, always tappable.
      onTap: state.busy
          ? null
          : () {
              cubit.discardChanges();
              Navigator.of(context).maybePop();
            },
      fullWidth: isPhone,
    );

    final Widget save = _ActionButton(
      label: l.save,
      primary: true,
      busy: state.busy,
      onTap:
          (state.busy || !state.isDirty) ? null : () => _confirmSave(context),
      fullWidth: isPhone,
    );

    return Container(
      // Item 181: no divider line (D-31); Discard on the cards' left edge,
      // Save on their right edge.
      color: AppColors.background,
      // PHONE (Settings bug report p.14): the two fixed 150-wide buttons sat
      // edge to edge with no padding, so they touched the screen sides and
      // each other. They now split the bar equally, 16 in from the edges and
      // 12 apart.
      child: isPhone
          // No horizontal inset of its own: the frame already gives 16, so
          // the buttons sit on the cards' edges (own review 21/10/2026).
          ? Row(
              children: <Widget>[
                Expanded(child: discard),
                SizedBox(width: 16.sp),
                Expanded(child: save),
              ],
            )
          // Desktop/tablet: Figma stacks Reset above Discard on the left and
          // pins Save to the right.
          : Column(
              children: [
                SizedBox(height: 12.sp),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[discard],
                    ),
                    const Spacer(),
                    save,
                  ],
                ),
                SizedBox(height: 12.sp),
              ],
            ),
    );
  }
}

/// The REAL home page of this device under the live stamp (D-245, owner
/// 21/10/2026: "the preview shows the real page").
class _PreviewCard extends StatelessWidget {
  final WatermarkSettings settings;
  final String text;

  const _PreviewCard({
    required this.settings,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    // The card has the device's own proportions, so the embedded page fills
    // it edge to edge (plus the title row).
    final Size screen = MediaQuery.sizeOf(context);
    // Moataz 23/10/2026: the page is scaled to the card width, so the 48
    // title row is added in real pixels — not inside the aspect ratio, which
    // scaled it and left a white strip down the page's left side.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) => SizedBox(
        width: box.maxWidth,
        height: box.maxWidth * screen.height / screen.width + 48,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // D-245 (21/10/2026): titled "Preview", no window dots.
              // Moataz 23/10/2026: exactly the 48 the aspect ratio above
              // reserves, so the page under it fills the card edge to edge —
              // no white strip beside it and no gap under the title.
              SizedBox(
                height: 48,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      S.of(context).preview,
                      style: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.text),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: WatermarkPreview(
                  settings: settings,
                  text: text,
                  child: EmbeddedHomePage(size: screen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One button in the bottom bar.
///
/// Not `customButton` (core 5): that enforces an app-wide fixed width, and this
/// bar needs a hugging button on desktop and a full-width one on the phone.
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final bool busy;
  final bool fullWidth;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.primary = false,
    this.busy = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    // App-standard button colours (18/10/2026): Save is the yellow primary,
    // dimmed (not grey) while there is nothing to save; Discard is the shared
    // secondary grey with its own readable text (D-28).
    // X-131 (21/10/2026): a DISABLED button is GREY with grey text — never
    // a faded yellow.
    // Owner 21/10/2026: R-3 — disabled = grey fill, black text, 50% opacity (as Social / Company).
    // Moataz 23/10/2026: Discard (secondary) keeps its own grey and its white
    // (dark mode) text even while dead; only the yellow Save goes grey.
    // Moataz 23/10/2026: Discard is the same grey as Discard on Personal
    // Information (AppColors.darkGrey fill, AppColors.text label).
    final Color background = primary
        ? (enabled ? AppColors.primary : AppColors.grey)
        : AppColors.darkGrey;
    final Color foreground = primary ? AppColors.textButton : AppColors.text;

    final Widget button = InkWell(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        // Hugs a long label ("Discard Changes") instead of cutting it with
        // "…"; the app button height (38).
        width: fullWidth ? double.infinity : null,
        constraints: BoxConstraints(minWidth: 150.sp),
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        height: 38.sp,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: busy && primary
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircleProgressMaster.inline(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
                ),
              )
            : Text(
                label,
                style: StyleText.fontSize16Weight500.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
    return Opacity(opacity: enabled ? 1.0 : 0.5, child: button);
  }
}

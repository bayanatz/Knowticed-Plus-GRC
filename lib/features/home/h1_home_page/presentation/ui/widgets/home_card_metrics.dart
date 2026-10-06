/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_card_metrics.dart
/// Purpose: Declares `HomeCardMetrics` — the one place the home component
///          cards get their size from.
/// Author: Knowticed Plus team
/// Created: 31/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// A home component is rendered by `HomeComponent.widget(model)`, and until now
/// each module widget brought its own width and height. Three separate call
/// sites build those cards:
///
///   • adding_widget_page.dart   → AddComponentWrapper      (the widget picker)
///   • edit_home_page.dart       → RemoveComponentWrapper   (the layout editor)
///   • home_screen.dart          → the component directly   (the dashboard)
///
/// Sizing one of them left the other two ragged, which is exactly what happened
/// when the picker was fixed on its own. All three now go through [box] below,
/// so there is a single number to change per dimension.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeCardMetrics {
  const HomeCardMetrics._();

  /// Width of every home component card, on every screen.
  static double get width => 250.sp;

  /// Height of every home component card, on every screen.
  static double get height => 120.sp;

  /// Gap BETWEEN two cards in a row.
  ///
  /// Applied as a `Row.spacing`, which puts this gap between neighbours and
  /// nothing at the two outer ends — as opposed to giving every card its own
  /// horizontal padding, which would also inset the first and last card from
  /// the panel edges.
  static double get gap => 20.sp;

  /// Fixed [height], NATURAL width — the card is as wide as its own content
  /// needs, and only its height is pinned.
  ///
  /// ADDED 31/8/2026 for the layout EDITOR and anywhere else a card should keep
  /// its own width. [box] pins both dimensions and is for the widget PICKER,
  /// where the point is a grid of identical tiles.
  ///
  /// Vertical behaviour is [box]'s: content taller than [height] scrolls inside
  /// the card rather than overflowing, and a short card is stretched up to the
  /// full height so its background paints the whole tile.
  static Widget heightBox({required Widget child}) {
    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: child,
        ),
      ),
    );
  }

  /// Sizes [child] to [width] × [height]. Used by the widget PICKER, where a
  /// uniform grid is the point; the editor uses [heightBox] instead.
  ///
  /// Width is a TIGHT constraint, so a module widget that still hardcodes a
  /// wider box is clamped instead of overflowing its row.
  ///
  /// Height is the pair below rather than a second tight constraint:
  ///
  ///   • `SingleChildScrollView` lays the card out with UNBOUNDED height, so a
  ///     card whose content needs more than [height] scrolls inside its own box
  ///     instead of showing an overflow stripe. The scroll is vertical and the
  ///     rows on the dashboard and editor scroll horizontally, so the two never
  ///     compete for a drag.
  ///   • `ConstrainedBox(minHeight:)` makes a SHORT card stretch to fill the
  ///     full height, so its background paints the whole tile rather than
  ///     collapsing to its intrinsic height and leaving a gap beneath it.
  ///
  /// Together: uniform tiles, and nothing is ever clipped away unreachably.
  /// Sizes [child] to [width], and to AT LEAST [height] — a card that needs
  /// more room grows instead of scrolling inside itself.
  ///
  /// ADDED 13/9/2026 for the DASHBOARD. [box] and [heightBox] pin the height
  /// and hide the excess behind an inner `SingleChildScrollView`; on the
  /// dashboard that reads as broken — the Forms card showed its title and two
  /// of its three buttons, and the third was only reachable by scrolling a
  /// card that gives no hint it scrolls, with empty panel below it the whole
  /// time. The layout EDITOR and widget PICKER keep [heightBox]: a grid of
  /// even tiles is the point there, and those cards are previews rather than
  /// things you operate. ([box] itself now has no callers.)
  ///
  /// [height] survives as the MINIMUM so a short card still paints a full
  /// tile rather than collapsing to its intrinsic height.
  ///
  /// No `IntrinsicHeight` above the row to even the cards up: several module
  /// widgets contain a `ListView`, which throws when asked for an intrinsic
  /// height. Cards in a row can end on different baselines; that is the
  /// cheaper flaw.
  static Widget fitBox({required Widget child}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width,
        maxWidth: width,
        minHeight: height,
      ),
      child: child,
    );
  }

  static Widget box({required Widget child}) {
    return SizedBox(
      width: width,
      height: height,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: child,
        ),
      ),
    );
  }
}

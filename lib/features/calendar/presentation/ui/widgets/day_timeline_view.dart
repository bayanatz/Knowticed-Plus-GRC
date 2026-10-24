/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: day_timeline_view.dart
/// Description: The day view — events laid out against an hour timeline.
/// Author: Amr Mesbah
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N13: `package:get` removed; the module palette is shared.
/// Updated: 7/10/2026 - To-Do cards open the To-Do module; 'To-Do List' glyph.
/// Updated: 7/10/2026 - To-Do cards open THAT to-do's details through the
///          shared `CalendarEventTap` (same as the month-view `EventCard`).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/theme/calendar_module_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/calendar/data/models/calendar_event_model.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/widgets/calendar_event_tap.dart';
import 'package:knowticed_plus/features/calendar/presentation/ui/widgets/calendar_module_lookup.dart';

/// Day timeline column, extracted from calendar_screen.dart.
class DayTimelineView extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEventModel> events;

  /// Whether to draw the "Up Comings / Total Due" header above the timeline.
  ///
  /// ADDED 13/9/2026. On a phone the screen already carries a title, the view
  /// toggle and the week strip before this widget starts, so a fourth header
  /// bar is a row of chrome between the user and the actual schedule. Mobile
  /// passes false; tablet and desktop keep it.
  final bool showHeader;

  const DayTimelineView({
    super.key,
    required this.selectedDate,
    required this.events,
    this.showHeader = true,
  });

  String _toArabicNumber(int number, BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (!isArabic) return number.toString();

    const arabicNumbers = [
      // D-145: Western digits in Arabic too.
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    ];
    return number.toString().split('').map((digit) {
      return int.tryParse(digit) != null
          ? arabicNumbers[int.parse(digit)]
          : digit;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    // Owner 21/10/2026 12:56 ("where is the round corners?"): the header sits
    // OUTSIDE the box, so the box below it is its own rounded card (8 on all
    // four corners) — before, the header's square strip hid the top corners.
    return Column(
      children: [
        if (showHeader) ...<Widget>[
          // 13/9/2026 — Figma MESBAH "Up Comings" header. Was the long-form
          // date plus an event count; the design calls for the
          // calendar-with-star mark, the section title, and the due total on
          // the trailing side. The date itself is already on the calendar
          // directly above this card, so nothing is lost by dropping it here.
          //
          // Both Texts stay Flexible: that is what fixed the 51px overflow on
          // a 375pt phone on 12/9, and a long Arabic title would bring it
          // straight back otherwise.
          context.isPhone
              ? Container()
              : Container(
                  padding: EdgeInsetsDirectional.only(
                    start: 0.sp,
                    end: 10.sp,
                    top: 12.sp,
                    bottom: 12.sp,
                  ),
                  child: Row(
                    children: <Widget>[
                      // Untinted on purpose — the asset carries its own two-tone
                      // palette (#797979 body, #FFDE59 star) straight from Figma.
                      // Owner item 207 (21/10/2026): the section icon is
                      // yellow at 16 like every card title icon — not the
                      // value colour.
                      // Figma (Settings 6-39421, "Meetings" icon): the two-tone
                      // calendar-star as drawn, 20, untinted.
                      CustomSvgImage(
                        // Owner 21/10/2026 13:00: the icon from his Figma (Home
                        // frame 2289-38275, grey body + yellow star), untinted —
                        // the white variant vanished in light mode.
                        assetPath:
                            'assets/icons_assets/main_icons_assets/ic_calendar_event_star.svg',
                        width: 20.r,
                        height: 20.r,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 8.sp),
                      // Expanded, not Flexible: it eats the slack so "Total Due"
                      // sits hard against the trailing edge as in the design.
                      Expanded(
                        child: Text(
                          S.of(context).upComings,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          // 207: a section title — 14/500 like the cards.
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Flexible(
                        flex: 0,
                        // 207 (12:56): the label grey, the NUMBER in the
                        // value colour — the two never share a colour.
                        child: Text.rich(
                          // Label grey, the NUMBER in the text colour and
                          // heavier — the two never share a colour (owner
                          // 22/10/2026: they looked identical in Arabic).
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: '${S.of(context).totalDue}: ',
                                style: StyleText.fontSize14Weight500.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              TextSpan(
                                text: _toArabicNumber(events.length, context),
                                style: StyleText.fontSize14Weight600.copyWith(
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: Builder(
              builder: (BuildContext context) {
                final List<_TimelineRow> rows = _buildRows();
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.sp,
                    vertical: 8.sp,
                  ),
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    return _buildTimeSlot(
                      context: context,
                      row: rows[index],
                      isFirst: index == 0,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// The rows the timeline draws — one per half-hour, all 24 hours of them.
  ///
  /// REVISED 13/9/2026. A previous pass collapsed each run of empty slots into
  /// a single band, because that is literally what the MESBAH frame shows
  /// (08:00, 08:30, 09:00, 10:00 — 09:30 is absent). But a mock only draws the
  /// rows it needs to show the style; the real widget is a DAY, and dropping
  /// hours from it means you can no longer scroll to a time and see that it is
  /// free. The full grid is back.
  ///
  /// What survives from the frame is the message: "You're all clear" marks
  /// where a free stretch BEGINS — the first empty slot after an event, or the
  /// start of the day — instead of repeating on all 47 empty rows.
  List<_TimelineRow> _buildRows() {
    final List<String> slots = _generateTimeSlots();
    final List<_TimelineRow> rows = <_TimelineRow>[];

    bool previousHadEvents = false;
    for (int i = 0; i < slots.length; i++) {
      final List<CalendarEventModel> slotEvents = _getEventsAtTime(slots[i]);
      final bool isEmpty = slotEvents.isEmpty;

      rows.add(
        _TimelineRow(
          timeSlot: slots[i],
          events: slotEvents,
          isGapStart: isEmpty && (i == 0 || previousHadEvents),
        ),
      );

      previousHadEvents = !isEmpty;
    }

    return rows;
  }

  List<String> _generateTimeSlots() {
    List<String> slots = [];
    for (int hour = 0; hour < 24; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      slots.add('${hour.toString().padLeft(2, '0')}:30');
    }
    return slots;
  }

  List<CalendarEventModel> _getEventsAtTime(String timeSlot) {
    return events.where((event) {
      final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(event.time);

      // An event whose `time` cannot be parsed used to return false for EVERY
      // slot, so it disappeared from the grid entirely while still being
      // counted in the "N events" header above — a builder that forgot to pass
      // `time` produced a day view that claimed events and showed none, with
      // nothing anywhere saying why. A card with no usable time is an all-day
      // card: it belongs at the top of the day, not nowhere.
      if (timeMatch == null) {
        if (kDebugMode && timeSlot == '00:00') {}
        return timeSlot == '00:00';
      }

      int eventHour = int.parse(timeMatch.group(1)!);
      final eventMinute = int.parse(timeMatch.group(2)!);

      if (event.time.contains('PM') && eventHour != 12) {
        eventHour += 12;
      } else if (event.time.contains('AM') && eventHour == 12) {
        eventHour = 0;
      }

      final roundedMinute = eventMinute < 15 ? 0 : (eventMinute < 45 ? 30 : 60);

      if (roundedMinute == 60) {
        eventHour += 1;
      }

      final finalMinute = roundedMinute == 60 ? 0 : roundedMinute;

      final eventTime =
          '${eventHour.toString().padLeft(2, '0')}:${finalMinute.toString().padLeft(2, '0')}';
      return eventTime == timeSlot;
    }).toList();
  }

  Widget _buildTimeSlot({
    required BuildContext context,
    required _TimelineRow row,
    required bool isFirst,
  }) {
    final String timeSlot = row.timeSlot;
    final List<CalendarEventModel> events = row.events;
    final hasEvents = events.isNotEmpty;
    final locale = Localizations.localeOf(context).languageCode;

    final timeParts = timeSlot.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = timeParts[1];

    // Hour and period are separate strings now: Figma stacks them as two
    // lines, "08:00" over "AM", not one "08:00 AM".
    final String displayHour;
    final String displayPeriod;
    if (locale == 'ar') {
      final arabicHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      displayHour =
          '${_toArabicNumber(arabicHour, context).padLeft(2, '0')}:${_toArabicNumber(int.parse(minute), context).padLeft(2, '0')}';
      displayPeriod = hour < 12 ? 'ص' : 'م';
    } else {
      final int twelveHour = hour == 0
          ? 12
          : hour <= 12
              ? hour
              : hour - 12;
      displayHour = '${twelveHour.toString().padLeft(2, '0')}:$minute';
      displayPeriod = hour < 12 ? 'AM' : 'PM';
    }

    // REDESIGNED 13/9/2026 to MESBAH 4717:16205 ("Meetings").
    //
    // Figma splits the time into TWO lines — "08:00" over "AM" — right-aligned
    // in a 35-wide column, with a 10 gap to the content. The old row put the
    // whole "08:00 AM" on one line in an 80-wide box, which is most of a phone
    // column spent on a label.
    //
    // An empty half-hour is a hairline rule, not a 40-high box with a left
    // border: the design reads as a continuous ruled timeline with cards
    // sitting on it, and a rule takes a sixth of the height, so far more of
    // the day fits on screen.
    return Padding(
      padding: EdgeInsets.only(bottom: 20.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40.sp,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 22/10/2026: "02:00" wrapped to "02:0" / "0" in Arabic on iPad
                // (the 40-wide column is a hair narrow for the Arabic font).
                // One line, scaled down only when it would not fit.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    displayHour,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ),
                SizedBox(height: 4.sp),
                Text(
                  displayPeriod,
                  textAlign: TextAlign.end,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Figma draws the rule ABOVE each row's content, and the very
                // first row has none — the timeline starts at its first card,
                // it does not open with a line.
                if (!isFirst) const _TimelineRule(),
                if (hasEvents) ...[
                  if (!isFirst) SizedBox(height: 8.sp),
                  for (int i = 0; i < events.length; i++) ...[
                    if (i > 0) SizedBox(height: 8.sp),
                    _buildEventCard(events[i], context),
                  ],
                ],
                // The "all clear" band. Only at the TOP of a free stretch:
                // on every empty row it would be 47 copies of the same
                // sentence.
                //
                // FIXED 13/9/2026 — this used to draw its own `_TimelineRule`
                // as well, which landed 4.sp under the row's leading rule
                // above and read as one line drawn twice. The row already has
                // a rule; the message just hangs beneath it.
                if (row.isGapStart) ...[
                  SizedBox(height: 8.sp),
                  Text(
                    S.of(context).youreAllClear,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize16Weight400.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Function Name: [_buildEventCard]
  ///
  /// Purpose: The event card, made tappable via [CalendarEventTap].
  ///
  /// ADDED 7/10/2026 for To-Do; since 22/10/2026 every module's card opens
  /// its module (see [CalendarEventTap.targetOf]).
  Widget _buildEventCard(CalendarEventModel event, BuildContext context) {
    return CalendarEventTap(
      event: event,
      child: _buildEventCardBody(event, context),
    );
  }

  Widget _buildEventCardBody(CalendarEventModel event, BuildContext context) {
    final moduleColor = _getModuleColor(event.moduleName);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // ✅ Extract bilingual task name
    String displayTaskName = event.taskName;
    if (event.taskName.contains(' / ')) {
      final parts = event.taskName.split(' / ');
      displayTaskName = isArabic && parts.length > 1 ? parts[1] : parts[0];
    }

    // ✅ Extract bilingual description
    String displayDescription = event.description;
    if (event.description.contains(' / ')) {
      final parts = event.description.split(' / ');
      displayDescription = isArabic && parts.length > 1 ? parts[1] : parts[0];
    }

    // Figma 4717:16213 — h 60, radius 10, 1.2 border, fill + 10 padding,
    // 5 gap, a 40 circular glyph well, then title 12 / subtitle 10.
    //
    // Two deliberate departures from the literal frame, both because the frame
    // is a mock with one module in it:
    //
    //   * the border and the glyph tint are the MODULE's colour
    //     (CalendarModulePalette), not the mock's fixed #0095FF / #FFF7D5 —
    //     the dots on the month grid above already colour-code by module, and
    //     a timeline where every card is the same blue would lose that.
    //   * the fill is AppColors.card, not #F5F5F5, so the card still reads in
    //     dark mode.
    //
    // The status chip is gone: Figma has no room for it in a 60-high card and
    // the status already rides in the card's own colour.
    // 22/10/2026 (Moataz): on a phone the title and the text were cut to one
    // line each ("I cannot see the data"). On a phone the card now grows to
    // fit two lines of each; tablet and desktop keep the fixed 60 height.
    final bool isPhone = kpIsPhoneLayout(context);
    return Container(
      height: isPhone ? null : 60.sp,
      constraints: isPhone ? BoxConstraints(minHeight: 60.sp) : null,
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: moduleColor, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 40.sp,
            height: 40.sp,
            decoration: BoxDecoration(
              color: moduleColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomSvgImage(
                assetPath: _getModuleIcon(event.moduleName),
                width: 20.sp,
                height: 20.sp,
                color: moduleColor,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          SizedBox(width: 5.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  FormatHelper.capitalize(displayTaskName),
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.text,
                  ),
                  maxLines: isPhone ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  FormatHelper.capitalize(displayDescription),
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  maxLines: isPhone ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Delegates to the shared palette (CR-SKEL-CAL-N11).
  Color _getModuleColor(String moduleName) =>
      CalendarModulePalette.colorOf(moduleName);

  /// 22/10/2026 (Moataz: "why is the icon Services? it should be Settings"):
  /// uses the same resolver as the list card, so every module gets its own
  /// icon here too.
  String _getModuleIcon(String moduleName) =>
      calendarModuleFor(moduleName).iconPathRole;
}

/// One drawn row of the timeline: either a half-hour that has events, or a
/// collapsed run of empty ones. See [DayTimelineView._buildRows].
class _TimelineRow {
  const _TimelineRow({
    required this.timeSlot,
    required this.events,
    this.isGapStart = false,
  });

  /// 'HH:mm'.
  final String timeSlot;
  final List<CalendarEventModel> events;

  /// This slot is free AND the one before it was not — the top of a free
  /// stretch, which is the only place the "all clear" message is drawn.
  final bool isGapStart;
}

/// The timeline's horizontal rule: a hairline with a small triangular cap at
/// each end (Figma 4717:16243 / 4717:16244).
///
/// Painted rather than shipped as an asset. The exported SVG is a single
/// full-width path, so stretching it to an arbitrary column width would skew
/// the caps; and the shape is plain geometry — two triangles and a line — not
/// an icon glyph whose vector data would have to be guessed at.
class _TimelineRule extends StatelessWidget {
  const _TimelineRule();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8,
      width: double.infinity,
      child: CustomPaint(
        painter: _TimelineRulePainter(color: AppColors.lightGrey),
      ),
    );
  }
}

class _TimelineRulePainter extends CustomPainter {
  const _TimelineRulePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double midY = size.height / 2;
    const double cap = 4; // half-height of the triangular end caps

    canvas.drawRect(Rect.fromLTWH(0, midY - 0.5, size.width, 1), paint);

    // Left cap, pointing inward.
    canvas.drawPath(
      Path()
        ..moveTo(0, midY - cap)
        ..lineTo(cap * 1.5, midY)
        ..lineTo(0, midY + cap)
        ..close(),
      paint,
    );

    // Right cap, mirrored.
    canvas.drawPath(
      Path()
        ..moveTo(size.width, midY - cap)
        ..lineTo(size.width - cap * 1.5, midY)
        ..lineTo(size.width, midY + cap)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimelineRulePainter oldDelegate) =>
      oldDelegate.color != color;
}

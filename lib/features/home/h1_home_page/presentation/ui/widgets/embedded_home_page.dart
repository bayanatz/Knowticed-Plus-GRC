/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: embedded_home_page.dart
/// Purpose: Declares `EmbeddedHomePage` — the REAL home page laid out at a
///          given device size and scaled to fit wherever it is shown. Used by
///          Settings › Home Layout › Home Preview (X-140: the real page of
///          each device with the unsaved layout) and by Settings › Watermark's
///          Preview card (D-245: the real page under the live stamp).
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// The page is wrapped in IgnorePointer: it is a picture of the page, not a
/// second live Home — taps go nowhere. MediaQuery is overridden to the device
/// size with zero insets, so the page lays itself out as it would on that
/// device (phone / iPad portrait / landscape), and FittedBox scales the
/// result down into the space it is given.
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/pages/home_screen.dart';

class EmbeddedHomePage extends StatelessWidget {
  const EmbeddedHomePage({
    super.key,
    required this.size,
    this.previewUnsaved = false,
  });

  /// The logical size the home page is laid out at (e.g. 375 × 812 for the
  /// phone, 768 × 1024 for the iPad in portrait).
  final Size size;

  /// Show the layout being edited (Home Preview) instead of the saved one.
  final bool previewUnsaved;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    return FittedBox(
      fit: BoxFit.contain,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: MediaQuery(
          data: media.copyWith(
            size: size,
            padding: EdgeInsets.zero,
            viewPadding: EdgeInsets.zero,
            viewInsets: EdgeInsets.zero,
          ),
          child: IgnorePointer(
            child: HomeScreen(previewUnsaved: previewUnsaved),
          ),
        ),
      ),
    );
  }
}

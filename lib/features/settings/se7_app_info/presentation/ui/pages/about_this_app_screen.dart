///*************************** FILE INFO ****************************///
/// File Name: about_this_app_screen.dart
/// Purpose: "About this platform" — the per-company description, fetched from
///          Firestore and rendered as markdown.
/// Author: Knowticed Plus team
/// Updated: 24/8/2026 - Rebuilt on the Terms & Conditions layout.
///
/// WHAT CHANGED AND WHY
///
/// The Firestore read is unchanged: same collection, same
/// `assignedCompanies` filter, same `descriptionAr` / `descriptionEn` fields.
/// Everything around it was replaced.
///
/// The page used to carry its own app-icon banner, a version block, a Lottie
/// animation and two PDF download buttons — which dragged `dio`,
/// `path_provider`, `permission_handler` and `dart:io` into a screen whose job
/// is to show one block of text. It looked nothing like Terms & Conditions,
/// the other document page in this module.
///
/// It is now the same shape as `terms_and_conditions.dart`: a header card
/// (icon + title) on top of a scrollable content pane, identical markdown
/// typography, and the same phone/tablet split. The only structural difference
/// is that this page's body is remote, so it also has loading, empty and error
/// states — Terms has its text inline and needs none.
///
/// The `arDocumentUrl` / `engDocumentUrl` fields are still in Firestore; this
/// page simply no longer offers them as downloads.
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/knowticed_logo.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/network/api_constants.dart'
    hide FirebaseCollections;
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AboutThisAppScreen extends StatefulWidget {
  const AboutThisAppScreen({super.key});

  @override
  State<AboutThisAppScreen> createState() => _AboutThisAppScreenState();
}

class _AboutThisAppScreenState extends State<AboutThisAppScreen> {
  static const String _icon =
      'assets/icons_assets/settings_assets/ic_page_about.svg';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  String? _description;
  DateTime? _lastUpdateDate;

  /// Null while things are fine. Holds a key, not a sentence: the text is
  /// resolved at build time so it follows a locale switch.
  _AboutError? _error;

  /// The fetch reads `Localizations.localeOf(context)`, which is not available
  /// in initState — hence didChangeDependencies, guarded so an inherited-widget
  /// change does not refetch on every rebuild.
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fetched) return;
    _fetched = true;
    _fetchAboutData();
  }

  /// `ApiConstants.baseUri` is "Demo/75440689" or just the id; the company is
  /// the last segment either way.
  String? _currentCompanyId() {
    final String baseUri = ApiConstants.baseUri;
    if (baseUri.isEmpty) return null;

    final String last = baseUri.split('/').last;
    return last.isNotEmpty ? last : null;
  }

  Future<void> _fetchAboutData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String? companyId = _currentCompanyId();
      if (companyId == null) {
        setState(() {
          _isLoading = false;
          _error = _AboutError.noCompany;
        });
        return;
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(FirebaseCollections.adminRoot)
          .doc(FirebaseCollections.companyData)
          .collection('about_this_app')
          .where('assignedCompanies', arrayContains: companyId)
          .limit(1)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = _AboutError.empty;
        });
        return;
      }

      final Map<String, dynamic> data = snapshot.docs.first.data();
      final bool isArabic =
          Localizations.localeOf(context).languageCode == 'ar';

      setState(() {
        _description = _clean(
          isArabic
              ? data['descriptionAr'] as String?
              : data['descriptionEn'] as String?,
        );

        final Object? updated = data['lastUpdateDate'];
        _lastUpdateDate = updated is Timestamp ? updated.toDate() : null;

        _isLoading = false;
        // A document that exists but has no body for this language is the same
        // dead end as no document at all, so it reports the same way.
        if (_description == null || _description!.isEmpty) {
          _error = _AboutError.empty;
        }
      });
    } catch (_) {
      if (!mounted) return;
      // The raw Firestore message is not surfaced — it is not something a user
      // can act on, and Retry is the only useful response.
      setState(() {
        _isLoading = false;
        _error = _AboutError.failed;
      });
    }
  }

  /// Strips the wrapping quotes the console adds when a long description is
  /// pasted as a triple-quoted or quoted string. Carried over from the previous
  /// implementation — the stored documents really do contain them.
  String? _clean(String? raw) {
    if (raw == null) return null;

    String value = raw.trim();
    if (value.startsWith("'''") && value.endsWith("'''") && value.length > 6) {
      value = value.substring(3, value.length - 3);
    }
    if (value.startsWith('"') && value.endsWith('"') && value.length > 1) {
      value = value.substring(1, value.length - 1);
    }
    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = !kpIsPhoneLayout(context);

    if (!isTablet) {
      // Phones push this as its own route, so it owns a Scaffold — the same
      // split TermsConditions uses.
      //
      // FIXED 8/9/2026 — the content pane used to be `Expanded`, which threw
      // "RenderFlex children have non-zero flex but incoming height
      // constraints are unbounded" the moment the page opened on a phone:
      // SideFrameMasterServices wraps `child` in a SingleChildScrollView on
      // mobile, so this Column has no bounded height for a flex child to
      // divide. The markdown body is itself a scrollable and needs a real
      // height either way — it now takes one from the viewport.
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.of(context).settings,
          secondTitle: FormatHelper.capitalize(S.of(context).aboutThisPlatform),
          onFirstTap: () => Navigator.pop(context),
          onSecondTap: () => Navigator.pop(context),
          child: Column(
            children: <Widget>[
              _header(context),
              _contentPane(context),
            ],
          ),
        ),
      );
    }

    // Tablet / desktop: rendered inside settings_layout's Expanded, which does
    // hand down a bounded height — so `Expanded` is correct here.
    // D-246 (21/10/2026): the box ENDS after the content with the normal gap
    // (Flexible + a shrink-wrapped body), not at the bottom edge.
    // One card for header + body: two touching rounded boxes left a hairline
    // seam between them on the desktop (Moataz 23/10/2026).
    return Column(
      children: <Widget>[
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: ColoredBox(
              color: AppColors.card,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _header(context),
                  // Owner 21/10/2026: scrolls inside the box like Privacy / Terms (the
                  // shrink-wrapped body overflowed the pane when the text was long).
                  Flexible(
                    child: SingleChildScrollView(child: _contentPane(context)),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 16.sp),
      ],
    );
  }

  /// Title card above the content.
  ///
  /// CHANGED 21/9/2026 — the same header as Privacy Statement: the app logo
  /// with "Last Update" in the top-right corner, then the icon + title row.
  Widget _header(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              // Owner 21/10/2026: top-aligned, the same as Privacy / Terms.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Same asset choice as privacy_Statement.dart's pane.
                CustomSvgImage.natural(
                  assetPath: knowticedLogoAsset(lightMode: lightMode),
                  width: 50.w,
                  height: 50.h,
                  fit: BoxFit.fill,
                ),
                const Spacer(),
                if (_lastUpdateDate != null) ...<Widget>[
                  Text('${S.of(context).lastUpdate}: ',
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.secondaryText)),
                  Text(_formattedLastUpdate(context),
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.text)),
                ],
              ],
            ),
            // Owner 21/10/2026: 20 under the logo row, as on Privacy / Terms.
            SizedBox(height: 20.h),
            // D-246: the title ONCE — "About Knowticed Plus" with its section
            // icon (the same 30 tile + 16 icon as Terms / Privacy); the body's
            // own first heading is stripped below so it is not repeated.
            Row(
              children: <Widget>[
                // Owner 21/10/2026: just the icon (16), no square tile behind it.
                CustomSvgImage.natural(
                  assetPath: _icon,
                  width: 24.sp,
                  height: 24.sp,
                ),
                SizedBox(width: 8.sp),
                Expanded(
                  child: Text(
                    S.of(context).aboutKnowticedPlus,
                    // Owner 21/10/2026: same title style as Privacy / Terms.
                    style: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.secondaryText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentPane(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Not `const`: AppColors.card is a theme-dependent getter, not a
        // compile-time constant.
        color: AppColors.card,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircleProgressMaster());
    }

    if (_error != null) {
      return _errorState(context, _error!);
    }

    return Markdown(
      // D-246: the box hugs its content; the page frame scrolls.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.sp),
      data: _withoutLeadingHeading(
          _description!, S.of(context).aboutKnowticedPlus),
      onTapLink: (String text, String? url, String title) async {
        if (url == null) return;
        final Uri link = url.contains('@') && !url.startsWith('http')
            ? Uri(scheme: 'mailto', path: url)
            : Uri.parse(url);
        await launchUrl(link, mode: LaunchMode.externalApplication);
      },
      // Same typography as TermsConditions so the two documents read
      // identically.
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.text,
          height: 1.6,
        ),
        h1: StyleText.fontSize16Weight600.copyWith(
          color: AppColors.text,
          height: 1.8,
        ),
        h2: StyleText.fontSize15Weight600.copyWith(
          color: AppColors.text,
          height: 1.8,
        ),
        h3: StyleText.fontSize14Weight600.copyWith(
          color: AppColors.text,
          height: 1.8,
        ),
        listBullet: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.text, // 23/10/2026 (Moataz): body text is black
          height: 1.6,
        ),
      ),
    );
  }

  /// The last-update date in the app locale — Arabic-Indic numerals in
  /// Arabic, as the rest of the app does. Shown in the header since 21/9/2026
  /// (it used to be appended to the markdown as an italic footer line).
  String _formattedLastUpdate(BuildContext context) {
    final String locale = Localizations.localeOf(context).languageCode;
    return DateFormat('dd MMMM yyyy', locale).format(_lastUpdateDate!);
  }

  /// Drops a first-line markdown heading ("# About …") — the header above
  /// already shows the title once (D-246).
  static String _withoutLeadingHeading(String markdown, String title) {
    final List<String> lines = markdown.trimLeft().split('\n');
    if (lines.isNotEmpty) {
      final String first =
          lines.first.trim().replaceFirst(RegExp(r'^#+\s*'), '').trim();
      // A markdown heading, or the title written as a plain first line.
      if (lines.first.trimLeft().startsWith('#') ||
          first.toLowerCase() == title.trim().toLowerCase() ||
          first.toLowerCase() == 'about knowticed plus') {
        lines.removeAt(0);
      }
    }
    return lines.join('\n').trimLeft();
  }

  Widget _errorState(BuildContext context, _AboutError error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _messageFor(context, error),
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.secondaryText),
            ),
            // Retry is offered only where it can help. A company that has no
            // document assigned will not grow one by tapping again.
            if (error == _AboutError.failed) ...<Widget>[
              SizedBox(height: 16.h),
              customButton(
                title: S.of(context).retry,
                function: _fetchAboutData,
                width: 150.w,
                height: 36,
                radius: 4.r,
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.textButton),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _messageFor(BuildContext context, _AboutError error) {
    switch (error) {
      case _AboutError.failed:
        return S.of(context).anErrorOccurred;
      case _AboutError.noCompany:
      case _AboutError.empty:
        // Deliberately the same line for both: from the reader's side "your
        // company has no document" and "the document has no text in your
        // language" are the same outcome, and neither is actionable in-app.
        return S.of(context).noDataAvailable;
    }
  }
}

/// Why the page has nothing to render. Kept as an enum rather than a String so
/// the message can be resolved at build time and follow a locale switch.
enum _AboutError { noCompany, empty, failed }

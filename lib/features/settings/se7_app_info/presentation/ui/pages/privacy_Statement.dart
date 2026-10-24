/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: privacy_statement.dart
/// Description: `PrivacyStatementPage` page, state and UI of the `PrivacyStatementPage` widget, `_PrivacyError` enum.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/helper/export_directory.dart';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/knowticed_logo.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:knowticed_plus/core/network/api_constants.dart'
    hide FirebaseCollections;
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';

const bool _kDemoOwnerTools = bool.fromEnvironment('KP_OWNER_TOOLS');
const String _kDemoPdfUrl =
    'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

class PrivacyStatementPage extends StatefulWidget {
  const PrivacyStatementPage({super.key});

  @override
  State<PrivacyStatementPage> createState() => _PrivacyStatementPageState();
}

class _PrivacyStatementPageState extends State<PrivacyStatementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  String? _description;
  DateTime? _lastUpdateDate;
  String? _arDocumentUrl;
  String? _engDocumentUrl;
  bool _isDownloading = false;

  /// Null while things are fine. Holds a key, not a sentence, so the message is
  /// resolved at build time and follows a locale switch — the same shape
  /// AboutThisAppScreen uses.
  ///
  /// CHANGED 8/9/2026 — was `String? _errorMessage` carrying hardcoded English
  /// ("No data available yet", "Error loading data: `<raw Firestore text>`")
  /// that never reached the screen anyway: the empty state rendered a bare
  /// Lottie and nothing else, so every failure looked identical and silent.
  _PrivacyError? _error;

  /// The fetch reads `Localizations.localeOf(context)`, which is not available
  /// in initState — hence didChangeDependencies, guarded so an inherited-widget
  /// change does not refetch on every rebuild.
  bool _fetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fetched) return;
    _fetched = true;
    _fetchPrivacyData();
  }

  /// `ApiConstants.baseUri` is "Demo/75440689" or just the id; the company is
  /// the last segment either way.
  String? _currentCompanyId() {
    final String baseUri = ApiConstants.baseUri;
    if (baseUri.isEmpty) return null;

    final String last = baseUri.split('/').last;
    return last.isNotEmpty ? last : null;
  }

  Future<void> _fetchPrivacyData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String? companyId = _currentCompanyId();
      if (companyId == null) {
        setState(() {
          _isLoading = false;
          _error = _PrivacyError.noCompany;
        });
        return;
      }

      // Company_Data/privacy_policy/templates, filtered to this company.
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection(FirebaseCollections.adminRoot)
          .doc(FirebaseCollections.companyData)
          .collection('privacy_policy')
          .where('assignedCompanies', arrayContains: companyId)
          .limit(1)
          .get();

      if (!mounted) return;

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = _PrivacyError.empty;
        });
        return;
      }

      final Map<String, dynamic> data = querySnapshot.docs.first.data();
      final String locale = Localizations.localeOf(context).languageCode;

      setState(() {
        _description = _clean(
          locale == 'ar'
              ? data['descriptionAr'] as String?
              : data['descriptionEn'] as String?,
        );

        // Guarded rather than cast: a `lastUpdateDate` stored as a string threw
        // here and the whole page fell into the catch below as a load failure.
        final Object? updated = data['lastUpdateDate'];
        _lastUpdateDate = updated is Timestamp ? updated.toDate() : null;

        _arDocumentUrl = data['arDocumentUrl'] as String?;
        _engDocumentUrl = data['engDocumentUrl'] as String?;
        // DEMO (Moataz 23/10/2026): owner-tools builds show a sample PDF so
        // the Download button can be seen before a real file is attached.
        if (_kDemoOwnerTools) {
          if (_arDocumentUrl == null || _arDocumentUrl!.isEmpty) {
            _arDocumentUrl = _kDemoPdfUrl;
          }
          if (_engDocumentUrl == null || _engDocumentUrl!.isEmpty) {
            _engDocumentUrl = _kDemoPdfUrl;
          }
        }
        _isLoading = false;

        // A document that exists but has no body in this language is the same
        // dead end as no document at all, so it reports the same way.
        if (_description == null || _description!.isEmpty) {
          _error = _PrivacyError.empty;
        }
      });
    } catch (_) {
      if (!mounted) return;
      // The raw Firestore message is not surfaced — it is not something a user
      // can act on, and Retry is the only useful response.
      setState(() {
        _isLoading = false;
        _error = _PrivacyError.failed;
      });
    }
  }

  /// Strips the wrapping quotes the console adds when a long description is
  /// pasted as a triple-quoted or quoted string — the stored documents really
  /// do contain them.
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

  String _getFormattedDate(BuildContext context) {
    if (_lastUpdateDate == null) return '';
    final String locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ar') {
      return DateFormat('d MMMM yyyy', 'ar').format(_lastUpdateDate!);
    } else {
      return DateFormat('d MMM yyyy', 'en').format(_lastUpdateDate!);
    }
  }

  // ✅ Correct permission handling (no manageExternalStorage)
  Future<bool> _requestStoragePermission(String locale) async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) return true;

    final status = await Permission.storage.request();
    if (status.isGranted) return true;

    // App dialog instead of a red snackbar (house rule).
    if (mounted) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_action_delete_role.json',
        title: locale == 'ar'
            ? 'يرجى منح إذن التخزين'
            : 'Please grant storage permission',
      );
    }
    return false;
  }

  Future<void> _downloadPDF() async {
    final String locale = Localizations.localeOf(context).languageCode;
    final String? pdfUrl = locale == 'ar' ? _arDocumentUrl : _engDocumentUrl;

    if (pdfUrl == null || pdfUrl.isEmpty) {
      CustomDialogManager.showMessage(
        context: context,
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_action_delete_role.json',
        title: locale == 'ar'
            ? 'رابط المستند غير متاح'
            : 'Document link not available',
      );
      return;
    }

    try {
      setState(() => _isDownloading = true);

      final hasPermission = await _requestStoragePermission(locale);
      if (!hasPermission) {
        if (mounted) setState(() => _isDownloading = false);
        return;
      }

      final String? downloadPath = await _getDownloadPath();
      if (downloadPath == null) {
        throw Exception('Could not determine download path');
      }

      final String fileName =
          'Privacy_Policy_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '$downloadPath/$fileName';

      final Dio dio = Dio();
      await dio.download(pdfUrl, filePath);

      // Desktop: open the folder so the file is in front of the user, as the
      // other exports do. Best-effort; a no-op on phones.
      if (!Platform.isAndroid && !Platform.isIOS) {
        await ExportDirectory.reveal(filePath);
      }

      // CR-KNP-SET-APP-06 (20/10/2026): every setState after an await is
      // guarded — the user can leave the page while the PDF downloads.
      if (!mounted) return;
      setState(() => _isDownloading = false);
      _showSuccessDialog(context, locale, filePath);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      // Settings bug report p.17: the raw exception text ("Exception:
      // Could not determine download path") was shown in a red snackbar.
      // It is now the app's own message dialog with a plain sentence; the
      // detail goes to the debug log only.
      CustomDialogManager.showMessage(
        context: context,
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_action_delete_role.json',
        title: locale == 'ar'
            ? 'حدث خطأ أثناء تنزيل المستند'
            : 'Could not download the document',
        subtitle:
            locale == 'ar' ? 'يرجى المحاولة مرة أخرى' : 'Please try again.',
      );
    }
  }

  Future<String?> _getDownloadPath() async {
    if (Platform.isAndroid) {
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) return directory.path;
      final appDir = await getExternalStorageDirectory();
      if (appDir != null) {
        final downloadDir = Directory('${appDir.path}/Download');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir.path;
      }
    } else if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
    // ADDED 21/9/2026 — Settings bug report p.10: "Could not determine
    // download path". Desktop (macOS / Windows / Linux) had no branch and fell
    // through to null. It now uses the shared resolver every export uses —
    // the real Downloads folder, including on a sandboxed macOS build.
    final Directory downloads = await ExportDirectory.resolve();
    return downloads.path;
  }

  void _showSuccessDialog(
    BuildContext context,
    String locale,
    String filePath,
  ) {
    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (!context.mounted) return;
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        });
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            width: 411,
            padding: EdgeInsets.all(16.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
                  width: 120.w,
                  height: 120.h,
                  repeat: false,
                ),
                SizedBox(height: 16.h),
                Text(
                  locale == 'ar'
                      ? 'تم تنزيل الملف بنجاح'
                      : FormatHelper.capitalize("File downloaded successfully"),
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  locale == 'ar' ? 'المسار:' : 'Saved to:',
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.text.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    filePath,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircleProgressMaster.inline(color: AppColors.primary),
      );
    }

    if (_error != null || _description == null) {
      // CHANGED 8/9/2026 — this used to be a Lottie and nothing else, so a
      // Firestore failure, an unassigned company and a document with no Arabic
      // body all looked like the same blank screen with no way forward. It now
      // says which of those happened and offers Retry where retrying can help.
      final _PrivacyError error = _error ?? _PrivacyError.empty;

      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomEmptyState(
                lottiePath:
                    "assets/lottie_assets/main_lottie_assets/lot_empty_state.json",
                size: 220,
                verticalPadding: 0,
              ),
              SizedBox(height: 8.h),
              Text(
                _messageFor(context, error),
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              // Retry is offered only where it can help. A company with no
              // assigned document will not grow one by tapping again.
              if (error == _PrivacyError.failed) ...[
                SizedBox(height: 16.h),
                customButton(
                  title: S.of(context).retry,
                  function: _fetchPrivacyData,
                  width: 150.w,
                  height: 36,
                  radius: 4.r,
                  color: AppColors.primary,
                  textStyle: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.textButton,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Markdown(
      // D-246: the box hugs its content; the page frame scrolls.
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.sp),
      data: _withoutLeadingTitle(_description!),
      onTapLink: (text, url, title) async {
        if (url != null) {
          final uri = url.contains('support@')
              ? Uri(scheme: 'mailto', path: url.split('@').join('@'))
              : Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        // D-246: body 14 in the normal text colour.
        p: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.text,
          height: 1.6,
        ),
        h1: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.text,
          height: 1.6,
        ),
        h3: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.text,
          height: 1.6,
        ),
        listBullet: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.text, // 23/10/2026 (Moataz): body text is black
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildDownloadButton(String locale) {
    return InkWell(
      onTapDown: _isDownloading ? null : (_) => HapticController.low(),
      onTap: _isDownloading ? null : _downloadPDF,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isDownloading)
              SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircleProgressMaster.inline(
                  strokeWidth: 2,
                  color: AppColors.secondaryPrimary,
                ),
              )
            else
              CustomSvgImage(
                assetPath:
                    "assets/icons_assets/main_icons_assets/ic_action_download.svg",
                width: 16.w,
                height: 16.h,
                color: AppColors.secondaryPrimary,
              ),
            SizedBox(width: 8.w),
            Text(
              // 21/9/2026 — was the About This Platform label.
              S.of(context).downloadPDFofPrivacyAndPolicy,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.secondaryPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _messageFor(BuildContext context, _PrivacyError error) {
    switch (error) {
      case _PrivacyError.failed:
        return S.of(context).anErrorOccurred;
      case _PrivacyError.noCompany:
      case _PrivacyError.empty:
        // Deliberately the same line for both: from the reader's side "your
        // company has no privacy statement" and "the statement has no text in
        // your language" are the same outcome, and neither is actionable here.
        return S.of(context).noDataAvailable;
    }
  }

  bool get _hasDocumentUrl =>
      (_arDocumentUrl != null && _arDocumentUrl!.isNotEmpty) ||
      (_engDocumentUrl != null && _engDocumentUrl!.isNotEmpty);
  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final locale = Localizations.localeOf(context).languageCode;

    return isMobile
        ? Scaffold(
            backgroundColor: AppColors.background,
            body: SideFrameMasterServices(
              titleText: S.of(context).settings,
              secondTitle: S.of(context).privacyStatement,
              onSecondTap: () => Navigator.pop(context),
              onFirstTap: () => Navigator.pop(context),
              child: Column(
                children: [
                  // D-246 / item 169 (21/10/2026): ONE box, like About This
                  // Platform — logo left + Last Update right on one row,
                  // the title once, then the text; the box ends after it.
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Logo + Date ──────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomSvgImage.natural(
                              assetPath:
                                  knowticedLogoAsset(lightMode: lightMode),
                              width: 50.w,
                              height: 50.h,
                              fit: BoxFit.fill,
                            ),
                            const Spacer(),
                            if (_lastUpdateDate != null)
                              Row(
                                children: [
                                  Text(
                                    "${S.of(context).lastUpdate}: ",
                                    style:
                                        StyleText.fontSize12Weight500.copyWith(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  Text(
                                    _getFormattedDate(context),
                                    style:
                                        StyleText.fontSize12Weight500.copyWith(
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        SizedBox(height: 16.sp),
                        // ── Title ────────────────────────────────────
                        Row(
                          children: [
                            // Owner 21/10/2026: just the icon (16), no square tile behind it.
                            CustomSvgImage.natural(
                              assetPath:
                                  "assets/icons_assets/settings_assets/ic_page_privacy.svg",
                              width: 24.sp,
                              height: 24.sp,
                            ),
                            SizedBox(width: 8.sp),
                            Text(
                              S.of(context).privacyStatement,
                              style: StyleText.fontSize16Weight600.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.sp),
                        // ── Content ──────────────────────────────────
                        _buildContent(),
                      ],
                    ),
                  ),
                  // ── Download ─────────────────────────────────
                  // Guarded like the tablet branch: the button used to show on
                  // phones even when the document had no URL, and tapping it only
                  // produced a red "link not available" snackbar.
                  if (_hasDocumentUrl) _buildDownloadButton(locale),
                ],
              ),
            ),
          )
        // One card for header + body: two touching rounded boxes left a hairline
        // seam between them on the desktop (Moataz 23/10/2026).
        : Column(
            children: [
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: ColoredBox(
                    color: AppColors.card,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Header ──────────────────────────────────────
                        Container(
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
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomSvgImage.natural(
                                      assetPath: knowticedLogoAsset(
                                          lightMode: lightMode),
                                      width: 50.w,
                                      height: 50.h,
                                      fit: BoxFit.fill,
                                    ),
                                    const Spacer(),
                                    if (_lastUpdateDate != null)
                                      Row(
                                        children: [
                                          Text(
                                            "${S.of(context).lastUpdate}: ",
                                            style: StyleText.fontSize12Weight500
                                                .copyWith(
                                              color: AppColors.secondaryText,
                                            ),
                                          ),
                                          Text(
                                            _getFormattedDate(context),
                                            style: StyleText.fontSize12Weight500
                                                .copyWith(
                                              color: AppColors.text,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                Row(
                                  children: [
                                    // Owner 21/10/2026: just the icon (16), no square tile behind it.
                                    CustomSvgImage.natural(
                                      assetPath:
                                          "assets/icons_assets/settings_assets/ic_page_privacy.svg",
                                      width: 24.sp,
                                      height: 24.sp,
                                    ),
                                    SizedBox(width: 8.sp),
                                    Text(
                                      S.of(context).privacyStatement,
                                      style: StyleText.fontSize16Weight500
                                          .copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_hasDocumentUrl)
                                      _buildDownloadButton(locale),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // ── Content ─────────────────────────────────────
                        // FIXED 21/9/2026 — "BOTTOM OVERFLOWED BY 34 PIXELS". A screen-height
                        // fraction (0.57.h / 0.625.h) ignored the settings header card and
                        // the pane padding above it. settings_layout hands this page a bounded
                        // height through its own Expanded, so the content takes what is left.
                        // D-183 (18/10/2026): the card ends after its last field (D-146
                        // inset) — Flexible, not Expanded; it still scrolls when longer.
                        // D-215 (20/10/2026): the white section runs to the bottom of the pane.
                        Flexible(
                          child: SingleChildScrollView(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: _buildContent(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // D-215 (21/10/2026): the panel has no bottom inset of its own,
              // so the section ends with the same 15 gap as every other page.
              SizedBox(height: 16.sp),
            ],
          );
  }
}

/// Why the page has nothing to render. Kept as an enum rather than a String
/// so the message can be resolved at build time and follow a locale switch.
enum _PrivacyError { noCompany, empty, failed }

/// D-215 (20/10/2026): the page already shows its title in the header, so a
/// stored document that starts with the same title (e.g. "# Terms and
/// Conditions") loses that first heading — the title is written once.
String _withoutLeadingTitle(String markdown) {
  final List<String> lines = markdown.split('\n');
  int i = 0;
  while (i < lines.length && lines[i].trim().isEmpty) {
    i++;
  }
  if (i >= lines.length) return markdown;
  final String first = lines[i]
      .replaceFirst(RegExp(r'^\s*#+\s*'), '')
      .replaceAll(RegExp(r'[*_:]'), '')
      .trim()
      .toLowerCase();
  const List<String> titles = <String>[
    'terms and conditions',
    'terms & conditions',
    'privacy statement',
    'privacy policy',
    'الشروط والأحكام',
    'بيان الخصوصية',
    'سياسة الخصوصية',
  ];
  if (!titles.contains(first)) return markdown;
  return lines.sublist(i + 1).join('\n').trimLeft();
}

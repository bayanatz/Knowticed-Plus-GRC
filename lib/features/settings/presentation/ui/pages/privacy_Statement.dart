import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/side_frame_master.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_svg.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/enums/enum.dart';

import 'package:demo_app/features/settings/mode_changer.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/network/api_constants.dart';
import '../../../../../generated/l10n.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';

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
  String? _errorMessage;
  String? _arDocumentUrl;
  String? _engDocumentUrl;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _fetchPrivacyData();
  }

  Future<void> _fetchPrivacyData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final baseUri = ApiConstants.baseUri;
      final companyId = baseUri.split('/').last;

      if (companyId.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Company not identified';
        });
        return;
      }

      // ✅ privacy_policy collection
      final QuerySnapshot querySnapshot = await _firestore
          .collection('Company_Data')
          .doc('privacy_policy')
          .collection('templates')
          .where('assignedCompanies', arrayContains: companyId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No data available yet';
        });
        return;
      }

      final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
      final String locale = Localizations.localeOf(context).languageCode;

      setState(() {
        String? rawDescription = locale == 'ar'
            ? data['descriptionAr'] as String?
            : data['descriptionEn'] as String?;

        if (rawDescription != null) {
          rawDescription = rawDescription.trim();
          if (rawDescription.startsWith("'''") &&
              rawDescription.endsWith("'''")) {
            rawDescription =
                rawDescription.substring(3, rawDescription.length - 3);
          }
          if (rawDescription.startsWith('"') &&
              rawDescription.endsWith('"')) {
            rawDescription =
                rawDescription.substring(1, rawDescription.length - 1);
          }
          _description = rawDescription.trim();
        }

        if (data['lastUpdateDate'] != null) {
          _lastUpdateDate =
              (data['lastUpdateDate'] as Timestamp).toDate();
        }

        _arDocumentUrl = data['arDocumentUrl'] as String?;
        _engDocumentUrl = data['engDocumentUrl'] as String?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading data: ${e.toString()}';
      });
    }
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locale == 'ar'
              ? 'يرجى منح إذن التخزين'
              : 'Please grant storage permission'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return false;
  }

  Future<void> _downloadPDF() async {
    final String locale = Localizations.localeOf(context).languageCode;
    final String? pdfUrl =
    locale == 'ar' ? _arDocumentUrl : _engDocumentUrl;

    if (pdfUrl == null || pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locale == 'ar'
              ? 'رابط المستند غير متاح'
              : 'Document link not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isDownloading = true);

      final hasPermission = await _requestStoragePermission(locale);
      if (!hasPermission) {
        setState(() => _isDownloading = false);
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

      setState(() => _isDownloading = false);
      if (mounted) _showSuccessDialog(context, locale, filePath);
    } catch (e) {
      setState(() => _isDownloading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(locale == 'ar'
                ? 'حدث خطأ أثناء تنزيل المستند'
                : 'Error downloading document: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
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
    return null;
  }

  void _showSuccessDialog(
      BuildContext context, String locale, String filePath) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        });
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r)),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            width: 411,
            padding: EdgeInsets.all(15.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie/approved.json',
                  width: 120.w,
                  height: 120.h,
                  repeat: false,
                ),
                SizedBox(height: 16.h),
                Text(
                  locale == 'ar'
                      ? 'تم تنزيل الملف بنجاح'
                      : capitalize("File downloaded successfully"),
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.text),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  locale == 'ar' ? 'المسار:' : 'Saved to:',
                  style: StyleText.fontSize14Weight400.copyWith(
                      color: AppColors.text.withOpacity(0.7)),
                ),
                SizedBox(height: 4.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    filePath,
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.text),
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
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null || _description == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Lottie.asset(
              width: 400.w,
              height: 400.h,
              repeat: true,
              "assets/lottie/empty.json",
              fit: BoxFit.fill,
            ),
          ]
        ),
      );
    }

    return Markdown(
      padding: EdgeInsets.all(15.sp),
      data: _description!,
      onTapLink: (text, url, title) async {
        if (url != null) {
          final uri = url.contains('support@')
              ? Uri(scheme: 'mailto', path: url.split('@').join('@'))
              : Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      styleSheet:
      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.secondaryText, height: 1.6),
        h1: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.text, height: 1.6),
        h3: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.text, height: 1.6),
        listBullet: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.secondaryText, height: 1.6),
      ),
    );
  }

  Widget _buildDownloadButton(String locale) {
    return InkWell(
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
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondaryPrimary),
              )
            else
              CustomSvg(
                assetPath: "assets/download.svg",
                width: 16.w,
                height: 16.h,
                color: AppColors.secondaryPrimary,
              ),
            SizedBox(width: 8.w),
            Text(
              S.of(context).downloadPDFofAboutThisApp,
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.secondaryPrimary),
            ),
          ],
        ),
      ),
    );
  }
  bool get _hasDocumentUrl =>
      (_arDocumentUrl != null && _arDocumentUrl!.isNotEmpty) ||
          (_engDocumentUrl != null && _engDocumentUrl!.isNotEmpty);
  @override
  Widget build(BuildContext context) {
    final isMobile = context.isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final orientation = MediaQuery.of(context).orientation;
    final locale = Localizations.localeOf(context).languageCode;

    return isMobile
        ? Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMaster(
        titleText: S.of(context).settings,
        secondTitle: S.of(context).privacyStatement,
        onSecondTap: () => Navigator.pop(context),
        onFirstTap: () => Navigator.pop(context),
        child: Column(
          children: [
            // ── Logo + Date ──────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  lightMode
                      ? "assets/light_app_icon.svg"
                      : "assets/logo_app.svg",
                  width: 50.w,
                  height: 50.h,
                  fit: BoxFit.fill,
                ),
                const Spacer(),
                if (_lastUpdateDate != null)
                  Row(
                    children: [
                      Text("${S.of(context).lastUpdate}: ",
                          style: StyleText.fontSize12Weight500
                              .copyWith(
                              color: AppColors.secondaryText)),
                      Text(_getFormattedDate(context),
                          style: StyleText.fontSize12Weight500
                              .copyWith(color: AppColors.text)),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 20.sp),
            // ── Title ────────────────────────────────────
            Row(
              children: [
                CustomSvg(
                    assetPath: "assets/note_icon.svg",
                    width: 25,
                    height: 25,
                    fit: BoxFit.fill),
                SizedBox(width: 5.w),
                Text(
                  S.of(context).privacyStatement,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
            SizedBox(height: 10.sp),
            // ── Content ──────────────────────────────────
            Container(
              height: 0.78.h,
              padding: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: _buildContent(),
            ),
            // ── Download ─────────────────────────────────
            _buildDownloadButton(locale),
          ],
        ),
      ),
    )
        : Column(
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
            padding: EdgeInsets.all(15.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      !lightMode
                          ? "assets/light_app_icon.svg"
                          : "assets/logo_app.svg",
                      width: 50.w,
                      height: 50.h,
                      fit: BoxFit.fill,
                    ),
                    const Spacer(),
                    if (_lastUpdateDate != null)
                      Row(
                        children: [
                          Text("${S.of(context).lastUpdate}: ",
                              style: StyleText.fontSize12Weight500
                                  .copyWith(
                                  color:
                                  AppColors.secondaryText)),
                          Text(_getFormattedDate(context),
                              style: StyleText.fontSize12Weight500
                                  .copyWith(color: AppColors.text)),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    CustomSvg(
                        assetPath: "assets/note_icon.svg",
                        width: 25,
                        height: 25,
                        fit: BoxFit.fill),
                    SizedBox(width: 5.w),
                    Text(
                      S.of(context).privacyStatement,
                      style: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.secondaryText),
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
        Container(
          height: orientation == Orientation.portrait
              ? Mode.owner
              ? 0.688.h
              : 0.625.h
              : 0.57.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: _buildContent(),
        ),
      ],
    );
  }
}
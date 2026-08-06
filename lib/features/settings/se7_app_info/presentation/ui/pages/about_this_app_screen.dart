import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/custom/circle_progress.dart';
import 'package:grc_module/features/settings/main_controller/presentation/ui/widgets/shared/custom_appbar_mobile.dart';


import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/50_custom_side_frame_master.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/generated/l10n.dart';

import 'package:grc_module/core/custom/32-custom_svg.dart';
class AboutThisAppScreen extends StatefulWidget {
  const AboutThisAppScreen({super.key});

  @override
  State<AboutThisAppScreen> createState() => _AboutThisAppScreenState();
}

class _AboutThisAppScreenState extends State<AboutThisAppScreen> {
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
    _fetchAboutData();
  }

  String? _getCurrentCompanyId() {
    // ApiConstants.baseUri format is typically "Demo/{companyId}" or "{companyId}"
    // Adjust based on your actual baseUri format
    final baseUri = ApiConstants.baseUri;
    if (baseUri.isEmpty) return null;

    // If format is "Demo/75440689" → split and take last part
    final parts = baseUri.split('/');
    return parts.last.isNotEmpty ? parts.last : null;
  }

  Future<void> _fetchAboutData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Step 1: Get current company ID
      // Replace this with however you store/access the logged-in company ID
      final String? companyId = _getCurrentCompanyId();

      if (companyId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Company not identified';
        });
        return;
      }

      // Step 2: Query templates where assignedCompanies contains this company's ID
      final QuerySnapshot querySnapshot = await _firestore
          .collection('Company_Data')
          .doc('about_this_app')
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
        // Get description based on locale
        String? rawDescription = locale == 'ar'
            ? data['descriptionAr'] as String?
            : data['descriptionEn'] as String?;

        if (rawDescription != null) {
          rawDescription = rawDescription.trim();
          if (rawDescription.startsWith("'''") && rawDescription.endsWith("'''")) {
            rawDescription = rawDescription.substring(3, rawDescription.length - 3);
          }
          if (rawDescription.startsWith('"') && rawDescription.endsWith('"')) {
            rawDescription = rawDescription.substring(1, rawDescription.length - 1);
          }
          _description = rawDescription.trim();
        }

        // Get last update date
        if (data['lastUpdateDate'] != null) {
          _lastUpdateDate = (data['lastUpdateDate'] as Timestamp).toDate();
        }

        // Get document URLs
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


  Future<String?> _getDownloadPath() async {
    try {
      if (Platform.isAndroid) {
        // For Android, try to use the public Downloads directory
        final directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          return directory.path;
        }

        // Fallback to app-specific directory
        final appDir = await getExternalStorageDirectory();
        if (appDir != null) {
          final downloadDir = Directory('${appDir.path}/Download');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          return downloadDir.path;
        }
      } else if (Platform.isIOS) {
        // iOS uses Documents directory
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // Desktop platforms: Use Downloads directory
        final directory = await getDownloadsDirectory();
        if (directory != null) {
          return directory.path;
        }

        // Fallback for desktop
        final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
        if (home != null) {
          String downloadPath;
          if (Platform.isMacOS || Platform.isLinux) {
            downloadPath = '$home/Downloads';
          } else if (Platform.isWindows) {
            downloadPath = '$home\\Downloads';
          } else {
            return null;
          }

          // Ensure the directory exists
          final dir = Directory(downloadPath);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
          return downloadPath;
        }
      }
    } catch (e) {
      print('Error getting download path: $e');
    }
    return null;
  }

  Future<void> _downloadPDF() async {
    final String locale = Localizations.localeOf(context).languageCode;
    final String? pdfUrl = locale == 'ar' ? _arDocumentUrl : _engDocumentUrl;

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
      setState(() {
        _isDownloading = true;
      });

      // Request storage permission for Android
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        // For Android 11+ (API 30+), also try manage external storage
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }

        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(locale == 'ar'
                  ? 'يرجى منح إذن التخزين'
                  : 'Please grant storage permission'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isDownloading = false;
          });
          return;
        }
      }

      // Get download directory
      final String? downloadPath = await _getDownloadPath();

      if (downloadPath == null) {
        throw Exception('Could not determine download path');
      }

      final String fileName = 'Privacy_Statement_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '$downloadPath/$fileName';

      // Download the file
      Dio dio = Dio();
      await dio.download(
        pdfUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      setState(() {
        _isDownloading = false;
      });

      // Show success dialog with actual file path and name
      _showSuccessDialog(context, locale, filePath, fileName);

    } catch (e) {
      setState(() {
        _isDownloading = false;
      });

      print('Download error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locale == 'ar'
              ? 'حدث خطأ أثناء تنزيل المستند: ${e.toString()}'
              : 'Error downloading document: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccessDialog(BuildContext context, String locale, String filePath, String fileName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // Auto dismiss after 3 seconds
        Future.delayed(Duration(seconds: 3), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
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
            padding: EdgeInsets.all(15.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/approved.json',
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
                // File path
                Text(
                  locale == 'ar' ? 'المسار:' : 'Saved to:',
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.text.withOpacity(0.7),
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

  String _getFormattedDate(BuildContext context) {
    if (_lastUpdateDate == null) {
      return '';
    }

    final String locale = Localizations.localeOf(context).languageCode;

    if (locale == 'ar') {
      // Format for Arabic: "٢٨ يوليو ٢٠٢٥"
      final DateFormat formatter = DateFormat('d MMMM yyyy', 'ar');
      return formatter.format(_lastUpdateDate!);
    } else {
      // Format for English: "28 Jul 2025"
      final DateFormat formatter = DateFormat('d MMM yyyy', 'en');
      return formatter.format(_lastUpdateDate!);
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_errorMessage != null || _description == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              width: 400.w,
              height: 400.h,
              repeat: true,
              "assets/lottie_assets/notification_lottie_assets/empty.json",
              fit: BoxFit.fill,
            ),
          ],
        ),
      );
    }

    return Markdown(
      padding: EdgeInsets.all(15.sp),
      data: _description!,
      onTapLink: (text, url, title) async {
        if (url != null && url.contains('support@')) {
          final Uri params = Uri(
            scheme: 'mailto',
            path: url.split('@').join('@'),
          );
          final String emailUrl = params.toString();
          var link = Uri.parse(emailUrl);
          await launchUrl(
            link,
            mode: LaunchMode.externalApplication,
          );
        } else if (url != null) {
          var link = Uri.parse(url);
          await launchUrl(
            link,
            mode: LaunchMode.externalApplication,
          );
        }
      },
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.secondaryText,
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
          color: AppColors.secondaryText,
          height: 1.6,
        ),
      ),
    );
  }


  bool get _hasDocumentUrl =>
      (_arDocumentUrl != null && _arDocumentUrl!.isNotEmpty) ||
          (_engDocumentUrl != null && _engDocumentUrl!.isNotEmpty);


  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final orientation = MediaQuery.of(context).orientation;

    return MediaQuery.of(context).size.shortestSide > 600
        ? Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                topRight: Radius.circular(8.r)),
          ),
          child: Padding(
            padding: EdgeInsets.all(15.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: SvgPicture.asset(
                        !lightMode
                            ? "assets/icons_assets/main_icons_assets/light_app_icon.svg"
                            : "assets/icons_assets/main_icons_assets/logo_app.svg",
                        width: 50.w,
                        height: 50.h,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Spacer(),
                    if (_lastUpdateDate != null)
                      Row(
                        children: [
                          Text(
                            "${S.of(context).lastUpdate}: ",
                            style: StyleText.fontSize12Weight500.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          Text(
                            _getFormattedDate(context),
                            style: StyleText.fontSize12Weight500.copyWith(
                              color: AppColors.text,
                            ),
                          )
                        ],
                      )
                  ],
                ),
                SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomSvgImage(
                        assetPath: "assets/icons_assets/settings_assets/notification_announcement.svg",
                        width: 25,
                        height: 25,
                        fit: BoxFit.fill),
                    SizedBox(width: 5.w),
                    Text(
                        FormatHelper.capitalize(
                            S.of(context).aboutThisPlatform),
                        style: StyleText.fontSize16Weight500.copyWith(
                            color: lightMode
                                ? AppColors.secondaryText
                                : AppColors.grey)),
                    Spacer(),
                    if (_hasDocumentUrl)
                    InkWell(
                      onTap: _isDownloading ? null : _downloadPDF,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (_isDownloading)
                              SizedBox(
                                  width: 16.w,
                                  height: 16.h,
                                  child: CircleProgressMaster()
                              )
                            else
                              CustomSvgImage(
                                assetPath: "assets/icons_assets/form_builder_assets/download_arrow.svg",
                                width: 16.w,
                                height: 16.h,
                                color: AppColors.secondaryPrimary,
                              ),
                            SizedBox(width: 8.w),
                            Text(
                              S.of(context).downloadPDFofAboutThisApp,
                              style: StyleText.fontSize14Weight500.copyWith(
                                color: AppColors.secondaryPrimary,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),

              ],
            ),
          ),
        ),
        Container(
          height: orientation == Orientation.portrait
              ? 0.625.h
              : 0.57.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.inversePrimary,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8)),
          ),
          child: _buildContent(),
        ),
      ],
    )
        : Scaffold(
          backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.of(context).settings,
          secondTitle: S.of(context).aboutThisApp,
          onSecondTap: () {
            Navigator.pop(context);
          },
          onFirstTap: () {
            Navigator.pop(context);
          },
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    child: SvgPicture.asset(
                      !lightMode
                          ? "assets/icons_assets/main_icons_assets/logo_app.svg"
                          : "assets/icons_assets/main_icons_assets/light_app_icon.svg",
                      width: 50.w,
                      height: 50.h,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Spacer(),
                  if (_lastUpdateDate != null)
                    Row(
                      children: [
                        Text(
                          "${S.of(context).lastUpdate}: ",
                          style: StyleText.fontSize12Weight500.copyWith(
                              color: AppColors.secondaryText),
                        ),
                        Text(
                          _getFormattedDate(context),
                          style: StyleText.fontSize12Weight500
                              .copyWith(color: AppColors.text),
                        )
                      ],
                    )
                ],
              ),
              SizedBox(height: 20.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomSvgImage(
                      assetPath: "assets/icons_assets/settings_assets/notification_announcement.svg",
                      width: 25,
                      height: 25,
                      fit: BoxFit.fill),
                  SizedBox(width: 5.w),
                  Text(S.of(context).aboutThisApp,
                      style: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.secondaryText)),
                ],
              ),
              SizedBox(height: 10.sp),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 0.78.h,
                    padding: const EdgeInsets.only(top: 0, bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: _buildContent(),
                  ),
                ],
              ),
              InkWell(
                onTap: _isDownloading ? null : _downloadPDF,
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (_isDownloading)
                        SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircleProgressMaster()
                        )
                      else
                        CustomSvgImage(
                          assetPath: "assets/icons_assets/form_builder_assets/download_arrow.svg",
                          width: 16.w,
                          height: 16.h,
                          color: AppColors.secondaryPrimary,
                        ),
                      SizedBox(width: 8.w),
                      Text(
                        S.of(context).downloadPDFofAboutThisApp,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.secondaryPrimary,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
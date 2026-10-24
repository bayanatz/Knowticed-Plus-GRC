/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: import_page_methods2.dart
/// Description: Declares `_ImportPageMethods2`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/import_page.dart';

extension _ImportPageMethods2 on _UploadFileTabletRolesState {
  void _showHeaderErrorDialog(List<String> missingHeaders) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
      title: S.of(context).headerMismatch,
      subtitle: "${S.of(context).missingColumns}: ${missingHeaders.join(', ')}",
      closeAfter: const Duration(seconds: 5),
    );
  }

  void _showMissingHeadersWarning(List<String> missingHeaders) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Warning Invalid Column Title: ${missingHeaders.join(', ')}',
        ),
        duration: Duration(seconds: 3),
        backgroundColor: AppColors.orange,
      ),
    );
  }

  void _showAdditionalColumnsWarning(List<String> additionalHeaders) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Warning Additional Column: ${additionalHeaders.join(', ')}',
        ),
        duration: Duration(seconds: 3),
        backgroundColor: AppColors.orange,
      ),
    );
  }

  Future<bool> requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (status.isGranted) {
          return true;
        }

        if (status.isDenied) {
          status = await Permission.storage.request();
          if (status.isGranted) {
            return true;
          }
        }

        if (status.isPermanentlyDenied) {
          var manageStatus = await Permission.manageExternalStorage.status;
          if (manageStatus.isDenied) {
            manageStatus = await Permission.manageExternalStorage.request();
          }
          return manageStatus.isGranted;
        }

        return status.isGranted;
      } else if (Platform.isIOS) {
        return true;
      }
      return true;
    } catch (e) {
      return true;
    }
  }
}

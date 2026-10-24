/// Module: services / sv4_bulk_upload_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: upload_file.dart
/// Purpose: can make bulk upload of file by drag and drop here
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';

import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services/sv1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:lottie/lottie.dart';
import 'package:desktop_drop/desktop_drop.dart';

import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';

import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/presentation/ui/pages/data_upload_upload_file_details_toggle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';
import 'package:knowticed_plus/features/services/helpers/constants/master_upload_headers.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/data/data_source/service_excel_reader.dart';
import 'package:knowticed_plus/features/services/data/utils/storage_permission.dart';
import 'package:knowticed_plus/features/services/helpers/constants/services_lottie.dart';
import 'package:knowticed_plus/features/services/sv4_bulk_upload_services/domain/use_cases/upload_file_row_validator.dart';
part 'upload_file_part2.dart';

class UploadFileTablet extends StatefulWidget {
  const UploadFileTablet({super.key});

  @override
  State<UploadFileTablet> createState() => _UploadFileTabletState();
}

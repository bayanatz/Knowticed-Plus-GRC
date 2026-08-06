import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/1-custom_dropdwon.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/circle_progress.dart';
import 'package:lottie/lottie.dart';
import 'package:grc_module/core/custom/2-custom_textfield.dart' hide AppLanguage;
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/active_directory_controller.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/ui/widgets/tabs/user_data_tab.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/ui/widgets/tabs/wrong_data_tab.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';

part '../widgets/csv_table_builders1.dart';
part '../widgets/csv_table_builders2.dart';
part '../widgets/csv_export_dialog.dart';
part '../widgets/csv_export_preview.dart';
part '../widgets/csv_active_directory_filter_dialog.dart';

// ---------------------------------------------------------------------------
// Column index constants — derived from EmployeeDataItems enum order.
// 0:id  1:firstName  2:middleName  3:lastName
// 4:firstNameArabic  5:middleNameArabic  6:lastNameArabic
// 7:email  8:mobileCountryCode  9:mobileNumber
// 10:homeCountryCode  11:homeNumber  12:officeCountryCode  13:officeNumber
// 14:extension  15:gender  16:country  17:province  18:city
// 19:postalCode  20:street  21:language
// 22:departmentId  23:departmentEnglishName  24:departmentArabicName
// 25:supervisorEmail  26:role  27:englishTitle  28:arabicTitle
// 29:workLocation  30:none
// ---------------------------------------------------------------------------
class _ColumnIndex {
  static const int department   = 23;
  static const int role         = 26;
  static const int title        = 27;
  static const int workLocation = 29;
  static const int supervisor   = 25;
  static const int gender       = 15;
  static const int nationality  = -1; // not in CSV
  static const int country      = 16;
}

// ════════════════════════════════════════════════════════════════════════════
// MAIN WIDGET
// ════════════════════════════════════════════════════════════════════════════

class CustomCsvTable extends GetView<ActiveDirectoryController> {
  const CustomCsvTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
        bloc: Get.find<ActiveDirectoryController>(),
        builder: (context, state) {
      final controller = Get.find<ActiveDirectoryController>();
      return controller.loadingData
          ? const Center(child: CircleProgressMaster())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(controller, context, isVertical),
          Expanded(
            child: _buildTableArea(controller, context, isVertical),
          ),
          if (controller.isEditMode && controller.selectedIndex == 1)
            _buildEditBottomBar(controller, context),
        ],
      );
    });
  }
}

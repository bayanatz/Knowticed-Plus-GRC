import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/active_directory_controller.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import './custom_csv_table_page.dart';

class CsvView extends StatelessWidget {
  const CsvView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    if (!Get.isRegistered<ActiveDirectoryController>()) {
      Get.put(ActiveDirectoryController(
        departmentCubit: context.read<MainCoreDepartmentCubit>(),
      ));
    }

    return const Scaffold(body: SafeArea(child: CustomCsvTable()));
  }
}
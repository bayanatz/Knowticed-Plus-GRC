///************************ FILE INFO ****************************///
///Purpose: Entry point for the settings screen mobile and tablet
///Author: Amr Mesbah
///Refactored At: 10//11/2023
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/controllers/notification_controller.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';

import 'package:grc_module/features/home/h1_home_page/presentation/controller/home_cubit.dart';

import 'package:grc_module/features/settings/main_controller/data/models/employee_directory_model.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/settings_controller.dart';
import './settings_layout.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:grc_module/core/custom/loading.dart';

NewEmployeeModelHistory? employee = NewEmployeeModelHistory();
EmployeeDirectoryModel? employeeDirectory;
GlobalKey settingsKey = GlobalKey();

class SettingsScreen extends StatefulWidget {
  final int? index;
  bool hasBack;
  SettingsScreen({this.index, this.hasBack = true, Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late SettingsController settingsController;
  bool isLoading = true;
  bool darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }


  @override
  void dispose() {
    // Clean up
    super.dispose();
  }

  Future<void> _initializeSettings() async {
    try {
      settingsController = Get.find<SettingsController>();
    } catch (e) {
      settingsController = Get.put(SettingsController());
    }

    await getEmployee();
    settingsController.selectedContainerIndex = widget.index ?? 0;

    if (mounted) {  // ✅ Add mounted check
      setState(() {
        isLoading = false;
      });
    }
  }

  void setSelectedContainerIndex(int index) {
    if (!mounted) return; // ✅ Add mounted check

    setState(() {
      if (index != 11) {
        settingsController.selectedContainerIndex = index;
      }
      if (index == 10) {
        Get.find<SettingsController>().healthInsuranceController.getData();
      }
    });
  }

  EmployeeController addEmployeeController = Get.find();
  final storage = GetStorage();

  Future<void> getEmployee() async {
    employee = await addEmployeeController
        .getEmployee(storage.read(SettingsConstants.emailKey));
  }

  Future<void> getEmployeeDirectory() async {
    employeeDirectory = await addEmployeeController
        .getEmployeeDirectory(storage.read(SettingsConstants.emailKey));
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return const SizedBox.shrink(); // ✅ Add mounted check

    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: isLoading
          ? const CircleProgress()
          : GetBuilder<SettingsController>(
        init: Get.find<SettingsController>(),
        builder: (_) {
          return Row(
            children: [
              Expanded(
                child: GetBuilder<SettingsController>(
                  init: Get.find<SettingsController>(),
                  builder: (_) {
                    if (!mounted) return const SizedBox.shrink(); // ✅ Add mounted check

                    return Container(
                      child: isTablet
                          ? Navigator(
                        key: settingsKey,
                        onGenerateRoute: (settings) {
                          return MaterialPageRoute(
                            builder: (_) {
                              return SettingsLayout();
                            },
                          );
                        },
                      )
                          : SettingsLayout(),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
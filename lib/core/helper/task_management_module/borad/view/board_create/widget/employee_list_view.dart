import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/main_yellow_button.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// Created by Islam Diab
/// updated by Nour Nabil
/// Date : 26/02/2025
/// last Update : 15/03/2025
/// objective: this file represents the  the employee list view that has all the employees available.
class EmployeeUtils {
  final String id;
  final String name;
  final String email;
  final String title;
  final String subtitle;
  final String? photo;
  bool isSelected;

  EmployeeUtils({
    required this.id,
    required this.name,
    required this.email,
    required this.title,
    required this.subtitle,
    required this.photo,
    this.isSelected = false,
  });
}

class EmployeeListView extends StatefulWidget {
  final List<EmployeeEntityPro> employees;
  final Function(List<EmployeeUtils>) onSelectionChanged; // Callback function

  const EmployeeListView({
    super.key,
    required this.employees,
    required this.onSelectionChanged, // Accept callback
  });
  @override
  State<EmployeeListView> createState() => _EmployeeListViewState();
}

// AddEmployeeController addEmployeeController = Get.find();
// List<EmployeeEntity> allEmployeesEntities =
//     addEmployeeController.allEmployeesEntities!;

class _EmployeeListViewState extends State<EmployeeListView> {
  List<EmployeeUtils> allEmployees = [];
  // final List<EmployeeUtils> allEmployees = List.generate(
  //   allEmployeesEntities.length,
  //   (index) => EmployeeUtils(
  //     id: allEmployeesEntities[index].id!,
  //     name:
  //         "${allEmployeesEntities[index].firstName!} ${allEmployeesEntities[index].lastName!}",
  //     title: allEmployeesEntities[index].departmentId!,
  //     subtitle: allEmployeesEntities[index].role!,
  //     photo: allEmployeesEntities[index].photo,
  //     isSelected: false,
  //   ),
  // );
  @override
  void initState() {
    // TODO: implement initState
    getEmployees();
    super.initState();
  }

  String getNameOfDepartment(String index) {
    switch (index) {
      case '1':
        return "Executive".tr;
      case '2':
        return "Operations".tr;
      case '3':
        return "Finance".tr;
      case '4':
        return "Information Technology".tr;
      case '5':
        return "Human Resources".tr;
      case '6':
        return "Marketing".tr;
      case '7':
        return "Sales".tr;
      case '8':
        return "Data Management".tr;
      case '9':
        return "Compliance & Legal".tr;
      case '10':
        return "Customer Support".tr;
      default:
        return "None".tr;
    }
  }

  void getEmployees() {
    allEmployees = List.generate(
      widget.employees.length,
      (index) => EmployeeUtils(
        id: widget.employees[index].id!,
        name:
            "${widget.employees[index].firstName!} ${widget.employees[index].lastName!}",
        title: getNameOfDepartment(widget.employees[index].departmentId!),
        subtitle: widget.employees[index].role!,
        photo: widget.employees[index].photo,
        email: widget.employees[index].email!,
        isSelected: false,
      ),
    );
    print(widget.employees[0].firstName);
  }

  /// Selected Employees
  final List<EmployeeUtils> selectedEmployee = [];

  ///
  void toggleEmployeeSelection(EmployeeUtils employee) {
    setState(() {
      employee.isSelected = !employee.isSelected;
      if (employee.isSelected) {
        selectedEmployee.add(employee);
      } else {
        selectedEmployee.removeWhere((p) => p.id == employee.id);
      }
    });
    widget.onSelectionChanged(selectedEmployee);
  }


// Remove employee from selected
  void removeEmployeeFromSelected(EmployeeUtils employee) {
    setState(() {
      selectedEmployee.removeWhere((p) => p.id == employee.id);

      final originalEmployee =
          allEmployees.firstWhere((p) => p.id == employee.id);
      originalEmployee.isSelected = false;
    });
  }

  // Select all employees
  void selectAllEmployees() {
    setState(() {
      for (var employee in allEmployees) {
        if (!employee.isSelected) {
          employee.isSelected = true;
          selectedEmployee.add(employee);
        }
      }

      // Notify parent widget
      widget.onSelectionChanged(selectedEmployee);
    });

  }

  ImageProvider employeePhoto(int index) {
    if (allEmployees[index].photo == null) {
      return Image.asset('assets/icons/Ellipse 225.png').image;
    }
    return Image.network(allEmployees[index].photo!).image;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ReusableElevatedButton(
            icon: 'assets/icons/all-agree 1.svg',
            buttonText: 'Select All',
            onPressed: selectAllEmployees,
          ),
        ),
        const SizedBox(height: 10),
        selectedEmployee.isEmpty
            ? const SizedBox.shrink()
            : SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedEmployee.length,
                  itemBuilder: (context, index) {
                    final employee = selectedEmployee[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: employeePhoto(index),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => removeEmployeeFromSelected(employee),
                              child: SvgPicture.asset(
                                'assets/icons/Close Circle.svg',
                                width: 12,
                                height: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          itemCount: allEmployees.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final employee = allEmployees[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: AppColors.colorLightGrey,
              ),
              child: InkWell(
                onTap: () => toggleEmployeeSelection(employee),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        foregroundColor: Colors.amber,
                        backgroundImage: employeePhoto(index),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              allEmployees[index].name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              allEmployees[index].title,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              allEmployees[index].subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      employee.isSelected
                          ? Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: GestureDetector(
                                child: SvgPicture.asset(
                                  'assets/icons_assets/main_icons_assets/CheckListOn.svg',
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: GestureDetector(
                                child: SvgPicture.asset(
                                  'assets/icons_assets/main_icons_assets/CheckListOff.svg',
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}



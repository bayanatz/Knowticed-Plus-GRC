

// Global permission variables
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/employees/employees_views/employees_hr_view/add_new_employee_vertical.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';

import 'package:demo_app/core/helper/employees/presentation/ui/pages/Permissions.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/additional_information.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/position_details.dart';
import 'package:demo_app/features/settings/mode_changer.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';
import 'package:demo_app/core/helper/employees/core_widgets/buttons/main_custom_icon_button.dart';
// REMOVED_MODULE: import '../../../../controllers/users_access_controller.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/custom_appbar.dart';
import 'package:demo_app/features/employee/data/models/emplyees_model/mobile_phone_model.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/add_new_employee_controller.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/add_employee_page_widgets/add_employee_indicators_appbar.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/widgets/add_employee_page_widgets/add_new_employee_page_title.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/add_new_employee_person_info.dart';

String homePermission = '';
String employeePermission = '';
String chatPermission = '';
String boardPermission = '';
String checkPermission = '';
String settingPermission = '';

// Document URLs
String? imageUrl;
String? educationCertificate;
String? idPhoto;
String? armyCertificate;
String? drivingLicense;
String? maritalCertificate;
String? insuranceCard;
String? supervisor;
String? supervisorName2;

class AddNewEmployeeScreen extends StatefulWidget {
  const AddNewEmployeeScreen({super.key});

  @override
  State<AddNewEmployeeScreen> createState() => _AddNewEmployeeScreenState();
}

class _AddNewEmployeeScreenState extends State<AddNewEmployeeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  /// Initialize all state variables
  void _initializeState() {
    homePermission = '';
    employeePermission = '';
    chatPermission = '';
    boardPermission = '';
    checkPermission = '';
    settingPermission = '';
    supervisor = null;
    supervisorName2 = null;
    imageUrl = null;
    educationCertificate = null;
    idPhoto = null;
    armyCertificate = null;
    drivingLicense = null;
    maritalCertificate = null;
    insuranceCard = null;
    gender = null;
    nation = null;
    maritalStatus = null;
    language = null;
    department = null;
    role = null;
    type = null;
    country2 = null;
    city2 = null;
    province2 = null;
    jobLocation = null;
    jobCompensation = null;
    currency = null;
    days = null;
    weekends = null;
    startTime2 = null;
    endTime2 = null;
    asset = [];
    firstName2 = null;
    firstName2InArabic = null;
    lastName2 = null;
    lastName2InArabic = null;
    middleName2 = null;
    middleName2InArabic = null;
    address2 = null;
    phone2 = null;
    insuranceName2 = null;
    nationalId2 = null;
    passportNumber2 = null;
    passportDate2 = null;
    nationalDate2 = null;
    postal2 = null;
    insurancePoliceName2 = null;
    phoneNumberInsu2 = null;
    salary2 = null;
    title2 = null;
    titleInArabic2 = null;
    birthday2 = null;
    contactName2 = [];
    contactPostalCode2 = [];
    contactMiddleName2 = [];
    contactLastName2 = [];
    contactEmail2 = [];
    contactCountry2 = [];
    contactCity2 = [];
    contactProvince2 = [];
    contactAddress2 = [];
    contactRelation2 = [];
    contactNumber2 = [];
    contactCodeNumber2 = [];
    contactAppNumber2 = [];
  }

  // Controllers
  PageController pageController = PageController();
  final HapticController hapticController = Get.put(HapticController());
  final AddNewEmployeeController addNewEmployeeController =
  Get.put(AddNewEmployeeController());
  // UsersAccessController removed — add your own access controller when needed

  // Permission value
  double permissions = 0;

  // Personal info variables
  String? gender;
  String? nation;
  String? maritalStatus;
  String? language;
  String? firstName2;
  String? firstName2InArabic;
  String? birthday2;
  String? lastName2;
  String? lastName2InArabic;
  String? middleName2;
  String? middleName2InArabic;
  String? address2;
  String? nationalId2;
  String? passportNumber2;
  String? passportDate2;
  String? nationalDate2;
  String? postal2;
  String? country2;
  String? city2;
  String? province2;
  String? phone2;
  String? insuranceName2;
  String? insurancePoliceName2;
  String? phoneNumberInsu2;
  String? salary2;
  String? title2;
  String? titleInArabic2;

  TimeOfDay? startTime2;
  TimeOfDay? endTime2;

  // Emergency contact lists
  List<String?> contactName2 = [];
  List<String?> contactPostalCode2 = [];
  List<String?> contactMiddleName2 = [];
  List<String?> contactLastName2 = [];
  List<String?> contactEmail2 = [];
  List<String?> contactCountry2 = [];
  List<String?> contactCity2 = [];
  List<String?> contactProvince2 = [];
  List<String?> contactAddress2 = [];
  List<String?> contactRelation2 = [];
  List<String?> contactNumber2 = [];
  List<String?> contactCodeNumber2 = [];
  List<String?> contactAppNumber2 = [];

  // Health insurance text controllers
  TextEditingController insuranceName = TextEditingController();
  TextEditingController insurancePoliceName = TextEditingController();
  TextEditingController phoneNumberInsu = TextEditingController();
  List<TextEditingController> contactName = [TextEditingController()];
  List<TextEditingController> contactPostalCode = [TextEditingController()];
  List<TextEditingController> contactMiddleName = [TextEditingController()];
  List<TextEditingController> contactLastName = [TextEditingController()];
  List<TextEditingController> contactEmail = [TextEditingController()];
  List<TextEditingController> contactCountry = [TextEditingController()];
  List<TextEditingController> contactCity = [TextEditingController()];
  List<TextEditingController> contactProvince = [TextEditingController()];
  List<TextEditingController> contactAddress = [TextEditingController()];
  bool hasSecond = false;
  List<TextEditingController> contactRelation = [TextEditingController()];
  List<TextEditingController> contactNumber = [TextEditingController()];

  // Position details variables
  String? department;
  String? role;
  String? type;
  String? jobLocation;
  String? jobCompensation;
  String? currency;
  TextEditingController salary = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController titleInArabic = TextEditingController();

  String? days;
  String? weekends;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  late List<String?> asset;
  int selectedIndex = 0;
  List<TextEditingController> assetName = [TextEditingController()];
  List<TextEditingController> assetId = [TextEditingController()];
  List<TextEditingController> assetDescription = [TextEditingController()];

  int assetsCount = 0;

  ButtonStyle buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      minimumSize: Size(0.065.w, 0.05.h),
      backgroundColor: color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );
  }

  /// Validate required fields before saving
  bool _validateRequiredFields() {
    if (firstName2 == null || firstName2!.isEmpty) {
      _showValidationError('First name is required');
      return false;
    }
    if (lastName2 == null || lastName2!.isEmpty) {
      _showValidationError('Last name is required');
      return false;
    }
    if (addNewEmployeeController.email.text.isEmpty) {
      _showValidationError('Email is required');
      return false;
    }
    return true;
  }

  /// Show validation error dialog
  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Validation Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to save employee: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show loading indicator (placeholder - implement with your loading system)
  void showLoadingIndicator() {
    // Implement your loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
  }

  /// Hide loading indicator
  void hideLoadingIndicator() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double widthOfData = 0.27.w;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: GetBuilder<EmployeeController>(
          init: Get.find<EmployeeController>(),
          builder: (addEmployeeController) {
            return Row(
              children: <Widget>[
                isPortrait
                    ? Expanded(
                  child: Column(
                    children: [
                      CustomAppBar(),
                      // TODO: Implement mobile add-employee form (AddNewEmployeeVerticalView was removed)
                      const Expanded(child: Center(child: Text('Mobile employee form — implement here'))),
                    ],
                  ),
                )
                    : Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomAppBar(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              height: 0.85.h,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 0.03.h,
                                  horizontal: 0.02.h,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    AddNewEmployeePageTitle(),
                                    AddNewEmployeeIndicators(
                                      selectedIndex: Mode.addNewEmployeeIndex,
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: SizedBox(
                                          height: MediaQuery.of(context).size.longestSide,
                                          child: PageView.builder(
                                            itemCount: 6,
                                            physics: const NeverScrollableScrollPhysics(),
                                            controller: pageController,
                                            onPageChanged: (value) {
                                              setState(() {
                                                Mode.addNewEmployeeIndex = value;
                                              });
                                            },
                                            itemBuilder: (context, index) {
                                              return _buildPageContent(
                                                addEmployeeController,
                                                widthOfData,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    _buildNavigationButtons(addEmployeeController),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build page content based on current index
  Widget _buildPageContent(
      EmployeeController addEmployeeController,
      double widthOfData,
      ) {
    switch (Mode.addNewEmployeeIndex) {
      case 0:
        return _buildPersonalInfoPage(addEmployeeController, widthOfData);
      case 1:
        return _buildHealthInsurancePage();
      case 2:
        return _buildPositionDetailsPage(addEmployeeController, widthOfData);
      case 3:
        return _buildAdditionalInfoPage();
      case 12:
        return const PermissionsView();
      default:
        return const SizedBox();
    }
  }

  /// Build personal info page
  Widget _buildPersonalInfoPage(
      EmployeeController addEmployeeController,
      double widthOfData,
      ) {
    return AddNewEmployeePersonInfo(
      // Address handlers
      addressState: (value) {
        setState(() {
          address2 = value.text;
          print('address="${value.text}"');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                street: value.text.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      addressfinishState: (value) {},

      // City handlers
      cityState: (value) {
        setState(() {
          city2 = value.text;
          print('city=${value.text}');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                city: value.text.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      cityfinishState: (value) {
        setState(() {});
      },

      // Province handlers
      provinceState: (value) {
        setState(() {
          province2 = value.text;
          print('province=${value.text}');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                province: value.text.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      provincefinishState: (value) {
        setState(() {});
      },

      // Country handler
      countryState: (value) {
        setState(() {
          country2 = value.text;
          print('country=${value.text}');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                country: value.text.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      countryfinishState: (value) {
        setState(() {
          addNewEmployeeController.personalInfoValue += 1 / 10;
        });
      },

      // Middle name handlers
      MiddleNameState: (value) {
        setState(() {
          middleName2 = value.text;
          print('middleName=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                middleName: value.text,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      MiddleNameStateInArabic: (value) {
        setState(() {
          middleName2InArabic = value.text;
          print('middleName2InArabic=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                middleNameInArabic: value.text,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      MiddlenNamefinishState: (value) {
        setState(() {});
      },

      // National ID handlers
      nationalIdState: (value) {
        setState(() {
          nationalId2 = value.text;
          print('nationalId=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                nationalId: value.text,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      nationalIdfinishState: (value) {
        setState(() {});
      },

      // Passport handlers
      passportNumberState: (value) {
        setState(() {
          passportNumber2 = value.text;
          print('passportNumber=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                passport: value.text,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      passportDateState: (value) {
        setState(() {
          passportDate2 = value;
          print('passportDate=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                passportExpirationDate: value,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      nationalDateState: (value) {
        setState(() {
          nationalDate2 = value;
          print('nationalDate=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                nationalIdExpirationDate: value,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },

      // Postal code handler
      postalState: (value) {
        setState(() {
          postal2 = value.text;
          print('postal=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                postalCode: value.text,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },

      // Birthday handler
      birthDateState: (value) {
        setState(() {
          birthday2 = value;
          print('birthday=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                birthDay: value.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      birthDatefinishState: (value) {
        setState(() {
          addNewEmployeeController.personalInfoValue += 1 / 10;
        });
      },

      // Controller and dimensions
      addEmployeeController: addEmployeeController,
      widthOfData: widthOfData,
      personInfoCount: addNewEmployeeController.personalInfoValue,
      personInfoState: (value) {
        setState(() {
          addNewEmployeeController.personalInfoValue = value;
        });
      },

      // First name handlers
      firstNameState: (value) {
        setState(() {
          firstName2 = value.text;
          print('firstName=${value.text}');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                firstName: value.text.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      firstNameStateInArabic: (value) {
        setState(() {
          firstName2InArabic = value.text;
          print('firstName2InArabic=${value.text}');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                firstNameInArabic: value.text.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      firstNamefinishState: (value) {
        setState(() {});
      },

      // Last name handlers
      lastNameState: (value) {
        setState(() {
          lastName2 = value.text;
          print('lastName=${value.text}');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                lastName: value.text.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      lastNameStateInArabic: (value) {
        setState(() {
          lastName2InArabic = value.text;
          print('lastName2InArabic=${value.text}');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                lastNameInArabic: value.text.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      lastNamefinishState: (value) {
        setState(() {
          addNewEmployeeController.personalInfoValue += 1 / 10;
        });
      },

      // Gender handler
      gender: gender,
      genderState: (value) {
        setState(() {
          gender = value;
          print('gender=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                gender: value!.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );

          addNewEmployeeController.personalInfoValue += 1 / 10;
        });
      },

      // Email handler
      emailState: (value) {
        setState(() {
          print('email=${value.text}');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                email: value.text,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      emailfinishState: (value) {
        setState(() {
          addNewEmployeeController.personalInfoValue += 1 / 10;
        });
      },

      // Phone handler
      phoneState: (value) {
        setState(() {
          phone2 = value.completeNumber;
          print('phone=${value.completeNumber}');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                mobilePhone:
                  MobilePhone(
                    phones: [value.number],
                    countryCode: [value.countryCode],
                    countryApp: [value.countryISOCode ?? ''], // Add country app/ISO code if available
                    timestamps: [Timestamp.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch)],
                  )
                ,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      phonefinishState: (value) {
        setState(() {
          addNewEmployeeController.personalInfoValue += 1 / 10;
        });
      },

      // Nationality handler
      nation: nation,
      nationState: (value) {
        setState(() {
          nation = value;
          print('nationality=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                nationality: value!.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );

          addNewEmployeeController.personalInfoValue += 1 / 10;
        });
      },

      // Marital status handler
      maritalStatus: maritalStatus,
      maritalStatusState: (value) {
        setState(() {
          maritalStatus = value;
          print('maritalStatus=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                maritalStatus: value!.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );

          addNewEmployeeController.personalInfoValue += 1 / 10;
        });
      },

      // Language handler
      language: language,
      languageState: (value) {
        setState(() {
          language = value;
          print('language=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                language: value!.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );

          addNewEmployeeController.personalInfoValue += 1 / 10;
        });
      },
    );
  }

  /// Build health insurance page
  Widget _buildHealthInsurancePage() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        // TODO: Implement health insurance form with emergency contacts
        // using NewEmployeeModelHistory emergency contact fields
        child: Center(
          child: Text('Health Insurance Section - To Be Implemented'),
        ),
      ),
    );
  }

  /// Build position details page
  Widget _buildPositionDetailsPage(
      EmployeeController addEmployeeController,
      double widthOfData,
      ) {
    return PositionDetailsView(
      widthOfData: widthOfData,

      // Department handler
      department: department,
      departmentState: (value) {
        setState(() {
          print('department=$value');
          final addDepartmentController = Get.find<MainCoreDepartmentController>();
          String? deptId = addDepartmentController.getDepartmentIdFromDepartmentName(
              departmentName: value!
          );

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                departmentId: deptId,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );

          department = value;
          addNewEmployeeController.psitionDetailsValue += 1 / 13;
        });
      },

      // Role handler
      role: role,
      roleState: (value) {
        setState(() {
          print('role=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                role: value!.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );

          role = value;
          addNewEmployeeController.psitionDetailsValue += 1 / 13;
        });
      },

      // Job type handler
      type: type,
      typeState: (value) {
        setState(() {
          print('jobType=$value');
          // Note: jobType is not in NewEmployeeModelHistory
          // Store in local state only or add to model if needed
          type = value;
          addNewEmployeeController.psitionDetailsValue += 1 / 13;
        });
      },

      // Currency handler
      currency: currency,
      currencyState: (value) {
        setState(() {
          print('currency=$value');
          // Note: currency is not in NewEmployeeModelHistory
          // Store in local state only or add to model if needed
          currency = value;
          addNewEmployeeController.psitionDetailsValue += 1 / 13;
        });
      },

      // Job compensation handler
      jobCompensation: jobCompensation,
      jobCombensationState: (value) {
        setState(() {
          print('jobCompensation=$value');
          // Note: jobCompensation is not in NewEmployeeModelHistory
          // Store in local state only or add to model if needed
          jobCompensation = value;
          addNewEmployeeController.psitionDetailsValue += 1 / 13;
        });
      },

      // Job location handler
      jobLocation: jobLocation,
      jobLocationState: (value) {
        setState(() {
          print('jobLocation=$value');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                workLocation: value!.toLowerCase(),
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );

          jobLocation = value;
          addNewEmployeeController.psitionDetailsValue += 1 / 13;
        });
      },

      // Salary handlers
      salary: salary,
      salaryState: (value) {
        setState(() {
          salary2 = value.text;
          print('salary=${value.text}');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                // salary: value.text,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      salaryfinishState: (value) {
        setState(() {
          addNewEmployeeController.psitionDetailsValue += 1 / 13;
        });
      },

      // Title handlers
      title: title,
      titleState: (value) {
        setState(() {
          title2 = value.text;
          print('title=${value.text}');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                title: value.text,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },
      titleInArabic: titleInArabic,
      titleStateInArabic: (value) {
        setState(() {
          titleInArabic2 = value.text;
          print('titleInArabic=${value.text}');

          addEmployeeController.employeeModel.value =
              addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
                titleInArabic: value.text,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        });
      },

      // Work days handler
      days: days,
      daysState: (value) {
        setState(() {
          print('workDays=$value');
          // Note: workDays is not in NewEmployeeModelHistory
          // Store in local state only or add to model if needed
          days = value;
          addNewEmployeeController.psitionDetailsValue += 1 / 13;
        });
      },

      // Weekends handler
      weekends: weekends,
      weekEndsState: (value) {
        setState(() {});
      },

      // Work time handlers
      startTime: startTime,
      startTimeState: (value) {
        setState(() {
          startTime2 = value;
          print('startTime=$value');
          // Note: startTime is not in NewEmployeeModelHistory
          // Store in local state only or add to model if needed
        });
      },
      endTime: endTime,
      endTimeState: (value) {
        setState(() {
          endTime2 = value;
          print('endTime=$value');
          // Note: endTime is not in NewEmployeeModelHistory
          // Store in local state only or add to model if needed
        });
      },
    );
  }

  /// Build additional information page
  Widget _buildAdditionalInfoPage() {
    return AdditionInformations(
      name: "${addNewEmployeeController.firstName.text}_${addNewEmployeeController.lastName.text}",
      addInfoState: (value) {
        setState(() {
          addNewEmployeeController.additionalInfo = value;
        });
      },
      additionalInfo: addNewEmployeeController.additionalInfo,
    );
  }

  /// Build navigation buttons
  Widget _buildNavigationButtons(EmployeeController addEmployeeController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Back button
        Mode.addNewEmployeeIndex == 0
            ? Container()
            : MainCustomIconButton(
          onPressed: () {
            hapticController.triggerHapticFeedback(
              vibration: VibrateType.heavyImpact,
              hapticFeedback: HapticFeedback.heavyImpact,
            );
            setState(() {
              Mode.addNewEmployeeIndex--;
              pageController.animateToPage(
                Mode.addNewEmployeeIndex,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
              );
            });
          },
          buttonText: "back".tr,
          buttonStyle: buttonStyle(
            Theme.of(context).colorScheme.onSecondary,
          ),
        ),

        // Next/Save button
        MainCustomIconButton(
          onPressed: _getNextButtonAction(addEmployeeController),
          buttonText: Mode.addNewEmployeeIndex == 3 ? "Save".tr : "Next".tr,
          buttonStyle: _getNextButtonStyle(),
        ),
      ],
    );
  }

  /// Get next button action based on current page
  VoidCallback _getNextButtonAction(EmployeeController addEmployeeController) {
    // Check if button should be disabled
    if (_isNextButtonDisabled()) {
      return () {};
    }

    // Save action on last page
    if (Mode.addNewEmployeeIndex == 3) {
      return () => _saveEmployee(addEmployeeController);
    }

    // Next page action
    return () {
      hapticController.triggerHapticFeedback(
        vibration: VibrateType.heavyImpact,
        hapticFeedback: HapticFeedback.heavyImpact,
      );
      setState(() {
        if (Mode.addNewEmployeeIndex == 2) {
          addNewEmployeeController.assetsUp = 1;
        }
        if (Mode.addNewEmployeeIndex == 3) {
          permissions = 1;
        }
        Mode.addNewEmployeeIndex++;
        pageController.animateToPage(
          Mode.addNewEmployeeIndex,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );
      });
    };
  }

  /// Check if next button should be disabled
  bool _isNextButtonDisabled() {
    if (Mode.addNewEmployeeIndex == 0 &&
        addNewEmployeeController.personalInfoValue < 1) {
      return true;
    }
    if (Mode.addNewEmployeeIndex == 1 &&
        addNewEmployeeController.healthInsuranceValue < 1) {
      return true;
    }
    if (Mode.addNewEmployeeIndex == 2 &&
        addNewEmployeeController.psitionDetailsValue < 1) {
      return true;
    }
    if (Mode.addNewEmployeeIndex == 3 &&
        addNewEmployeeController.assetsUp < 1) {
      return true;
    }
    if (Mode.addNewEmployeeIndex == 4 &&
        addNewEmployeeController.additionalInfo < 1) {
      return true;
    }
    if (Mode.addNewEmployeeIndex == 5 && permissions < 1) {
      return true;
    }
    return false;
  }

  /// Get next button style based on state
  ButtonStyle _getNextButtonStyle() {
    if (_isNextButtonDisabled()) {
      return buttonStyle(AppColors.greyDark);
    }
    return buttonStyle(AppColors.signOut);
  }

  /// Save employee to database
  Future<void> _saveEmployee(EmployeeController addEmployeeController) async {
    hapticController.triggerHapticFeedback(
      vibration: VibrateType.heavyImpact,
      hapticFeedback: HapticFeedback.heavyImpact,
    );

    // Validate required fields
    if (!_validateRequiredFields()) {
      return;
    }

    showLoadingIndicator();

    try {
      // Set status to inactive (pending activation)
      addEmployeeController.employeeModel.value =
          addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
            status: 'inactive',
            activationDate: null,
            deactivationDate: null,
            password: null,
            defaultPassword: '123456',
            addTimestamp: DateTime.now().millisecondsSinceEpoch,
          );

      // Add document URLs if available
      if (imageUrl != null) {
        addEmployeeController.employeeModel.value =
            addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
              // employeePhoto: imageUrl!,
              addTimestamp: DateTime.now().millisecondsSinceEpoch,
            );
      }
      if (drivingLicense != null) {
        addEmployeeController.employeeModel.value =
            addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
              // drivingLicense: drivingLicense!,
              addTimestamp: DateTime.now().millisecondsSinceEpoch,
            );
      }
      if (educationCertificate != null) {
        addEmployeeController.employeeModel.value =
            addEmployeeController.employeeModel.value.copyWithUpdateSynchronized(
              // educationCertificate: educationCertificate!,
              addTimestamp: DateTime.now().millisecondsSinceEpoch,
            );
      }

      // Get employee email
      final employeeEmail = addEmployeeController.employeeModel.value.email.last;

      // Create user access record
      // TODO: Create UsersAccessModel instance with proper access configuration
      // await usersAccessController.addUserAccess(usersAccessModel, employeeEmail);

      // Save employee to database
      await addEmployeeController.createEmployee(
        addEmployeeController.employeeModel.value,
        employeeEmail,
        // true,
      );

      hideLoadingIndicator();

      // Show success dialog
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Employee successfully added"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close add employee screen
                  Navigator.pop(context); // Go back to list
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      hideLoadingIndicator();
      print('Error saving employee: $e');
      _showErrorDialog(e.toString());
    }
  }
}
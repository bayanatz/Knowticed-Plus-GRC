import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/widgets/storage_location_form_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/add_new_supplier_second_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/widgets/add_new_supplier_third/draft.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/features/inventory/helpers/constants/constant_lists.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

class AddNewSupplier extends StatefulWidget {
  const AddNewSupplier({super.key});

  @override
  State<AddNewSupplier> createState() => _AddNewSupplierState();
}

class _AddNewSupplierState extends State<AddNewSupplier> {
  // Image picker and supplier image file
  final ImagePicker _picker = ImagePicker();
  File? supplierImageFile;

  // Image picker method
  Future<void> _pickSupplierImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        supplierImageFile = File(picked.path);
      });
    }
  }

  // Supplier image upload widget

  /// Supplier photo — Figma 4307:27702 (65 circle + 24 camera badge).
  Widget supplierImageUploadWidget() {
    return CirclePhotoPicker(
      onTap: _pickSupplierImage,
      image: supplierImageFile != null
          ? Image.file(supplierImageFile!, fit: BoxFit.cover)
          : null,
    );
  }

  ///////////////////////// Controller ////////////////////////////////
  TextEditingController supplierIdController = TextEditingController();
  TextEditingController supplierNameController = TextEditingController();
  TextEditingController businessTypeController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();
  TextEditingController businessRegistrationController =
      TextEditingController();
  TextEditingController supplierRankController = TextEditingController();
  TextEditingController createdByController = TextEditingController();
  TextEditingController dateAddedController = TextEditingController();
  TextEditingController faxNumberController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController preferredLanguageController = TextEditingController();

  ///////////////////////// Variable ////////////////////////////////
  List<ContactFormData> contacts = [ContactFormData()];
  bool showSupplierDetails = true;
  bool showContactDetails = true;
  bool showBankDetails = true;
  bool showAddressDetails = true;
  String? selectedBusinessType;
  bool isGeneratingId = false;

  // Firestore reference - ONLY FIRESTORE
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, String?> validationErrors = {};
  bool isFormValid = false;

  ///////////////////////////////////// validation /////////////////////////////////

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? _getFieldError(String fieldKey) {
    return validationErrors[fieldKey];
  }

  String _contactKey(int index, String field) {
    return index == 0 ? field : 'contact${index + 1}_$field';
  }

  // 2. Update _validateRequiredFields method to trigger setState for UI updates
  bool _validateRequiredFields() {
    validationErrors.clear();

    // Supplier details
    if (supplierIdController.text.trim().isEmpty) {
      validationErrors['supplierId'] = S.of(context).supplierIdRequired;
    }
    if (supplierNameController.text.trim().isEmpty) {
      validationErrors['supplierName'] = S.of(context).supplierNameRequired;
    }
    if (selectedBusinessType == null || selectedBusinessType!.isEmpty) {
      validationErrors['businessType'] = S.of(context).businessTypeRequired;
    }
    if (taxNumberController.text.trim().isEmpty) {
      validationErrors['taxNumber'] = S.of(context).taxNumberRequired;
    }
    if (businessRegistrationController.text.trim().isEmpty) {
      validationErrors['businessRegistration'] =
          S.of(context).businessRegistrationRequired;
    }

    // Contacts
    for (int i = 0; i < contacts.length; i++) {
      final c = contacts[i];

      if (c.firstNameController.text.trim().isEmpty) {
        validationErrors[_contactKey(i, 'firstName')] = i == 0
            ? S.of(context).firstNameRequired
            : S.of(context).contactNumberFirstName('${i + 1}');
      }

      if (c.lastNameController.text.trim().isEmpty) {
        validationErrors[_contactKey(i, 'lastName')] = i == 0
            ? S.of(context).lastNameRequired
            : S.of(context).contactNumberLastName('${i + 1}');
      }

      if (c.phoneNumberController.text.trim().isEmpty) {
        validationErrors[_contactKey(i, 'phoneNumber')] = i == 0
            ? S.of(context).phoneNumberRequired
            : S.of(context).contactNumberPhoneNumber('${i + 1}');
      }

      if (c.middleNameController.text.trim().isEmpty) {
        validationErrors[_contactKey(i, 'middleName')] = i == 0
            ? S.of(context).middleNameRequired
            : S.of(context).contactNumberMiddleName('${i + 1}');
      }

      if (c.titleController.text.trim().isEmpty) {
        validationErrors[_contactKey(i, 'title')] = i == 0
            ? S.of(context).titleRequired
            : S.of(context).contactNumberTitle('${i + 1}');
      }

      if (c.faxNumberController.text.trim().isEmpty) {
        validationErrors[_contactKey(i, 'faxNumber')] = i == 0
            ? S.of(context).faxNumberRequired
            : S.of(context).contactNumberFaxNumber('${i + 1}');
      }

      if (c.preferredLanguageController.text.trim().isEmpty) {
        validationErrors[_contactKey(i, 'preferredLanguage')] = i == 0
            ? S.of(context).preferredLanguageRequired
            : S.of(context).contactNumberPreferredLanguage('${i + 1}');
      }

      final email = c.emailController.text.trim();
      if (email.isEmpty) {
        validationErrors[_contactKey(i, 'email')] = i == 0
            ? S.of(context).emailRequired
            : S.of(context).contactNumberEmail('${i + 1}');
      } else if (!_isValidEmail(email)) {
        validationErrors[_contactKey(i, 'email')] = i == 0
            ? S.of(context).validEmailRequired
            : S.of(context).contactNumberValidEmail('${i + 1}');
      }
    }

    setState(() {});
    return validationErrors.isEmpty;
  }

  void _handleNextButton() {
    if (_validateRequiredFields()) {
      saveSupplierData();
      navigateTo(context, AddNewSupplierSecondToggle());
    }
    // No need for dialog anymore - errors will show under fields
  }

  var employeeEntity = Get.find<MainCoreEmployeeController>().employeeEntity!;

  ///////////////////////////////////// validation /////////////////////////////////

  @override
  void initState() {
    super.initState();
    debugPrint(employeeEntity.email);
    _generateUniqueSupplierID();
  }

  ///////////////////////// Supplier ID Generation Methods ////////////////////////////////

  /// Generates a unique supplier ID with format SP + 3 random digits
  Future<void> _generateUniqueSupplierID() async {
    setState(() {
      isGeneratingId = true;
    });

    try {
      String uniqueId = await _createUniqueSupplierID();
      supplierIdController.text = uniqueId;

      // Save the generated ID to Firestore
      await _saveSupplierIdToFirestore(uniqueId);
    } catch (e) {
      debugPrint('Error generating supplier ID: $e');
      // Show error to user
      _showErrorDialog('Failed to generate Supplier ID. Please try again.');
    } finally {
      setState(() {
        isGeneratingId = false;
      });
    }
  }

  /// Creates a unique supplier ID by checking existing IDs in Firestore
  Future<String> _createUniqueSupplierID() async {
    const int maxAttempts = 100; // Prevent infinite loop
    int attempts = 0;

    while (attempts < maxAttempts) {
      String candidateId = _generateSupplierIdFormat();

      // Check if this ID already exists in Firestore
      bool exists = await _checkIfSupplierIdExists(candidateId);

      if (!exists) {
        return candidateId;
      }

      attempts++;
    }

    throw Exception(
      'Unable to generate unique supplier ID after $maxAttempts attempts',
    );
  }

  /// Generates supplier ID with format SP + 3 random digits (SP001-SP999)
  String _generateSupplierIdFormat() {
    Random random = Random();
    int randomNumber = random.nextInt(999) + 1; // 1-999
    return 'SP${randomNumber.toString().padLeft(3, '0')}';
  }

  /// Checks if supplier ID already exists in Firestore
  Future<bool> _checkIfSupplierIdExists(String supplierId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('InventoryUser')
          .doc(InventoryPaths.userEmail)
          .collection('Supplier_Id')
          .doc(supplierId)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking supplier ID existence: $e');
      return false; // Assume it doesn't exist if we can't check
    }
  }

  /// Saves the supplier ID to Firestore to mark it as used
  Future<void> _saveSupplierIdToFirestore(String supplierId) async {
    try {
      await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('InventoryUser')
          .doc(InventoryPaths.userEmail)
          .collection('Supplier_Id')
          .doc(supplierId)
          .set({
        'created_at': FieldValue.serverTimestamp(),
        'status': 'active',
        'created_by': InventoryPaths.userEmail,
        'supplier_id': supplierId,
      });
    } catch (e) {
      debugPrint('Error saving supplier ID to Firestore: $e');
      rethrow;
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
      title: S.of(context).error,
      subtitle: message,
      closeAfter: const Duration(seconds: 5),
    );
  }

  ///////////////////////// Existing Methods ////////////////////////////////

  // Add new contact function
  void _addNewContact() {
    setState(() {
      contacts.add(ContactFormData());
    });
  }

  // Remove contact function
  void _removeContact(int index) {
    if (contacts.length > 1) {
      setState(() {
        contacts[index].dispose();
        contacts.removeAt(index);
      });
    }
  }

  // Updated saveSupplierData method with image
  void saveSupplierData() {
    debugPrint('=== SAVING PAGE 1 DATA ===');
    debugPrint('Supplier ID: "${supplierIdController.text}"');
    debugPrint('Supplier Name: "${supplierNameController.text}"');
    debugPrint('Business Type: "$selectedBusinessType"');
    debugPrint('Tax Number: "${taxNumberController.text}"');
    debugPrint(
        'Business Registration: "${businessRegistrationController.text}"');
    debugPrint('Supplier Rank: "${supplierRankController.text}"');
    debugPrint('Created By: "${createdByController.text}"');
    debugPrint('Date Added: "${dateAddedController.text}"');
    debugPrint(
      'Supplier Image: ${supplierImageFile != null ? "Selected" : "Not selected"}',
    );
    debugPrint('Contacts count: ${contacts.length}');
    if (contacts.isNotEmpty) {
      debugPrint(
          'First Contact Name: "${contacts[0].firstNameController.text}"');
    }

    SupplierDraftStore.instance.setFromPage1(
      supplierID: supplierIdController.text,
      supplierName: supplierNameController.text,
      businessType: selectedBusinessType ?? '',
      taxNumber: taxNumberController.text,
      businessRegistrationNumber: businessRegistrationController.text,
      supplierRank: supplierRankController.text,
      createdBy: createdByController.text,
      dateAdded: dateAddedController.text,
      contacts: contacts,
      supplierImageFile: supplierImageFile, // Fixed this line
    );

    debugPrint('Page 1 data saved to SupplierDraftStore');
    debugPrint('=== END PAGE 1 SAVE ===');
  }

  /// Empties step 1. The auto-generated Supplier ID is kept.
  void _clearForm() {
    for (final c in [
      supplierNameController,
      taxNumberController,
      businessRegistrationController,
    ]) {
      c.clear();
    }
    for (final contact in contacts) {
      for (final c in [
        contact.firstNameController,
        contact.middleNameController,
        contact.lastNameController,
        contact.titleController,
        contact.phoneNumberController,
        contact.faxNumberController,
        contact.emailController,
        contact.preferredLanguageController,
      ]) {
        c.clear();
      }
    }
    setState(() {
      supplierImageFile = null;
      selectedBusinessType = null;
      validationErrors.clear();
    });
  }

  /// Realistic test values (debug builds only — see FormToolsBar).
  void _fillSampleData() {
    final types = ConstantLists.businessTypeList();
    supplierNameController.text = 'Nile Tech Supplies';
    taxNumberController.text = '312-458-907';
    businessRegistrationController.text = 'CR-2024-118734';
    final c = contacts.first;
    c.firstNameController.text = 'Salem';
    c.middleNameController.text = 'Mohamed';
    c.lastNameController.text = 'Ahmed';
    c.titleController.text = 'Sales Manager';
    c.phoneNumberController.text = '01025369874';
    c.faxNumberController.text = '0224567890';
    c.emailController.text = 'salem.ahmed@niletech.com';
    c.preferredLanguageController.text = 'English';
    setState(() {
      selectedBusinessType = types.isEmpty ? null : (types.first['key'] ?? '');
      validationErrors.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = context.isPhone;
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventory,
          onFirstTap: () {
            navigateTo(context, InventoryManagement());
          },
          secondTitle: S.of(context).addingNewSupplier,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // Clear All / Fill sample data (sample only in debug builds).
                FormToolsBar(onClear: _clearForm, onFill: _fillSampleData),
                SizedBox(height: 10.sp),

                // Supplier Details Section
                Row(
                  children: [
                    Text(
                      S.of(context).supplierDetails,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 8.sp),

                // Supplier Details Container
                if (showSupplierDetails)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15.sp),
                      child: Column(
                        children: [
                          // Updated image section with upload functionality
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              supplierImageUploadWidget(), // Use the new upload widget
                            ],
                          ),
                          SizedBox(height: 15.sp), // image 65 → label (Figma)
                          buildResponsiveFields(
                            left: supplierIdField(),
                            right: supplierNameField(),
                            leftFieldKey: 'supplierId',
                            rightFieldKey: 'supplierName',
                            context: context,
                          ),
                          SizedBox(height: 15.sp),
                          buildResponsiveFields(
                            left: businessTypeField(),
                            right: taxNumberField(),
                            leftFieldKey: 'businessType',
                            rightFieldKey: 'taxNumber',
                            context: context,
                          ),
                          SizedBox(height: 15.sp),
                          isMobile
                              ? businessRegistrationField()
                              : buildResponsiveFields(
                                  left: businessRegistrationField(),
                                  leftFieldKey: 'businessRegistration',
                                  right: SizedBox(),
                                  context: context,
                                ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 20.sp),

                // Point Of Contact Details Header
                Row(
                  children: [
                    Text(
                      S.of(context).pointOfContactDetails,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    Spacer(),
                  ],
                ),

                SizedBox(height: 8.sp),

                // First Contact (Main Contact)
                if (showContactDetails)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15.sp),
                      child: Column(
                        children: [
                          buildResponsiveFields(
                            left: firstNameField(contacts[0]),
                            right: middleNameField(contacts[0]),
                            leftFieldKey: _contactKey(0, 'firstName'),
                            rightFieldKey: _contactKey(0, 'middleName'),
                            context: context,
                          ),
                          SizedBox(height: 15.sp),
                          buildResponsiveFields(
                            left: lastNameField(contacts[0]),
                            right: titleField(contacts[0]),
                            leftFieldKey: 'lastName',
                            rightFieldKey: null,
                            context: context,
                          ),
                          SizedBox(height: 15.sp),
                          buildResponsiveFields(
                            left: phoneNumberField(contacts[0]),
                            right: faxNumberField(contacts[0]),
                            leftFieldKey: 'phoneNumber',
                            rightFieldKey: null,
                            context: context,
                          ),
                          SizedBox(height: 15.sp),
                          buildResponsiveFields(
                            left: emailField(contacts[0]),
                            right: preferredLanguageField(contacts[0]),
                            leftFieldKey: 'email',
                            rightFieldKey: null,
                            context: context,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Additional Contacts in separate containers
                if (showContactDetails)
                  ...contacts.skip(1).toList().asMap().entries.map((entry) {
                    int actualIndex = entry.key + 1;
                    ContactFormData contact = entry.value;
                    return Column(
                      children: [
                        SizedBox(height: 20.sp),
                        // Header with title and remove button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${actualIndex + 1}${actualIndex == 0 ? 'st' : actualIndex == 1 ? 'nd' : actualIndex == 2 ? 'rd' : 'th'} ${S.of(context).contact} Details",
                              style: StyleText.fontSize16Weight600.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTapDown: (_) => HapticController.high(),
                              onTap: () => _removeContact(actualIndex),
                              child: Container(
                                width: 15.w,
                                height: 15.h,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.remove,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ],
                        ),
                        SizedBox(height: 8.sp),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15.sp),
                            child: Column(
                              children: [
                                buildResponsiveFields(
                                  left: firstNameField(contact),
                                  right: middleNameField(contact),
                                  leftFieldKey:
                                      'contact${actualIndex + 1}_firstName',
                                  rightFieldKey: null,
                                  context: context,
                                ),
                                SizedBox(height: 15.sp),
                                buildResponsiveFields(
                                  left: lastNameField(contact),
                                  right: titleField(contact),
                                  leftFieldKey:
                                      'contact${actualIndex + 1}_lastName',
                                  rightFieldKey: null,
                                  context: context,
                                ),
                                SizedBox(height: 15.sp),
                                buildResponsiveFields(
                                  left: phoneNumberField(contact),
                                  right: faxNumberField(contact),
                                  leftFieldKey:
                                      'contact${actualIndex + 1}_phoneNumber',
                                  rightFieldKey: null,
                                  context: context,
                                ),
                                SizedBox(height: 15.sp),
                                buildResponsiveFields(
                                  left: emailField(contact),
                                  right: preferredLanguageField(contact),
                                  leftFieldKey:
                                      'contact${actualIndex + 1}_email',
                                  rightFieldKey: null,
                                  context: context,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                // Add Contact Button
                if (showContactDetails) SizedBox(height: 8.sp),
                if (showContactDetails)
                  Row(
                    children: [
                      customButtonWithSvg(
                        width: 100.w,
                        height: 30.h,
                        title: S.of(context).contact,
                        function: _addNewContact,
                        svgColor: AppTheme.readableOn(AppColors.blackButton),
                        color: AppColors.blackButton,
                        radius: 4.r,
                        textStyle: StyleText.fontSize14Weight500.copyWith(
                          color: AppTheme.readableOn(AppColors.blackButton),
                        ),
                        image:
                            'assets/icons_assets/main_icons_assets/ic_action_plus.svg',
                        widthImage: 12.w,
                        heightImage: 12.h,
                        colorBorder: Colors.transparent,
                        space: 8.w,
                      ),
                    ],
                  ),

                SizedBox(height: 20.sp),

                // Discard & Next buttons
                Row(
                  textDirection: TextDirection
                      .ltr, // X-73: Cancel left, action right in both languages

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customButton(
                      title: S.of(context).discard,
                      function: () {
                        Navigator.pop(context);
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: AppColors.grey,
                    ),
                    customButton(
                      title: S.of(context).next,
                      function:
                          _handleNextButton, // Use the new validation function
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: _isFormValidForButtonColor()
                          ? AppColors.primary
                          : Colors.grey[500], // ✅ Use the new method
                    ),
                  ],
                ),

                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isFormValidForButtonColor() {
    // Check supplier details
    if (supplierIdController.text.trim().isEmpty) return false;
    if (supplierNameController.text.trim().isEmpty) return false;
    if (selectedBusinessType == null || selectedBusinessType!.isEmpty) {
      return false;
    }
    if (taxNumberController.text.trim().isEmpty) return false;
    if (businessRegistrationController.text.trim().isEmpty) return false;

    // Check ALL contacts
    for (int i = 0; i < contacts.length; i++) {
      ContactFormData contact = contacts[i];

      if (contact.firstNameController.text.trim().isEmpty) return false;
      if (contact.lastNameController.text.trim().isEmpty) return false;
      if (contact.phoneNumberController.text.trim().isEmpty) return false;
      if (contact.emailController.text.trim().isEmpty) return false;
      if (contact.middleNameController.text.trim().isEmpty) return false;
      if (contact.titleController.text.trim().isEmpty) return false;
      if (contact.faxNumberController.text.trim().isEmpty) return false;
      if (contact.preferredLanguageController.text.trim().isEmpty) return false;
      if (!_isValidEmail(contact.emailController.text.trim())) return false;
    }

    return true;
  }

  ///////////////////////// Field Widgets ////////////////////////////////

  /// Updated Supplier ID field with auto-generation and regenerate button
  Widget supplierIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            StorageTextField(
              label: S.of(context).supplierId,
              controller: supplierIdController,
              readOnly: true,
              textDirection: ui.TextDirection.ltr,
              onlyDigits: false,
              onChanged: (_) => setState(() {}),
            ),
            if ((_getFieldError('supplierId')) != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  (_getFieldError('supplierId'))!,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.red),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Updated field methods to accept ContactFormData parameter
  Widget firstNameField(ContactFormData contact) {
    final i = contacts.indexOf(contact);
    final key = _contactKey(i, 'firstName');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).firstName,
          controller: contact.firstNameController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              validationErrors.remove(key);
            });
          },
        ),
        if ((_getFieldError(key)) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError(key))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget middleNameField(ContactFormData contact) {
    final i = contacts.indexOf(contact);
    final key = _contactKey(i, 'middleName');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).middleName,
          controller: contact.middleNameController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              validationErrors.remove(key);
            });
          },
        ),
        if ((_getFieldError(key)) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError(key))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget lastNameField(ContactFormData contact) {
    final i = contacts.indexOf(contact);
    final key = _contactKey(i, 'lastName');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).lastName,
          controller: contact.lastNameController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              validationErrors.remove(key);
            });
          },
        ),
        if ((_getFieldError(key)) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError(key))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget titleField(ContactFormData contact) {
    final i = contacts.indexOf(contact);
    final key = _contactKey(i, 'title');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).title,
          controller: contact.titleController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              validationErrors.remove(key);
            });
          },
        ),
        if ((_getFieldError(key)) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError(key))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget phoneNumberField(ContactFormData contact) {
    final i = contacts.indexOf(contact);
    final key = _contactKey(i, 'phoneNumber');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).phoneNumber,
          controller: contact.phoneNumberController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              validationErrors.remove(key);
            });
          },
        ),
        if ((_getFieldError(key)) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError(key))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget faxNumberField(ContactFormData contact) {
    final i = contacts.indexOf(contact);
    final key = _contactKey(i, 'faxNumber');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).faxNumber,
          controller: contact.faxNumberController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              validationErrors.remove(key);
            });
          },
        ),
        if ((_getFieldError(key)) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError(key))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget emailField(ContactFormData contact) {
    final i = contacts.indexOf(contact);
    final key = _contactKey(i, 'email');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).email,
          controller: contact.emailController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              validationErrors.remove(key);
            });
          },
        ),
        if ((_getFieldError(key)) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError(key))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget preferredLanguageField(ContactFormData contact) {
    final i = contacts.indexOf(contact);
    final key = _contactKey(i, 'preferredLanguage');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).preferredLanguage,
          controller: contact.preferredLanguageController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              validationErrors.remove(key);
            });
          },
        ),
        if ((_getFieldError(key)) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError(key))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  // Don't forget to dispose all controllers
  @override
  void dispose() {
    supplierIdController.dispose();
    supplierNameController.dispose();
    businessTypeController.dispose();
    taxNumberController.dispose();
    businessRegistrationController.dispose();
    supplierRankController.dispose();
    createdByController.dispose();
    dateAddedController.dispose();

    // Dispose all contact controllers
    for (var contact in contacts) {
      contact.dispose();
    }

    super.dispose();
  }

  // Keep your existing supplier field methods unchanged
  Widget supplierNameField() {
    const key = 'supplierName';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).supplierName,
          controller: supplierNameController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) => setState(() {
            validationErrors.remove(key);
          }),
        ),
        if ((_getFieldError(key)) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError(key))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget taxNumberField() {
    const key = 'taxNumber';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).taxNumber,
          controller: taxNumberController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) => setState(() {
            validationErrors.remove(key);
          }),
        ),
        if ((_getFieldError(key)) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError(key))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget businessRegistrationField() {
    const key = 'businessRegistration';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).businessRegistrationNumber,
          controller: businessRegistrationController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) => setState(() {
            validationErrors.remove(key);
          }),
        ),
        if ((_getFieldError(key)) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError(key))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget businessTypeField() {
    return StorageDropdown<String>(
      label: S.of(context).businessType,
      hint: S.of(context).businessType,
      items: (ConstantLists.businessTypeList())
          .map((e) => DropdownItem<String>(
              value: e['key'] ?? '', label: e['value'] ?? ''))
          .toList(),
      value: selectedBusinessType,
      onChanged: (value) {
        setState(() {
          selectedBusinessType = value;
          if (validationErrors.containsKey('businessType')) {
            validationErrors.remove('businessType');
          }
        });
      },
    );
  }

  Widget buildResponsiveFields({
    required BuildContext context,
    required Widget left,
    required Widget right,
    String? leftFieldKey,
    String? rightFieldKey,
  }) {
    final isMobile = kpIsPhoneLayout(context);

    // Check if any field in this row has an error
    bool hasRowError = false;
    if (leftFieldKey != null && validationErrors.containsKey(leftFieldKey)) {
      hasRowError = true;
    }
    if (rightFieldKey != null && validationErrors.containsKey(rightFieldKey)) {
      hasRowError = true;
    }

    // Wrap each field with consistent height container when there's a row error
    Widget wrappedLeft = hasRowError
        ? SizedBox(
            height: 76.h, // TextField height + error text height + spacing
            child: left,
          )
        : left;

    Widget wrappedRight = hasRowError && right is! SizedBox
        ? SizedBox(
            height: 76.h, // TextField height + error text height + spacing
            child: right,
          )
        : right;

    if (isMobile) {
      return Column(
        children: [wrappedLeft, SizedBox(height: 10.sp), wrappedRight],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: wrappedLeft),
          SizedBox(width: 15.sp),
          Expanded(child: wrappedRight),
        ],
      );
    }
  }
}

// Helper class to manage contact form data
class ContactFormData {
  final TextEditingController faxNumberController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController emailController;
  final TextEditingController middleNameController;
  final TextEditingController titleController;
  final TextEditingController preferredLanguageController;

  ContactFormData()
      : faxNumberController = TextEditingController(),
        firstNameController = TextEditingController(),
        lastNameController = TextEditingController(),
        phoneNumberController = TextEditingController(),
        emailController = TextEditingController(),
        middleNameController = TextEditingController(),
        titleController = TextEditingController(),
        preferredLanguageController = TextEditingController();

  void dispose() {
    faxNumberController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    middleNameController.dispose();
    titleController.dispose();
    preferredLanguageController.dispose();
  }

  ///////////////////// Auto Genrate ///////////////////////

  ///////////////////// Auto Genrate ///////////////////////
}

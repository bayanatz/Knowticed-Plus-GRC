import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/widgets/storage_location_form_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/add_new_supplier_third_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/widgets/add_new_supplier_third/draft.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class AddNewSupplierSecond extends StatefulWidget {
  const AddNewSupplierSecond({super.key});

  @override
  State<AddNewSupplierSecond> createState() => _AddNewSupplierSecondState();
}

class _AddNewSupplierSecondState extends State<AddNewSupplierSecond> {
  ///////////////////////// Controller ////////////////////////////////

  TextEditingController iBANController = TextEditingController();
  TextEditingController bankAddressController = TextEditingController();
  TextEditingController beneficiaryBankNameController = TextEditingController();
  TextEditingController beneficiaryNameController = TextEditingController();
  TextEditingController bankSWIFTController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController streetNameController = TextEditingController();
  TextEditingController stateOrProvinceController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController warehouseAddressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  ///////////////////////// Controller ////////////////////////////////

  ///////////////////////// Variable ////////////////////////////////
  List<AddressFormData> addresses = [
    AddressFormData(),
  ]; // Start with one address
  bool showSupplierDetails = true;
  bool showContactDetails = true;
  bool showBankDetails = true;
  bool showAddressDetails = true;
  String? selectedBusinessType;

  Map<String, String?> validationErrors = {};
  bool isFormValid = false;

  ///////////////////////// Variable ////////////////////////////////

  bool _validateRequiredFields() {
    validationErrors.clear();

    // ----- Bank details -----
    if (beneficiaryNameController.text.trim().isEmpty) {
      validationErrors['beneficiaryName'] =
          S.of(context).beneficiaryNameRequired;
    }
    if (beneficiaryBankNameController.text.trim().isEmpty) {
      validationErrors['beneficiaryBankName'] =
          S.of(context).beneficiaryBankNameRequired;
    }
    if (iBANController.text.trim().isEmpty) {
      validationErrors['iban'] = S.of(context).ibanRequired;
    }
    if (bankAddressController.text.trim().isEmpty) {
      validationErrors['bankAddress'] = S.of(context).bankAddressRequired;
    }
    // ✅ NEW: swift code
    if (bankSWIFTController.text.trim().isEmpty) {
      validationErrors['swiftCode'] = S.of(context).swiftCodeRequired;
    }

    // ----- Addresses -----
    for (int i = 0; i < addresses.length; i++) {
      final address = addresses[i];
      final prefix = i == 0 ? '' : 'address${i + 1}_';

      if (address.countryController.text.trim().isEmpty) {
        validationErrors['${prefix}country'] = i == 0
            ? S.of(context).countryRequired
            : S.of(context).addressNumberCountry;
      }
      if (address.cityController.text.trim().isEmpty) {
        validationErrors['${prefix}city'] = i == 0
            ? S.of(context).cityRequired
            : S.of(context).addressNumberCity;
      }
      // ✅ NEW: state / province
      if (address.stateOrProvinceController.text.trim().isEmpty) {
        validationErrors['${prefix}stateOrProvince'] = i == 0
            ? S.of(context).stateRequired
            : S.of(context).addressNumberState('${i + 1}');
      }
      if (address.streetNameController.text.trim().isEmpty) {
        validationErrors['${prefix}streetName'] = i == 0
            ? S.of(context).streetNameRequired
            : S.of(context).addressNumberStreetName;
      }
      if (address.postalCodeController.text.trim().isEmpty) {
        validationErrors['${prefix}postalCode'] = i == 0
            ? S.of(context).postalCodeRequired
            : S.of(context).addressNumberPostalCode;
      }
    }

    setState(() {});
    return validationErrors.isEmpty;
  }

  bool _isFormValidForButtonColor() {
    if (beneficiaryNameController.text.trim().isEmpty) return false;
    if (beneficiaryBankNameController.text.trim().isEmpty) return false;
    if (iBANController.text.trim().isEmpty) return false;
    if (bankAddressController.text.trim().isEmpty) return false;
    if (bankSWIFTController.text.trim().isEmpty) return false; // ✅ swift

    for (final a in addresses) {
      if (a.countryController.text.trim().isEmpty) return false;
      if (a.cityController.text.trim().isEmpty) return false;
      if (a.stateOrProvinceController.text.trim().isEmpty) {
        return false; // ✅ state
      }
      if (a.streetNameController.text.trim().isEmpty) return false;
      if (a.postalCodeController.text.trim().isEmpty) return false;
    }
    return true;
  }

  // 3. Update your Next button function
  void _handleNextButton() {
    if (_validateRequiredFields()) {
      saveBankAndAddressData();
      navigateTo(context, AddNewSupplierThirdToggle());
    }
    // No need for dialog anymore - errors will show under fields
  }

  ///////////////////////// Address Management Functions ////////////////////////////////

  // Add new address function
  void _addNewAddress() {
    setState(() {
      addresses.add(AddressFormData());
    });
  }

  // Remove address function
  void _removeAddress(int index) {
    if (addresses.length > 1) {
      // Keep at least one address
      setState(() {
        addresses[index].dispose(); // Dispose controllers
        addresses.removeAt(index);
      });
    }
  }

  ///////////////////////// Address Management Functions ////////////////////////////////

  // Replace your saveBankAndAddressData method in Page 2 with this debug version:

  void saveBankAndAddressData() {
    debugPrint('=== SAVING PAGE 2 DATA ===');
    debugPrint('Beneficiary Name: "${beneficiaryNameController.text}"');
    debugPrint('Bank Name: "${beneficiaryBankNameController.text}"');
    debugPrint('SWIFT Code: "${bankSWIFTController.text}"');
    debugPrint('IBAN: "${iBANController.text}"');
    debugPrint('Bank Address: "${bankAddressController.text}"');
    debugPrint('Addresses count: ${addresses.length}');
    if (addresses.isNotEmpty) {
      debugPrint(
          'First Address Country: "${addresses[0].countryController.text}"');
      debugPrint('First Address City: "${addresses[0].cityController.text}"');
    }

    SupplierDraftStore.instance.setFromPage2(
      beneficiaryName: beneficiaryNameController.text,
      beneficiaryBankName: beneficiaryBankNameController.text,
      bankSWIFTBICCode: bankSWIFTController.text,
      beneficiaryBankAccountNumberIBAN: iBANController.text,
      bankAddress: bankAddressController.text,
      addresses: addresses,
    );

    debugPrint('Page 2 data saved to SupplierDraftStore');
    debugPrint('=== END PAGE 2 SAVE ===');
  }

  String? _getFieldError(String fieldKey) {
    return validationErrors[fieldKey];
  }

  /// Empties step 2 (bank + every address).
  void _clearForm() {
    for (final c in [
      beneficiaryNameController,
      beneficiaryBankNameController,
      iBANController,
      bankSWIFTController,
      bankAddressController,
    ]) {
      c.clear();
    }
    for (final a in addresses) {
      for (final c in [
        a.countryController,
        a.stateOrProvinceController,
        a.cityController,
        a.postalCodeController,
        a.streetNameController,
        a.warehouseAddressController,
      ]) {
        c.clear();
      }
    }
    setState(() => validationErrors.clear());
  }

  /// Realistic test values (debug builds only — see FormToolsBar).
  void _fillSampleData() {
    beneficiaryNameController.text = 'Nile Tech Supplies LLC';
    beneficiaryBankNameController.text = 'National Bank of Egypt';
    iBANController.text = 'EG380019000500000000263180002';
    bankSWIFTController.text = 'NBEGEGCX';
    bankAddressController.text = '1187 Corniche El Nil, Boulak, Cairo, Egypt';
    final a = addresses.first;
    a.countryController.text = 'Egypt';
    a.stateOrProvinceController.text = 'Cairo';
    a.cityController.text = 'Nasr City';
    a.postalCodeController.text = '11371';
    a.streetNameController.text = '12 Abbas El Akkad St.';
    a.warehouseAddressController.text = 'Same As Business Address';
    setState(() => validationErrors.clear());
  }

  @override
  Widget build(BuildContext context) {
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

                // Bank Transfer Details & Hide
                Row(
                  children: [
                    Text(
                      S.of(context).bankTransferDetails,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    Spacer(),
                    // GestureDetector(
                    //   onTap: () {
                    //     setState(() {
                    //       showBankDetails = !showBankDetails;
                    //     });
                    //   },
                    //   child: Text(
                    //     showBankDetails ? S.of(context).hide : S.of(context).expand,
                    //     style: StyleText.fontSize14Weight500.copyWith(
                    //       color: Color(0xff1877F2),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: 8.sp),

                // Bank Transfer Details (unchanged)
                if (showBankDetails)
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
                            left: beneficiaryNameField(),
                            right: beneficiaryBankNameField(),
                            context: context,
                          ),
                          SizedBox(height: 15.sp),
                          buildResponsiveFields(
                            left: ibanField(),
                            right: swiftBankCodeField(),
                            context: context,
                          ),
                          SizedBox(height: 15.sp),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    StorageTextField(
                                      label: S.of(context).bankAddress,
                                      controller: bankAddressController,
                                      multiline: true,
                                      textDirection: ui.TextDirection.ltr,
                                      onlyDigits: false,
                                      onChanged: (v) {
                                        setState(() {
                                          if (v.trim().isNotEmpty) {
                                            validationErrors.remove(
                                              'bankAddress',
                                            );
                                          }
                                        });
                                      },
                                    ),
                                    if ((_getFieldError('bankAddress')) != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          (_getFieldError('bankAddress'))!,
                                          style: StyleText.fontSize12Weight400
                                              .copyWith(color: AppColors.red),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(height: 20.sp),

                // Address Details Header
                Row(
                  children: [
                    Text(
                      S.of(context).addressDetails,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    Spacer(),
                    // GestureDetector(
                    //   onTap: () {
                    //     setState(() {
                    //       showAddressDetails = !showAddressDetails;
                    //     });
                    //   },
                    //   child: Text(
                    //     showAddressDetails ? S.of(context).hide : S.of(context).expand,
                    //     style: StyleText.fontSize14Weight500.copyWith(
                    //       color: Color(0xff1877F2),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),

                SizedBox(height: 8.sp),

                // First Address (Main Address)
                if (showAddressDetails)
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
                            left: countryField(addresses[0]),
                            right: stateOrProvinceField(addresses[0]),
                            leftFieldKey:
                                'country', // or '${prefix}country' when looping
                            rightFieldKey: 'stateOrProvince',
                            context: context,
                          ),
                          SizedBox(height: 15.sp),
                          buildResponsiveFields(
                            left: cityField(addresses[0]),
                            right: postalCodeField(addresses[0]),
                            context: context,
                          ),
                          SizedBox(height: 15.sp),
                          streetNameField(addresses[0]),
                        ],
                      ),
                    ),
                  ),

                // Additional Addresses in separate containers
                if (showAddressDetails)
                  ...addresses.skip(1).toList().asMap().entries.map((entry) {
                    int actualIndex = entry.key + 1;
                    AddressFormData address = entry.value;
                    return Column(
                      children: [
                        SizedBox(height: 20.sp),
                        // Header with title and remove button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${actualIndex + 1}${actualIndex == 0 ? 'st' : actualIndex == 1 ? 'nd' : actualIndex == 2 ? 'rd' : 'th'} ${S.of(context).address} Details",
                              style: StyleText.fontSize16Weight600.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                            Spacer(),
                            GestureDetector(
                              onTapDown: (_) => HapticController.high(),
                              onTap: () => _removeAddress(actualIndex),
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
                                  left: countryField(address),
                                  right: stateOrProvinceField(address),
                                  context: context,
                                ),
                                SizedBox(height: 15.sp),
                                buildResponsiveFields(
                                  left: cityField(address),
                                  right: postalCodeField(address),
                                  context: context,
                                ),
                                SizedBox(height: 15.sp),
                                buildResponsiveFields(
                                  left: streetNameField(address),
                                  right: SizedBox(),
                                  context: context,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                // Add Address Button
                if (showAddressDetails) SizedBox(height: 8.sp),
                if (showAddressDetails)
                  Row(
                    children: [
                      customButtonWithSvg(
                        width: 100.w,
                        height: 30.h,
                        title: S.of(context).address,
                        function: _addNewAddress, // Updated function
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

                // ✅ Discard & ✅ Next (unchanged)
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
                      textStyle: StyleText.fontSize16Weight400.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: _isFormValidForButtonColor()
                          ? AppColors.primary
                          : Colors.grey[500],
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
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top
        children: [
          Expanded(child: wrappedLeft),
          SizedBox(width: 15.sp),
          Expanded(child: wrappedRight),
        ],
      );
    }
  }

  // Bank Transfer Fields (unchanged)
  Widget beneficiaryNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).beneficiaryName,
          controller: beneficiaryNameController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              if (validationErrors.containsKey('beneficiaryName')) {
                validationErrors.remove('beneficiaryName');
              }
            });
          },
        ),
        if ((_getFieldError('beneficiaryName')) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError('beneficiaryName'))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget beneficiaryBankNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).beneficiaryBankName,
          controller: beneficiaryBankNameController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              if (validationErrors.containsKey('beneficiaryBankName')) {
                validationErrors.remove('beneficiaryBankName');
              }
            });
          },
        ),
        if ((_getFieldError('beneficiaryBankName')) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError('beneficiaryBankName'))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget beneficiaryBankAccountNumberField() {
    return StorageTextField(
      label: S.of(context).beneficiaryBankName,
      controller: beneficiaryBankNameController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget swiftBankCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).swiftCode,
          controller: bankSWIFTController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) => setState(() {
            validationErrors.remove('swiftCode');
          }),
        ),
        if ((_getFieldError('swiftCode')) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError('swiftCode'))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget ibanField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).iban,
          controller: iBANController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              if (validationErrors.containsKey('iban')) {
                validationErrors.remove('iban');
              }
            });
          },
        ),
        if ((_getFieldError('iban')) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError('iban'))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  // Updated Address Fields to accept AddressFormData parameter
  Widget countryField(AddressFormData address) {
    int addressIndex = addresses.indexOf(address);
    String addressPrefix =
        addressIndex == 0 ? '' : 'address${addressIndex + 1}_';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).country,
          controller: address.countryController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              if (validationErrors.containsKey('${addressPrefix}country')) {
                validationErrors.remove('${addressPrefix}country');
              }
            });
          },
        ),
        if ((_getFieldError('${addressPrefix}country')) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError('${addressPrefix}country'))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget stateOrProvinceField(AddressFormData address) {
    final i = addresses.indexOf(address);
    final prefix = i == 0 ? '' : 'address${i + 1}_';
    final key = '${prefix}stateOrProvince';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).state,
          controller: address.stateOrProvinceController,
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

  Widget cityField(AddressFormData address) {
    int addressIndex = addresses.indexOf(address);
    String addressPrefix =
        addressIndex == 0 ? '' : 'address${addressIndex + 1}_';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).city,
          controller: address.cityController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              if (validationErrors.containsKey('${addressPrefix}city')) {
                validationErrors.remove('${addressPrefix}city');
              }
            });
          },
        ),
        if ((_getFieldError('${addressPrefix}city')) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError('${addressPrefix}city'))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget postalCodeField(AddressFormData address) {
    int addressIndex = addresses.indexOf(address);
    String addressPrefix =
        addressIndex == 0 ? '' : 'address${addressIndex + 1}_';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).postalCode,
          controller: address.postalCodeController,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              if (validationErrors.containsKey('${addressPrefix}postalCode')) {
                validationErrors.remove('${addressPrefix}postalCode');
              }
            });
          },
        ),
        if ((_getFieldError('${addressPrefix}postalCode')) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError('${addressPrefix}postalCode'))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget streetNameField(AddressFormData address) {
    int addressIndex = addresses.indexOf(address);
    String addressPrefix =
        addressIndex == 0 ? '' : 'address${addressIndex + 1}_';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        StorageTextField(
          label: S.of(context).description,
          controller: address.streetNameController,
          multiline: true,
          textDirection: ui.TextDirection.ltr,
          onlyDigits: false,
          onChanged: (_) {
            setState(() {
              if (validationErrors.containsKey('${addressPrefix}streetName')) {
                validationErrors.remove('${addressPrefix}streetName');
              }
            });
          },
        ),
        if ((_getFieldError('${addressPrefix}streetName')) != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              (_getFieldError('${addressPrefix}streetName'))!,
              style:
                  StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget warehouseAddressField(AddressFormData address) {
    return StorageTextField(
      label: S.of(context).warehouseName,
      controller: address.warehouseAddressController,
      textDirection: ui.TextDirection.ltr,
      onlyDigits: false,
      onChanged: (_) => setState(() {}),
    );
  }

  // Don't forget to dispose all controllers
  @override
  void dispose() {
    iBANController.dispose();
    bankAddressController.dispose();
    beneficiaryBankNameController.dispose();
    beneficiaryNameController.dispose();
    bankSWIFTController.dispose();
    _searchController.dispose();

    // Dispose all address controllers
    for (var address in addresses) {
      address.dispose();
    }

    super.dispose();
  }
}

// Helper class to manage address form data
class AddressFormData {
  final TextEditingController countryController;
  final TextEditingController cityController;
  final TextEditingController streetNameController;
  final TextEditingController stateOrProvinceController;
  final TextEditingController postalCodeController;
  final TextEditingController warehouseAddressController;

  AddressFormData()
      : countryController = TextEditingController(),
        cityController = TextEditingController(),
        streetNameController = TextEditingController(),
        stateOrProvinceController = TextEditingController(),
        postalCodeController = TextEditingController(),
        warehouseAddressController = TextEditingController();

  void dispose() {
    countryController.dispose();
    cityController.dispose();
    streetNameController.dispose();
    stateOrProvinceController.dispose();
    postalCodeController.dispose();
    warehouseAddressController.dispose();
  }
}

import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv8_assets_and_consumables/presentation/ui/pages/p30_select_employee_toogel.dart';
import 'package:knowticed_plus/features/inventory/inv8_assets_and_consumables/presentation/ui/pages/p32_select_services_history_toogel.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class AssetsDetailsNameDesktopScreen extends StatefulWidget {
  final ProductModel? productModel;
  const AssetsDetailsNameDesktopScreen({super.key, this.productModel});

  @override
  State<AssetsDetailsNameDesktopScreen> createState() =>
      _AssetsDetailsNameDesktopScreenState();
}

class _AssetsDetailsNameDesktopScreenState
    extends State<AssetsDetailsNameDesktopScreen> {
  /////////////////////////////// Approval Cycle //////////////////////////////////////////

  late ApprovalSection section;

  @override
  void initState() {
    super.initState();

    section = ApprovalSection(
      selectedApprovers: [
        EmployeeEntity(
          id: '1',
          firstName: "Ahmed",
          lastName: "Abd el Rahman",
          firstNameInArabic: "أحمد",
          lastNameInArabic: "عبد الرحمن",
          title: "HR",
          titleInArabic: "الموارد البشرية",
          gender: "male",
        ),
        EmployeeEntity(
          id: '2',
          firstName: "Sara",
          lastName: "Ali",
          firstNameInArabic: "سارة",
          lastNameInArabic: "علي",
          title: "Finance",
          titleInArabic: "المالية",
          gender: "female",
        ),
        EmployeeEntity(
          id: '3',
          firstName: "Mohamed",
          lastName: "Youssef",
          firstNameInArabic: "محمد",
          lastNameInArabic: "يوسف",
          title: "IT",
          titleInArabic: "تكنولوجيا المعلومات",
          gender: "male",
        ),
        EmployeeEntity(
          id: '4',
          firstName: "Laila",
          lastName: "Ibrahim",
          firstNameInArabic: "ليلى",
          lastNameInArabic: "إبراهيم",
          title: "Legal",
          titleInArabic: "القانونية",
          gender: "female",
        ),
        EmployeeEntity(
          id: '5',
          firstName: "Omar",
          lastName: "Salem",
          firstNameInArabic: "عمر",
          lastNameInArabic: "سالم",
          title: "Operations",
          titleInArabic: "العمليات",
          gender: "male",
        ),
      ],
    );
  }
  /////////////////////////////// Approval Cycle //////////////////////////////////////////

  //////////////////////////////////////// Filter person ////////////////////////////////////

  final List<Map<String, dynamic>> maintenanceDummyData = [
    {
      "status": "Complete",
      "statusColor": Colors.green,
      "icon": "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
      "scheduleDate": "23 Feb 2024",
      "requestedDate": "22 Nov 2024",
      "startDate": "23 Feb 2024",
      "endDate": "23 Feb 2024",
    },
    {
      "status": "Pending",
      "statusColor": Colors.orange,
      "icon": "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
      "scheduleDate": "12 Jun 2024",
      "requestedDate": "10 Jun 2024",
      "startDate": "12 Jun 2024",
      "endDate": "13 Jun 2024",
    },
    {
      "status": "In Progress",
      "statusColor": Colors.blue,
      "icon": "assets/icons_assets/main_icons_assets/ic_time_calendar.svg",
      "scheduleDate": "01 Jul 2024",
      "requestedDate": "28 Jun 2024",
      "startDate": "01 Jul 2024",
      "endDate": "03 Jul 2024",
    },
  ];

  //////////////////////////////////////// Filter person ////////////////////////////////////

  //////////////////////////////////////// Filter person ////////////////////////////////////

  final List<Map<String, dynamic>> supplierDummyData = [
    {
      "supplierId": "001",
      "supplierName": "IT Tech",
      "businessType": "Manufacturer",
      "taxNumber": "102154452659841612",
      "businessRegistrationNumber": "102154452659841612",
      "supplierRank": "Preferred",
      "createdBy": "Amro Handousa",
      "dateAdded": "10 May 2025",
      "name": "Amr Mesbah",
      "department": "Marketing",
      "title": "Marketing Manager",
      "assignedDate": "23 Feb 2024",
      "returnDate": "22 Nov 2024",
      "quantity": "10",
      "location": "Office",
      "lastUpdate": "28 May 2020",
      "image": "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
      "contact": {
        "firstName": "Salem",
        "middleName": "Mohameed",
        "lastName": "Ahmed",
        "title": "Manager",
        "phone": "01025369874",
        "fax": "01025369874",
        "email": "mohammed@outlook.com",
        "preferredLanguage": "English",
      },
      "bankTransferDetails": {
        "beneficiaryName": "Salem",
        "beneficiaryBankName": "QNB",
        "iban": "EG800002000156789012345678901",
        "swiftCode": "QNBAEGCXXXX",
        "bankAddress": "21 Bank Street, Cairo",
      },
      "addressDetails": {
        "country": "Egypt",
        "state": "Cairo Governorate",
        "city": "Cairo",
        "postalCode": "11371",
        "streetName": "Tahrir Street",
      },
      "contractDetails": {
        "startDate": "24 Nov 2018",
        "endDate": "24 Nov 2024",
        "documents": {
          "contract": "Contract_ITTech.pdf",
          "registration": "Reg_ITTech.pdf",
          "taxCertificate": "Tax_ITTech.pdf",
          "fileSize": "62 KB",
          "fileDate": "28 Dec 2023",
        },
      },
    },
    {
      "supplierId": "002",
      "supplierName": "Alpha Build",
      "businessType": "Construction",
      "taxNumber": "201234567891234",
      "businessRegistrationNumber": "201234567891234",
      "supplierRank": "Approved",
      "createdBy": "Oamr Elhassan",
      "dateAdded": "15 Jan 2024",
      "name": "Oamr Elhassan",
      "department": "Marketing",
      "title": "Marketing Manager",
      "assignedDate": "23 Feb 2024",
      "returnDate": "22 Nov 2024",
      "quantity": "10",
      "location": "Office",
      "lastUpdate": "28 May 2020",
      "image": "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
      "contact": {
        "firstName": "Kareem",
        "middleName": "Ibrahim",
        "lastName": "Hassan",
        "title": "Procurement Lead",
        "phone": "01112345678",
        "fax": "01187654321",
        "email": "kareem@alphabuild.com",
        "preferredLanguage": "Arabic",
      },
      "bankTransferDetails": {
        "beneficiaryName": "Kareem Ibrahim",
        "beneficiaryBankName": "Banque Misr",
        "iban": "EG150123456789012345678901234",
        "swiftCode": "BMISEGCXXXX",
        "bankAddress": "5 Al Nasr Street, Nasr City",
      },
      "addressDetails": {
        "country": "Egypt",
        "state": "Cairo Governorate",
        "city": "Nasr City",
        "postalCode": "11765",
        "streetName": "El Nasr Road",
      },
      "contractDetails": {
        "startDate": "01 Feb 2024",
        "endDate": "01 Feb 2025",
        "documents": {
          "contract": "AlphaBuild_Contract.pdf",
          "registration": "Alpha_Reg.pdf",
          "taxCertificate": "Alpha_Tax.pdf",
          "fileSize": "45 KB",
          "fileDate": "01 Feb 2024",
        },
      },
    },
    {
      "supplierId": "003",
      "supplierName": "Green Pharma",
      "businessType": "Pharmaceutical",
      "taxNumber": "305998877665544",
      "businessRegistrationNumber": "305998877665544",
      "supplierRank": "Qualified",
      "createdBy": "Ali Mostafa",
      "dateAdded": "20 Feb 2023",
      "name": "Ali Mostafa",
      "department": "Marketing",
      "title": "Marketing Manager",
      "assignedDate": "23 Feb 2024",
      "returnDate": "22 Nov 2024",
      "quantity": "10",
      "location": "Office",
      "lastUpdate": "28 May 2020",
      "image": "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
      "contact": {
        "firstName": "Layla",
        "middleName": "Samir",
        "lastName": "Mostafa",
        "title": "Operations Officer",
        "phone": "01234567890",
        "fax": "01234567891",
        "email": "layla@greenpharma.org",
        "preferredLanguage": "English",
      },
      "bankTransferDetails": {
        "beneficiaryName": "Layla Samir",
        "beneficiaryBankName": "CIB",
        "iban": "EG980010000123456789012345678",
        "swiftCode": "CIBEEGCXXXX",
        "bankAddress": "Downtown Branch, Cairo",
      },
      "addressDetails": {
        "country": "Egypt",
        "state": "Giza",
        "city": "Dokki",
        "postalCode": "12611",
        "streetName": "El Tahrir Street",
      },
      "contractDetails": {
        "startDate": "20 Feb 2023",
        "endDate": "20 Feb 2026",
        "documents": {
          "contract": "GreenPharma_Agreement.pdf",
          "registration": "Green_Reg.pdf",
          "taxCertificate": "Green_TaxCert.pdf",
          "fileSize": "75 KB",
          "fileDate": "15 Jan 2023",
        },
      },
    },
  ];

  //////////////////////////////////////// Filter person ////////////////////////////////////

  ///////////////////////////////// Variable //////////////////////////////////////////////

  final List<Map<String, String>> departments = [
    {"key": "dep1", "value": "Dep1"},
    {"key": "dep2", "value": "Dep2"},
    {"key": "dep3", "value": "Dep3"},
    {"key": "dep4", "value": "Dep4"},
  ];
  String? selectedDepartment;

  ///////////////////////////////// Variable //////////////////////////////////////////////
  bool showProductDetails = true;
  ///////////////////////////////// Controller ////////////////////////////////////////////
  final TextEditingController _searchController = TextEditingController();

  ///////////////////////////////// Controller ////////////////////////////////////////////
  String selectedRoom = 'All';

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'ar';
    Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            {
              navigateTo(context, InventoryManagement());
            }
          },
          secondTitle: S.of(context).assetsNameDetails,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // Request Id
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Request Id
                    Text(
                      "${S.of(context).requestId}: ",
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                    Text(
                      "001",
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                // space
                SizedBox(height: 8.sp),

                // centre content
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 15.sp,
                      right: 15.sp,
                      left: 15.sp,
                    ),
                    // All context in page section 1
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // First Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // image
                            Container(
                              width: 80.sp,
                              height: 80.sp,
                              decoration: BoxDecoration(
                                color: lightMode
                                    ? AppColors.grey
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: CustomSvgImage(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                                width: 40.sp,
                                height: 40.sp,
                                fit: BoxFit.scaleDown,
                                color: AppColors.blackButton,
                              ),
                            ),

                            // space
                            SizedBox(width: 10.sp),
                            // productID &  productType & supplierName  & category
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                itemText(
                                  value: "100000000",
                                  label: "${S.of(context).productID}: ",
                                ),
                                SizedBox(height: 7.sp),
                                itemText(
                                  value: "Asset",
                                  label: "${S.of(context).productType}: ",
                                ),
                                SizedBox(height: 7.sp),
                                itemText(
                                  value: "TechSource Solutions",
                                  label: "${S.of(context).supplierName}: ",
                                ),
                                SizedBox(height: 7.sp),
                                itemText(
                                  value: "Electronics Electronics  ",
                                  label: "${S.of(context).category}: ",
                                ),
                              ],
                            ),

                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * .1,
                            ),

                            // subcategory &  brand & model  & expectedLifetime
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                itemText(
                                  value: "Computer Computer",
                                  label: "${S.of(context).subcategory}: ",
                                ),
                                SizedBox(height: 7.sp),
                                itemText(
                                  value: "Dell",
                                  label: "${S.of(context).brand}: ",
                                ),
                                SizedBox(height: 7.sp),
                                itemText(
                                  value: "GZ 15",
                                  label: "${S.of(context).model}: ",
                                ),
                                SizedBox(height: 7.sp),
                                itemText(
                                  value: "5 Years",
                                  label: "${S.of(context).expectedLifetime}: ",
                                ),
                              ],
                            ),
                            // space
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width * .1,
                            ),
                            // subcategory &  brand & model  & expectedLifetime
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                itemText(
                                  value: "10",
                                  label: "${S.of(context).quantity}: ",
                                ),
                                SizedBox(height: 7.sp),
                                itemText(
                                  value: "10",
                                  label: "${S.of(context).unitCost}: ",
                                ),
                                SizedBox(height: 7.sp),
                                itemText(
                                  value: "USA",
                                  label: "${S.of(context).currency}: ",
                                ),
                                SizedBox(height: 7.sp),
                                itemText(
                                  value: "Electronic",
                                  label:
                                      "${S.of(context).storageRequirement}: ",
                                ),
                              ],
                            ),

                            Spacer(),

                            // Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${S.of(context).status}: ",
                                  style: StyleText.fontSize10Weight500.copyWith(
                                    color: AppColors.blackButton,
                                  ),
                                ),
                                Text(
                                  S.of(context).inStock,
                                  style: StyleText.fontSize10Weight500.copyWith(
                                    color: AppColors.lightGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // name of product
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Dell GS 15",
                              style: StyleText.fontSize14Weight400.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                          ],
                        ),

                        // space
                        SizedBox(height: 15.sp),

                        // Additional Note
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Additional Note:
                            Text(
                              "${S.of(context).additionalNote}: ",
                              style: StyleText.fontSize12Weight500.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),

                            // value of Additional Note:
                            Text(
                              "Lorem Ipsum Lorem IpsumLorem IpsumLorem",
                              style: StyleText.fontSize12Weight500.copyWith(
                                color: AppColors.blackButton,
                              ),
                            ),
                          ],
                        ),

                        // space
                        SizedBox(height: 20.sp),
                        // Approval Cycle
                        Row(
                          children: [
                            Text(
                              "${S.of(context).approvalCycle}: ",
                              style: StyleText.fontSize12Weight400.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),

                        // space
                        SizedBox(height: 13.sp),

                        // Approval Cycle item
                        buildApprovalCycleRow(section),

                        // space
                        SizedBox(height: 20.sp),

                        // // qr code image &  Download as PNG & and assign
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // qr code image
                                Image(
                                  image: AssetImage(
                                      "assets/icons_assets/inventory_assets/img_qr.png"),
                                  width: 50.sp,
                                  height: 50.sp,
                                  fit: BoxFit.scaleDown,
                                ),
                                // space
                                SizedBox(height: 5.sp),
                                // Download as PNG
                                Row(
                                  children: [
                                    // image download
                                    CustomSvgImage(
                                      assetPath:
                                          "assets/icons_assets/main_icons_assets/ic_action_download.svg",
                                      width: 16.sp,
                                      height: 16.sp,
                                      color: AppColors.blue,
                                      fit: BoxFit.scaleDown,
                                    ),

                                    SizedBox(width: 5.sp),

                                    // downloadAsPng
                                    Text(
                                      S.of(context).downloadAsPng,
                                      style: StyleText.fontSize12Weight500
                                          .copyWith(color: Color(0xff1877F2)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),
                            customButton(
                              title: S.of(context).assign,
                              function: () {
                                navigateTo(context, SelectDetailsSection());
                              },
                              radius: 8.r,
                              textStyle: StyleText.fontSize16Weight500.copyWith(
                                color: AppColors.textButton,
                              ),
                              height: 38.sp,
                              width: 135.sp,
                              color: AppColors.primary,
                            ),
                          ],
                        ),

                        // space
                        SizedBox(height: 15.sp),
                      ],
                    ),
                  ),
                ),

                // space
                SizedBox(height: 20.sp),

                // Filter Widget
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [filterSection(context)],
                ),

                // space
                SizedBox(height: 15.sp),

                // assigningHistory title
                Row(
                  children: [
                    Text(
                      S.of(context).assigningHistory,
                      style: StyleText.fontSize16Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                // space
                SizedBox(height: 8.sp),

                // Search and DropDown Department
                Row(
                  children: [
                    // Search
                    Expanded(
                      child: SizedBox(
                        height: 38.sp,
                        child: AppSearchTextField(
                          controller: _searchController,
                          expanded: false,
                        ),
                      ),
                    ),
                    // space
                    SizedBox(width: ButtonSizing.toolbarGap(context)),
                    // Department
                    SizedBox(
                      width: 135.sp,
                      child: CustomDropdown<String>(
                        items: (departments)
                            .map((e) => DropdownItem<String>(
                                value: e['key'] ?? '', label: e['value'] ?? ''))
                            .toList(),
                        value: selectedDepartment,
                        onChanged: (value) {
                          setState(() {
                            selectedDepartment = value;
                          });
                        },
                        hint: selectedLabel == "Assigning History"
                            ? S.of(context).department
                            : S.of(context).branch,
                        height: 38.sp,
                        fillColor: AppColors.card,
                      ),
                    ),
                  ],
                ),
                // space
                SizedBox(height: 10.sp),

                selectedLabel != "Service History"
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: CrossAxisCountHelper
                              .getCrossAxisCountForDefaultTablet2(
                            context,
                          ),
                          crossAxisSpacing: 15.sp,
                          mainAxisSpacing: 15.sp,
                          mainAxisExtent: 121.sp,
                        ),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          final item = supplierDummyData[index];
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10.sp),
                                child: Column(
                                  children: [
                                    // "name": "Amro Handousa",
                                    // "department": "Marketing",
                                    // "title": "Marketing Manager",
                                    // "assignedDate": "23 Feb 2024",
                                    // "returnDate": "22 Nov 2024",
                                    // "quantity": "10",
                                    // "location": "Office",
                                    // "lastUpdate": "28 May 2020",
                                    // "image": "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                                    Stack(
                                      children: [
                                        Positioned(
                                          //left: 100,
                                          //top: ,
                                          right: 0,
                                          child: itemTextProduct(
                                            labelStyle: StyleText
                                                .fontSize8Weight400
                                                .copyWith(
                                              color: AppColors.secondaryText,
                                            ),
                                            valueStyle: StyleText
                                                .fontSize8Weight400
                                                .copyWith(
                                              color: AppColors.blackButton,
                                            ),
                                            value: item["lastUpdate"],
                                            label: S.of(context).lastUpdate,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            // image
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image(
                                                  image: AssetImage(
                                                    "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                                                  ),
                                                  width: 40.sp,
                                                  height: 40.sp,
                                                  fit: BoxFit.scaleDown,
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 5.sp),
                                            // info
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['name'],
                                                  style: StyleText
                                                      .fontSize14Weight500
                                                      .copyWith(
                                                    color:
                                                        AppColors.blackButton,
                                                  ),
                                                ),
                                                SizedBox(height: 0.sp),
                                                Text(
                                                  item['department'].toString(),
                                                  style: StyleText
                                                      .fontSize10Weight500
                                                      .copyWith(
                                                    color: lightMode
                                                        ? AppColors
                                                            .secondaryText
                                                        : AppColors.grey,
                                                  ),
                                                ),
                                                SizedBox(height: 0.sp),
                                                Text(
                                                  item['title'].toString(),
                                                  style: StyleText
                                                      .fontSize10Weight500
                                                      .copyWith(
                                                    color: lightMode
                                                        ? AppColors
                                                            .secondaryText
                                                        : AppColors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 13.sp),

                                    // Assigned Date & Return Date & quantityAssigned & location
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            itemTextProduct(
                                              label:
                                                  "${S.of(context).assignedDate}: ",
                                              value: item["assignedDate"],
                                            ),
                                            SizedBox(height: 10.sp),
                                            itemTextProduct(
                                              label:
                                                  "${S.of(context).quantityAssigned}: ",
                                              value: item["quantity"],
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            itemTextProduct(
                                              label:
                                                  "${S.of(context).returnDate}: ",
                                              value: item["returnDate"],
                                            ),
                                            SizedBox(height: 10.sp),
                                            itemTextProduct(
                                              label:
                                                  "${S.of(context).location}: ",
                                              value: item["location"],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : buildServiceHistoryWidget(),

                SizedBox(height: 15.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //////////////////////////////// Stock Section ////////////////////////////////

  Widget buildServiceHistoryWidget() {
    final List<String> roomFilters = ['All', 'Warehouse', 'Room 13'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Filter Row
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: roomFilters.map((room) {
            final bool isSelected = room == selectedRoom;

            return Padding(
              padding: EdgeInsets.only(right: 8.sp),
              child: GestureDetector(
                onTapDown: (_) => HapticController.low(),
                onTap: () {
                  setState(() {
                    selectedRoom = room;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.card,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.sp,
                    vertical: 8.sp,
                  ),
                  child: Center(
                    child: Text(
                      room,
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: isSelected
                            ? AppColors.blackButton // ✅ black text on yellow
                            : AppColors.blackButton,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // space
        SizedBox(height: 15.sp),

        GridView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
              context,
            ),
            crossAxisSpacing: 15.sp,
            mainAxisSpacing: 15.sp,
            mainAxisExtent: 101.sp,
          ),
          itemCount: maintenanceDummyData.length,
          itemBuilder: (context, index) {
            final item = maintenanceDummyData[index];
            return GestureDetector(
              onTap: () {
                navigateTo(context, SelectServicesHistorySection());
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 15.sp,
                  vertical: 8.sp,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            '${S.of(context).status}: ',
                            style: StyleText.fontSize10Weight500.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                        Text(
                          "${item["status"]}",
                          style: StyleText.fontSize10Weight500.copyWith(
                            color: item["statusColor"], // dynamic status color
                          ),
                        ),
                      ],
                    ),
                    // Calendar icon and two labels
                    Row(
                      children: [
                        Image(
                          image: AssetImage(
                              "assets/icons_assets/main_icons_assets/ic_time_calendar.svg"),
                          width: 50.sp,
                          height: 50.sp,
                          fit: BoxFit.scaleDown,
                        ),
                        SizedBox(width: 5.sp),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              itemText(
                                label: "${S.of(context).maintenanceSchedule}: ",
                                value: item["scheduleDate"],
                              ),
                              SizedBox(height: 8.sp),
                              itemText(
                                label:
                                    "${S.of(context).requestedMaintenance}: ",
                                value: item["requestedDate"],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.sp),
                    // Start and End date row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        itemText(
                          label: "${S.of(context).startDate}: ",
                          value: item["startDate"],
                        ),
                        itemText(
                          label: "${S.of(context).endDate}: ",
                          value: item["endDate"],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  //////////////////////////////// Stock Section ////////////////////////////////

  ////////////////////////// item in any Container /////////////////////////////
  Widget itemTextProduct({
    required String label,
    required String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(label),
          style: labelStyle ??
              StyleText.fontSize10Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
        ),
        Text(
          FormatHelper.capitalize(value),
          style: valueStyle ??
              StyleText.fontSize10Weight500.copyWith(
                color: AppColors.blackButton,
              ),
        ),
      ],
    );
  }
  ////////////////////////// item in any Container /////////////////////////////

  /////////////////////////// Filter in Assigned & Stock //////////////////////////////////

  String selectedLabel = "Assigning History"; // Default selected chip

  Widget filterSection(BuildContext context) {
    final Map<String, String> filterItems = {
      "Assigning History": S.of(context).assigningHistory,
      "Service History": S.of(context).serviceHistory,
    };

    final Map<String, String> filterCounts = {
      "Assigning History": "14",
      "Service History": "7",
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterItems.entries.map((entry) {
          final key = entry.key;
          final label = entry.value;
          final count = filterCounts[key] ?? "0";
          return _statusChip(
            count,
            key,
            label,
            context,
          ); // ✅ Now passes all required arguments
        }).toList(),
      ),
    );
  }

  Widget _statusChip(
    String count,
    String key,
    String label,
    BuildContext context,
  ) {
    bool isSelected = key == selectedLabel;
    bool isLight = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        setState(() {
          selectedLabel = key;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            // 22/10/2026 — Owner (phone): count chips match Notifications — box 35, number 14/400, label 14/600.
            width: context.isPhone ? 35.sp : 45.sp,
            height: context.isPhone ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isLight ? AppColors.white : AppColors.chatBackground),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: (context.isPhone
                        ? StyleText.fontSize14Weight400
                        : StyleText.fontSize20Weight500)
                    .copyWith(
                  color: isSelected
                      ? AppColors.textButton
                      : isLight
                          ? AppColors.secondaryText
                          : AppColors.grey,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          Text(
            FormatHelper.capitalize(label),
            style: (context.isPhone
                    ? StyleText.fontSize14Weight600
                    : StyleText.fontSize16Weight600)
                .copyWith(
              color: isSelected
                  ? isLight
                      ? AppColors.blackButton
                      : AppColors.white
                  : (isLight ? AppColors.secondaryText : AppColors.grey),
            ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }

  /////////////////////////// Filter in Assigned & Stock //////////////////////////////////

  ////////////////////////// item in any Container /////////////////////////////
  Widget itemText({
    required String label,
    required String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(label),
          style: labelStyle ??
              StyleText.fontSize10Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
        ),
        Text(
          FormatHelper.capitalize(value),
          style: valueStyle ??
              StyleText.fontSize10Weight500.copyWith(
                color: AppColors.blackButton,
              ),
        ),
      ],
    );
  }
  ////////////////////////// item in any Container /////////////////////////////

  //////////////////////////////// Approval Cycle //////////////////////////////
  Widget buildApprovalCycleRow(ApprovalSection section) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    var theme = Theme.of(context).brightness == Brightness.light;

    return Column(
      children: List.generate(
        (section.selectedApprovers.length / 5).ceil(), // Changed to 5
        (rowIndex) {
          final rowItems = section.selectedApprovers
              .skip(rowIndex * 5)
              .take(5)
              .toList(); // Changed to 5

          return Padding(
            padding: EdgeInsets.only(bottom: 8.sp),
            child: Row(
              children: List.generate(rowItems.length * 2 - 1, (i) {
                if (i.isEven) {
                  final index = i ~/ 2;
                  final employee = rowItems[index];
                  return Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundColor: Colors.transparent,
                            child: ClipOval(
                              child: CustomSvgImage.natural(
                                assetPath: employee.gender == "male"
                                    ? 'assets/icons_assets/main_icons_assets/ic_user_avatar_male.png'
                                    : 'assets/icons_assets/main_icons_assets/ic_user_avatar_female.png',
                                semanticsLabel: 'Gender Icon',
                                fit: BoxFit.cover,
                                width: 40.sp,
                                height: 40.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 6.sp),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FormatHelper.capitalize(
                              isEnglish
                                  ? "${employee.firstName} ${employee.lastName}"
                                  : "${employee.firstNameInArabic} ${employee.lastNameInArabic}",
                            ),
                            style: StyleText.fontSize10Weight500.copyWith(
                              color: theme
                                  ? AppColors.blackButton
                                  : AppColors.white,
                            ),
                          ),
                          Text(
                            FormatHelper.capitalize(
                              isEnglish
                                  ? employee.title ?? ''
                                  : employee.titleInArabic ?? '',
                            ),
                            style: StyleText.fontSize10Weight500.copyWith(
                              color: theme
                                  ? AppColors.secondaryText
                                  : AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.sp),
                    child: Transform.rotate(
                      angle: isEnglish ? 0 : 3.1416,
                      child: CustomSvgImage.natural(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg",
                        width: 25.sp,
                        color: theme ? AppColors.text : AppColors.whiteShadow,
                      ),
                    ),
                  );
                }
              }),
            ),
          );
        },
      ),
    );
  }

  //////////////////////////////// Approval Cycle //////////////////////////////
}

class EmployeeEntity {
  final String id; // ✅ Required for selection logic
  final String? firstName;
  final String? lastName;
  final String? firstNameInArabic;
  final String? lastNameInArabic;
  final String? title;
  final String? titleInArabic;
  final String? departmentId;
  final String gender;

  EmployeeEntity({
    required this.id, // ✅ Make sure it's passed
    this.firstName,
    this.lastName,
    this.firstNameInArabic,
    this.lastNameInArabic,
    this.title,
    this.titleInArabic,
    this.departmentId,
    required this.gender,
  });
}

class ApprovalSection {
  final GlobalKey iconKey = GlobalKey();
  final LayerLink layerLink = LayerLink();
  OverlayEntry? overlayEntry;
  String? selectedRequestType;
  TextEditingController searchController = TextEditingController();
  GlobalKey tooltipIconKey = GlobalKey();

  List<EmployeeEntity> selectedApprovers;

  ApprovalSection({
    this.selectedRequestType,
    this.selectedApprovers = const [],
  });
}

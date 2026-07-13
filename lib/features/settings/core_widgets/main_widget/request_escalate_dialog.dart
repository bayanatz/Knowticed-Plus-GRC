// ignore_for_file: prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/enum/app_enums.dart';
import 'package:multi_dropdown/models/chip_config.dart';
import 'package:multi_dropdown/models/value_item.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import 'package:demo_app/features/settings/presentation/ui/widgets/additional_info_update.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/contact_info_update.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/emergency_contact_info_update.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/health_insurance_update.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/location_info_update.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/personal_data_update.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/exclate_photo_data_row.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/settings/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/column_request_data.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_container.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/cupertino_time_picker.dart';
import 'package:demo_app/features/settings/core_widgets/dialogs/response_dialog.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/filters_appbar.dart';
import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/settings_header.dart';
import 'package:demo_app/features/settings/core_widgets/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/date_picker_class.dart';
import 'package:demo_app/core/enums/enum.dart';

class RequestExcalateDialog extends StatefulWidget {
  RequestExcalateDialog({super.key, required this.title, required this.imageUrl, required this.isExclate,
    this.isToShowImage, this.isSetting = false, this.onPressed});
  final String title;
  final String imageUrl;
  final bool isExclate;
  final bool? isSetting;
  final bool? isToShowImage;
  void Function()? onPressed;
  @override
  State<RequestExcalateDialog> createState() => _RequestExcalateDialogState();
}

class _RequestExcalateDialogState extends State<RequestExcalateDialog> {
  String? requestType;
  String? section;
  DateTime? selectedDate;
  List<DateTime?> _range = [];
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  String hintDate = "";
  late MultiSelectController _controller;
  List<ValueItem<dynamic>> optionsD = [];

  @override
  void initState() { _controller = MultiSelectController(); super.initState(); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await DatePicker().showDatePicker(context, _range, DateTime.now(), CalendarDatePicker2Type.range);
    if (picked != null) {
      setState(() {
        _range = picked;
        selectedDate = picked[0];
        hintDate = "${'From'.tr} ${picked[0]!.day} ${DateFormat.MMM().format(picked[0]!).tr} ${'To'.tr} ${picked.last!.day} ${DateFormat.MMM().format(picked.last!).tr}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    Color fieldBg = lightMode ? AppColors.colorLightGrey : AppColors.colorBlack;

    TextStyle headersStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: isPortrait ? FontConstants.fontSize019.h : FontConstants.fontSize022.h,
      fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.inverseSurface);

    ButtonStyle btnStyle(Color c) => ElevatedButton.styleFrom(
      minimumSize: isPortrait ? Size(0.18.w, 0.05.h) : Size(0.068.w, 0.05.h),
      backgroundColor: c, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))));

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        vertical: isTablet ? 0.04.h : 0,
        horizontal: isTablet ? (isPortrait ? 0.05.w : 0.15.w) : 0.06.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Theme.of(context).colorScheme.inversePrimary),
          width: isTablet ? 0.8.w : null,
          child: widget.isToShowImage == true
              ? Image.network(widget.imageUrl)
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.02.w),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: isPortrait ? 0.01.h : 0.02.h),
                          child: FiltersAppBar(imageUrl: widget.imageUrl, title: widget.title)),
                        if (widget.isSetting != true) ...[
                          ColumnRequestData(title: "Leave Type", isOptional: false, isTextField: false,
                            buttonWidth: double.infinity, dropWidth: 0.88.w, isExpanded: false, hint: "Type",
                            dropdownValue: requestType, dropDownValueState: (v) => setState(() => requestType = v)),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 0.015.h),
                            child: Row(children: [
                              Expanded(child: GestureDetector(onTap: () => _selectDate(context),
                                child: ColumnRequestData(fillColor: fieldBg, title: "Start Date", textController: startDate,
                                  isTextField: true, hint: hintDate, enabled: false, isOptional: false, isExpanded: true,
                                  hasPrefix: true, hasSuffix: true, suffixUrl: "assets/icons_assets/main_icons_assets/newCalenderFixed.svg"))),
                              SizedBox(width: 0.02.w),
                              Expanded(child: GestureDetector(onTap: () => _selectDate(context),
                                child: ColumnRequestData(fillColor: fieldBg, title: "End Date", textController: endDate,
                                  isTextField: true, hint: hintDate, isOptional: false, isExpanded: true,
                                  enabled: false, hasPrefix: true, hasSuffix: true, suffixUrl: "assets/icons_assets/main_icons_assets/newCalenderFixed.svg"))),
                            ])),
                          Row(children: [
                            Expanded(child: GestureDetector(onTap: () => showDialog(context: context,
                                builder: (_) => CupertinoTimePicker(onDateTimeChanged: (_) {})),
                              child: ColumnRequestData(fillColor: fieldBg, title: "Start Time", isTextField: true,
                                hint: "Text here", enabled: false, isOptional: false, hasPrefix: true, isExpanded: true,
                                hasSuffix: true, suffixUrl: "assets/icons_assets/main_icons_assets/newTimeIconFixed.svg", controllerState: (_) {}, maxlength: 120))),
                            SizedBox(width: 0.02.w),
                            Expanded(child: GestureDetector(onTap: () => showDialog(context: context,
                                builder: (_) => CupertinoTimePicker(onDateTimeChanged: (_) {})),
                              child: ColumnRequestData(fillColor: fieldBg, title: "End Time", isTextField: true,
                                hint: "Text here", enabled: false, isOptional: false, hasPrefix: true, isExpanded: true,
                                hasSuffix: true, suffixUrl: "assets/icons_assets/main_icons_assets/newTimeIconFixed.svg", controllerState: (_) {}, maxlength: 120))),
                          ]),
                          Padding(padding: EdgeInsets.symmetric(vertical: 0.015.h),
                            child: SizedBox(width: double.infinity,
                              child: ColumnRequestData(title: "Reason", isOptional: true,
                                fillColor: Theme.of(context).colorScheme.inversePrimary,
                                isTextField: true, maxlines: 5, hint: "Enter you reason", isExpanded: true))),
                          Padding(padding: EdgeInsets.only(top: 0.025.h, bottom: 0.015.h),
                            child: Text("Why you want to leave..?".tr, style: AppFontStyle.cairoRegularStyle.copyWith(
                              fontSize: FontConstants.fontSize020.h, fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.inverseSurface))),
                        ],
                        if (widget.isSetting == true) ...[
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            ColumnRequestData(buttonHeight: isPortrait ? 0.044.h : 0.07.h, title: "Section",
                              isOptional: false, isTextField: false, isExpanded: false, hint: "Section",
                              isDescription: true, buttonWidth: isPortrait ? 0.3.w : null, dropWidth: isPortrait ? 0.3.w : null,
                              dropdownValue: requestType,
                              dropDownValueState: (v) => setState(() { requestType = v; section = v; optionsD.clear(); })),
                            if (requestType != null && requestType!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: Get.locale.toString().contains('en') ? 0.02.w : 0,
                                  right: Get.locale.toString().contains('en') ? 0 : 0.02.w),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text("Fields".tr, style: headersStyle.copyWith(height: 1.6)),
                                  SizedBox(
                                    width: isPortrait ? 0.42.w : 0.44.w,
                                    height: isPortrait ? 0.045.h : 0.07.h,
                                    child: MultiSelectDropDown(
                                      borderRadius: 8, dropdownBorderRadius: 8,
                                      selectedOptionIcon: const Icon(Icons.check, size: 16),
                                      clearIcon: const Icon(Icons.close, size: 16),
                                      padding: EdgeInsets.only(
                                        right: Get.locale.toString().contains("en") ? (isPortrait ? 0.02.w : 0.01.w) : (isPortrait ? 0.007.w : 0.003.w),
                                        left: Get.locale.toString().contains("en") ? (isPortrait ? 0.009.w : 0.006.w) : (isPortrait ? 0.02.w : 0.01.w)),
                                      borderColor: Colors.transparent, borderWidth: 1.1, hint: "Fields".tr,
                                      dropdownHeight: 0.18.h,
                                      suffixIcon: const Icon(Icons.arrow_drop_down),
                                      hintColor: Theme.of(context).colorScheme.scrim,
                                      hintStyle: AppFontStyle.cairoRegularStyle.copyWith(color: AppColors.colorGrey, height: 1.2,
                                        fontSize: isPortrait ? FontConstants.fontSize016.h : FontConstants.fontSize022.h),
                                      controller: _controller,
                                      onOptionSelected: (opts) => setState(() => optionsD = opts),
                                      radiusGeometry: BorderRadius.circular(8),
                                      fieldBackgroundColor: fieldBg,
                                      dropdownBackgroundColor: Theme.of(context).colorScheme.inversePrimary,
                                      optionsBackgroundColor: Theme.of(context).colorScheme.inversePrimary,
                                      selectedOptionBackgroundColor: Colors.transparent,
                                      options: requestType == "Personal Information".tr
                                          ? [ValueItem(label: "Personal Data".tr, value: '1'), ValueItem(label: 'Contact Information'.tr, value: '2'), ValueItem(label: 'Location Information'.tr, value: '3')]
                                          : requestType == "Health Insurance".tr
                                              ? [ValueItem(label: "Health Insurance".tr, value: '1'), ValueItem(label: 'Emergency Contact Information'.tr, value: '2')]
                                              : requestType == "Additional Information".tr
                                                  ? [ValueItem(label: "Additional Information".tr, value: '1')]
                                                  : [ValueItem(label: "", value: '1')],
                                      selectionType: SelectionType.multi,
                                      chipConfig: ChipConfig(deleteIcon: Icon(Icons.cancel, size: isPortrait ? 0.02.h : 0.03.h, color: AppColors.textButton), wrapType: WrapType.scroll, radius: 12),
                                      optionTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
                                        color: Theme.of(context).colorScheme.scrim,
                                        fontSize: isPortrait ? FontConstants.fontSize016.h : FontConstants.fontSize020.h, height: 1.8)),
                                  ),
                                ])),
                          ]),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            if (optionsD.isNotEmpty) Padding(padding: EdgeInsets.only(top: 0.02.h, bottom: 0.01.h),
                              child: SizedBox(width: isTablet ? (isPortrait ? 0.46.w : 0.37.w) : 0.37.w,
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [Text("Current".tr, style: headersStyle), Text("New".tr, style: headersStyle)]))),
                            _sec(optionsD, "Additional Information", 'assets/icons_assets/main_icons_assets/add_info_title.svg', AdditionalInfoUpdate()),
                            _sec(optionsD, "Health Insurance", 'assets/icons_assets/main_icons_assets/Hospital.svg', const HealthInsuranceUpdate()),
                            _sec(optionsD, "Emergency Contact Information", 'assets/icons_assets/main_icons_assets/UsersGroup.svg', const EmergencyContactInfoUpdate()),
                            _sec(optionsD, "Personal Data", 'assets/icons_assets/main_icons_assets/personalInfo.svg', const PersonalDataUpdate()),
                            _sec(optionsD, "Contact Information", 'assets/icons_assets/main_icons_assets/contactInfoPhone.svg', ContactInfoUpdate()),
                            _sec(optionsD, "Location Information", 'assets/icons_assets/main_icons_assets/LocationInfo.svg', LocationInfoUpdate()),
                          ]),
                        ],
                        if (widget.isSetting != true)
                          ColumnRequestData(title: "Assign to", isOptional: false,
                            fillColor: Theme.of(context).colorScheme.inversePrimary,
                            isTextField: true, hint: "Enter the name", isExpanded: true),
                        widget.isExclate
                            ? const ExcalatePhotoDataRow(photoUrl: "assets/images/escaltephoto.png", title: "Sick Leave", space: "50 mb")
                            : widget.onPressed == null
                                ? Padding(padding: EdgeInsets.symmetric(vertical: 0.02.h),
                                    child: Custom_Container(height: isPortrait ? 0.045.h : 0.055.h,
                                      imageAddress: "assets/icons_assets/main_icons_assets/upload_pic.svg", text: "Upload Attachment",
                                      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                                      borderColor: AppColors.lightPrimary, iconColor: AppColors.lightPrimary, textColor: AppColors.lightPrimary))
                                : const SizedBox(height: 45),
                        if (widget.isExclate == false && optionsD.isNotEmpty)
                          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                            MainCustomIconButton(
                              onPressed: widget.isSetting == false && requestType == null ? () {}
                                  : widget.onPressed == null
                                      ? () { Navigator.pop(context); showDialog(context: context, builder: (_) => const ResponseDialog(subtitle: "You Successful Send Leave Sick", title: '', lottieAsset: '')); }
                                      : widget.onPressed!,
                              buttonText: widget.isExclate ? "Escalates".tr : "Send".tr,
                              buttonStyle: widget.isSetting == false && requestType == null ? btnStyle(AppColors.greyDark) : btnStyle(AppColors.signOut))
                          ]),
                        SizedBox(height: 0.015.h),
                      ],
                    ),
                  )),
        ),
      ),
    );
  }

  Widget _sec(List<ValueItem<dynamic>> opts, String label, String icon, Widget content) {
    if (opts.isEmpty || !opts.any((i) => i.label.tr == label.tr)) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: EdgeInsets.only(bottom: 0.02.h, top: 0.01.h),
        child: SettingsHeader(imagePath: icon, text: label.tr, hideDiv: true)),
      content,
    ]);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_drop_down_menu.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/column_request_data.dart';
import 'package:demo_app/core/utils/app_image_provider.dart';

class RowIconTextAnnouncement extends StatefulWidget {
  RowIconTextAnnouncement(
      {super.key,
      required this.iconUrl,
      required this.text,
      this.isSmall = false,
      this.isDescribtion = false,
      this.isDropDown = false,
      this.hideImage = false,
      this.status,
      this.statusState,
      this.isProvider = false,
      this.providerNAme,
      this.profileImage,
      required this.value});
  final String iconUrl;
  final String text;
  final String value;
  bool? isSmall;
  final bool isDescribtion;
  final bool isDropDown;
  final bool hideImage;
  String? status;
  String? profileImage;
  ValueChanged<String?>? statusState;
  final bool isProvider;
  TextEditingController? providerNAme;

  @override
  State<RowIconTextAnnouncement> createState() =>
      _RowIconTextAnnouncementState();
}

class _RowIconTextAnnouncementState extends State<RowIconTextAnnouncement> {
  void updateProviderName(String newProviderName) {
    setState(() {
      widget.providerNAme?.text = newProviderName;
    });
  }

  List<String> arabicStatus = [
    'Done'.tr,
    'In Progress'.tr,
    'Canceled'.tr,
  ];
  List<String> englishStatus = [
    'Done',
    'In Progress',
    'Canceled',
  ];
  Color getValueColor(String value) {
    String translatedValue = value.tr.toLowerCase();

    switch (translatedValue) {
      case 'in progress':
      case 'تحت التقدم':
        return AppColors.secondaryColor;
      case 'pending':
      case 'قيد الانتظار':
        return AppColors.warning;
      case 'rejected':
      case 'مرفوض':
      case 'canceled':
      case 'ملغى':
      case 'inactive':
      case 'غير نشط':
        return AppColors.delete;
      case 'approved':
      case 'موافق':
      case 'done':
      case 'مكتمل':
      case 'active':
      case 'نشط':
        return AppColors.unBlock;
      default:
        return themeController.currentTheme == AppColors.lightTheme
            ? AppColors.colorBlack
            : AppColors.colorWhiteDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double dropdownWidthVert = 0.28.w;
    double dropdownWidthHori = 0.2.w;
    TextStyle textStyle = AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: widget.isSmall == true
            ? widget.isSmall == true
                ? isPortrait
                    ? FontConstants.fontSize015.h
                    : FontConstants.fontSize012.w
                : FontConstants.fontSize014.w
            : isTablet
                ? isPortrait
                    ? FontConstants.fontSize014.h
                    : FontConstants.fontSize014.w
                : FontConstants.fontSize018.h,
        color: themeController.currentTheme == AppColors.lightTheme
            ? AppColors.colorDarkGrey
            : AppColors.colorGreydark,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
        height: isTablet ? 1.5 : 1.3);

    TextStyle valueStyle = AppFontStyle.cairoRegularStyle.copyWith(
        fontSize: widget.isSmall == true
            ? widget.isSmall == true
                ? isPortrait
                    ? FontConstants.fontSize015.h
                    : FontConstants.fontSize012.w
                : FontConstants.fontSize014.w
            : isTablet
                ? isPortrait
                    ? FontConstants.fontSize014.h
                    : FontConstants.fontSize014.w
                : FontConstants.fontSize018.h,
        color: getValueColor(widget.value),
        fontWeight: FontWeight.w500,
        height: isTablet ? 1.5 : 1.3);

    return widget.isDescribtion
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    widget.iconUrl,
                    color: AppColors.signOut,
                    height: isPortrait
                        ? 0.025.h
                        : widget.isSmall == true
                            ? 0.025.h
                            : 0.035.h,
                  ), //'assets/icons/Org.svg'
                  SizedBox(width: 0.01.w),
                  Text(
                    "${widget.text.tr}: ", //widget.isGrade == true ? 'Teacher:' : 'Organizer:'
                    style: textStyle,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.015.h),
                child: Text(
                  widget.value.contains('@')
                      ? widget.value.tr
                      : widget.value.tr
                          .capitalize!, //' ${widget.organizerName}'.capitalize as String
                  style: valueStyle,
                  // overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        : Row(
            crossAxisAlignment: widget.isDropDown || widget.isProvider
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.center,
            children: [
              widget.hideImage == true
                  ? const SizedBox.shrink()
                  : SvgPicture.asset(
                      widget.iconUrl,
                      color: AppColors.signOut,
                      height: isTablet
                          ? (isPortrait
                              ? 0.02.h
                              : widget.isSmall == true
                                  ? 0.025.h
                                  : 0.035.h)
                          : 0.025.h,
                    ), //'assets/icons/Org.svg'
              widget.hideImage == true
                  ? const SizedBox.shrink()
                  : SizedBox(width: isTablet ? 0.01.w : 0.02.w),
              Text(
                "${widget.text.tr}: ", //widget.isGrade == true ? 'Teacher:' : 'Organizer:'
                style: textStyle,
              ),
              widget.isDropDown
                  ? SizedBox(width: 0.01.w)
                  : const SizedBox.shrink(),
              widget.isDropDown
                  ? CustomDropdownButton2(
                      hint: "Status",
                      borded: false,
                      buttonHeight: isPortrait ? 0.04.h : 0.055.h,
                      buttonWidth: isTablet
                          ? (isPortrait ? dropdownWidthVert : dropdownWidthHori)
                          : 0.45.w,
                      dropdownWidth: isTablet
                          ? (isPortrait ? dropdownWidthVert : dropdownWidthHori)
                          : 0.45.w,
                      subColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      buttonDecoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                      ),
                      buttonPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 0.01.w : 0.02.w),
                      value: Get.locale.toString().contains('en')
                          ? widget.status
                          : arabicStatus[englishStatus.indexOf(widget.status!)],
                      dropdownItems: Get.locale.toString().contains('en')
                          ? englishStatus
                          : arabicStatus,
                      onChanged: (value) {
                        setState(() {
                          widget.status = value;
                          widget.statusState!(Get.locale
                                  .toString()
                                  .contains('en')
                              ? value
                              : englishStatus[arabicStatus.indexOf(value!)]);
                        });
                      },
                    )
                  : isTablet
                      ? widget.isProvider
                          ? Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // showDialog(
                                  //     context: context,
                                  //     builder: (context) {
                                  //       return ChangeProviderDialog(
                                  //         currentProviderName:
                                  //             widget.providerNAme!.text,
                                  //         newProvider: widget.providerNAme!,
                                  //         onProviderChanged: updateProviderName,
                                  //       );
                                  //     });
                                },
                                child: ColumnRequestData(
                                  title: "",
                                  hideTitle: true,
                                  isTextField: true,
                                  enabled: false,
                                  hint: widget.value,
                                  textController: widget.providerNAme,
                                  isOptional: false,
                                  isExpanded: true,
                                  hasSuffix: true,
                                  sizerSuffix: isPortrait ? 0.45 : 0.5,
                                  suffixUrl: 'assets/icons_assets/main_icons_assets/isEditIcon.svg',
                                  suffixHasColor: true,
                                  //    suffixColor: AppColors.signOut,
                                ),
                              ),
                            )
                          : Expanded(
                              child: Row(
                                children: [
                                  if (widget.profileImage != null)
                                    widget.profileImage!.contains('assets')
                                        ? CircleAvatar(
                                            radius:
                                                isPortrait ? 0.02.w : 0.015.w,
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: appImageProvider(
                                                widget.profileImage!),
                                          )
                                        : CircleAvatar(
                                            radius:
                                                isPortrait ? 0.02.w : 0.015.w,
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: NetworkImage(
                                                widget.profileImage!),
                                          ),
                                  if (widget.profileImage != null)
                                    SizedBox(
                                      width: 0.005.w,
                                    ),
                                  Expanded(
                                    child: Text(
                                      widget.value.contains('@')
                                          ? widget.value.tr
                                          : widget.value.tr
                                              .capitalize!, //' ${widget.organizerName}'.capitalize as String
                                      style: valueStyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )
                      : widget.isProvider
                          ? GestureDetector(
                              onTap: () {
                                // showDialog(
                                //     context: context,
                                //     builder: (context) {
                                //       return ChangeProviderDialog(
                                //         currentProviderName:
                                //             widget.providerNAme!.text,
                                //         newProvider: widget.providerNAme!,
                                //         onProviderChanged: updateProviderName,
                                //       );
                                //     });
                              },
                              child: SizedBox(
                                width: 0.48.w,
                                child: ColumnRequestData(
                                  title: "",
                                  hideTitle: true,
                                  isTextField: true,
                                  enabled: false,
                                  hint: widget.value,
                                  textController: widget.providerNAme,
                                  isOptional: false,
                                  isExpanded: true,
                                  hasSuffix: true,
                                  sizerSuffix: isPortrait ? 0.45 : 0.5,
                                  suffixUrl: 'assets/icons_assets/main_icons_assets/isEditIcon.svg',
                                  suffixHasColor: true,
                                  //    suffixColor: AppColors.signOut,
                                ),
                              ))
                          : Expanded(
                              child: Row(
                                children: [
                                  if (widget.profileImage != null)
                                    widget.profileImage!.contains('assets')
                                        ? CircleAvatar(
                                            radius: 0.04.w,
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: appImageProvider(
                                                widget.profileImage!),
                                          )
                                        : CircleAvatar(
                                            radius: 0.04.w,
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: NetworkImage(
                                                widget.profileImage!),
                                          ),
                                  if (widget.profileImage != null)
                                    SizedBox(
                                      width: 0.01.w,
                                    ),
                                  Expanded(
                                    child: Text(
                                      widget.value.contains('@')
                                          ? widget.value.tr
                                          : widget.value.tr.capitalize!,
                                      style: valueStyle.copyWith(
                                          height: widget.profileImage != null
                                              ? 1.6
                                              : null),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
            ],
          );
  }
}

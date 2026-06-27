// ignore_for_file: sdk_version_since

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_icon_container.dart';
import 'package:demo_app/features/settings/presentation/ui/widgets/location_info_update.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/request_escalate_dialog.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_additional_info.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:demo_app/features/settings/presentation/ui/pages/profile_screen.dart';

class AdditionalInfoUpdate extends StatefulWidget {
  const AdditionalInfoUpdate({super.key});

  @override
  State<AdditionalInfoUpdate> createState() => _AdditionalInfoUpdateState();
}

class _AdditionalInfoUpdateState extends State<AdditionalInfoUpdate> {
  List<String> imageExtentions = [
    ".PSD",
    ".XCF",
    ".AI",
    ".CDR",
    ".tif",
    ".tiff",
    ".bmp",
    ".jpg",
    ".jpeg",
    ".gif",
    ".png",
    ".eps",
    ".raw",
    ".cr2",
    ".nef",
    ".orf",
    ".sr2"
  ];
  // String? educationCertificate2;
  // String? idPhoto2;
  // String? armyCertificate2;
  // String? drivingLicense2;
  // String? maritalCertificate2;
  // String? insuranceCard2;
  bool isImage(String filePath) {
    bool flag = false;
    for (String imageExtention in imageExtentions) {
      if (filePath.contains(imageExtention)) {
        return true;
      }
    }
    return flag;
  }

  String getFileNameFromPath(String path) {
    List<String> splitedPath = path.split('/');
    String fileName = splitedPath.last;
    return fileName;
  }

  Future<void> pickAndUploadFile(
    int index,
  ) async {
    FilePickerResult? pickedPdf = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (pickedPdf != null) {
      showLoadingIndicator();
      final file = File(pickedPdf.files.single.path!);
      String filePath = pickedPdf.files.single.path!;
      setState(() {
        index == 1
            ? educationFileName = getFileNameFromPath(filePath)
            : index == 0
                ? idPhotoFileName = getFileNameFromPath(filePath)
                : index == 3
                    ? armyFileName = getFileNameFromPath(filePath)
                    : index == 2
                        ? driveFileName = getFileNameFromPath(filePath)
                        : index == 5
                            ? maritalFileName = getFileNameFromPath(filePath)
                            : insuranceFileName = getFileNameFromPath(filePath);
      });

      if (isImage(filePath)) {
        Reference ref = FirebaseStorage.instance.ref().child(
            'employee/"${employee!.firstName!.last!}_${employee!.lastName!.last!}"/${index == 0 ? "education_certificate_photo" : index == 1 ? "id_photo" : index == 2 ? "army_certificate_photo" : index == 3 ? "driving_license_photo" : index == 4 ? "marital_certificate_photo" : "insurance_card_photo"}_${DateTime.now()}.png');
        final metadata = SettableMetadata(contentType: 'image/jpeg');
        final TaskSnapshot task = await ref.putFile(file, metadata);
        index == 1
            ? educationCertificate2 = await task.ref.getDownloadURL()
            : index == 0
                ? idPhoto2 = await task.ref.getDownloadURL()
                : index == 3
                    ? armyCertificate2 = await task.ref.getDownloadURL()
                    : index == 2
                        ? drivingLicense2 = await task.ref.getDownloadURL()
                        : index == 5
                            ? maritalCertificate2 =
                                await task.ref.getDownloadURL()
                            : insuranceCard2 = await task.ref.getDownloadURL();
      } else {
        final Reference storageRef = FirebaseStorage.instance.ref().child(
            'employee/"${employee!.firstName!.last!}_${employee!.lastName!.last!}"/${index == 0 ? "education_certificate_file" : index == 1 ? "id_file" : index == 2 ? "army_certificate_file" : index == 3 ? "driving_license_file" : index == 4 ? "marital_certificate_file" : "insurance_card_file"}_${DateTime.now()}.pdf');
        final metadata = SettableMetadata(contentType: 'application/pdf');
        final TaskSnapshot task = await storageRef.putFile(file, metadata);
        index == 1
            ? educationCertificate2 = await task.ref.getDownloadURL()
            : index == 0
                ? idPhoto2 = await task.ref.getDownloadURL()
                : index == 3
                    ? armyCertificate2 = await task.ref.getDownloadURL()
                    : index == 2
                        ? drivingLicense2 = await task.ref.getDownloadURL()
                        : index == 5
                            ? maritalCertificate2 =
                                await task.ref.getDownloadURL()
                            : insuranceCard2 = await task.ref.getDownloadURL();
      }
      setState(() {});
      hideLoadingIndicator();
    }
  }

  void initState() {
    educationFileName = null;
    idPhotoFileName = null;
    armyFileName = null;
    driveFileName = null;
    maritalFileName = null;
    insuranceFileName = null;

    educationCertificate2 = null;
    idPhoto2 = null;
    armyCertificate2 = null;
    drivingLicense2 = null;
    maritalCertificate2 = null;
    insuranceCard2 = null;

    super.initState();
  }

  String? educationFileName;
  String? idPhotoFileName;
  String? armyFileName;
  String? driveFileName;
  String? maritalFileName;
  String? insuranceFileName;
  @override
  Widget build(BuildContext context) {
    return /*Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomIconContainer(
                isSmallerFont: MediaQuery.of(context).size.shortestSide > 600
                    ? false
                    : true,
                text: "ID Photo",
                image: employee!.idPhoto!.idPhoto?.lastOrNull != null
                    ? isImage(employee!.idPhoto!.idPhoto!.lastOrNull!)
                        ? employee!.idPhoto!.idPhoto?.lastOrNull
                        : 'assets/images/pdf.jpg'
                    : null,
                isEdit: true,
                onPressed: () async {
                  if (employee!.idPhoto!.idPhoto?.lastOrNull != null) {
                    var link =
                        Uri.parse(employee!.idPhoto!.idPhoto!.lastOrNull!);
                    isImage(employee!.idPhoto!.idPhoto!.lastOrNull!)
                        ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return RequestExcalateDialog(
                                isSetting: true,
                                title: "",
                                imageUrl:
                                    employee!.idPhoto!.idPhoto!.lastOrNull!,
                                isExclate: false,
                                isToShowImage: true,
                              );
                            },
                          )
                        : await launchUrl(
                            link,
                            mode: LaunchMode.externalApplication,
                          );
                  }
                },
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: CustomIconContainer(
                isSmallerFont: MediaQuery.of(context).size.shortestSide > 600
                    ? false
                    : true,
                text: "ID Photo",
                image: idPhoto2 != null
                    ? isImage(idPhoto2!)
                        ? idPhoto2
                        : 'assets/images/pdf.jpg'
                    : null,
                isEdit: true,
                onPressed: () {
                  pickAndUploadFile(0);
                },
                isEditIcon: true,
              ),
            )
          ],
        ),
        SizedBox(
          height: 0.02.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomIconContainer(
                isSmallerFont: MediaQuery.of(context).size.shortestSide > 600
                    ? false
                    : true,
                text: 'Education Certificate'.tr,
                isEdit: true,
                image: employee!.educationCertificate!.educationCertificate
                            ?.lastOrNull !=
                        null
                    ? isImage(employee!.educationCertificate!
                            .educationCertificate!.lastOrNull!)
                        ? employee!.educationCertificate!.educationCertificate
                            ?.lastOrNull
                        : 'assets/images/pdf.jpg'
                    : null,
                onPressed: () async {
                  if (employee!.educationCertificate!.educationCertificate
                          ?.lastOrNull !=
                      null) {
                    var link = Uri.parse(
                        employee!.certificate?.certificateFile?.lastOrNull ??
                            '');
                    isImage(employee!
                                .certificate?.certificateFile?.lastOrNull ??
                            '')
                        ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return RequestExcalateDialog(
                                isSetting: true,
                                title: "",
                                imageUrl: employee!.certificate?.certificateFile
                                        ?.lastOrNull ??
                                    '',
                                isExclate: false,
                                isToShowImage: true,
                              );
                            },
                          )
                        : await launchUrl(
                            link,
                            mode: LaunchMode.externalApplication,
                          );
                  }
                },
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: CustomIconContainer(
                isSmallerFont: MediaQuery.of(context).size.shortestSide > 600
                    ? false
                    : true,
                text: 'Education Certificate'.tr,
                isEdit: true,
                image: educationCertificate2 != null
                    ? isImage(educationCertificate2!)
                        ? educationCertificate2
                        : 'assets/images/pdf.jpg'
                    : null,
                onPressed: () {
                  pickAndUploadFile(1);
                },
                isEditIcon: true,
              ),
            )
          ],
        ),
        SizedBox(
          height: 0.02.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomIconContainer(
                isSmallerFont: MediaQuery.of(context).size.shortestSide > 600
                    ? false
                    : true,
                text: "Driving License".tr,
                image: employee!.drivingLicense!.drivingLicense?.lastOrNull !=
                        null
                    ? isImage(employee!
                            .drivingLicense!.drivingLicense!.lastOrNull!)
                        ? employee!.drivingLicense!.drivingLicense?.lastOrNull
                        : 'assets/images/pdf.jpg'
                    : null,
                isEdit: true,
                onPressed: () async {
                  if (employee!.drivingLicense!.drivingLicense?.lastOrNull !=
                      null) {
                    var link = Uri.parse(
                        employee!.drivingLicense!.drivingLicense!.lastOrNull!);
                    isImage(employee!
                            .drivingLicense!.drivingLicense!.lastOrNull!)
                        ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return RequestExcalateDialog(
                                isSetting: true,
                                title: "",
                                imageUrl:
                                    employee!.idPhoto!.idPhoto!.lastOrNull!,
                                isExclate: false,
                                isToShowImage: true,
                              );
                            },
                          )
                        : await launchUrl(
                            link,
                            mode: LaunchMode.externalApplication,
                          );
                  }
                },
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: CustomIconContainer(
                isSmallerFont: MediaQuery.of(context).size.shortestSide > 600
                    ? false
                    : true,
                text: "Driving License".tr,
                image: drivingLicense2 != null
                    ? isImage(drivingLicense2!)
                        ? drivingLicense2
                        : 'assets/images/pdf.jpg'
                    : null,
                isEdit: true,
                onPressed: () {
                  pickAndUploadFile(2);
                },
                isEditIcon: true,
              ),
            )
          ],
        ),
        SizedBox(
          height: 0.02.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomIconContainer(
                isSmallerFont: MediaQuery.of(context).size.shortestSide > 600
                    ? false
                    : true,
                text: "Marital Service Certificate".tr,
                image: employee!.armyCertificate!.armyCertificate?.lastOrNull !=
                        null
                    ? isImage(employee!
                            .armyCertificate!.armyCertificate!.lastOrNull!)
                        ? employee!
                            .armyCertificate!.armyCertificate?.lastOrNull!
                        : 'assets/images/pdf.jpg'
                    : null,
                isEdit: true,
                onPressed: () async {
                  if (employee!.armyCertificate!.armyCertificate?.lastOrNull !=
                      null) {
                    var link = Uri.parse(employee!
                        .armyCertificate!.armyCertificate!.lastOrNull!);
                    isImage(employee!
                            .armyCertificate!.armyCertificate!.lastOrNull!)
                        ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return RequestExcalateDialog(
                                isSetting: true,
                                title: "",
                                imageUrl: employee!.maritalCertificate!
                                    .maritalCertificate!.lastOrNull!,
                                isExclate: false,
                                isToShowImage: true,
                              );
                            },
                          )
                        : await launchUrl(
                            link,
                            mode: LaunchMode.externalApplication,
                          );
                  }
                },
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: CustomIconContainer(
                isSmallerFont: MediaQuery.of(context).size.shortestSide > 600
                    ? false
                    : true,
                text: "Marital Service Certificate".tr,
                image: armyCertificate2 != null
                    ? isImage(armyCertificate2!)
                        ? armyCertificate2
                        : 'assets/images/pdf.jpg'
                    : null,
                isEdit: true,
                onPressed: () {
                  pickAndUploadFile(3);
                },
                isEditIcon: true,
              ),
            )
          ],
        ),
        SizedBox(
          height: 0.02.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomIconContainer(
                isSmallerFont: MediaQuery.of(context).size.shortestSide > 600
                    ? false
                    : true,
                text: "Life Insurance".tr,
                image: employee!.insuranceCard!.insuranceCard?.lastOrNull !=
                        null
                    ? isImage(
                            employee!.insuranceCard!.insuranceCard!.lastOrNull!)
                        ? employee!.insuranceCard!.insuranceCard?.lastOrNull!
                        : 'assets/images/pdf.jpg'
                    : null,
                isEdit: true,
                onPressed: () async {
                  if (employee!.insuranceCard!.insuranceCard?.lastOrNull !=
                      null) {
                    var link = Uri.parse(
                        employee!.insuranceCard!.insuranceCard!.lastOrNull!);
                    isImage(employee!.insuranceCard!.insuranceCard!.lastOrNull!)
                        ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return RequestExcalateDialog(
                                isSetting: true,
                                title: "",
                                imageUrl: employee!
                                    .insuranceCard!.insuranceCard!.lastOrNull!,
                                isExclate: false,
                                isToShowImage: true,
                              );
                            },
                          )
                        : await launchUrl(
                            link,
                            mode: LaunchMode.externalApplication,
                          );
                  }
                },
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: CustomIconContainer(
                isSmallerFont: MediaQuery.of(context).size.shortestSide > 600
                    ? false
                    : true,
                text: "Life Insurance".tr,
                image: insuranceCard2 != null
                    ? isImage(insuranceCard2!)
                        ? insuranceCard2
                        : 'assets/images/pdf.jpg'
                    : null,
                isEdit: true,
                onPressed: () {
                  pickAndUploadFile(4);
                },
                isEditIcon: true,
              ),
            )
          ],
        ),
        SizedBox(
          height: 0.02.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CustomIconContainer(
                isSmallerFont: MediaQuery.of(context).size.shortestSide > 600
                    ? false
                    : true,
                text: "Marital Certificate".tr,
                image: employee!.maritalCertificate!.maritalCertificate
                            ?.lastOrNull !=
                        null
                    ? isImage(employee!.maritalCertificate!.maritalCertificate!
                            .lastOrNull!)
                        ? employee!
                            .maritalCertificate!.maritalCertificate!.lastOrNull!
                        : 'assets/images/pdf.jpg'
                    : null,
                isEdit: true,
                onPressed: () async {
                  if (employee!
                          .maritalCertificate!.maritalCertificate?.lastOrNull !=
                      null) {
                    var link = Uri.parse(employee!
                        .maritalCertificate!.maritalCertificate!.lastOrNull!);
                    isImage(employee!.maritalCertificate!.maritalCertificate!
                            .lastOrNull!)
                        ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return RequestExcalateDialog(
                                isSetting: true,
                                title: "",
                                imageUrl: employee!.maritalCertificate!
                                    .maritalCertificate!.lastOrNull!,
                                isExclate: false,
                                isToShowImage: true,
                              );
                            },
                          )
                        : await launchUrl(
                            link,
                            mode: LaunchMode.externalApplication,
                          );
                  }
                },
              ),
            ),
            SizedBox(width: spaceWidth),
            Expanded(
              child: CustomIconContainer(
                isSmallerFont: MediaQuery.of(context).size.shortestSide > 600
                    ? false
                    : true,
                text: "Marital Certificate".tr,
                image: maritalCertificate2 != null
                    ? isImage(maritalCertificate2!)
                        ? maritalCertificate2
                        : 'assets/images/pdf.jpg'
                    : null,
                isEdit: true,
                onPressed: () {
                  pickAndUploadFile(5);
                },
                isEditIcon: true,
              ),
            )
          ],
        ),
        SizedBox(
          height: 0.02.h,
        ),
      ],
    );*/Container();
  }
}

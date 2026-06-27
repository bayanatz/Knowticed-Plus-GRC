import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/additionalInformation_container.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:file_picker/file_picker.dart';
import 'package:demo_app/core/helper/employees/presentation/ui/pages/add_new_employee_view.dart';

// ignore: must_be_immutable
class AdditionInformations extends StatefulWidget {
  AdditionInformations({
    super.key,
    required this.additionalInfo,
    required this.addInfoState,
    required this.name,
    this.isPreview = false,
  });
  double additionalInfo;
  ValueChanged<double> addInfoState;
  bool isPreview;
  String name;
  @override
  State<AdditionInformations> createState() => _AdditionInformationsState();
}

String? educationFileName;
String? idPhotoFileName;
String? armyFileName;
String? driveFileName;
String? maritalFileName;
String? insuranceFileName;
String? license;
String? marital;
String? insuranceCard;

class _AdditionInformationsState extends State<AdditionInformations> {
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
  String getFileNameFromPath(String path) {
    List<String> splitedPath = path.split('/');
    String fileName = splitedPath.last;
    return fileName;
  }

  bool isImage(String filePath) {
    bool flag = false;
    for (String imageExtention in imageExtentions) {
      if (filePath.contains(imageExtention)) {
        return true;
      }
    }
    return flag;
  }

  Future<void> pickAndUploadFile(int index, String name) async {
    FilePickerResult? pickedPdf = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (pickedPdf != null) {
      showLoadingIndicator();
      final file = File(pickedPdf.files.single.path!);
      String filePath = pickedPdf.files.single.path!;
      setState(() {
        index == 0
            ? educationFileName = getFileNameFromPath(filePath)
            : index == 1
                ? idPhotoFileName = getFileNameFromPath(filePath)
                : index == 2
                    ? armyFileName = getFileNameFromPath(filePath)
                    : index == 3
                        ? driveFileName = getFileNameFromPath(filePath)
                        : index == 4
                            ? maritalFileName = getFileNameFromPath(filePath)
                            : insuranceFileName = getFileNameFromPath(filePath);
      });

      if (isImage(filePath)) {
        Reference ref = FirebaseStorage.instance.ref().child(
            'employee/$name/${index == 0 ? "education_certificate_photo" : index == 1 ? "id_photo" : index == 2 ? "army_certificate_photo" : index == 3 ? "driving_license_photo" : index == 4 ? "marital_certificate_photo" : "insurance_card_photo"}_${DateTime.now()}.png');
        final metadata = SettableMetadata(contentType: 'image/jpeg');
        final TaskSnapshot task = await ref.putFile(file, metadata);
        index == 0
            ? educationCertificate = await task.ref.getDownloadURL()
            : index == 1
                ? idPhoto = await task.ref.getDownloadURL()
                : index == 2
                    ? armyCertificate = await task.ref.getDownloadURL()
                    : index == 3
                        ? drivingLicense = await task.ref.getDownloadURL()
                        : index == 4
                            ? maritalCertificate =
                                await task.ref.getDownloadURL()
                            : insuranceCard = await task.ref.getDownloadURL();
      } else {
        final Reference storageRef = FirebaseStorage.instance.ref().child(
            'employee/$name/${index == 0 ? "education_certificate_file" : index == 1 ? "id_file" : index == 2 ? "army_certificate_file" : index == 3 ? "driving_license_file" : index == 4 ? "marital_certificate_file" : "insurance_card_file"}_${DateTime.now()}.pdf');
        final metadata = SettableMetadata(contentType: 'application/pdf');
        final TaskSnapshot task = await storageRef.putFile(file, metadata);
        index == 0
            ? educationCertificate = await task.ref.getDownloadURL()
            : index == 1
                ? idPhoto = await task.ref.getDownloadURL()
                : index == 2
                    ? armyCertificate = await task.ref.getDownloadURL()
                    : index == 3
                        ? drivingLicense = await task.ref.getDownloadURL()
                        : index == 4
                            ? maritalCertificate =
                                await task.ref.getDownloadURL()
                            : insuranceCard = await task.ref.getDownloadURL();
      }
      setState(() {});
      hideLoadingIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AdditionInformationContainer(
            title: educationFileName ?? "Education Certificate",
            onPressed: () async {
              await pickAndUploadFile(0, widget.name);
              setState(() {
                widget.additionalInfo += 1 / 2;
                widget.addInfoState(widget.additionalInfo);
              });
            }),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.025.h),
          child: AdditionInformationContainer(
              title: idPhotoFileName ?? "ID Photo",
              onPressed: () async {
                await pickAndUploadFile(1, widget.name);
                setState(() {
                  widget.additionalInfo += 1 / 2;
                  widget.addInfoState(widget.additionalInfo);
                });
              }),
        ),
        AdditionInformationContainer(
            title: armyFileName ?? "Army Certificate",
            onPressed: () async {
              await pickAndUploadFile(2, widget.name);
              setState(() {
                widget.additionalInfo += 1 / 2;
                widget.addInfoState(widget.additionalInfo);
              });
            }),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.025.h),
          child: AdditionInformationContainer(
              title: driveFileName ?? "Driving License",
              onPressed: () async {
                await pickAndUploadFile(3, widget.name);
                setState(() {
                  widget.additionalInfo += 1 / 2;
                  widget.addInfoState(widget.additionalInfo);
                });
              }),
        ),
        AdditionInformationContainer(
            title: maritalFileName ?? "Marital Certificate",
            onPressed: () async {
              await pickAndUploadFile(4, widget.name);
              setState(() {
                widget.additionalInfo += 1 / 2;
                widget.addInfoState(widget.additionalInfo);
              });
            }),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.025.h),
          child: AdditionInformationContainer(
              title: insuranceFileName ?? "Insurance Card",
              onPressed: () async {
                await pickAndUploadFile(5, widget.name);
                setState(() {
                  widget.additionalInfo += 1 / 2;
                  widget.addInfoState(widget.additionalInfo);
                });
              }),
        ),
      ],
    );
  }
}

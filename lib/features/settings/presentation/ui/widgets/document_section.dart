///*************************** FILE INFO **********************************///
/// Purpose: A core widget that displays the additional info documents and images.
/// Author: Mohamed Elrashidy
/// Refactored At: 13/11/2024
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_icon_container.dart';
import 'package:demo_app/core/theme/app_font_size.dart';

class DocumentSection extends StatefulWidget {
  final String? educationCertificateImage;
  final Function()? educationCertificateOnPressed;
  final String? idPhotoImage;
  final Function()? idPhotoOnPressed;
  final String? drivingLicenseImage;
  final Function()? drivingLicenseOnPressed;
  final String? maritalServiceProofImage;
  final Function()? maritalServiceProofOnPressed;
  final String? lifeInsuranceCardImage;
  final Function()? lifeInsuranceCardOnPressed;
  final String? maritalCertificateImage;
  final Function()? maritalCertificateOnPressed;

  const DocumentSection({
    Key? key,
    this.educationCertificateImage,
    this.educationCertificateOnPressed,
    this.idPhotoImage,
    this.idPhotoOnPressed,
    this.drivingLicenseImage,
    this.drivingLicenseOnPressed,
    this.maritalServiceProofImage,
    this.maritalServiceProofOnPressed,
    this.lifeInsuranceCardImage,
    this.lifeInsuranceCardOnPressed,
    this.maritalCertificateImage,
    this.maritalCertificateOnPressed,
  }) : super(key: key);

  @override
  _DocumentSectionState createState() => _DocumentSectionState();
}

class _DocumentSectionState extends State<DocumentSection> {
  @override
  Widget build(BuildContext context) {
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double space = 0.02.h;
    return isVertical
        ? Column(
            children: [
              Container(
                width: double.infinity,
                child: CustomIconContainer(
                  text: 'Education Certificate'.tr,
                  image: widget.educationCertificateImage,
                  onPressed: widget.educationCertificateOnPressed,
                ),
              ),
              SizedBox(height: space),
              Container(
                width: double.infinity,
                child: CustomIconContainer(
                  text: 'ID Photo'.tr,
                  image: widget.idPhotoImage,
                  onPressed: widget.idPhotoOnPressed,
                ),
              ),
              SizedBox(height: space),
              Container(
                width: double.infinity,
                child: CustomIconContainer(
                  text: 'Driving License'.tr,
                  image: widget.drivingLicenseImage,
                  onPressed: widget.drivingLicenseOnPressed,
                ),
              ),
              SizedBox(
                height: space,
              ),
              Container(
                width: double.infinity,
                child: CustomIconContainer(
                  text: 'Martial Service Proof'.tr,
                  image: widget.maritalServiceProofImage,
                  onPressed: widget.maritalServiceProofOnPressed,
                ),
              ),
              SizedBox(
                height: space,
              ),
              Container(
                width: double.infinity,
                child: CustomIconContainer(
                  text: 'Life Insurance Card'.tr,
                  image: widget.lifeInsuranceCardImage,
                  onPressed: widget.lifeInsuranceCardOnPressed,
                ),
              ),
              SizedBox(height: space),
              Container(
                width: double.infinity,
                child: CustomIconContainer(
                  text: 'Marital Certificate'.tr,
                  image: widget.maritalCertificateImage,
                  onPressed: widget.maritalCertificateOnPressed,
                ),
              ),
              SizedBox(
                height: space,
              ),
            ],
          )
        : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right:
                            Get.locale.toString().contains('en') ? 0.02.h : 0,
                        left: Get.locale.toString().contains('ar') ? 0.02.h : 0,
                      ),
                      child: CustomIconContainer(
                        text: 'Education Certificate'.tr,
                        image: widget.educationCertificateImage,
                        onPressed: widget.educationCertificateOnPressed,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomIconContainer(
                      text: 'ID Photo'.tr,
                      image: widget.idPhotoImage,
                      onPressed: widget.idPhotoOnPressed,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 0.03.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right:
                            Get.locale.toString().contains('en') ? 0.02.h : 0,
                        left: Get.locale.toString().contains('ar') ? 0.02.h : 0,
                      ),
                      child: CustomIconContainer(
                        text: 'Driving License'.tr,
                        image: widget.drivingLicenseImage,
                        onPressed: widget.drivingLicenseOnPressed,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomIconContainer(
                      text: 'Martial Service Proof'.tr,
                      image: widget.maritalServiceProofImage,
                      onPressed: widget.maritalServiceProofOnPressed,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 0.03.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right:
                            Get.locale.toString().contains('en') ? 0.02.h : 0,
                        left: Get.locale.toString().contains('ar') ? 0.02.h : 0,
                      ),
                      child: CustomIconContainer(
                        text: 'Life Insurance Card'.tr,
                        image: widget.lifeInsuranceCardImage,
                        onPressed: widget.lifeInsuranceCardOnPressed,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomIconContainer(
                      text: 'Marital Certificate'.tr,
                      image: widget.maritalCertificateImage,
                      onPressed: widget.maritalCertificateOnPressed,
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}

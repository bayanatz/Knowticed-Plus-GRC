import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:demo_app/core/custom/loading.dart';
///************************ FILE INFO ************************///
/// Class Name: AddNewEmployeeController
/// Purpose: Controller for add new employee
/// Author: Mohammad Elrashidy
/// Created At: 6/11/2024
class AddNewEmployeeController extends GetxController{
  final ImagePicker picker = ImagePicker();
  // indicator controllers
  double personalInfoValue = 0;
  double additionalInfo = 0;
  double assetsUp = 0;
  double healthInsuranceValue = 0;
  double preview = 0;
  double psitionDetailsValue = 0;





  // personal info text controllers
  TextEditingController firstName = TextEditingController();
  TextEditingController firstNameInArabic = TextEditingController();
  TextEditingController middleName = TextEditingController();
  TextEditingController middleNameInArabic = TextEditingController();
  TextEditingController birthDate = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController lastNameInArabic = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController province = TextEditingController();
  TextEditingController nationalId = TextEditingController();
  TextEditingController passportNumber = TextEditingController();
  TextEditingController passportDate = TextEditingController();
  TextEditingController nationalDate = TextEditingController();
  TextEditingController postal = TextEditingController();

  String? imageUrl;

  File? _image;
  Future<void> uploadImage(String name) async {
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    showLoadingIndicator();
    _image = File(pickedFile!.path);
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('/employee/$name/personal_photo_${DateTime.now()}.jpeg');
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    UploadTask uploadTask = ref.putFile(_image!, metadata);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

    imageUrl = await taskSnapshot.ref.getDownloadURL();

    hideLoadingIndicator();
    update();
  }

}
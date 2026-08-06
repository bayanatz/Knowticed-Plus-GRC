import 'package:get/get.dart';

abstract class ImageSelector {
  static String getUserImage({required String? imagePath, required String? gender})
  {
    String userImagePath;
    if (imagePath != null) {
      userImagePath =imagePath;
    } else {
      if (gender == 'female')
        userImagePath = 'assets/icons_assets/main_icons_assets/female_avatar.png';
      else {
        userImagePath = 'assets/icons_assets/main_icons_assets/male_avatar.png';
      }
    }
    return userImagePath;
  }
}

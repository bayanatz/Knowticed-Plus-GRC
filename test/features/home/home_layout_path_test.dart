/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_layout_path_test.dart
/// Purpose: The Home layout collection is `Home_Layouts` (no space), inside
///          the Settings module — it is where the schema puts it.
/// Created At: 23/10/2026
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';

void main() {
  test('the Home layout lives at Modules/settings/Home_Layouts', () {
    ApiConstants.baseUri = 'Demo/75440689';
    expect(ApiConstants.homeLayout,
        'Demo/75440689/Modules/settings/Home_Layouts');
  });
}

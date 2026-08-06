import 'package:grc_module/core/network/api_constants.dart';

String getBaseUrl(String path) {
 // print("base Uri is ${ApiConstants.baseUri}");
  return "${ApiConstants.baseUri}/$path";
}


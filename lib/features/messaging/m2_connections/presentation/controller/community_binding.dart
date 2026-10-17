// Date: 1/9/2024
// By:  Nada Mohammed ,Mohamed Ashraf
// Last update: 1/9/2024
// Objectives: This file is responsible for providing the community binding used in the community feature.
import 'package:get/get.dart';

import 'package:grc_module/features/messaging/m1_chat/presentation/controller/message_controller.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/media_controller.dart';
import 'package:grc_module/features/messaging/m2_connections/presentation/controller/community_controller.dart';

class CommunityBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MessageCubit());

    Get.lazyPut(() => CommunityCubit());
    //Get.lazyPut(() => GroupsController());
    Get.lazyPut(() => MediaCubit(), fenix: true);
  }
}

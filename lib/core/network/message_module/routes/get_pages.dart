// Date: 5/8/2024
// By: Mohamed Ashraf, Youssef Ashraf, Nada Mohammed
// Last update: 5/9/2024
// Objectives: This file is responsible for providing the get pages for the app.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import 'package:grc_module/features/messaging/m1_chat/data/models/message/doc_message_model.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/message/message_model.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/message/poll_message_model.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/pages/all_chat_view_tablet.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/pages/all_chats_view_mobile.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/widgets/confirm_caption_view.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/widgets/doc_view.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/widgets/image_interact_view.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/widgets/poll_details_view.dart';
import 'package:grc_module/features/messaging/m3_groups/presentation/ui/pages/mobile/mobile_group_chat_profile_view.dart';
import 'package:grc_module/features/messaging/m3_groups/presentation/ui/pages/mobile/mobile_single_chat_profile_view.dart';
import 'package:grc_module/features/messaging/m3_groups/presentation/ui/pages/tablet/create_group_page_tablet.dart';
import 'package:grc_module/features/messaging/m2_connections/presentation/controller/community_binding.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/messages_bindings.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/pages/starred_messages_view.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/pages/maps_view.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/media/media_model.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/media_binding.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/ui/pages/mobile_media_view.dart';
import 'package:grc_module/core/network/message_module/routes/app_routes.dart';

abstract class AppPages {
  static const initial = Routes.tabBar;

  static final routes = [
    // Routes.message removed — mobile chat is now opened via Navigator.push
    // with ChatMobileView receiving its cubits by constructor (pure Bloc, §3).
    GetPage(
        name: Routes.groupChatProfile,
        page: () => const MobileGroupChatProfileView(),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(
          milliseconds: 400,
        ),
        binding: MessagesBindings()),
    GetPage(
      name: Routes.singleChatProfile,
      page: () => const MobileSingleChatProfileView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
    ),
    GetPage(
      name: Routes.starredMessages,
      page: () => StarredMessagesView(
        title: Get.arguments?['title'] as String,
        imageUrl: Get.arguments?['imageUrl'] as String?,
      ),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      binding: MessagesBindings(),
    ),
    GetPage(
      name: Routes.confirmCaptionScreen,
      page: () => ConfirmCaptionView(
        files: Get.arguments?['files'] as List<PlatformFile>,
      ),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
    ),
    GetPage(
      name: Routes.media,
      page: () => MobileMediaView(
        model: Get.arguments!['media'] as MediaModel,
        recieverName: Get.arguments!['recieverName'] as String,
      ),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      binding: MediaBindings(),
    ),

    GetPage(
      name: Routes.maps,
      page: () => MapsView(
        isSelecting: Get.arguments['isSelecting'] as bool,
      ),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 350,
      ),
    ),
    GetPage(
      name: Routes.imageInteract,
      page: () => ImageInteractView(
        image: Get.arguments['image'] as File,
      ),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(
        milliseconds: 430,
      ),
    ),
    GetPage(
      name: Routes.pollDetails,
      page: () => PollDetailsView(
        model: Get.arguments['pollModel'] as PollMessageModel,
      ),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
    ),
    GetPage(
      name: Routes.docView,
      page: () => DocView(
        model: Get.arguments['docMessageModel'] as DocMessageModel,
      ),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
    ),
    GetPage(
      name: Routes.allChatsViewMobile,
      page: () => AllChatsViewMobile(
        message: Get.arguments['forwardMessage'] as List<MessageModel>,
      ),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      binding: CommunityBinding(),
    ),
    GetPage(
      name: Routes.allChatsViewTablet,
      page: () => AllChatViewTablet(
        message: Get.arguments['forwardMessage'] as List<MessageModel>,
      ),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      binding: CommunityBinding(),
    ),
    //***************** Group ****************
    GetPage(
      name: Routes.createGroupPageMobile,
      page: () => CreateGroupPageTablet(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      binding: CommunityBinding(),
    ),
    GetPage(
      name: Routes.createGroupPageTablet,
      page: () => CreateGroupPageTablet(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(
        milliseconds: 400,
      ),
      binding: CommunityBinding(),
    ),
  ];
}

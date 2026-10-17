/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: app_assets.dart
/// Purpose: Declares `AppAssets`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

// Date: 6/8/2024
// By: Mohamed Ashraf, Youssef Ashraf, Nada Mohammed
// Last update: 4/9/2024
// Objectives: This file is responsible for providing the app assets.

// assets
abstract class AppAssets {
  //***************************** IMAGES ***************************************
  // --------------------- General ---------------------

  static const String pdf =
      'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
  static const String xls =
      'assets/icons_assets/messaging_assets/img_file_xls.png';

  // --------------------- Wallpaper ---------------------

  //--------------------- Community ---------------------
  static const String profile =
      'assets/icons_assets/main_icons_assets/ic_user_group.svg';

  //****************************************************************************

//******************************* VECTORS ************************************

  static const String add =
      'assets/icons_assets/main_icons_assets/ic_action_plus.svg';
  static const String minusCircle =
      'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg';
  static const String filter =
      'assets/icons_assets/main_icons_assets/ic_action_filter.svg';
  static const String arrowDown =
      'assets/icons_assets/main_icons_assets/ic_nav_chevron_down.svg';
  static const String arrowForward =
      'assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg';
  static const String mobileArrowBack =
      'assets/icons_assets/messaging_assets/ic_nav_chevron_left_bold.svg';

  static const String clock =
      'assets/icons_assets/main_icons_assets/ic_time_clock.svg';

  static const String link =
      'assets/icons_assets/main_icons_assets/ic_action_attach_blue.svg';
  static const String play =
      'assets/icons_assets/messaging_assets/ic_media_play.svg';
  static const String pause =
      'assets/icons_assets/messaging_assets/ic_media_pause.svg';
  static const String video =
      'assets/icons_assets/messaging_assets/ic_video.svg';

  static const String camera =
      'assets/icons_assets/main_icons_assets/ic_media_camera_teal.svg';

  /// ADDED 2/9/2026. The composer icons in the MESBAH Figma (MESSAGES page)
  /// come from the watermark set, not the messaging set — [camera] and [mic]
  /// above are the older, heavier glyphs and stay where they are used.
  static const String cameraWatermark =
      'assets/icons_assets/main_icons_assets/ic_media_camera_teal.svg';
  static const String micWatermark =
      'assets/icons_assets/main_icons_assets/ic_media_microphone.svg';
  static const String galleryWhite =
      'assets/icons_assets/messaging_assets/ic_gallery_image_white.svg';

  static const String close =
      'assets/icons_assets/main_icons_assets/ic_action_cancel.svg';
  static const String document =
      'assets/icons_assets/messaging_assets/ic_document.svg';
  static const String galleryImage =
      'assets/icons_assets/messaging_assets/ic_media_image_edit.svg';
  static const String audioMsg =
      'assets/icons_assets/messaging_assets/ic_media_audio_message.svg';

  static const String contactImage =
      'assets/icons_assets/messaging_assets/ic_user_contact_book.svg';
  static const String poolImage =
      'assets/icons_assets/messaging_assets/ic_comms_poll.svg';

  static const String copy =
      'assets/icons_assets/main_icons_assets/ic_action_copy.svg';
  static const String forward =
      'assets/icons_assets/messaging_assets/ic_action_forward.svg';
  static const String reply =
      'assets/icons_assets/main_icons_assets/ic_nav_back_curved.svg';
  static const String star = 'assets/icons_assets/messaging_assets/ic_star.svg';
  static const String pin =
      'assets/icons_assets/messaging_assets/ic_pushpin.svg';
  static const String trash =
      'assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg';
  static const String search2 =
      'assets/icons_assets/main_icons_assets/ic_action_search_thin.svg';
  static const String reminder =
      'assets/icons_assets/messaging_assets/ic_carbon_reminder.svg';

  static const String group =
      'assets/icons_assets/main_icons_assets/ic_group_people_white.svg';
  static const String people =
      'assets/icons_assets/messaging_assets/ic_people.svg';
  static const String person =
      'assets/icons_assets/main_icons_assets/ic_user_profile.svg';

  static const String emptyNotification =
      'assets/icons_assets/main_icons_assets/ic_comms_notification_bell.svg';
  static const String location =
      'assets/icons_assets/messaging_assets/ic_location_pin_outline.svg';
  static const String message =
      'assets/icons_assets/main_icons_assets/ic_comms_chat_double.svg';
  static const String mic =
      'assets/icons_assets/main_icons_assets/ic_media_microphone.svg';
  static const String more =
      'assets/icons_assets/main_icons_assets/ic_nav_more_vertical.svg';
  static const String poll = 'assets/icons_assets/messaging_assets/ic_poll.svg';
  static const String scroll =
      'assets/icons_assets/messaging_assets/ic_nav_scroll_down.svg';
  static const String search =
      'assets/icons_assets/main_icons_assets/ic_action_search.svg';

  static const String send =
      'assets/icons_assets/main_icons_assets/ic_action_send.svg';
  static const String happyFace =
      'assets/icons_assets/messaging_assets/ic_happy_face.svg';
  static const String sort =
      'assets/icons_assets/main_icons_assets/ic_action_sort.svg';

// --------------------- Emotions ----------------------------------

  static const Map<String, String> emotions = {
    'clap': 'assets/icons_assets/messaging_assets/ic_reaction_thanks.svg',
    'like': 'assets/icons_assets/main_icons_assets/ic_reaction_like.svg',
    'love': 'assets/icons_assets/messaging_assets/ic_reaction_love.svg',
    'sad': 'assets/icons_assets/messaging_assets/ic_reaction_sad.svg',
    'wow': 'assets/icons_assets/main_icons_assets/ic_reaction_wow.svg',
    'xd': 'assets/icons_assets/messaging_assets/ic_reaction_laugh.svg',
  };

  //****************************************************************************

  //***************************** LOTTIE FILES *********************************
  static const String trashGif =
      'assets/lottie_assets/main_lottie_assets/lot_action_delete.json';
  static const String media =
      'assets/lottie_assets/main_lottie_assets/lot_media_loading.json';
  static const String links =
      'assets/lottie_assets/messaging_lottie_assets/lot_empty_links.json';
  static const String docs =
      'assets/lottie_assets/messaging_lottie_assets/lot_empty_documents.json';
  static const String directMessages =
      'assets/lottie_assets/messaging_lottie_assets/lot_empty_direct_messages.json';
  static const String groups =
      'assets/lottie_assets/messaging_lottie_assets/lot_empty_groups.json';

  //****************************************************************************
}

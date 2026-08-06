// Date: 6/8/2024
// By: Mohamed Ashraf, Youssef Ashraf, Nada Mohammed
// Last update: 5/9/2024
// Objectives: This file is responsible for providing the routes of the app.

        abstract class Routes {
  // Home
  static const tabBar = '/tabBar';

  static const home = '/home';



  // Message
  static const message = '/message';
  static const pollDetails = '/message/pollDetails';
  static const docView = '/message/docView';

  static const managementChatProfile = '/message/managementChatProfile';
  static const groupChatProfile = '/message/groupChatProfile';
  static const singleChatProfile = '/message/singleChatProfile';
  static const starredMessages = '/message/starredMessages';

  static const confirmCaptionScreen = '/message/confirmCaptionScreen';
  static const imageInteract = '/message/imageInteract';

  static const media = '/message/chatProfile/media';
  static const directMessage = '/directMessage';
  static const wallpaperCategory = '/wallpaperCategory';
  static const wallpaperDetails = '/wallpaper/wallpaperDetails';
  static const maps = '/maps';
  static const allChatsViewMobile = '/message/allChatsViewMobile';
  static const allChatsViewTablet = '/message/allChatsViewTablet';

  // emergency contact
  static const emergencyContact = '/profileMenuPage/emergencyContact';
  static const editEmergencyContact =
      '/profileMenuPage/emergencyContact/editEmergencyContact';

  // Sort
  static const sortPage = '/sortPage';

  // image picker
  static const imageOptionsDialog = '/imageOptionsDialog';


  //Customer Support
  static const customerSupport = '/customerSupport';
  static const history = '/history';

  // community - filter
  static const communityFilterPage = '/communityFilterPage';

  // community - groups
  static const createGroupPageMobile = '/createGroupPageMobile';
  static const createGroupPageTablet = '/createGroupPageTablet';


  // community - sort
  static const communitySortPage = '/communitySortPage';




}

/// Module: messaging/m1_chat
///
///*************************** FILE INFO ****************************///
/// File Name: message_controller.dart
/// Description: `MessageState` state, `MessageInitial`, `MessageCubit` cubit (state management).
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

// Date: 6/8/2024
// By: Nada Mohammed , Youssef Ashraf
// Last update: 28/8/2024
// Objectives: This file is responsible for providing a cubit for the messages in the direct messaging screen.

import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_time_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart' hide PermissionStatus;
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:knowticed_plus/core/helper/extensions.dart'
    hide ContextExtension;
import 'package:knowticed_plus/features/messaging/m1_chat/domain/enum/reacts.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:pdfx/pdfx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:knowticed_plus/core/routes/app_routes.dart';
import 'package:knowticed_plus/features/messaging/helpers/services/audio_record_service.dart';
import 'package:knowticed_plus/features/messaging/helpers/constants/messaging_assets.dart';
import 'package:knowticed_plus/core/helper/get_dialog_helper.dart';
import 'package:knowticed_plus/core/helper/share_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/message/audio_message_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/message/doc_message_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/message/message_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/message/poll_message_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/message/video_message_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/domain/entity/message_entity.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/ui/pages/tablet/tablet_group_chat_profile_view.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/data/models/member_model.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/community_controller.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/data/models/legacy_group_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/location_message_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/chat/chat_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/chat_enums.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/date_time_helper.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/app_services/image_picker_cubit.dart';

part 'message_controller/message_loaded.dart';
part 'message_controller/message_cubit_methods.dart';
part 'message_controller/message_cubit_methods_2.dart';

// State classes
abstract class MessageState {}

class MessageInitial extends MessageState {}

// Cubit
class MessageCubit extends Cubit<MessageState> {
  /// Public [emit] for this cubit's extension / part files and widgets
  /// ([emit] itself is protected).
  void emitState(MessageState state) => emit(state);

  MessageCubit() : super(MessageInitial());

  OverlayEntry? overlayEntry;
  late TabController tabController;
  late TabController tabGroupController;

  final scrollController = ItemScrollController();
  final scrollPositionsListener = ItemPositionsListener.create();
  final scrollOffsetListener = ScrollOffsetListener.create();
  final msgMenuScrollController = ScrollController();
  final messageFocusNode = FocusNode();
  final searchMemberController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController groupDescriptionController =
      TextEditingController(text: '');
  final TextEditingController groupNameController =
      TextEditingController(text: '');
  final TextEditingController questionController = TextEditingController();

  final stopwatch = Stopwatch();
  final SwiperController swiperController = SwiperController();
  final MapController mapController = MapController();

  Duration newRecordDuration = Duration.zero;
  int firstVisibleIndex = 0;
  int speedIndex = 0;

  List<String> groupInfoTabs = [S.current.member];
  List<String> communityTabs = [
    S.current.all,
    S.current.design,
    S.current.department_marketing
  ];

  final muteNotificationsDurationValues = [
    DurationValues.hours_8,
    DurationValues.week_1,
    DurationValues.always,
  ];

  final disappearingMessagingDurationValues = [
    DurationValues.hours_24,
    DurationValues.days_7,
    DurationValues.days_90,
    DurationValues.always,
    DurationValues.off,
  ];

  List<Speeds> speeds = [
    Speeds.speed_1,
    Speeds.speed_1_0_5,
    Speeds.speed_2,
  ];

  ChatModel? _chatModel;
  ChatModel? get chatModel => _chatModel;

  int? _firstUnreadIndex;
  int? get firstUnreadIndex => _firstUnreadIndex;

  bool _isEmojiPickerVisible = false;
  bool _isRecording = false;
  int _ellapsedSeconds = 0;
  int _ellapsedMinutes = 0;
  AudioMessageModel? _currentlyPlayingAudioModel;
  DurationValues? _duration;
  final List<bool> _clearOption = [false, false];
  bool? _reportContact;
  bool? _blockContact;
  bool _multibleChoices = false;
  List<TextEditingController> _pollOptions = [
    TextEditingController(),
    TextEditingController(),
  ];
  List<TextEditingController> _captionControllers = [];
  final int _swiperIndex = 0;
  double _bufferedVideo = 0.0;
  bool _isPlaying = false;
  String _videoDuration = '';
  bool _progressShown = true;
  final bool _slideChanging = false;
  MessageEntity? _editMessageModel;
  MessageModel? _replyMessageModel;
  int? _replyScrollIndex = -1;
  bool _reactVisible = false;
  List<bool> _forwardCheckBoxes = [];
  List<MessageModel> _selectedForwardMessages = [];
  bool _selectMessages = false;
  LocationMessageModel? _pickedLocation;
  String _selectedAllTab = S.current.about;
  final Map<int, String> _selectedRole = {};

  void initialize(TickerProvider vsync) async {
    tabGroupController =
        TabController(vsync: vsync, length: groupInfoTabs.length);
    tabGroupController.addListener(() {
      _selectedAllTab = groupInfoTabs[tabGroupController.index];
      _emitLoadedState();
    });

    await AudioRecordService.initializeController();
    tabController = TabController(
      length: communityTabs.length,
      vsync: vsync,
    );

    _emitLoadedState();
  }

  void setChatModel(ChatModel chat) {
    _chatModel = chat;
    _emitLoadedState();
  }

  ///called when user exit the messages view
  void resetResources() {
    if (_firstUnreadIndex != null) {
      _firstUnreadIndex = null;
    }
    stopAudios();
    if (overlayEntry != null && overlayEntry!.mounted) {
      overlayEntry!.remove();
      overlayEntry!.dispose();
    }
  }

  void setRole(int index, String role) {
    _selectedRole[index] = role;
    _emitLoadedState();
  }

  void getFirstUnreadIndex() {
    if (_chatModel == null) return;

    final firstUnread = _chatModel!.messages.indexWhere(
      (element) => element.isRead == false,
    );

    if (firstUnread == -1) {
      _firstUnreadIndex = null;
      _emitLoadedState();
      return;
    }

    _firstUnreadIndex = firstUnread;
    _emitLoadedState();
  }

  int getLastUnreadMessage() {
    if (_chatModel == null) return -1;
    return _chatModel!.messages.lastIndexWhere(
      (element) => element.isRead == false,
    );
  }

  void scrollToLatest(int index, {int? milliseconds, BuildContext? context}) {
    bool indexVisible = false;

    if (!indexVisible) {
      scrollController.scrollTo(
        index: index,
        duration: Duration(milliseconds: milliseconds ?? 400),
        curve: Curves.decelerate,
      );

      if (_firstUnreadIndex != null) {
        setAllMessagesRead();
        _firstUnreadIndex = null;
        _emitLoadedState();

        if (context != null && _chatModel != null) {
          context.read<CommunityCubit>().refreshCommunity();
        }
      }
    }
  }

  void setAllMessagesRead() {
    if (_chatModel == null || _firstUnreadIndex == null) return;

    for (int i = _firstUnreadIndex!; i < _chatModel!.messages.length; i++) {
      // §10 — isRead is final; reassign via copyWith.
      _chatModel!.messages[i] = _chatModel!.messages[i].copyWith(isRead: true);
    }
  }

  void selectDuration(DurationValues value) {
    _duration = value;
    _emitLoadedState();
  }

  void selectClearOption(bool value, {required int index}) {
    _clearOption[index] = value;
    _emitLoadedState();
  }

  void toggleReportContact(bool value) {
    _reportContact = value;
    _emitLoadedState();
  }

  void toggleBlockContact(bool value) {
    _blockContact = value;
    _emitLoadedState();
  }

  String getMediaTitle() {
    if (_chatModel == null) return '';

    if (_chatModel!.otherUser != null) {
      return _chatModel!.otherUser!.firstName;
    }
    if (_chatModel!.groupModel != null) {
      return _chatModel!.groupModel!.groupName;
    }
    return '';
  }

  void resetScheduleMessage() {
    messageController.clear();
    dateController.clear();
    timeController.clear();
  }

  List<MessageModel> getStarredMessages() {
    if (_chatModel == null) return [];
    return _chatModel!.messages.where((element) => element.isStarred).toList();
  }

  void toggleStar(MessageModel message) {
    final wasStarred = message.isStarred;
    // §10 — isStarred is final; reassign the element in the list via copyWith.
    final starIndex =
        _chatModel?.messages.indexWhere((element) => element == message) ?? -1;
    if (starIndex != -1) {
      _chatModel!.messages[starIndex] =
          message.copyWith(isStarred: !wasStarred);
    }

    Fluttertoast.showToast(
      msg: wasStarred
          ? S.current.messageRemovedFromStarredMessages
          : S.current.messageAddedToStarredMessages,
      backgroundColor: AppColors.primary,
      textColor: AppTheme.readableOn(AppColors.primary),
    );

    _emitLoadedState();
  }

  void deleteMessage(MessageModel model) {
    if (_chatModel == null) return;

    // §10 — isDeleted is final; reassign the matching element via copyWith.
    final delIndex =
        _chatModel!.messages.indexWhere((element) => element == model);
    if (delIndex != -1) {
      _chatModel!.messages[delIndex] =
          _chatModel!.messages[delIndex].copyWith(isDeleted: true);
    }
    _emitLoadedState();
  }

  void toggleEmojiPicker() {
    _isEmojiPickerVisible = !_isEmojiPickerVisible;
    _emitLoadedState();
  }

  void updateGroupDescription(
      String groupId, String description, GroupModel group) {
    group.groupDescription = description;
    _emitLoadedState();
  }

  void stopAudios() {
    if (_currentlyPlayingAudioModel != null) {
      _currentlyPlayingAudioModel!.playerController.pausePlayer();
      _currentlyPlayingAudioModel!.isCurrentPlaying = false;
      _currentlyPlayingAudioModel!.playerController.stopPlayer();
      _emitLoadedState();
    }
  }

  Future<void> uploadAudio(AudioMessageModel model) async {
    File(model.audioPath);
    await rootBundle.load(model.audioPath);
  }

  Future<void> updateAudioSpeed({required AudioMessageModel audio}) async {
    if (speedIndex == speeds.length) {
      speedIndex = 0;
    } else {
      speedIndex++;
    }

    if (speeds[speedIndex].rate.toInt() == 2) {
      audio.speedUpDuration = audio.duration ~/ 2;
    } else {
      audio.speedUpDuration =
          audio.duration ~/ (speeds[speedIndex].rate.toInt() + 1);
    }

    audio.rate = speeds[speedIndex].name;
    await audio.playerController.setRate(speeds[speedIndex].rate);

    _emitLoadedState();
  }

  Future<void> pickContact(BuildContext context) async {
    final granted = await Permission.contacts.request();
    if (granted.isGranted) {
      Contact? contact = await FlutterContacts.native.showPicker();
      if (contact != null && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<List<String>> getAddress(lat_lng.LatLng point) async {
    try {
      List<Placemark> placeMark = await Geocoding().placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      String country = placeMark[0].country!;
      String state = placeMark[0].administrativeArea!;
      String city = state.split(" ")[0];
      String street = placeMark[0].street!;

      return [street, "$city, $country"];
    } catch (e) {
      return Future.value([e.toString()]);
    }
  }

  Future<void> setPickedLocation(dynamic point, Uint8List? bytes) async {
    final address = await getAddress(point);

    _pickedLocation = LocationMessageModel(
      latitude: point.latitude,
      longitude: point.longitude,
      address: '${address[0]}-${address[1]}',
      locationImagePngBytes: bytes,
    );
    _emitLoadedState();
  }

  void updateMultibleChoices(bool val) {
    _multibleChoices = val;
    _emitLoadedState();
  }

  void addPollOption() {
    _pollOptions.add(TextEditingController());
    _emitLoadedState();
  }

  void resetPollData() {
    questionController.clear();
    _pollOptions = [
      TextEditingController(),
      TextEditingController(),
    ];
    _multibleChoices = false;
  }

  Future<void> docUploadListener(DocMessageModel model) async {
    final doc = await PdfDocument.openFile(model.docPath);

    model.totalPages = doc.pagesCount;
    final page = await doc.getPage(1);
    await page.render(
      width: page.width,
      height: page.height,
    );
    page.close();
  }

  void generateFormFields(int count) {
    _captionControllers = List.generate(
      count,
      (index) => TextEditingController(),
    );
    _emitLoadedState();
  }

  void showProgress() {
    _progressShown = true;
    _emitLoadedState();
  }

  void playVideo(VideoMessageModel model) {
    if (model.playerController.value.isPlaying) {
      model.playerController.pause();
    } else {
      model.playerController.play();
    }
  }

  void toggleEditMessage(MessageEntity model) {
    if (_replyMessageModel != null) {
      _replyMessageModel = null;
    }
    _editMessageModel = model;
    messageFocusNode.requestFocus();
    _emitLoadedState();
  }

  void cancelEdit() {
    _editMessageModel = null;
    _emitLoadedState();
  }

  void submitEditMessage() {
    // Implementation needed
    _emitLoadedState();
  }

  void toggleReplyMessage({required MessageModel model, required int index}) {
    if (_editMessageModel != null) {
      _editMessageModel = null;
    }
    // §10 — index is final; pass it through copyWith instead of a cascade.
    _replyMessageModel = model.copyWith(
      docModel: model.docModel,
      locationModel: model.locationModel,
      audioModel: model.audioModel,
      image: model.image,
      message: model.message,
      index: index,
    );
    messageFocusNode.requestFocus();
    _emitLoadedState();
  }

  Future<void> scrollAndHighlight(int index) async {
    await scrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.decelerate,
    );
    _replyScrollIndex = index;
    _emitLoadedState();

    Future.delayed(
      const Duration(seconds: 1),
      () {
        _replyScrollIndex = index;
        _emitLoadedState();
      },
    );
  }

  void cancelReply() {
    _replyMessageModel = null;
    _emitLoadedState();
  }

  void showReactions() {
    _reactVisible = true;
    _emitLoadedState();
  }

  void showMessageOverlay({
    required BuildContext context,
    required MessageEntity messageModel,
    required int index,
    required Widget content,
    required bool isGroup,
  }) {
    final RenderBox bubbleBox = context.findRenderObject() as RenderBox;
    bubbleBox.localToGlobal(Offset.zero);
  }

  void generateForwardCheckboxes(int index) {
    if (_chatModel == null) return;

    _forwardCheckBoxes = List.generate(
      _chatModel!.messages.length,
      (index) => false,
    );
    _forwardCheckBoxes[index] = true;
    _selectedForwardMessages.add(_chatModel!.messages[index]);
    _emitLoadedState();
  }

  void toggleSelectMessages(bool val) {
    _selectMessages = val;
    if (!val) {
      _forwardCheckBoxes = [];
      _selectedForwardMessages = [];
    }
    _emitLoadedState();
  }

  void selectForwardMessage({required bool val, required int messageIndex}) {
    if (_chatModel == null) return;

    _forwardCheckBoxes[messageIndex] = val;
    if (val) {
      _selectedForwardMessages.add(_chatModel!.messages[messageIndex]);
    } else {
      _selectedForwardMessages.removeWhere(
          (e) => e.hashCode == _chatModel!.messages[messageIndex].hashCode);
    }
    _emitLoadedState();
  }

  @override
  Future<void> close() {
    messageFocusNode.dispose();
    searchMemberController.dispose();
    messageController.dispose();
    dateController.dispose();
    timeController.dispose();
    groupDescriptionController.dispose();
    groupNameController.dispose();
    questionController.dispose();
    msgMenuScrollController.dispose();
    tabController.dispose();
    tabGroupController.dispose();

    for (var controller in _pollOptions) {
      controller.dispose();
    }
    for (var controller in _captionControllers) {
      controller.dispose();
    }

    return super.close();
  }
}

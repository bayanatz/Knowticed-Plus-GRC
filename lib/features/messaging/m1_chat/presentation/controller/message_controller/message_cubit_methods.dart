/// Module: messaging/m1_chat
///
///*************************** FILE INFO ****************************///
/// File Name: message_cubit_methods.dart
/// Description: Methods of `MessageCubit` — split out of `message_controller.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../message_controller.dart';

// Split from message_controller.dart to keep every file under 700 lines.

extension MessageCubitMethods on MessageCubit {
  Future<void> menuSelectAndNavigate(
    String value,
    String title, {
    required BuildContext context,
  }) async {
    if (value == S.of(context).viewContact) {
      if (ContextExtension(context).isTablett) {
        final communityCubit = context.read<CommunityCubit>();
        communityCubit.toggleShowAdditionalInfo(true);
        // Set specific view flags if needed
      } else {
        Navigator.pushNamed(context, Routes.singleChatProfile);
      }
    } else if (value == S.of(context).viewGroup) {
      GetDialogHelper.generalDialog(
        child: TabletGroupChatProfileView(),
        context: context,
      );
    } else if (value == S.of(context).mediaLinksAndDocs) {
      if (ContextExtension(context).isTablett) {
        final communityCubit = context.read<CommunityCubit>();
        communityCubit.toggleShowAdditionalInfo(true);
      } else {
        if (_chatModel != null) {
          Navigator.pushNamed(
            context,
            Routes.media,
            arguments: {
              'media': _chatModel!.mediaModel,
              'recieverName': title,
            },
          );
        }
      }
    } else if (value == S.of(context).scheduleAMessage) {
      // Was Mobile/TabletScheduleMessageDialog. Those were thin wrappers around
      // showDatePicker/showTimePicker whose Done button only called
      // resetScheduleMessage(), so the pickers now run inline and the result is
      // confirmed through CustomDialogManager.
      final pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDate: DateTime.now(),
      );
      if (pickedDate == null || !context.mounted) return;

      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) => Theme(
          data: AppTheme.lightTheme,
          child: child!,
        ),
      );
      if (pickedTime == null || !context.mounted) return;

      dateController.text = DateTimeHelper.formatDate(pickedDate);
      timeController.text = pickedTime.format(context);

      await CustomDialogManager.showDialogFlow(
        context: context,
        confirmWidth: 411, // narrower confirm dialog (bug report #7)
        confirmLottie: AppAssets.media,
        confirmTitle: S.of(context).scheduleAMessage,
        confirmSubtitle: '${dateController.text} ${timeController.text}',
        confirmYesText: S.of(context).status_done,
        confirmNoText: S.of(context).Cancel,
        onNoPressed: resetScheduleMessage,
        onConfirm: () async {
          resetScheduleMessage();
          return true;
        },
        successLottie: AppAssets.media,
        successTitle: S.of(context).scheduleAMessage,
        successSubtitle: '${dateController.text} ${timeController.text}',
      );
    }
  }

  Future<void> addMessage({
    String? audio,
    String? caption,
    File? video,
    File? doc,
    File? image,
    LocationMessageModel? location,
    BuildContext? context,
  }) async {
    if (_chatModel == null) return;

    messageFocusNode.unfocus();

    if (audio != null) {
      var playerController = PlayerController();
      playerController.preparePlayer(
        volume: 1,
        shouldExtractWaveform: true,
        path: audio,
        noOfSamples: playerController
            .getNumOfSamples(AudioRecordService.audioWavesSpacing),
      );
    }

    var newMessage = MessageModel(
      sentUserID: '1',
      image: image,
      replyMessageModel: _replyMessageModel,
      sentDate: DateTime.now(),
      docModel: doc != null ? DocMessageModel(docPath: doc.path) : null,
      audioModel: audio != null
          ? AudioMessageModel(
              audioPath: audio,
              duration: newRecordDuration,
            )
          : null,
      videoModel: null,
      message: caption,
      locationModel: location,
      isMeLastMessage: true,
    );

    if (doc != null) {
      await docUploadListener(newMessage.docModel!);
    }

    newRecordDuration = Duration.zero;
    _chatModel!.messages.add(newMessage);
    _isEmojiPickerVisible = false;
    _replyMessageModel = null;
    _editMessageModel = null;

    _emitLoadedState();

    // A context that is gone is not passed on (it only refreshes Community).
    if (context != null && context.mounted) {
      scrollToLatest(_chatModel!.messages.length - 1, context: context);
    } else {
      scrollToLatest(_chatModel!.messages.length - 1);
    }

    if (context != null) {
      if (!context.mounted) return;
      context.read<CommunityCubit>().refreshCommunity();
    }
  }

  Member? getSentUserByID(String id, MessageModel message) {
    if (_chatModel == null) return null;

    final loggedInUser = Member(
      id: id,
      lastName: 'Ahmed',
      firstName: 'You',
      phoneNumber: '+20 1234567890',
      avatarUrl: AppAssets.profile,
    );

    if (_chatModel!.otherUser != null) {
      var otherID = _chatModel!.otherUser!.id;
      if (id == otherID) {
        return _chatModel!.otherUser!;
      } else {
        return loggedInUser;
      }
    }

    if (_chatModel!.groupModel != null) {
      var groupMemberID = _chatModel!.groupModel!.groupMembers
          .firstWhere((element) => element.id == message.sentUserID)
          .id;
      if (id == groupMemberID) {
        return _chatModel!.groupModel!.groupMembers
            .firstWhere((element) => element.id == message.sentUserID);
      } else {
        return loggedInUser;
      }
    }

    return null;
  }

  Future<void> startPlayingAudio(AudioMessageModel model) async {
    model.playerController.addListener(() {
      model.playerController.playerState == PlayerState.playing
          ? model.isCurrentPlaying = true
          : model.isCurrentPlaying = false;
      _emitLoadedState();
    });

    model.playerController.onCompletion.listen((event) {
      model.isCurrentPlaying = false;
      _emitLoadedState();
    });

    if (_currentlyPlayingAudioModel != null &&
        !identical(_currentlyPlayingAudioModel, model) &&
        _currentlyPlayingAudioModel!.isCurrentPlaying) {
      await _currentlyPlayingAudioModel!.playerController.pausePlayer();
    }

    final isPlaying = model.playerController.playerState == PlayerState.playing;
    final isInitialized =
        model.playerController.playerState == PlayerState.initialized;
    final isPaused = model.playerController.playerState == PlayerState.paused;

    _currentlyPlayingAudioModel = model;

    if (isInitialized || isPaused) {
      model.isCurrentPlaying = true;
    } else if (isPlaying) {
      _currentlyPlayingAudioModel = model;
      await model.playerController.pausePlayer();
    }

    _emitLoadedState();
  }

  Future<void> startRecording() async {
    final res = await Permission.microphone.status;
    if (res == PermissionStatus.granted) {
      if (_currentlyPlayingAudioModel != null) {
        await _currentlyPlayingAudioModel!.playerController.pausePlayer();
        _currentlyPlayingAudioModel!.isCurrentPlaying = false;
        _emitLoadedState();
      }

      stopwatch.start();
      Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          _ellapsedSeconds = stopwatch.elapsed.inSeconds % 60;
          _ellapsedMinutes = stopwatch.elapsed.inMinutes;
          _emitLoadedState();
        },
      );

      final result = await AudioRecordService.startRecording();
      result.fold(
        (l) {
          Fluttertoast.showToast(
              msg: S.current.errorOccuredPleaseTryAgain,
              backgroundColor: AppColors.primary,
              textColor: AppTheme.readableOn(AppColors.primary));
        },
        (r) {
          _isRecording = true;
          _emitLoadedState();
        },
      );
    } else {
      if (res == PermissionStatus.denied) {
        Fluttertoast.showToast(
          msg: S.current.pleaseEnableMicrophoneService,
          backgroundColor: AppColors.primary,
          textColor: AppTheme.readableOn(AppColors.primary),
        );
        return;
      }

      await Permission.microphone.request();
    }
  }

  Future<void> stopRecording({bool? cancel, BuildContext? context}) async {
    stopwatch.stop();

    newRecordDuration = stopwatch.elapsed;

    stopwatch.reset();
    _ellapsedSeconds = 0;
    _ellapsedMinutes = 0;

    final result = await AudioRecordService.stopAndSave(cancel);

    result.fold(
      (l) {
        Fluttertoast.showToast(
            msg: S.current.errorOccuredPleaseTryAgain,
            backgroundColor: AppColors.primary,
            textColor: AppTheme.readableOn(AppColors.primary));
      },
      (r) {
        _isRecording = false;
        _emitLoadedState();

        if (r != null) {
          addMessage(audio: r, context: context);
        }
      },
    );
  }

  Future<void> pickFile({
    bool? audio,
    bool? doc,
    required BuildContext context,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: audio ?? false
          ? FileType.custom
          : doc ?? false
              ? FileType.custom
              : FileType.media,
      allowMultiple: true,
      allowedExtensions: doc ?? false
          ? ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx']
          : audio ?? false
              ? [
                  'mp3',
                  'wav',
                  'aac',
                  'm4a',
                  'flac',
                  'ogg',
                  'wma',
                  'aiff',
                  'alac',
                  'mpeg'
                ]
              : null,
    );

    if (context.mounted) Navigator.of(context).pop();

    if (result != null && context.mounted) {
      if ((audio ?? false) || (doc ?? false)) {
        await CustomDialogManager.showDialogFlow(
          context: context,
          confirmWidth: 411, // narrower confirm dialog (bug report #7)
          confirmLottie: AppAssets.media,
          confirmTitle: S.of(context).totalPickedFiles,
          confirmSubtitle: result.files.length.toString(),
          confirmYesText: S.of(context).send,
          confirmNoText: S.of(context).Cancel,
          onConfirm: () async {
            for (var file in result.files) {
              if (audio ?? false) {
                await addMessage(audio: file.path!, context: context);
              } else {
                await addMessage(doc: File(file.path!), context: context);
              }
            }
            return true;
          },
          successLottie: AppAssets.media,
          successTitle: S.of(context).send,
          successSubtitle: S.of(context).totalPickedFiles,
        );
      } else {
        generateFormFields(result.files.length);
        if (context.mounted) {
          Navigator.pushNamed(
            context,
            Routes.confirmCaptionScreen,
            arguments: {
              'files': result.files,
              'chatModel': _chatModel,
            },
          );
        }
      }
    }
  }

  Future<void> sendImageCamera(
      BuildContext context, ImagePickerCubit imagePickerController) async {
    await imagePickerController.takeImage();
    if (imagePickerController.state.pickedFile != null) {
      final files = [
        PlatformFile(
          name: 'takenImage',
          path: imagePickerController.state.pickedFile!.path,
          size: 0,
        ),
      ];
      generateFormFields(files.length);

      if (context.mounted) {
        Navigator.pushNamed(
          context,
          Routes.confirmCaptionScreen,
          arguments: {
            'files': files,
            'chatModel': _chatModel,
          },
        );
      }

      imagePickerController.clearPickedImage();
    }
  }

  Future<void> setCurrentLocation(
    bool isSelecting, {
    LocationMessageModel? location,
    BuildContext? context,
  }) async {
    if (isSelecting) {
      bool isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!isLocationServiceEnabled) {
        Fluttertoast.showToast(
          msg: S.current.pleaseEnableLocationServices,
          backgroundColor: AppColors.primary,
          textColor: AppTheme.readableOn(AppColors.primary),
        );
        return;
      }

      final permission = await Permission.location.request();

      if (permission.isGranted) {
        Position? currentLocation = await Geolocator.getCurrentPosition(
          // The settings the deprecated `desiredAccuracy:` built.
          locationSettings: defaultTargetPlatform == TargetPlatform.android
              ? AndroidSettings(accuracy: LocationAccuracy.low)
              : LocationSettings(accuracy: LocationAccuracy.low),
        );

        final address = await getAddress(
          lat_lng.LatLng(
            currentLocation.latitude,
            currentLocation.longitude,
          ),
        );

        _pickedLocation = LocationMessageModel(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude,
          address: '${address[0]}-${address[1]}',
        );
      } else {
        _pickedLocation = const LocationMessageModel(
          latitude: 30.033333,
          longitude: 31.233334,
          address: 'Tahrir Square-Cairo, Egypt',
        );
      }
    } else {
      _pickedLocation = location;
    }

    if (isSelecting && context != null && context.mounted) {
      Navigator.pushNamed(
        context,
        Routes.maps,
        arguments: {'isSelecting': true},
      );
    }

    _emitLoadedState();
  }

  bool validatePoll() {
    if (questionController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: S.current.pleaseAddAQuestion,
        backgroundColor: AppColors.primary,
        textColor: AppTheme.readableOn(AppColors.primary),
      );
      return false;
    }

    for (int i = 0; i <= 1; i++) {
      if (_pollOptions[i].text.trim().isEmpty) {
        Fluttertoast.showToast(
          msg: S.current.fillAtLeastTwoOptions,
          backgroundColor: AppColors.primary,
          textColor: AppTheme.readableOn(AppColors.primary),
        );
        return false;
      }
    }

    Set<String> uniqueStrings = {};
    for (int i = 0; i < _pollOptions.length; i++) {
      if (_pollOptions[i].text.isNotEmpty) {
        if (!uniqueStrings.add(_pollOptions[i].text.trim())) {
          Fluttertoast.showToast(
              msg: S.current.optionsMustBeUnique,
              backgroundColor: AppColors.primary,
              textColor: AppTheme.readableOn(AppColors.primary));
          return false;
        }
      }
    }
    return true;
  }

  void confirmPoll(BuildContext context) {
    if (_chatModel == null) return;

    if (validatePoll()) {
      List<bool> pollValues = [];
      List<String> options = [];
      List<int> votes = [];

      for (int i = 0; i < _pollOptions.length; i++) {
        pollValues.add(false);
        votes.add(0);
        if (_pollOptions[i].text.trim().isNotEmpty) {
          options.add(_pollOptions[i].text);
        }
      }

      _pollOptions = [];
      _chatModel!.messages.add(
        MessageModel(
          sentUserID: '1',
          isMeLastMessage: true,
          sentDate: DateTime.now(),
          pollModel: PollMessageModel(
            question: questionController.text,
            pollValues: pollValues,
            options: options,
            votes: votes,
          )..isMultible = _multibleChoices,
        ),
      );

      if (context.mounted) {
        if (ContextExtension(context).isTablett ||
            ContextExtension(context).isLandscape) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          Navigator.of(context).popUntil(
            (route) => route.settings.name == Routes.message,
          );
        }
      }

      resetPollData();
      _emitLoadedState();

      scrollToLatest(_chatModel!.messages.length - 1, context: context);
    }
  }

  void updatePollOption({
    bool? option,
    required int index,
    required PollMessageModel model,
  }) {
    if (model.isMultible) {
      model.pollValues[index] = option ?? false;
      if (option ?? false) {
        model.votes[index] += 1;
        model.voters[model.options[index]]!.add(
          Member(
              id: '1',
              lastName: 'Ahmed',
              firstName: 'Aya Ahmed',
              phoneNumber: '',
              avatarUrl: AppAssets.profile),
        );
      } else {
        if (model.votes[index] > 0) {
          model.votes[index] -= 1;
          model.voters[model.options[index]]!.removeLast();
        }
      }
    } else {
      if (index == model.selectedOptionIndex) {
        if (model.votes[index] > 0) {
          model.votes[index] -= 1;
          model.voters[model.options[index]]!.removeLast();
          model.selectedOptionIndex = null;
        }
      } else {
        model.votes[index] += 1;
        model.voters[model.options[index]]!.add(
          Member(
            id: '1',
            lastName: 'Ahmed',
            firstName: 'Aya Ahmed',
            phoneNumber: '',
            avatarUrl: AppAssets.profile,
          ),
        );

        if (model.selectedOptionIndex != null &&
            model.votes[model.selectedOptionIndex!] > 0) {
          model.votes[model.selectedOptionIndex!] -= 1;
          model.voters[model.options[model.selectedOptionIndex!]]!.removeLast();
        }

        model.selectedOptionIndex = index;
      }
    }
    _emitLoadedState();
  }

  Future<void> videoListener(VideoMessageModel model, [String? id]) async {
    model.playerController.addListener(() async {
      _isPlaying = model.isCurrentPlaying;
      if (model.isCurrentPlaying) {
        _bufferedVideo =
            model.playerController.value.position.inMilliseconds.toDouble();
        _videoDuration =
            model.formatDuration(model.playerController.value.position);
        if (_progressShown) {
          if (!_slideChanging) {
            await Future.delayed(
              const Duration(seconds: 2),
              () {
                _progressShown = false;
                _emitLoadedState();
              },
            );
          }
        }
      }
      _emitLoadedState();
    });
  }
}

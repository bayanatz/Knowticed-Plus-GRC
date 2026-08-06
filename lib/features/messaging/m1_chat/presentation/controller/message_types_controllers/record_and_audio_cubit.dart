/// Module: messaging / chat / presentation/controller/message_types_controllers/record_and_audio_cubit.dart
import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:grc_module/core/services/media_picker_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/message_types_controllers/record_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:grc_module/core/services/message_module/audio_record_service.dart';
import 'package:grc_module/core/helper/main_helper/get_dialog_helper.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import '../../../data/models/message/audio_message_model.dart';
import '../../../domain/entity/new_message_content_entity.dart';
import '../../../domain/repository/chat_repository/base_chat_repository.dart';
import '../../../../../../core/helper/message_module/main_helper/chat_constants.dart';
import '../main_controllers/master_chat_cubit.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';
import 'package:grc_module/core/constants/message_module/app_assets.dart';
import 'package:grc_module/generated/l10n.dart';

///********************** FILE INFO ********************///
/// Class Name: RecordAndAudioCubit
/// Purpose: This class is responsible for handling the record and audio messages.
/// Attributes:
///           MasterChatCubit masterChatCubit - The main cubit that manages the chat.
///           BaseChatRepository chatRepository - The repository that handles the chat data.
/// Created By: Mohamed Elrashidy
/// Created On: 2/11/2024

// State class
class RecordAndAudioState {
  final bool isRecording;
  final bool isProcessing;
  final int elapsedSeconds;
  final int elapsedMinutes;
  final Duration newRecordDuration;
  final int speedIndex;
  final AudioMessageModel? currentlyPlayingAudioModel;
  final String? error;

  RecordAndAudioState({
    this.isRecording = false,
    this.isProcessing = false,
    this.elapsedSeconds = 0,
    this.elapsedMinutes = 0,
    this.newRecordDuration = Duration.zero,
    this.speedIndex = 0,
    this.currentlyPlayingAudioModel,
    this.error,
  });

  RecordAndAudioState copyWith({
    bool? isRecording,
    bool? isProcessing,
    int? elapsedSeconds,
    int? elapsedMinutes,
    Duration? newRecordDuration,
    int? speedIndex,
    AudioMessageModel? Function()? currentlyPlayingAudioModel,
    String? Function()? error,
  }) {
    return RecordAndAudioState(
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      elapsedMinutes: elapsedMinutes ?? this.elapsedMinutes,
      newRecordDuration: newRecordDuration ?? this.newRecordDuration,
      speedIndex: speedIndex ?? this.speedIndex,
      currentlyPlayingAudioModel: currentlyPlayingAudioModel != null
          ? currentlyPlayingAudioModel()
          : this.currentlyPlayingAudioModel,
      error: error != null ? error() : this.error,
    );
  }
}

// Cubit
class RecordAndAudioCubit extends Cubit<RecordAndAudioState> {
  final MasterChatCubit masterChatCubit;
  final BaseChatRepository chatRepository;
  late RecordCubit recordCubit;

  final stopwatch = Stopwatch();
  Timer? _timer;

  RecordAndAudioCubit({
    required this.masterChatCubit,
    required this.chatRepository,
  }) : super(RecordAndAudioState()) {
    recordCubit = RecordCubit(masterChatCubit: masterChatCubit);
  }

  /// Method Name: startPlayingAudio
  /// Purpose: Start or pause audio playback
  Future<void> startPlayingAudio(AudioMessageModel model) async {

    // Listen to player state changes
    model.playerController.addListener(() {
      model.isCurrentPlaying =
          model.playerController.playerState == PlayerState.playing;
      emit(state); // Trigger rebuild
    });

    // Listen to audio completion
    model.playerController.onCompletion.listen((event) {
      model.isCurrentPlaying = false;
      emit(state);
    });

    // Stop currently playing audio if different
    if (state.currentlyPlayingAudioModel != null &&
        !identical(state.currentlyPlayingAudioModel, model) &&
        state.currentlyPlayingAudioModel!.isCurrentPlaying) {
      await state.currentlyPlayingAudioModel!.playerController.pausePlayer();
    }

    final isPlaying = model.playerController.playerState == PlayerState.playing;
    final isInitialized =
        model.playerController.playerState == PlayerState.initialized;
    final isPaused = model.playerController.playerState == PlayerState.paused;

    // Update currently playing audio
    emit(state.copyWith(currentlyPlayingAudioModel: () => model));

    if (isInitialized || isPaused) {
      model.isCurrentPlaying = true;
      await model.playerController.startPlayer();
    } else if (isPlaying) {
      await model.playerController.pausePlayer();
    }
  }

  /// Method Name: startRecording
  /// Purpose: Start audio recording with permission check
  Future<void> startRecording() async {
    final res = await Permission.microphone.status;

    if (res == PermissionStatus.granted) {
      // Pause currently playing audio
      if (state.currentlyPlayingAudioModel != null) {
        await state.currentlyPlayingAudioModel!.playerController.pausePlayer();
        state.currentlyPlayingAudioModel!.isCurrentPlaying = false;
        emit(state);
      }

      // Start stopwatch and timer
      stopwatch.start();
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        emit(state.copyWith(
          elapsedSeconds: stopwatch.elapsed.inSeconds % 60,
          elapsedMinutes: stopwatch.elapsed.inMinutes,
        ));
      });

      // Start recording
      final result = await AudioRecordService.startRecording();

      result.fold(
            (error) {
          Fluttertoast.showToast(
            msg: 'Error Occurred, Please try again',
            backgroundColor: AppColors.primary,
            textColor: AppTheme.contrastColor(),
          );
          _stopTimer();
          emit(state.copyWith(error: () => error.toString()));
        },
            (success) {
          emit(state.copyWith(
            isRecording: true,
            error: () => null,
          ));
        },
      );
    } else {
      if (res == PermissionStatus.denied) {
        Fluttertoast.showToast(
          msg: 'Please enable microphone service!',
          backgroundColor: AppColors.primary,
          textColor: AppTheme.contrastColor(),
        );
        return;
      }

      await Permission.microphone.request();
    }
  }

  /// Method Name: stopRecording
  /// Purpose: Stop recording and optionally save
  Future<void> stopRecording({bool? cancel}) async {
    stopwatch.stop();
    final duration = stopwatch.elapsed;
    stopwatch.reset();
    _stopTimer();

    emit(state.copyWith(
      elapsedSeconds: 0,
      elapsedMinutes: 0,
      newRecordDuration: duration,
    ));

    final result = await AudioRecordService.stopAndSave(cancel);

    result.fold(
          (error) {
        Fluttertoast.showToast(
          msg: 'Error Occurred, Please try again',
          backgroundColor: AppColors.primary,
          textColor: AppTheme.contrastColor(),
        );
        emit(state.copyWith(
          isRecording: false,
          error: () => error.toString(),
        ));
      },
          (recordPath) {
        emit(state.copyWith(isRecording: false, error: () => null));

        if (recordPath != null) {
          sendAudioMessage(audio: File(recordPath));
        }
      },
    );
  }

  /// Method Name: stopAudios
  /// Purpose: Stop all currently playing audios
  void stopAudios() {
    if (state.currentlyPlayingAudioModel != null) {
      state.currentlyPlayingAudioModel!.playerController.pausePlayer();
      state.currentlyPlayingAudioModel!.isCurrentPlaying = false;
      state.currentlyPlayingAudioModel!.playerController.stopPlayer();
      emit(state.copyWith(currentlyPlayingAudioModel: () => null));
    }
  }

  /// Method Name: updateAudioSpeed
  /// Purpose: Cycle through audio playback speeds
  Future<void> updateAudioSpeed({required AudioMessageModel audio}) async {
    int newSpeedIndex = state.speedIndex;

    // Cycle through speeds
    if (newSpeedIndex >= speeds.length - 1) {
      newSpeedIndex = 0;
    } else {
      newSpeedIndex++;
    }

    final speed = speeds[newSpeedIndex];

    // Update speed-up duration
    if (speed.rate.toInt() == 2) {
      audio.speedUpDuration = audio.duration ~/ 2;
    } else {
      audio.speedUpDuration = audio.duration ~/ (speed.rate.toInt() + 1);
    }

    audio.rate = speed.name;
    await audio.playerController.setRate(speed.rate);

    emit(state.copyWith(speedIndex: newSpeedIndex));
  }

  /// Method Name: pickAudio
  /// Purpose: Pick audio files from device
  Future<void> pickAudio({required BuildContext context}) async {
    emit(state.copyWith(isProcessing: true, error: () => null));

    try {
      // Picker owned by MediaPickerService — cubit no longer touches FilePicker (§16).
      final paths = await MediaPickerService()
          .pickFilePaths(allowedExtensions: ChatConstants.audioExtensions);

      emit(state.copyWith(isProcessing: false));

      if (paths.isNotEmpty && context.mounted) {
        await CustomDialogManager.showDialogFlow(
          context: context,
          confirmLottie: AppAssets.media,
          confirmTitle: S.of(context).totalPickedFiles,
          confirmSubtitle: paths.length.toString(),
          confirmYesText: S.of(context).send,
          confirmNoText: S.of(context).Cancel,
          onConfirm: () async {
            for (final p in paths) {
              sendAudioMessage(audio: File(p));
            }
            return true;
          },
          successLottie: AppAssets.media,
          successTitle: S.of(context).send,
          successSubtitle: S.of(context).totalPickedFiles,
        );
      }
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        error: () => 'Failed to pick audio files',
      ));
    }
  }

  /// Method Name: sendAudioMessage
  /// Purpose: Send audio message to chat
  Future<void> sendAudioMessage({required File audio}) async {

    try {
      AudioMessageModel audioMessageModel = AudioMessageModel(
        audioPath: audio.path,
        duration: state.newRecordDuration,
      );

      AudioMessageContentEntity messageContentEntity =
      AudioMessageContentEntity(audio: audioMessageModel);

      final currentUser = masterChatCubit.state.currentUser;
      final otherConnectionSide = masterChatCubit.state.otherConnectionSide;

      if (currentUser == null || otherConnectionSide == null) {
        throw Exception('Missing user or connection data');
      }

      await chatRepository.sendNewMessage(
        currentUser: currentUser,
        otherConnectionSide: otherConnectionSide,
        messageContent: messageContentEntity,
      );

      // Reset duration after sending
      emit(state.copyWith(newRecordDuration: Duration.zero));
    } catch (e) {
      emit(state.copyWith(error: () => 'Failed to send audio message'));
    }
  }

  /// Stop the timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(error: () => null));
  }

  /// Reset state
  void reset() {
    _stopTimer();
    stopwatch.stop();
    stopwatch.reset();
    emit(RecordAndAudioState());
  }

  @override
  Future<void> close() {
    _stopTimer();
    stopwatch.stop();
    return super.close();
  }
}

// Speed configurations
List<Speeds> speeds = [
  Speeds.speed_1,
  Speeds.speed_1_0_5,
  Speeds.speed_2,
];
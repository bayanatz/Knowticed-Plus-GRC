/// Module: messaging / chat / data/models/message/audio_message_model.dart
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:grc_module/core/helper/main_helper/extensions.dart';

import 'package:grc_module/core/services/message_module/audio_record_service.dart';

// Date: 2/9/2024
// By: Youssef Ashraf, Nada Mohamed
// Audio Model which is part of message model to handle its own configurations.

/// Part of Message Model
class AudioMessageModel {
  String audioPath;
  String rate;
  bool isCurrentPlaying;
  Duration duration;
  Duration? speedUpDuration;
  late PlayerController playerController;

  AudioMessageModel({
    required this.audioPath,
    required this.duration,
    this.speedUpDuration,
    this.isCurrentPlaying = false,
    this.rate = '1.0x',
  }) {
    initializeAudio();
  }

  initializeAudio() {
    playerController = PlayerController();
    playerController.preparePlayer(
      volume: 1,
      shouldExtractWaveform: true,
      path: audioPath,
      noOfSamples: playerController
          .getNumOfSamples(AudioRecordService.audioWavesSpacing),
    );
  }

  String get formattedDuration {
    if (duration.inHours > 0) {
      return "${duration.inHours.toString().padLeft(2, '0')}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
    } else {
      return "${duration.inMinutes.toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
    }
  }

  CountDownTimerFormat get countDownTimerFormat {
    return duration.inHours > 0
        ? CountDownTimerFormat.hoursMinutesSeconds
        : CountDownTimerFormat.minutesSeconds;
  }

  AudioMessageModel copyWith({
    String? audioPath,
    String? rate,
    bool? isCurrentPlaying,
    Duration? duration,
    Duration? speedUpDuration,
  }) {
    return AudioMessageModel(
      audioPath: audioPath ?? this.audioPath,
      rate: rate ?? this.rate,
      isCurrentPlaying: isCurrentPlaying ?? this.isCurrentPlaying,
      duration: duration ?? this.duration,
      speedUpDuration: speedUpDuration ?? this.speedUpDuration,
    );
  }

  static const String AUDIO_PATH = "Media_Link";
  static const String DURATION = "Duration";
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      DURATION: duration.inMinutes,
      AUDIO_PATH: audioPath
    };
  }

  factory AudioMessageModel.fromMap(Map<String, dynamic> map) {
    return AudioMessageModel(
        audioPath: map[AUDIO_PATH],
        duration: Duration(minutes: map[DURATION] as int));
  }
}

enum Speeds {
  speed_1,
  speed_1_0_5,
  speed_2,
}

extension GetName on Speeds {
  String get name {
    switch (this) {
      case Speeds.speed_1:
        return '1.0x';
      case Speeds.speed_1_0_5:
        return '1.5x';
      case Speeds.speed_2:
        return '2.0x';
    }
  }

  double get rate {
    switch (this) {
      case Speeds.speed_1:
        return 1.0;
      case Speeds.speed_1_0_5:
        return 1.5;
      case Speeds.speed_2:
        return 2.0;
    }
  }
}
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dartz/dartz.dart';

import 'package:path_provider/path_provider.dart';

import 'package:grc_module/core/network/message_module/services/error_handler.dart';

//Youssef Ashraf
/// Class for Providing recording /playing audio Services
abstract class AudioRecordService {
  static late final RecorderController recorderController;

  // set the spacing between the audio waves
  static double get audioWavesSpacing => 5;

  static initializeController() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC;
  }

  static Future<Either<Failure, void>> startRecording() async {
    try {
      var directory = await getApplicationDocumentsDirectory();

      // -----for saving the file in the external storage if needed-----
      // var directory = Platform.isAndroid
      //     ? await getExternalStorageDirectory() // FOR ANDROID
      //     : await getApplicationSupportDirectory(); //FOR iOS

      final path = "${directory.path}/${DateTime.now().microsecond}.m4a";
      return Right(
        await recorderController.record(
          path: path,
          bitRate: 48000,
        ),
      );
    } catch (e) {
      return Left(
        FeatureFailure(
          e.toString(),
        ),
      );
    }
  }

  static Future<Either<Failure, String?>> stopAndSave(bool? cancel) async {
    try {
      final path = await recorderController.stop();

      if (cancel ?? false) {
        return const Right(null);
      }
      return Right(path);
    } catch (e) {
      return Left(
        FeatureFailure(
          e.toString(),
        ),
      );
    }
  }
}

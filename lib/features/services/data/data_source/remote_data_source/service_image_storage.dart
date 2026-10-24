/// Module: services / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: service_image_storage.dart
/// Purpose: Uploads and removes service pictures in Firebase Storage (rule
///          C2: the Storage calls moved out of CreateServiceCubit).
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services/helpers/services_log.dart';

/// Class Name: [ServiceImageStorage]
///
/// Purpose: The Storage side of the service picture.
class ServiceImageStorage {
  ServiceImageStorage({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Function Name: [upload]
  ///
  /// Purpose: Uploads a picture as JPEG under the services images folder.
  ///
  /// Parameters:
  /// - [bytes]: the picture on web.
  /// - [file]: the picture on other platforms.
  ///
  /// Returns: the download URL. Throws when neither is given or the upload
  /// fails; the cubit turns that into its error state.
  Future<String> upload({Uint8List? bytes, File? file}) async {
    final fileName = 'service_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(
          '${getBaseUrl(FirestoreCollections.servicesImagesStorage)}/$fileName',
        );
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    final UploadTask task;
    if (kIsWeb && bytes != null) {
      task = ref.putData(bytes, metadata);
    } else if (file != null) {
      task = ref.putFile(file, metadata);
    } else {
      throw StateError('No image selected');
    }
    final snapshot = await task;
    return snapshot.ref.getDownloadURL();
  }

  /// Function Name: [deleteQuietly]
  ///
  /// Purpose: Deletes a picture that no saved service uses. A failure is only
  /// logged: the object may already be gone.
  ///
  /// Parameters:
  /// - [url]: the picture's download URL.
  Future<void> deleteQuietly(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      svcLog('could not delete unsaved upload', error: e);
    }
  }
}

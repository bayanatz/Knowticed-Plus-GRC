import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload image to Firebase Storage and return download URL
  ///
  /// [imageFile] - The image file to upload
  /// [userEmail] - User email for organizing storage structure
  /// [storageLocationId] - Storage location ID for unique naming
  ///
  /// Returns the download URL string or null if upload fails
  static Future<String?> uploadStorageLocationImage({
    required File imageFile,
    required String userEmail,
    required String storageLocationId,
  }) async {
    try {
      // Create a unique filename
      final String fileName =
          '${storageLocationId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      // Create storage reference with organized path structure
      // Path: /storage_locations/{userEmail}/{fileName}
      final Reference storageRef = _storage
          .ref()
          .child('storage_locations')
          .child(userEmail)
          .child(fileName);

      // Set metadata for the image
      final SettableMetadata metadata = SettableMetadata(
        contentType: _getContentType(imageFile.path),
        customMetadata: {
          'uploadedBy': userEmail,
          'storageLocationId': storageLocationId,
          'uploadTimestamp': DateTime.now().toIso8601String(),
        },
      );

      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadURL = await snapshot.ref.getDownloadURL();

      debugPrint('Image uploaded successfully: $downloadURL');
      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  /// Delete image from Firebase Storage
  ///
  /// [imageUrl] - The download URL of the image to delete
  ///
  /// Returns true if deletion was successful, false otherwise
  static Future<bool> deleteStorageLocationImage(String imageUrl) async {
    try {
      final Reference imageRef = _storage.refFromURL(imageUrl);
      await imageRef.delete();
      debugPrint('Image deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Get content type based on file extension
  static String _getContentType(String filePath) {
    final String extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  /// Compress and upload image (optional optimization)
  ///
  /// This method can be used if you want to compress images before upload
  /// You'll need to add image compression package like flutter_image_compress
  static Future<String?> uploadCompressedStorageLocationImage({
    required File imageFile,
    required String userEmail,
    required String storageLocationId,
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) async {
    try {
      // Note: You'll need to add flutter_image_compress package
      // and implement compression logic here if needed

      // For now, just call the regular upload method
      return await uploadStorageLocationImage(
        imageFile: imageFile,
        userEmail: userEmail,
        storageLocationId: storageLocationId,
      );
    } catch (e) {
      debugPrint('Error uploading compressed image: $e');
      return null;
    }
  }
}

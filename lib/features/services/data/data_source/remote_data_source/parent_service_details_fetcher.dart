/// Module: services / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: parent_service_details_fetcher.dart
/// Purpose: Reads the CreateServices document of the service a request was
///          made for and returns its current name, description, duration
///          and image. The one place this lookup happens; every screen
///          reaches it through CreateServicesRepository.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/services/domain/entities/parent_service_details.dart';

class ParentServiceDetailsFetcher {
  ParentServiceDetailsFetcher(this.firestore);

  final FirebaseFirestore firestore;

  // CreateServices field keys (new names first, then the older camelCase).
  static const String _nameEnglish = 'Service_Name_English';
  static const String _nameEnglishOld = 'serviceNameEnglish';
  static const String _nameArabic = 'Service_Name_Arabic';
  static const String _nameArabicOld = 'serviceNameArabic';
  static const String _descriptionEnglish = 'Service_Description_English';
  static const String _descriptionEnglishOld = 'serviceDescriptionEnglish';
  static const String _descriptionArabic = 'Service_Description_Arabic';
  static const String _descriptionArabicOld = 'serviceDescriptionArabic';
  static const String _duration = 'Duration_Of_Services';
  static const String _durationOld = 'durationOfServices';
  static const String _unit = 'Selected_Duration_Unit';
  static const String _unitOld = 'selectedDurationUnit';
  static const String _imageUrl = 'Image_Url';

  /// History list: the LAST non-empty entry is the current value.
  static String _current(Object? value) {
    if (value == null) return '';
    if (value is List) {
      for (var i = value.length - 1; i >= 0; i--) {
        final item = value[i]?.toString() ?? '';
        if (item.isNotEmpty) return item;
      }
      return '';
    }
    return value.toString();
  }

  static String _field(Map<String, dynamic> data, String key, String oldKey) {
    if (data.containsKey(key)) return _current(data[key]);
    if (data.containsKey(oldKey)) return _current(data[oldKey]);
    return '';
  }

  /// Function Name: [fetch]
  ///
  /// Purpose: Reads the parent service. When it no longer exists the empty
  /// details are returned, so the screen shows "service removed" instead of
  /// another service's name (SVC-HOME-07). Read errors are thrown to the
  /// caller instead of looking like a miss.
  ///
  /// Parameters:
  /// - [parentServiceId]: the CreateServices document id.
  ///
  /// Returns: the service's current details, or [ParentServiceDetails.empty].
  Future<ParentServiceDetails> fetch(String parentServiceId) async {
    if (parentServiceId.isEmpty) return ParentServiceDetails.empty;

    final doc = await firestore
        .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
        .doc(parentServiceId)
        .get();
    final data = doc.data();
    if (!doc.exists || data == null) return ParentServiceDetails.empty;

    return ParentServiceDetails(
      nameEnglish: _field(data, _nameEnglish, _nameEnglishOld),
      nameArabic: _field(data, _nameArabic, _nameArabicOld),
      descriptionEnglish: _field(
        data,
        _descriptionEnglish,
        _descriptionEnglishOld,
      ),
      descriptionArabic: _field(
        data,
        _descriptionArabic,
        _descriptionArabicOld,
      ),
      duration: _field(data, _duration, _durationOld),
      unit: _field(data, _unit, _unitOld),
      imageUrl: _current(data[_imageUrl]),
    );
  }
}

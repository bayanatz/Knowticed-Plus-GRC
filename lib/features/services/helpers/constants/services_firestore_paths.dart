/// Module: services / helpers / constants
///
///*************************** FILE INFO ****************************///
/// File Name: services_firestore_paths.dart
/// Purpose: Firestore names the services module uses that are not in the
///          shared FirestoreCollections (rule H25: no path literals inside
///          repositories). The shared roots stay in core and are used as-is.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

/// Class Name: [ServicesFirestorePaths]
///
/// Purpose: Sub-collection names below a services document.
class ServicesFirestorePaths {
  const ServicesFirestorePaths._();

  /// The chat/comments sub-collection under a request document.
  static const String requestComments = 'comments';
}

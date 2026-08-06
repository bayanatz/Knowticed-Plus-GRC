import 'package:grc_module/features/home/main_controller/helper/qiyas/domain/entity/qiyas_tracker_entity.dart';

// REMOVED_MODULE: qiyas module was removed from knowticed.
// When adding the qiyas module, restore the full implementation from knowticed_plus.

class QiyasInterfaceConsumer {
  /// Returns empty tracker entity until qiyas module is added.
  Future<QiyasTrackerEntity> getTopicsAssignStatus() async {
    // TODO: Implement when qiyas module is added
    return QiyasTrackerEntity(
      numberOfTopics: 0,
      approvedTopics: [],
      partialAssigned: [],
      assigned: [],
      notAssigned: [],
    );
  }
}

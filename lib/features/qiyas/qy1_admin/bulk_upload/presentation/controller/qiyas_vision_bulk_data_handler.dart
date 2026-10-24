/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_vision_bulk_data_handler.dart
/// Purpose: Handles the initialization and clearing of vision data in the QiyasBulkVisionsController.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This class defines methods for initializing the vision data into the controller fields
///              and clearing the vision data from the controller fields. It helps manage vision data
///              within the bulk upload process by allowing easy setup and reset of vision-related information.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/features/qiyas/helpers/constant/visions.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_visions_controller.dart';

class QiyasVisionBulkDataHandler {
  void initializeVisionsData(
      QiyasBulkVisionsController controller, Visions vision) {
    controller.visionName.text = vision.visionName;
    controller.topicName.text = vision.topicName;
    controller.topicNumber.text = vision.topicNumber;
    controller.criterionName.text = vision.criterionName;
    controller.criterionNumber.text = vision.criterionNumber;
    controller.goal.text = vision.goal;
    controller.requirements.text = vision.requirements;
    controller.documents.text = vision.documents;
    controller.orders.text = vision.orders;
    controller.scope.text = vision.scope;
  }

  void clearVisionData(QiyasBulkVisionsController controller) {
    controller.visionName.clear();
    controller.topicName.clear();
    controller.topicNumber.clear();
    controller.criterionName.clear();
    controller.criterionNumber.clear();
    controller.goal.clear();
    controller.requirements.clear();
    controller.documents.clear();
    controller.orders.clear();
    controller.scope.clear();
  }
}

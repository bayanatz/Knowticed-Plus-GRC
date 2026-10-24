import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/models/vision_firestore.dart';

class Visions {
  String visionName;
  String topicName;
  String topicNumber;
  String criterionName;
  String criterionNumber;
  String goal;
  String requirements;
  String documents;
  String orders;
  String scope;

  Visions({
    required this.visionName,
    required this.topicName,
    required this.topicNumber,
    required this.criterionName,
    required this.criterionNumber,
    required this.goal,
    required this.requirements,
    required this.documents,
    required this.orders,
    required this.scope,
  });
  static Visions visionFireBasetoEntity(VisionModel visionFirestore) {
    return Visions(
      visionName: visionFirestore.visionName.last,
      topicName: visionFirestore.topicName.last,
      topicNumber: visionFirestore.topicNumber.last,
      criterionName: visionFirestore.criterionName.last,
      criterionNumber: visionFirestore.criterionNumber.last,
      goal: visionFirestore.goals.last,
      requirements: visionFirestore.appRequirements.last,
      documents: visionFirestore.evidenceDocuments.last,
      orders: visionFirestore.ordersDecisionsAndCirculars.last,
      scope: visionFirestore.scope.last,
    );
  }
}

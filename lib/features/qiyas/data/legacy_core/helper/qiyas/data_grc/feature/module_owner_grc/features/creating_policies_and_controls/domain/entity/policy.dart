// This class definition defines a data model for a policy, with various properties to store information about the policy. Here is a list explaining what each part of the class does:

// There are no class methods in this definition, only a constructor that initializes a new Policy object with the required properties:
// Policy: The constructor initializes a new Policy object with the required properties:
// creationDate: The date the policy was created
// lastEditDate: The date the policy was last edited
// name: The name of the policy
// nameArabic: The Arabic name of the policy
// controls: A list of controls associated with the policy
// status: The status of the policy
// weight: The weight of the policy
// imageUrl: The URL of the policy image
// hasArabicVersion: Whether the policy has an Arabic version
// describtion: A description of the policy
// policyNumber: The policy number
// startDate: The start date of the policy
// endDate: The end date of the policy
// describtionArabic: The Arabic description of the policy
// policyDocument: The policy document
// documentSize: The size of the policy document (optional)
// allowPartialCompliance: Whether partial compliance is allowed
// score: The score of the policy
// department: The department associated with the policy
// auditDepartment: A list of audit departments associated with the policy
// isActive: Whether the policy is active
import 'package:knowticed_plus/core/helper/localized_date.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/enums/enum.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/entity/control.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/data_grc_2/features/create_policy/domain/entity/audit_department.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/policy_firestore.dart';

class Policy {
  String? id;
  String name;
  String nameArabic;
  String status;
  String creationDate;
  int weight;
  String lastEditDate;
  String imageUrl;
  String describtion;
  bool? hasArabicVersion;
  List<Control> controls;
  String policyNumber;
  String startDate;
  String endDate;
  String describtionArabic;
  String policyDocument;
  String? documentSize;
  bool allowPartialCompliance;
  int score;
  String department;
  List<AuditDepartment> auditDepartment;
  bool isActive;

  Policy({
    this.id,
    required this.creationDate,
    required this.lastEditDate,
    required this.name,
    required this.nameArabic,
    required this.controls,
    required this.status,
    required this.weight,
    required this.imageUrl,
    this.hasArabicVersion,
    required this.describtion,
    required this.policyNumber,
    required this.startDate,
    required this.endDate,
    required this.describtionArabic,
    required this.policyDocument,
    this.documentSize,
    required this.allowPartialCompliance,
    required this.score,
    required this.department,
    required this.auditDepartment,
    required this.isActive,
  });

  static Policy policyFireBasetoEntity(PolicyFirestore policyFirestore) {
    return Policy(
        id: policyFirestore.id.last,
        imageUrl: "",
        name: capitalize(policyFirestore.name.last),
        nameArabic: capitalize(policyFirestore.nameArabic.last),
        describtion: capitalize(policyFirestore.description.last),
        describtionArabic: capitalize(policyFirestore.descriptionArabic.last),
        policyNumber: capitalize(policyFirestore.number.last),
        startDate: capitalize(policyFirestore.startDate.last),
        endDate: capitalize(policyFirestore.endDate.last),
        status: capitalize(policyFirestore.status.last),
        weight: int.parse(policyFirestore.weight.last),
        policyDocument: "",
        documentSize: "",
        creationDate: capitalize(LocalizedDate.forLocale(
            policyFirestore.timeStamp.first.toDate(), 'en')),
        lastEditDate: capitalize(LocalizedDate.forLocale(
            policyFirestore.timeStamp.last.toDate(), 'en')),
        controls: [],
        allowPartialCompliance: false,
        score: 0,
        department: '',
        auditDepartment: [],
        isActive: false,
        hasArabicVersion: null);
  }
}

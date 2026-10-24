// ignore_for_file: public_member_api_docs, sort_constructors_first
// This class definition defines a data model for a control owner, which represents an entity responsible for a control.

// Here is a list explaining what each class method does:

// There are no class methods in this definition, only a constructor that initializes a new ControlOwner object with the required properties:
// controlOwner: the name of the control owner
// controlOwnerDepartment: the department of the control owner
// controlOwnerImage: the image of the control owner
// assignedBy: the name of the person who assigned the control owner
// assignedByImage: the image of the person who assigned the control owner
// startDate: the start date of the control owner's assignment
// endDate: the end date of the control owner's assignment
import 'package:knowticed_plus/core/helper/localized_date.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/enums/enum.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/control_owner/features/home/data/models/control_owner_firestore.dart';

class ControlOwner {
  String? controlOwner;
  String? controlOwnerDepartment;
  String? controlOwnerImage;
  String? assignedBy;
  String? assignedByImage;
  String startDate;
  String endDate;
  String? id;
  String? timeStamp;
  List<String>? controls;
  List<String>? policies;
  String? status;

  ControlOwner({
    required this.controlOwner,
    this.controlOwnerDepartment,
    this.controlOwnerImage,
    this.assignedBy,
    this.assignedByImage,
    required this.startDate,
    required this.endDate,
    this.id,
    this.timeStamp,
    this.controls,
    this.policies,
    this.status,
  });

  static ControlOwner controlOwnerFireBasetoEntity(
      ControlOwnerFirestore controlOwnerFirestore) {
    return ControlOwner(
      controlOwner: controlOwnerFirestore.controlOwner.isNotEmpty
          ? capitalize(controlOwnerFirestore.controlOwner.last)
          : '',
      status: controlOwnerFirestore.status.isNotEmpty
          ? capitalize(controlOwnerFirestore.status.last)
          : '',
      controls: controlOwnerFirestore.controls.isNotEmpty
          ? controlOwnerFirestore.controls
          : [],
      endDate: controlOwnerFirestore.endDate.isNotEmpty
          ? capitalize(controlOwnerFirestore.endDate.last)
          : '',
      id: controlOwnerFirestore.moduleId.isNotEmpty
          ? controlOwnerFirestore.moduleId.last
          : '',
      policies: controlOwnerFirestore.policies.isNotEmpty
          ? controlOwnerFirestore.policies
          : [],
      startDate: controlOwnerFirestore.startDate.isNotEmpty
          ? capitalize(controlOwnerFirestore.startDate.last)
          : '',
      timeStamp: controlOwnerFirestore.timeStamp.isNotEmpty
          ? capitalize(LocalizedDate.forLocale(
              controlOwnerFirestore.timeStamp.last.toDate(), 'en'))
          : '',
    );
  }
}

// This class definition defines a data model for a control, which represents a unit of regulation or compliance in a business process.

// Here is a list explaining what each part of the class does:

// Fields:
// controlName: Stores the name of the control.
// controlOwnerList: Stores a list of control owners responsible for the control.
// controlWeight: Stores the weight or importance of the control.
// controlStatus: Stores the status of the control (e.g., active, inactive, pending).
// lastEdit: Stores the date of the last edit made to the control.
// score: Stores a score or rating associated with the control.
// justifications: Stores a justification or explanation for the control (optional).
// auditFrequency: Stores the frequency of audits for the control.
// describtion: Stores a description of the control.
// isActive: Stores a boolean indicating whether the control is active (defaults to false).
// department: Stores the department responsible for the control.
// controlAuditor: Stores the control auditor responsible for the control.
// commentsModelList: Stores a list of comments associated with the control.
// approvalsList: Stores a list of approvals associated with the control.
import 'package:knowticed_plus/core/helper/localized_date.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/enums/enum.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/domain/entity/control_owner.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/data_grc_2/features/create_policy/domain/entity/approval_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/data_grc_2/features/create_policy/domain/entity/comments_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/control_firestore.dart';

class Control {
  String? id;
  String controlName;
  List<ControlOwner> controlOwnerList;
  int controlWeight;
  String controlStatus;
  String lastEdit;
  int score;
  String? justifications;
  String auditFrequency;
  String describtion;
  bool isActive;
  String department;
  ControlOwner? controlAuditor;
  List<CommentsModel> commentsModelList;
  List<ApprovalModel> approvalsList;

  Control({
    this.id,
    required this.controlName,
    required this.controlOwnerList,
    required this.controlStatus,
    required this.controlWeight,
    required this.lastEdit,
    required this.score,
    required this.auditFrequency,
    required this.describtion,
    this.isActive = false,
    required this.department,
    this.controlAuditor,
    required this.commentsModelList,
    required this.approvalsList,
    this.justifications,
  });
  static Control controlFireBasetoEntity(ControlFirestore controlFirestore) {
    return Control(
      controlAuditor: null,
      justifications: '',
      id: controlFirestore.id.isNotEmpty ? controlFirestore.id.last : '',
      controlName: controlFirestore.name.isNotEmpty
          ? capitalize(controlFirestore.name.last)
          : '',
      describtion: controlFirestore.description.isNotEmpty
          ? capitalize(controlFirestore.description.last)
          : '',
      controlWeight: int.parse(controlFirestore.weight.isNotEmpty
          ? controlFirestore.weight.last
          : '0'),
      auditFrequency: controlFirestore.frequencyWeight.isNotEmpty
          ? capitalize(controlFirestore.frequencyWeight.last)
          : '',
      controlStatus: controlFirestore.status.isNotEmpty
          ? capitalize(controlFirestore.status.last)
          : '',
      lastEdit: controlFirestore.timeStamp.isNotEmpty
          ? LocalizedDate.forLocale(
              controlFirestore.timeStamp.last.toDate(), 'en')
          : '',
      controlOwnerList: [
        ControlOwner(
          assignedBy: 'Mazen Shabaan',
          assignedByImage:
              'assets/icons_assets/main_icons_assets/ic_user_person.png',
          endDate: '22 Oct 2024',
          startDate: '21 Oct 2024',
          controlOwner: 'John Doe',
          controlOwnerDepartment: 'IT',
          controlOwnerImage:
              'assets/icons_assets/main_icons_assets/ic_user_person.png',
        ),
        ControlOwner(
          assignedBy: 'Mazen Shabaan',
          assignedByImage:
              'assets/icons_assets/main_icons_assets/ic_user_person.png',
          endDate: '22 Oct 2024',
          startDate: '21 Oct 2024',
          controlOwner: 'Jane Smith',
          controlOwnerDepartment: 'Finance',
          controlOwnerImage: null,
        ), // No image)
        ControlOwner(
          assignedBy: 'Mazen Shabaan',
          assignedByImage:
              'assets/icons_assets/main_icons_assets/ic_user_person.png',
          endDate: '22 Oct 2024',
          startDate: '21 Oct 2024',
          controlOwner: 'John Doe',
          controlOwnerDepartment: 'IT',
          controlOwnerImage:
              'assets/icons_assets/main_icons_assets/ic_user_person.png',
        ),
      ],
      score: 0,
      isActive: true,
      department: "",
      commentsModelList: [],
      approvalsList: [],
    );
  }
}

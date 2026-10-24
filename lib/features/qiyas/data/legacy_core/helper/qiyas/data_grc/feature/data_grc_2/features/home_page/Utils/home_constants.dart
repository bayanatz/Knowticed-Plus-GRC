import 'package:get/get.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/entity/control.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/entity/policy.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/data_grc_2/features/create_policy/domain/entity/approval_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/data_grc_2/features/create_policy/domain/entity/audit_department.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/data_grc_2/features/create_policy/domain/entity/comments_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/domain/entity/control_owner.dart';

class HomeConstants {
  static List<String> grcTableHeader = [
    'NO'.tr,
    'Policy Name'.tr,
    'Description'.tr,
    'Weight'.tr,
    'Status'.tr,
    'Creation Date'.tr,
    'No of controls'.tr,
    'Last Edit Date'.tr
  ];
  static List<String> policyWeightIssueTable = [
    'NO'.tr,
    'Policy Number'.tr,
    'Policy Name'.tr,
    'Policy Description'.tr,
    'Start Date'.tr,
    'End Date'.tr,
    'Policy Weight'.tr,
  ];

  static List<Policy> policies = [
    Policy(
        auditDepartment: [
          AuditDepartment(name: 'Marketing', score: 100),
          AuditDepartment(name: 'HR', score: 60),
          AuditDepartment(name: 'Design', score: 20),
        ],
        department: "Media",
        score: 100,
        allowPartialCompliance: true,
        describtionArabic:
            'loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum',
        endDate: '20 Oct 2024',
        hasArabicVersion: true,
        nameArabic: 'بوليسة',
        policyDocument: 'attachement.pdf',
        documentSize: '32 kb',
        policyNumber: 'Ecg22scsldas',
        startDate: '11 Oct 2023',
        imageUrl:
            "assets/icons_assets/main_icons_assets/img_image_placeholder_large.png",
        creationDate: '01 Oct 2024',
        lastEditDate: '01 Oct 2024',
        name: 'Policy 1',
        status: 'Active',
        isActive: true,
        describtion:
            "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
        weight: 20, // Adjust the weight
        controls: [
          Control(
            approvalsList: [
              ApprovalModel(
                  file: "attached.pdf",
                  fileSize: "32 KB",
                  imagPath:
                      "assets/icons_assets/main_icons_assets/ic_user_person.png",
                  jobTitle: "Employee",
                  name: "Bassem Mohamed",
                  startTime: DateTime.now(),
                  status: null,
                  submissionNote:
                      "oremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum")
            ],
            commentsModelList: [
              CommentsModel(
                  name: "Mazen Shabaan",
                  description: "My Comment",
                  startTime: DateTime.now(),
                  imagPath:
                      "assets/icons_assets/main_icons_assets/ic_user_person.png",
                  isPdf: true,
                  jobTitle: "Employee",
                  date: "24 Jan 2024 at 12 : 00 PM"),
              CommentsModel(
                  name: "Mazen Shabaan",
                  description: "My Comment",
                  startTime: DateTime.now(),
                  imagPath:
                      "assets/icons_assets/main_icons_assets/ic_user_person.png",
                  isPdf: false,
                  jobTitle: "Employee",
                  date: "24 Jan 2024 at 12 : 00 PM")
            ],
            controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media',
            ),
            department: "Media",
            describtion:
                "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
            auditFrequency: "Bi-Weekly",
            score: 100,
            justifications:
                "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
            controlName: 'Control 1',
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
            controlStatus: 'Active',
            isActive: true,
            controlWeight: 5,
            lastEdit: '2024-09-01',
          ),
          Control(
            approvalsList: [],
            commentsModelList: [],
            controlAuditor: ControlOwner(
                assignedBy: 'Mazen Shabaan',
                assignedByImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                endDate: '22 Oct 2024',
                startDate: '21 Oct 2024',
                controlOwnerImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                controlOwner: 'Amro Handousa',
                controlOwnerDepartment: 'Media'),
            department: "Media",
            describtion:
                "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
            auditFrequency: "Bi-Weekly",
            score: 100,
            controlName: 'Control 2',
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
                controlOwner: null,
                controlOwnerDepartment: null,
                controlOwnerImage: null,
              ),
            ],
            controlStatus: 'Inactive',
            controlWeight: 0,
            lastEdit: '2024-09-05',
          ),
          Control(
            approvalsList: [],
            commentsModelList: [],
            controlAuditor: ControlOwner(
                assignedBy: 'Mazen Shabaan',
                assignedByImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                endDate: '22 Oct 2024',
                startDate: '21 Oct 2024',
                controlOwnerImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                controlOwner: 'Amro Handousa',
                controlOwnerDepartment: 'Media'),
            department: "Media",
            describtion:
                "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
            auditFrequency: "Bi-Weekly",
            score: 0,
            controlName: 'Control 3',
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
              ControlOwner(
                assignedBy: 'Mazen Shabaan',
                assignedByImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                endDate: '22 Oct 2024',
                startDate: '21 Oct 2024',
                controlOwner: 'Jane Smith',
                controlOwnerDepartment: 'Finance',
                controlOwnerImage: null,
              ),
            ],
            controlStatus: 'Expired',
            controlWeight: 5,
            lastEdit: '11 Oct 2023',
          ),
          Control(
            approvalsList: [],
            commentsModelList: [],
            controlAuditor: ControlOwner(
                assignedBy: 'Mazen Shabaan',
                assignedByImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                endDate: '22 Oct 2024',
                startDate: '21 Oct 2024',
                controlOwnerImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                controlOwner: 'Amro Handousa',
                controlOwnerDepartment: 'Media'),
            department: "Media",
            describtion:
                "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
            auditFrequency: "Bi-Weekly",
            score: 100,
            controlName: 'Control 4',
            controlOwnerList: [],
            controlStatus: 'Draft',
            controlWeight: 5,
            lastEdit: '2024-09-15',
          ),
          Control(
            approvalsList: [],
            commentsModelList: [],
            controlAuditor: ControlOwner(
                assignedBy: 'Mazen Shabaan',
                assignedByImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                endDate: '22 Oct 2024',
                startDate: '21 Oct 2024',
                controlOwnerImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                controlOwner: 'Amro Handousa',
                controlOwnerDepartment: 'Media'),
            department: "Media",
            describtion:
                "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
            auditFrequency: "Bi-Weekly",
            score: 100,
            controlName: 'Control 5',
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
              ControlOwner(
                assignedBy: 'Mazen Shabaan',
                assignedByImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                endDate: '22 Oct 2024',
                startDate: '21 Oct 2024',
                controlOwner: 'Alice Johnson',
                controlOwnerDepartment: 'HR',
                controlOwnerImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
              )
            ],
            controlStatus: 'Active',
            isActive: true,
            controlWeight: 5,
            lastEdit: '2024-09-20',
          ),
        ]),
    Policy(
      auditDepartment: [
        AuditDepartment(name: 'Marketing', score: 100),
        AuditDepartment(name: 'HR', score: 60),
        AuditDepartment(name: 'Design', score: 20),
        AuditDepartment(name: 'Software', score: 80),
      ],
      department: "Media", score: 100,
      allowPartialCompliance: true,
      describtionArabic:
          'loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum',
      endDate: '20 Oct 2024',
      hasArabicVersion: true,
      nameArabic: 'بوليسة',
      policyDocument: '',
      policyNumber: 'Ecg22scsldas',
      startDate: '11 Oct 2023',
      imageUrl:
          "assets/icons_assets/main_icons_assets/img_image_placeholder_large.png",
      creationDate: '01 Oct 2024',
      lastEditDate: '01 Oct 2024',
      name: 'Policy 2',

      status: 'Active',
      isActive: true,
      describtion:
          "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
      weight: 15, // Adjust the weight
      controls: [
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 6',
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
          controlStatus: 'Active',
          isActive: true,
          controlWeight: 5,
          lastEdit: '2024-09-01',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 7',
          controlOwnerList: [],
          controlStatus: 'Inactive',
          controlWeight: 0,
          lastEdit: '2024-09-05',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 8',
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
            ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwner: 'Jane Smith',
              controlOwnerDepartment: 'Finance',
              controlOwnerImage: null,
            ),
          ],
          controlStatus: 'Expired',
          controlWeight: 5,
          lastEdit: '11 Oct 2023',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 9',
          controlOwnerList: [],
          controlStatus: 'Draft',
          controlWeight: 5,
          lastEdit: '2024-09-15',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 19',
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
            ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwner: 'Alice Johnson',
              controlOwnerDepartment: 'HR',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
            )
          ],
          controlStatus: 'Active',
          isActive: true,
          controlWeight: 5,
          lastEdit: '2024-09-20',
        ),
      ],
    ),
    Policy(
      auditDepartment: [
        AuditDepartment(name: 'Marketing', score: 100),
        AuditDepartment(name: 'HR', score: 60),
        AuditDepartment(name: 'Design', score: 20),
      ],
      department: "Media", score: 100,
      allowPartialCompliance: true,
      describtionArabic:
          'loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum',
      endDate: '20 Oct 2024',
      hasArabicVersion: true,
      nameArabic: 'بوليسة',
      policyDocument: '',
      policyNumber: 'Ecg22scsldas',
      startDate: '11 Oct 2023',
      imageUrl:
          "assets/icons_assets/main_icons_assets/img_image_placeholder_large.png",
      creationDate: '01 Oct 2024',
      lastEditDate: '01 Oct 2024',
      name: 'Policy 3',

      status: 'Inactive',
      isActive: false,
      controls: [
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 11',
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
          controlStatus: 'Active',
          isActive: true,
          controlWeight: 5,
          lastEdit: '2024-09-01',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 12',
          controlOwnerList: [],
          controlStatus: 'Inactive',
          controlWeight: 0,
          lastEdit: '2024-09-05',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 13',
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
            ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwner: 'Jane Smith',
              controlOwnerDepartment: 'Finance',
              controlOwnerImage: null,
            ),
          ],
          controlStatus: 'Expired',
          controlWeight: 5,
          lastEdit: '11 Oct 2023',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 14',
          controlOwnerList: [],
          controlStatus: 'Draft',
          controlWeight: 5,
          lastEdit: '2024-09-15',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 15',
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
            ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwner: 'Alice Johnson',
              controlOwnerDepartment: 'HR',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
            )
          ],
          controlStatus: 'Active',
          isActive: true,
          controlWeight: 5,
          lastEdit: '2024-09-20',
        ),
      ],
      describtion:
          "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
      weight: 10, // Adjust the weight
    ),
    Policy(
      auditDepartment: [
        AuditDepartment(name: 'Marketing', score: 100),
        AuditDepartment(name: 'HR', score: 60),
        AuditDepartment(name: 'Design', score: 20),
      ],
      department: "Media", score: 100,
      allowPartialCompliance: true,
      describtionArabic:
          'loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum',
      endDate: '20 Oct 2024',
      hasArabicVersion: true,
      nameArabic: 'بوليسة',
      policyDocument: '',
      policyNumber: 'Ecg22scsldas',
      startDate: '11 Oct 2023',
      imageUrl:
          "assets/icons_assets/main_icons_assets/img_image_placeholder_large.png",
      creationDate: '01 Oct 2024',
      lastEditDate: '01 Oct 2024',
      name: 'Policy 4',

      describtion:
          "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
      status: 'Expired',
      isActive: true,
      weight: 10, // Adjust the weight
      controls: [
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 16',
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
          controlStatus: 'Active',
          isActive: true,
          controlWeight: 5,
          lastEdit: '2024-09-01',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 17',
          controlOwnerList: [],
          controlStatus: 'Inactive',
          controlWeight: 0,
          lastEdit: '2024-09-05',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 18',
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
            ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwner: 'Jane Smith',
              controlOwnerDepartment: 'Finance',
              controlOwnerImage: null,
            ),
          ],
          controlStatus: 'Expired',
          controlWeight: 5,
          lastEdit: '11 Oct 2023',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 19',
          controlOwnerList: [],
          controlStatus: 'Draft',
          controlWeight: 5,
          lastEdit: '2024-09-15',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 20',
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
            ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwner: 'Alice Johnson',
              controlOwnerDepartment: 'HR',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
            )
          ],
          controlStatus: 'Active',
          isActive: true,
          controlWeight: 5,
          lastEdit: '2024-09-20',
        ),
      ],
    ),
    Policy(
      auditDepartment: [
        AuditDepartment(name: 'Marketing', score: 100),
        AuditDepartment(name: 'HR', score: 60),
        AuditDepartment(name: 'Design', score: 20),
      ],
      department: "Media", score: 100,
      allowPartialCompliance: true,
      describtionArabic:
          'loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum',
      endDate: '20 Oct 2024',
      hasArabicVersion: true,
      nameArabic: 'بوليسة',
      policyDocument: '',
      policyNumber: 'Ecg22scsldas',
      startDate: '11 Oct 2023',
      imageUrl:
          "assets/icons_assets/main_icons_assets/img_image_placeholder_large.png",
      creationDate: '01 Oct 2024',
      lastEditDate: '01 Oct 2024',
      name: 'Policy 5',

      status: 'Draft',
      isActive: true,
      describtion:
          "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
      weight: 15, // Adjust the weight
      controls: [
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 21',
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
          controlStatus: 'Active',
          isActive: true,
          controlWeight: 5,
          lastEdit: '2024-09-01',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 22',
          controlOwnerList: [],
          controlStatus: 'Inactive',
          controlWeight: 0,
          lastEdit: '2024-09-05',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 23',
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
            ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwner: 'Jane Smith',
              controlOwnerDepartment: 'Finance',
              controlOwnerImage: null,
            ),
          ],
          controlStatus: 'Expired',
          controlWeight: 5,
          lastEdit: '11 Oct 2023',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 24',
          controlOwnerList: [],
          controlStatus: 'Draft',
          controlWeight: 5,
          lastEdit: '2024-09-15',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 25',
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
            ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwner: 'Alice Johnson',
              controlOwnerDepartment: 'HR',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
            )
          ],
          controlStatus: 'Active',
          isActive: true,
          controlWeight: 5,
          lastEdit: '2024-09-20',
        ),
      ],
    ),
    Policy(
        auditDepartment: [
          AuditDepartment(name: 'Marketing', score: 100),
          AuditDepartment(name: 'HR', score: 60),
          AuditDepartment(name: 'Design', score: 20),
        ],
        department: "Media",
        score: 100,
        allowPartialCompliance: true,
        describtionArabic:
            'loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum',
        endDate: '20 Oct 2024',
        hasArabicVersion: true,
        nameArabic: 'بوليسة',
        policyDocument: '',
        policyNumber: 'Ecg22scsldas',
        startDate: '11 Oct 2023',
        imageUrl:
            "assets/icons_assets/main_icons_assets/img_image_placeholder_large.png",
        creationDate: '01 Oct 2024',
        lastEditDate: '01 Oct 2024',
        name: 'Policy 6',
        describtion:
            "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
        status: 'Active',
        isActive: true,
        weight: 10, // Adjust the weight
        controls: [
          Control(
            approvalsList: [],
            commentsModelList: [],
            controlAuditor: ControlOwner(
                assignedBy: 'Mazen Shabaan',
                assignedByImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                endDate: '22 Oct 2024',
                startDate: '21 Oct 2024',
                controlOwnerImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                controlOwner: 'Amro Handousa',
                controlOwnerDepartment: 'Media'),
            department: "Media",
            describtion:
                "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
            auditFrequency: "Bi-Weekly",
            score: 100,
            controlName: 'Control 26',
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
            controlStatus: 'Active',
            isActive: true,
            controlWeight: 5,
            lastEdit: '2024-09-01',
          ),
          Control(
            approvalsList: [],
            commentsModelList: [],
            controlAuditor: ControlOwner(
                assignedBy: 'Mazen Shabaan',
                assignedByImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                endDate: '22 Oct 2024',
                startDate: '21 Oct 2024',
                controlOwnerImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                controlOwner: 'Amro Handousa',
                controlOwnerDepartment: 'Media'),
            department: "Media",
            describtion:
                "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
            auditFrequency: "Bi-Weekly",
            score: 100,
            controlName: 'Control 27',
            controlOwnerList: [],
            controlStatus: 'Inactive',
            controlWeight: 0,
            lastEdit: '2024-09-05',
          ),
          Control(
            approvalsList: [],
            commentsModelList: [],
            controlAuditor: ControlOwner(
                assignedBy: 'Mazen Shabaan',
                assignedByImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                endDate: '22 Oct 2024',
                startDate: '21 Oct 2024',
                controlOwnerImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                controlOwner: 'Amro Handousa',
                controlOwnerDepartment: 'Media'),
            department: "Media",
            describtion:
                "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
            auditFrequency: "Bi-Weekly",
            score: 100,
            controlName: 'Control 28',
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
              ControlOwner(
                assignedBy: 'Mazen Shabaan',
                assignedByImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                endDate: '22 Oct 2024',
                startDate: '21 Oct 2024',
                controlOwner: 'Jane Smith',
                controlOwnerDepartment: 'Finance',
                controlOwnerImage: null,
              ),
            ],
            controlStatus: 'Expired',
            controlWeight: 5,
            lastEdit: '11 Oct 2023',
          ),
          Control(
            approvalsList: [],
            commentsModelList: [],
            controlAuditor: ControlOwner(
                assignedBy: 'Mazen Shabaan',
                assignedByImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                endDate: '22 Oct 2024',
                startDate: '21 Oct 2024',
                controlOwnerImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                controlOwner: 'Amro Handousa',
                controlOwnerDepartment: 'Media'),
            department: "Media",
            describtion:
                "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
            auditFrequency: "Bi-Weekly",
            score: 100,
            controlName: 'Control 29',
            controlOwnerList: [],
            controlStatus: 'Draft',
            controlWeight: 5,
            lastEdit: '2024-09-15',
          ),
          Control(
            approvalsList: [],
            commentsModelList: [],
            controlAuditor: ControlOwner(
                assignedBy: 'Mazen Shabaan',
                assignedByImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                endDate: '22 Oct 2024',
                startDate: '21 Oct 2024',
                controlOwnerImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                controlOwner: 'Amro Handousa',
                controlOwnerDepartment: 'Media'),
            department: "Media",
            describtion:
                "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
            auditFrequency: "Bi-Weekly",
            score: 100,
            controlName: 'Control 30',
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
              ControlOwner(
                assignedBy: 'Mazen Shabaan',
                assignedByImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
                endDate: '22 Oct 2024',
                startDate: '21 Oct 2024',
                controlOwner: 'Alice Johnson',
                controlOwnerDepartment: 'HR',
                controlOwnerImage:
                    'assets/icons_assets/main_icons_assets/ic_user_person.png',
              )
            ],
            controlStatus: 'Active',
            isActive: true,
            controlWeight: 5,
            lastEdit: '2024-09-20',
          ),
        ]),
    Policy(
      auditDepartment: [
        AuditDepartment(name: 'Marketing', score: 100),
        AuditDepartment(name: 'HR', score: 60),
        AuditDepartment(name: 'Design', score: 20),
      ],
      department: "Media", score: 100,
      allowPartialCompliance: true,
      describtionArabic:
          'loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum',
      endDate: '20 Oct 2024',
      hasArabicVersion: true,
      nameArabic: 'بوليسة',
      policyDocument: '',
      policyNumber: 'Ecg22scsldas',
      startDate: '11 Oct 2023',
      imageUrl:
          "assets/icons_assets/main_icons_assets/img_image_placeholder_large.png",
      creationDate: '01 Oct 2024',
      lastEditDate: '01 Oct 2024',
      describtion:
          "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
      name: 'Policy 8',

      status: 'Active',
      isActive: true,
      controls: [
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 31',
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
          controlStatus: 'Active',
          isActive: true,
          controlWeight: 5,
          lastEdit: '2024-09-01',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 32',
          controlOwnerList: [],
          controlStatus: 'Inactive',
          controlWeight: 0,
          lastEdit: '2024-09-05',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 33',
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
            ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwner: 'Jane Smith',
              controlOwnerDepartment: 'Finance',
              controlOwnerImage: null,
            ),
          ],
          controlStatus: 'Expired',
          controlWeight: 5,
          lastEdit: '11 Oct 2023',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 34',
          controlOwnerList: [],
          controlStatus: 'Draft',
          controlWeight: 5,
          lastEdit: '2024-09-15',
        ),
        Control(
          approvalsList: [],
          commentsModelList: [],
          controlAuditor: ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              controlOwner: 'Amro Handousa',
              controlOwnerDepartment: 'Media'),
          department: "Media",
          describtion:
              "loremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsumloremIpsum",
          auditFrequency: "Bi-Weekly",
          score: 100,
          controlName: 'Control 35',
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
            ControlOwner(
              assignedBy: 'Mazen Shabaan',
              assignedByImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
              endDate: '22 Oct 2024',
              startDate: '21 Oct 2024',
              controlOwner: 'Alice Johnson',
              controlOwnerDepartment: 'HR',
              controlOwnerImage:
                  'assets/icons_assets/main_icons_assets/ic_user_person.png',
            )
          ],
          controlStatus: 'Active',
          isActive: true,
          controlWeight: 5,
          lastEdit: '2024-09-20',
        ),
      ],
      weight: 15, // Adjust the weight
    ),
  ];
}

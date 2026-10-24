// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:knowticed_plus/core/helper/localized_date.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/enums/enum.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/data/modules/module_firestore.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/entity/policy.dart';

import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/data_grc_2/features/home_page/Utils/home_constants.dart';

class ModuleEntity {
  String name;
  String nameArabic;
  String describtion;
  String describtionArabic;
  String department;
  String activationDate;
  String imageUrl;
  String creationDate;
  String latUpdate;
  String score;
  List<String> status;
  List<String> moduleOwner;
  List<Policy> policies;
  ModuleEntity({
    required this.name,
    required this.nameArabic,
    required this.describtion,
    required this.describtionArabic,
    required this.department,
    required this.activationDate,
    required this.imageUrl,
    required this.creationDate,
    required this.latUpdate,
    required this.score,
    required this.status,
    required this.moduleOwner,
    required this.policies,
  });

  static ModuleEntity moduleFireBasetoEntity(ModuleFirestore moduleFirestore) {
    return ModuleEntity(
      activationDate: moduleFirestore.activationDate.last,
      imageUrl: moduleFirestore.imageUrl.last,
      department: moduleFirestore.owningDepartment.last,
      describtion: moduleFirestore.describtion.last,
      describtionArabic: moduleFirestore.describtionArabic.last,
      name: moduleFirestore.name.last,
      nameArabic: moduleFirestore.nameArabic.last,
      latUpdate: capitalize(LocalizedDate.forLocale(
          moduleFirestore.timeStamp.last.toDate(), 'en')),
      status: moduleFirestore.status,
      creationDate: capitalize(LocalizedDate.forLocale(
          moduleFirestore.timeStamp.first.toDate(), 'en')),
      moduleOwner: [],
      policies: HomeConstants.policies,
      score: '',
    );
  }
}

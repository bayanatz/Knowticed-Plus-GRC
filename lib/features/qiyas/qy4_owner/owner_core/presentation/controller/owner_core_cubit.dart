import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/visions.dart';
import 'package:knowticed_plus/features/qiyas/qy2_champions/champigan_core/data/repository/champigan_repository.dart';

import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';

part 'owner_core_state.dart';

class OwnerCoreCubit extends Cubit<OwnerCoreState> {
  OwnerCoreCubit() : super(OwnerCoreInitial()) {
//    initCubit();
  }
  OwnerRepository ownerRepository = OwnerRepository();
  List<QiyasChampionEntity> ownerAccessList = [];
  List<Visions> visionsList = [];

  Future<void> getOwnerAccessList() async {
    final response = await ownerRepository.getOwnerAccessList(
        ownerId: Get.find<MainCoreEmployeeController>().employeeEntity!.email!);
    if (response.isLeft()) return;
    ownerAccessList =
        response.fold((_) => List<QiyasChampionEntity>.from([]), (r) => r);
  }

  Future<void> getAccessedCriteriaList() async {
    List<String> criteriaNumbers = [];
    for (var element in ownerAccessList) {
      criteriaNumbers.add(element.criteriaId.trim());
    }
    final response = await ownerRepository.getAccessedCriteriaList(
        criteriaNumbers: criteriaNumbers);
    if (response.isLeft()) return;
    visionsList = response.fold((_) => List<Visions>.from([]), (r) => r);
  }

  Future<void> initCubit() async {
    await getOwnerAccessList();
    await getAccessedCriteriaList();
    // sl<QiyasHomeCubit>().getVisions(visionsList);
  }
}

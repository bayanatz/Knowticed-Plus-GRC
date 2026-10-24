import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/visions.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/entities/qiyas_champion_entity.dart';
import 'package:knowticed_plus/features/qiyas/qy4_owner/owner_core/data/repository/owner_repository.dart';

part 'champigan_core_state.dart';

class ChampiganCoreCubit extends Cubit<ChampiganCoreState> {
  ChampiganCoreCubit() : super(ChampiganCoreInitial()) {
    initCubit();
  }
  ChampiganRepository champiganRepository = ChampiganRepository();
  List<QiyasChampionEntity> champiganAccessList = [];
  List<Visions> visionsList = [];

  Future<void> getChampiganAccessList() async {
    final response = await champiganRepository.getChampiganAccessList(
        championId:
            Get.find<MainCoreEmployeeController>().employeeEntity!.email!);
    if (response.isLeft()) return;
    champiganAccessList =
        response.fold((_) => List<QiyasChampionEntity>.from([]), (r) => r);
  }

  Future<void> getAccessedCriteriaList() async {
    List<String> criteriaNumbers = [];
    for (var element in champiganAccessList) {
      criteriaNumbers.add(element.criteriaId.trim());
    }
    final response = await champiganRepository.getAccessedCriteriaList(
        criteriaNumbers: criteriaNumbers);
    if (response.isLeft()) return;
    visionsList = response.fold((_) => List<Visions>.from([]), (r) => r);
  }

  Future<void> initCubit() async {
    await getChampiganAccessList();
    await getAccessedCriteriaList();
    //sl<QiyasHomeCubit>().getVisions(visionsList);
  }
}

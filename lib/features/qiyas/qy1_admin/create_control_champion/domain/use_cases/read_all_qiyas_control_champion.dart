/// ***************************** FILE INFO ***************************** ///
/// File Name: read_all_qiyas_control_champion.dart
/// Purpose: Defines the use case for reading all Qiyas Control Champions.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file contains the `ReadAllQiyasControlChampionUsecase` class, which encapsulates the business logic for fetching
///              all Qiyas Control Champions. It interacts with the `QiyasChampionRepo` repository to retrieve the list of Qiyas
///              Champion officers. The use case is part of the application layer and provides an abstraction over the repository
///              layer, ensuring that the logic is centralized and reusable across the application. It returns an `Either<Failure, List<T>>`
///              to handle both successful and failed operations gracefully.
/// ********************************************************************* ///
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart' show Failure;
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/base_repository/qiyas_champion_repo.dart';

class ReadAllQiyasControlChampionUsecase {
  final QiyasChampionRepo repository;

  ReadAllQiyasControlChampionUsecase(this.repository);

  Future<Either<Failure, List<QiyasChampionModel>>> execute() async {
    return await repository.readAllQiyasControlChampions();
  }
}

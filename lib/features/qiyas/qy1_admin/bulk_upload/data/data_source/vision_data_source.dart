/// ***************************** FILE INFO ***************************** ///
/// File Name: vision_data_source.dart
/// Purpose: Defines the data source operations related to vision data (create, edit, delete, read) in Firestore.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This file defines an abstract data source class and its implementation for interacting with
///              Firestore to perform CRUD operations on vision data. The `VisionDataSourceImpl` class implements
///              methods for creating, editing, reading, and deleting vision data, using a `FireBaseHelper` for
///              Firestore interactions.
/// ********************************************************************* ///
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/core/app_services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/qiyas/helpers/constant/api_constant.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/features/qiyas/helpers/helper/firebase_helper.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/models/vision_firestore.dart';

class VisionDataSource {
  FireBaseHelper<VisionModel> helper;
  VisionDataSource({required this.helper});
  WriteBatch? _batch;
  Future<void> createVision(VisionModel vision) async {
    FirebaseRepository.setDocumentWithIdWithBatch(
        collection: getBaseUrl(ApiConstant.kVisionNameCollection),
        data: vision.toMap(),
        documentId: vision.id,
        batch: _batch!);
  }

  void startTransaction() {
    _batch = FirebaseFirestore.instance.batch();
  }

  Future<Either<FirebaseFailure, dynamic>> commitTransaction() async {
    Either<FirebaseFailure, void> result;
    try {
      await _batch!.commit();
      result = Right(null);
    } catch (e) {
      result = Left(FirebaseFailure(e.toString()));
    }
    return result;
  }

  Future<void> deleteVision(VisionModel vision) {
    // TODO: implement deleteModule
    throw UnimplementedError();
  }

  Future<void> editVision(VisionModel vision) async {
    try {
      return await helper.editItem(
          "name", vision.visionName.last, vision.toMap());
    } on ServerFailure {
      rethrow;
    }
  }

  Future<List<VisionModel>> readALLVisions() async {
    try {
      return await helper.getItems();
    } on ServerFailure {
      rethrow;
    }
  }
}

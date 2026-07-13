///********************** FILE INFO ****************************///
/// File Name: home_remote_data_source.dart
/// Purpose: Remote data source for updating home components in Firebase
/// Author: Mohamed Elrashidy
/// Created at: 21/9/2025

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/api_constants.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/core/services/firebase/repository/firebase_repository.dart';
import 'package:demo_app/features/home/home_page/data_source/models/home_page_layout_model.dart';

class HomeRemoteDataSource {
  /// Function Name: [updateHomeComponents]
  ///
  /// Purpose: Update the home components layout in Firebase
  ///
  /// Parameters:
  /// - [layoutModel]: The layout model containing the updated components and app bar options
  updateHomeComponents(HomePageLayoutModel layoutModel) async {
    return await FirebaseRepository.setDocumentWithId(
        collection: ApiConstants.homeLayout,
        data: layoutModel.toMap(),
        documentId: layoutModel.id);
  }

  /// Function Name: [getHomeLayout]
  ///
  /// Purpose: Retrieve the home layout for a specific user from Firebase
  ///
  /// Parameters:
  /// - [currentUserEmail]: The email of the current user to fetch the layout for
  Future<Either<Failure, dynamic>> getHomeLayout(
      String currentUserEmail) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: ApiConstants.homeLayout, documentId: currentUserEmail);
  }
}

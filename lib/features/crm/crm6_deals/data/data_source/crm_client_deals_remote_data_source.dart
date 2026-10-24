// ****************** FILE INFO ******************
// File Name: crm_client_deals_remote_data_source.dart
// Purpose: Firestore persistence for client-owned deal transactions.
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_record_model.dart';

class CrmClientDealsRemoteDataSource {
  final FirebaseFirestore _firestore;
  CrmClientDealsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<Either<Failure, List<CrmClientDealRecordModel>>> watchClientDeals(
      {required String clientId}) async* {
    try {
      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in _firestore
              .collection(CrmFirestorePaths.clientDeals(clientId))
              .orderBy('Created_At', descending: true)
              .snapshots()) {
        yield Right(snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                CrmClientDealRecordModel.fromMap(doc.data()))
            .where((CrmClientDealRecordModel deal) => deal.status != 'archived')
            .toList());
      }
    } catch (error) {
      yield Left(FirebaseFailure(error.toString()));
    }
  }

  Stream<Either<Failure, CrmClientDealRecordModel?>> watchClientDeal(
      {required String clientId, required String dealId}) async* {
    try {
      await for (final DocumentSnapshot<Map<String, dynamic>> snapshot
          in _firestore
              .collection(CrmFirestorePaths.clientDeals(clientId))
              .doc(dealId)
              .snapshots()) {
        yield Right(snapshot.exists && snapshot.data() != null
            ? CrmClientDealRecordModel.fromMap(snapshot.data()!)
            : null);
      }
    } catch (error) {
      yield Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, CrmClientDealRecordModel>> createClientDeal(
      {required CrmClientDealRecordModel deal}) async {
    try {
      final DocumentReference<Map<String, dynamic>> reference = _firestore
          .collection(CrmFirestorePaths.clientDeals(deal.clientId))
          .doc();
      final DocumentReference<Map<String, dynamic>> createdEvent =
          reference.collection('Timeline').doc();
      final CrmClientDealRecordModel persisted = CrmClientDealRecordModel(
        id: reference.id,
        clientId: deal.clientId,
        categoryId: deal.categoryId,
        categoryNameEn: deal.categoryNameEn,
        categoryNameAr: deal.categoryNameAr,
        currentStageId: deal.currentStageId,
        stageNameEn: deal.stageNameEn,
        stageNameAr: deal.stageNameAr,
        assignedEmployeeId: deal.assignedEmployeeId,
        assignedEmployeeName: deal.assignedEmployeeName,
        nameEn: deal.nameEn,
        nameAr: deal.nameAr,
        noteEn: deal.noteEn,
        noteAr: deal.noteAr,
        currency: deal.currency,
        expectedValue: deal.expectedValue,
        likelihood: deal.likelihood,
        startDate: deal.startDate,
        closeDate: deal.closeDate,
        status: deal.status,
        subtotal: deal.subtotal,
        discountTotal: deal.discountTotal,
        taxTotal: deal.taxTotal,
        grandTotal: deal.grandTotal,
        productLines: deal.productLines,
        serviceLines: deal.serviceLines,
        checklist: deal.checklist,
        createdAt: deal.createdAt,
        createdBy: deal.createdBy,
      );
      await _firestore.runTransaction((Transaction transaction) async {
        transaction.set(reference, persisted.toMap());
        transaction.set(
          createdEvent,
          _eventMap('created', 'Deal created', persisted.createdBy),
        );
      });
      return Right(persisted);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, CrmClientDealRecordModel>> updateClientDeal(
      {required CrmClientDealRecordModel deal}) async {
    try {
      final DocumentReference<Map<String, dynamic>> reference = _firestore
          .collection(CrmFirestorePaths.clientDeals(deal.clientId))
          .doc(deal.id);
      await reference.set(deal.toMap(), SetOptions(merge: true));
      await reference.collection('Timeline').add(
            _eventMap(
                'details_updated', 'Deal details updated', deal.createdBy),
          );
      return Right(deal);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, Unit>> moveClientDealStage({
    required String clientId,
    required String dealId,
    required String stageId,
    required String stageNameEn,
    required String stageNameAr,
    required String changedBy,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> deal = _firestore
          .collection(CrmFirestorePaths.clientDeals(clientId))
          .doc(dealId);
      final DocumentReference<Map<String, dynamic>> event =
          deal.collection('Timeline').doc();
      await _firestore.runTransaction((Transaction transaction) async {
        transaction.update(deal, <String, dynamic>{
          'Current_Stage_Id': stageId,
          'Stage_Name_En': stageNameEn,
          'Stage_Name_Ar': stageNameAr,
          'Updated_At': FieldValue.serverTimestamp(),
          'Updated_By': changedBy,
        });
        transaction.set(event,
            _eventMap('stage_moved', 'Stage moved to $stageNameEn', changedBy));
      });
      return const Right(unit);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, Unit>> updateChecklistProgress({
    required String clientId,
    required String dealId,
    required List<Map<String, dynamic>> checklist,
    required String changedBy,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> deal = _firestore
          .collection(CrmFirestorePaths.clientDeals(clientId))
          .doc(dealId);
      await deal.update(<String, dynamic>{
        'Stage_Checklist': checklist,
        'Updated_At': FieldValue.serverTimestamp(),
        'Updated_By': changedBy
      });
      await deal.collection('Timeline').add(
          _eventMap('checklist_updated', 'Stage checklist updated', changedBy));
      return const Right(unit);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, Unit>> archiveClientDeal(
      {required String clientId, required String dealId}) async {
    try {
      final DocumentReference<Map<String, dynamic>> deal = _firestore
          .collection(CrmFirestorePaths.clientDeals(clientId))
          .doc(dealId);
      await deal.update(<String, dynamic>{
        'Status': 'archived',
        'Updated_At': FieldValue.serverTimestamp()
      });
      await deal
          .collection('Timeline')
          .add(_eventMap('archived', 'Deal archived', ''));
      return const Right(unit);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Map<String, dynamic> _eventMap(String type, String message, String user) =>
      <String, dynamic>{
        'Type': type,
        'Message': message,
        'Changed_By': user,
        'Changed_At': FieldValue.serverTimestamp(),
      };
}

// ****************** FILE INFO ******************
// File Name: crm_client_quotes_remote_data_source.dart
// Purpose: Firestore persistence for quotes scoped to a client deal.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_quote_record_model.dart';

class CrmClientQuotesRemoteDataSource {
  final FirebaseFirestore _firestore;
  CrmClientQuotesRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _quotes(
          String clientId, String dealId) =>
      _firestore
          .collection(CrmFirestorePaths.clientDealQuotes(clientId, dealId));

  Stream<Either<Failure, List<CrmClientQuoteRecordModel>>>
      watchClientDealQuotes(
          {required String clientId, required String dealId}) async* {
    try {
      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in _quotes(clientId, dealId)
              .orderBy('Created_At', descending: true)
              .snapshots()) {
        yield Right(snapshot.docs
            .map((doc) => CrmClientQuoteRecordModel.fromMap(doc.data()))
            .toList());
      }
    } catch (error) {
      yield Left(FirebaseFailure(error.toString()));
    }
  }

  Stream<Either<Failure, CrmClientQuoteRecordModel?>> watchClientDealQuote(
      {required String clientId,
      required String dealId,
      required String quoteId}) async* {
    try {
      await for (final DocumentSnapshot<Map<String, dynamic>> snapshot
          in _quotes(clientId, dealId).doc(quoteId).snapshots()) {
        yield Right(snapshot.exists && snapshot.data() != null
            ? CrmClientQuoteRecordModel.fromMap(snapshot.data()!)
            : null);
      }
    } catch (error) {
      yield Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, CrmClientQuoteRecordModel>> createClientDealQuote(
      {required CrmClientQuoteRecordModel quote}) async {
    try {
      final DocumentReference<Map<String, dynamic>> reference =
          _quotes(quote.clientId, quote.dealId).doc();
      final DocumentReference<Map<String, dynamic>> deal = _firestore
          .collection(CrmFirestorePaths.clientDeals(quote.clientId))
          .doc(quote.dealId);
      final DocumentReference<Map<String, dynamic>> event =
          deal.collection('Timeline').doc();
      final CrmClientQuoteRecordModel persisted = CrmClientQuoteRecordModel(
        id: reference.id,
        clientId: quote.clientId,
        dealId: quote.dealId,
        quoteNo: 'QT-${reference.id.substring(0, 8).toUpperCase()}',
        quoteFamilyId:
            quote.quoteFamilyId.isEmpty ? reference.id : quote.quoteFamilyId,
        sourceQuoteId: quote.sourceQuoteId,
        status: quote.status,
        version: quote.version,
        quoteDate: quote.quoteDate,
        validUntil: quote.validUntil,
        currency: quote.currency,
        productLines: quote.productLines,
        serviceLines: quote.serviceLines,
        subtotal: quote.subtotal,
        discountTotal: quote.discountTotal,
        taxTotal: quote.taxTotal,
        grandTotal: quote.grandTotal,
        paymentTerm: quote.paymentTerm,
        deliveryTerm: quote.deliveryTerm,
        noteEn: quote.noteEn,
        noteAr: quote.noteAr,
        attachments: quote.attachments,
        createdAt: quote.createdAt,
        createdBy: quote.createdBy,
        decisionBy: quote.decisionBy,
        decisionAt: quote.decisionAt,
        rejectReason: quote.rejectReason,
      );
      await _firestore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> dealSnapshot =
            await transaction.get(deal);
        if (!dealSnapshot.exists ||
            dealSnapshot.data()?['Status'] == 'archived') {
          throw StateError('The client deal is unavailable for quotes.');
        }
        transaction.set(reference, persisted.toMap());
        transaction.set(event, <String, dynamic>{
          'Type':
              quote.status == 'pending' ? 'quote_submitted' : 'quote_drafted',
          'Message':
              'Quote ${persisted.quoteNo} ${quote.status == 'pending' ? 'submitted for approval' : 'saved as draft'}',
          'Changed_By': quote.createdBy,
          'Changed_At': FieldValue.serverTimestamp(),
        });
      });
      return Right(persisted);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> updateQuoteStatus(
      {required String clientId,
      required String dealId,
      required String quoteId,
      required String status,
      required String changedBy}) async {
    try {
      final DocumentReference<Map<String, dynamic>> quote =
          _quotes(clientId, dealId).doc(quoteId);
      await quote.update(<String, dynamic>{
        'Status': status,
        'Updated_At': FieldValue.serverTimestamp(),
        'Updated_By': changedBy
      });
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> decideQuoteRequest({
    required String clientId,
    required String dealId,
    required String quoteId,
    required String decision,
    required String rejectReason,
    required String decidedBy,
  }) async {
    try {
      if (decision != 'approved' && decision != 'reject') {
        throw ArgumentError.value(decision, 'decision');
      }
      if (decision == 'reject' && rejectReason.trim().isEmpty) {
        throw StateError('A rejection reason is required.');
      }
      final DocumentReference<Map<String, dynamic>> quote =
          _quotes(clientId, dealId).doc(quoteId);
      final DocumentReference<Map<String, dynamic>> event = _firestore
          .collection(CrmFirestorePaths.clientDeals(clientId))
          .doc(dealId)
          .collection('Timeline')
          .doc();
      await _firestore.runTransaction((Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> snapshot =
            await transaction.get(quote);
        if (!snapshot.exists) throw StateError('Quote not found.');
        if ('${snapshot.data()?['Status'] ?? ''}' != 'pending') {
          throw StateError('This request has already been decided.');
        }
        final String quoteNo = '${snapshot.data()?['Quote_No'] ?? quoteId}';
        transaction.update(quote, <String, dynamic>{
          'Status': decision,
          'Decision_By': decidedBy,
          'Decision_At': FieldValue.serverTimestamp(),
          'Reject_Reason': decision == 'reject' ? rejectReason.trim() : '',
          'Updated_At': FieldValue.serverTimestamp(),
          'Updated_By': decidedBy,
        });
        transaction.set(event, <String, dynamic>{
          'Type': decision == 'approved' ? 'quote_approved' : 'quote_rejected',
          'Message': decision == 'approved'
              ? 'Quote $quoteNo approved'
              : 'Quote $quoteNo rejected: ${rejectReason.trim()}',
          'Changed_By': decidedBy,
          'Changed_At': FieldValue.serverTimestamp(),
        });
      });
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> updateClientDealQuote({
    required CrmClientQuoteRecordModel quote,
    required String changedBy,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> reference =
          _quotes(quote.clientId, quote.dealId).doc(quote.id);
      final DocumentReference<Map<String, dynamic>> event = _firestore
          .collection(CrmFirestorePaths.clientDeals(quote.clientId))
          .doc(quote.dealId)
          .collection('Timeline')
          .doc();
      await _firestore.runTransaction((Transaction transaction) async {
        transaction.set(reference, quote.toMap(), SetOptions(merge: true));
        transaction.update(reference, <String, dynamic>{
          'Updated_At': FieldValue.serverTimestamp(),
          'Updated_By': changedBy,
        });
        transaction.set(event, <String, dynamic>{
          'Type': 'quote_updated',
          'Message': 'Quote ${quote.quoteNo} updated',
          'Changed_By': changedBy,
          'Changed_At': FieldValue.serverTimestamp(),
        });
      });
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> deleteQuote(
      {required String clientId,
      required String dealId,
      required String quoteId,
      required String changedBy}) async {
    try {
      final DocumentReference<Map<String, dynamic>> quote =
          _quotes(clientId, dealId).doc(quoteId);
      final DocumentReference<Map<String, dynamic>> event = _firestore
          .collection(CrmFirestorePaths.clientDeals(clientId))
          .doc(dealId)
          .collection('Timeline')
          .doc();
      await _firestore.runTransaction((Transaction transaction) async {
        final snapshot = await transaction.get(quote);
        if (!snapshot.exists) throw StateError('Quote not found.');
        final quoteNumber = snapshot.data()?['Quote_No'] ?? quoteId;
        transaction.delete(quote);
        transaction.set(event, <String, dynamic>{
          'Type': 'quote_deleted',
          'Message': 'Quote $quoteNumber deleted',
          'Changed_By': changedBy,
          'Changed_At': FieldValue.serverTimestamp(),
        });
      });
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }
}

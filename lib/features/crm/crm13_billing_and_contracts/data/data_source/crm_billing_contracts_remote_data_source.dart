// ****************** FILE INFO ******************
// File Name: crm_billing_contracts_remote_data_source.dart
// Purpose: Remote data source for CRM Billing and Contracts operations
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/data/models/crm_billing_contract_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';

class CrmBillingContractsRemoteDataSource {
  final FirebaseFirestore _firestore;
  FirebaseStorage? _storage;

  CrmBillingContractsRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage;

  Stream<Either<Failure, List<CrmBillingContractModel>>>
      watchBillingContracts() async* {
    try {
      await _ensureStaticControls();
      final Stream<QuerySnapshot<Map<String, dynamic>>> stream =
          _firestore.collection(CrmFirestorePaths.billingContracts).snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot in stream) {
        final List<CrmBillingContractModel> items = snapshot.docs
            .map((doc) => CrmBillingContractModel.fromMap(doc.data(), doc.id))
            .where((item) => item.isStaticControl)
            .toList();
        _sortStaticControls(items);
        yield Right(items);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<CrmBillingContractModel>>>
      getBillingContracts() async {
    try {
      await _ensureStaticControls();
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(CrmFirestorePaths.billingContracts).get();

      final List<CrmBillingContractModel> items = snapshot.docs
          .map((doc) => CrmBillingContractModel.fromMap(doc.data(), doc.id))
          .where((item) => item.isStaticControl)
          .toList();
      _sortStaticControls(items);
      return Right(items);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, CrmBillingContractModel>> createBillingContract({
    required CrmBillingContractModel item,
    required String changedBy,
  }) async {
    return Left(FeatureFailure(
      'Billing and Contract controls are fixed and cannot be created.',
    ));
  }

  Future<Either<Failure, void>> updateBillingContract({
    required CrmBillingContractModel item,
    required String changedBy,
  }) async {
    if (!item.isStaticControl) {
      return Left(
          FeatureFailure('Only the fixed control content can be edited.'));
    }
    try {
      await _ensureStaticControls();
      await _firestore
          .collection(CrmFirestorePaths.billingContracts)
          .doc(item.id)
          .update(_contentUpdateMap(item, changedBy));
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> uploadContentFile({
    required String controlId,
    required String field,
    required List<int> bytes,
    required String fileName,
  }) async {
    const Set<String> editableFields = <String>{
      CrmBillingContractModel.LOGO_URL,
      CrmBillingContractModel.DIGITAL_SEAL_URL,
      CrmBillingContractModel.WATERMARK_URL,
      CrmBillingContractModel.SIGNATURE_URL,
    };
    if ((controlId != CrmBillingContractModel.billingControlId &&
            controlId != CrmBillingContractModel.contractControlId) ||
        !editableFields.contains(field) ||
        bytes.isEmpty ||
        fileName.trim().isEmpty) {
      return Left(FeatureFailure('The selected file cannot be uploaded.'));
    }

    try {
      final FirebaseStorage storage = _resolveStorage();
      final String safeName =
          fileName.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final String uniqueName =
          '${DateTime.now().millisecondsSinceEpoch}_$safeName';
      final Reference reference = storage.ref().child(
            CrmFirestorePaths.billingContractFileStoragePath(
              controlId: controlId,
              field: field,
              fileName: uniqueName,
            ),
          );
      final TaskSnapshot uploaded = await reference.putData(
        Uint8List.fromList(bytes),
        SettableMetadata(
          customMetadata: <String, String>{
            'controlId': controlId,
            'field': field,
            'originalName': fileName,
          },
        ),
      );
      return Right(await uploaded.ref.getDownloadURL());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  FirebaseStorage _resolveStorage() {
    final FirebaseStorage? existing = _storage;
    if (existing != null) return existing;

    final FirebaseApp app = Firebase.app();
    final String? bucket = app.options.storageBucket;
    if (bucket == null || bucket.trim().isEmpty) {
      throw StateError('Firebase Storage is not configured for this app.');
    }

    final FirebaseStorage storage = FirebaseStorage.instanceFor(
      app: app,
      bucket: bucket,
    );
    _storage = storage;
    return storage;
  }

  Future<Either<Failure, void>> deleteBillingContract({
    required String id,
    required String changedBy,
  }) async {
    return Left(FeatureFailure(
      'Billing and Contract controls are fixed and cannot be deleted.',
    ));
  }

  Future<Either<Failure, void>> toggleBillingContractStatus({
    required String id,
    required bool isActive,
    required String changedBy,
  }) async {
    return Left(FeatureFailure(
      'Billing and Contract controls have a fixed active status.',
    ));
  }

  Future<void> _ensureStaticControls() async {
    final List<CrmBillingContractModel> controls = <CrmBillingContractModel>[
      CrmBillingContractModel(
        id: CrmBillingContractModel.billingControlId,
        code: 'BILLING_CONTROL',
        nameEn: 'Billing Control',
        nameAr: 'التحكم بالفوترة',
        descriptionEn:
            'Manage invoice template, files, message, notes and colors.',
        descriptionAr:
            'إدارة قالب الفاتورة والملفات والرسائل والملاحظات والألوان.',
        status: 'Active',
        textColorHex: '#2d2d2d',
        highlightColorHex: '#9e9e9e',
        notes: const <CrmBilingualNoteModel>[
          CrmBilingualNoteModel(),
          CrmBilingualNoteModel(),
          CrmBilingualNoteModel(),
        ],
        createdAt: DateTime.now(),
        updatedBy: 'system',
      ),
      CrmBillingContractModel(
        id: CrmBillingContractModel.contractControlId,
        code: 'CONTRACT_CONTROL',
        nameEn: 'Contract Control',
        nameAr: 'التحكم بالعقود',
        descriptionEn:
            'Manage contract template, files, message, notes and colors.',
        descriptionAr:
            'إدارة قالب العقد والملفات والرسائل والملاحظات والألوان.',
        status: 'Active',
        textColorHex: '#2d2d2d',
        highlightColorHex: '#9e9e9e',
        notes: const <CrmBilingualNoteModel>[
          CrmBilingualNoteModel(),
          CrmBilingualNoteModel(),
          CrmBilingualNoteModel(),
        ],
        contractSections: const <CrmBilingualNoteModel>[
          CrmBilingualNoteModel(),
          CrmBilingualNoteModel(),
          CrmBilingualNoteModel(),
        ],
        createdAt: DateTime.now(),
        updatedBy: 'system',
      ),
    ];

    final CollectionReference<Map<String, dynamic>> collection =
        _firestore.collection(CrmFirestorePaths.billingContracts);
    final List<DocumentSnapshot<Map<String, dynamic>>> documents =
        await Future.wait(
      controls.map(
        (CrmBillingContractModel item) => collection.doc(item.id).get(),
      ),
    );
    final WriteBatch batch = _firestore.batch();
    bool hasWrites = false;
    for (int index = 0; index < controls.length; index++) {
      final CrmBillingContractModel control = controls[index];
      final DocumentSnapshot<Map<String, dynamic>> document = documents[index];
      if (!_needsStaticMetadata(document.data(), control)) continue;
      batch.set(
        collection.doc(control.id),
        _staticMetadataMap(control, document.exists),
        SetOptions(merge: true),
      );
      hasWrites = true;
    }
    if (hasWrites) {
      await batch.commit();
    }
  }

  bool _needsStaticMetadata(
    Map<String, dynamic>? current,
    CrmBillingContractModel control,
  ) {
    if (current == null) return true;
    return current[CrmBillingContractModel.kId] != control.id ||
        current[CrmBillingContractModel.CODE] != control.code ||
        current[CrmBillingContractModel.kNameEn] != control.nameEn ||
        current[CrmBillingContractModel.kNameAr] != control.nameAr ||
        current[CrmBillingContractModel.DESCRIPTION_EN] !=
            control.descriptionEn ||
        current[CrmBillingContractModel.DESCRIPTION_AR] !=
            control.descriptionAr ||
        current[CrmBillingContractModel.kStatus] != 'Active' ||
        current[CrmBillingContractModel.kIsDeleted] != false;
  }

  Map<String, dynamic> _staticMetadataMap(
    CrmBillingContractModel control,
    bool alreadyExists,
  ) {
    return <String, dynamic>{
      CrmBillingContractModel.kId: control.id,
      CrmBillingContractModel.CODE: control.code,
      CrmBillingContractModel.kNameEn: control.nameEn,
      CrmBillingContractModel.kNameAr: control.nameAr,
      CrmBillingContractModel.DESCRIPTION_EN: control.descriptionEn,
      CrmBillingContractModel.DESCRIPTION_AR: control.descriptionAr,
      CrmBillingContractModel.kStatus: 'Active',
      CrmBillingContractModel.kIsDeleted: false,
      if (!alreadyExists) ...control.toMap(),
    };
  }

  Map<String, dynamic> _contentUpdateMap(
    CrmBillingContractModel item,
    String changedBy,
  ) {
    return <String, dynamic>{
      CrmBillingContractModel.LOGO_URL: item.logoUrl,
      CrmBillingContractModel.DIGITAL_SEAL_URL: item.digitalSealUrl,
      CrmBillingContractModel.WATERMARK_URL: item.watermarkUrl,
      CrmBillingContractModel.SIGNATURE_URL: item.signatureUrl,
      CrmBillingContractModel.MESSAGE_EN: item.messageEn,
      CrmBillingContractModel.MESSAGE_AR: item.messageAr,
      CrmBillingContractModel.NOTES:
          item.notes.map((CrmBilingualNoteModel note) => note.toMap()).toList(),
      CrmBillingContractModel.CONTRACT_TERMS: item.contractTerms,
      CrmBillingContractModel.CONTRACT_TERMS_AR: item.contractTermsAr,
      CrmBillingContractModel.CONTRACT_SECTIONS: item.contractSections
          .map((CrmBilingualNoteModel section) => section.toMap())
          .toList(),
      CrmBillingContractModel.TEXT_COLOR_HEX: item.textColorHex,
      CrmBillingContractModel.HIGHLIGHT_COLOR_HEX: item.highlightColorHex,
      CrmBillingContractModel.kUpdatedAt: Timestamp.now(),
      CrmBillingContractModel.kUpdatedBy:
          changedBy.trim().isEmpty ? 'system' : changedBy.trim().toLowerCase(),
    };
  }

  void _sortStaticControls(List<CrmBillingContractModel> items) {
    items.sort(
      (CrmBillingContractModel first, CrmBillingContractModel second) =>
          (first.id == CrmBillingContractModel.billingControlId ? 0 : 1)
              .compareTo(
        second.id == CrmBillingContractModel.billingControlId ? 0 : 1,
      ),
    );
  }
}

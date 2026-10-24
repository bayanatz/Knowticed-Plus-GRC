/// Module: knowledge_hub/data/data_source/remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_firebase_services.part.2.dart
/// Description: Methods of `KnowledgeHubFirebaseServices` — split out of `knowledge_hub_firebase_services.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'knowledge_hub_firebase_services.dart';

/// Module: split extension 2 of KnowledgeHubFirebaseServices (kept under 800 LOC, §7).
mixin KnowledgeHubServicesPart2 on KnowledgeHubFirebaseServicesBase {
  /// Update existing knowledge document
  Future<bool> updateKnowledgeHub({
    required String knowledgeId,
    String? knowledgeImage,
    String? nameEnglish,
    String? nameArabic,
    String? descriptionEnglish,
    String? descriptionArabic,
    String? knowledgeDocumentType,
    String? owningDepartment,
    List<String>? limitedDepartments,
    bool? schedulePublishing,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? imageUrl,
    String? documentUrl,
    String? documentFileName,
    String? timeStamp,
    String? status,
    String? startTime,
    String? endTime,
    String? documentExtension,
    int? documentSize,
    String? createdByEmail,
  }) async {
    try {
      khLog('Updating knowledge with knowledgeId: $knowledgeId');

      // First, find the document by knowledgeId
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where(CreateKnowledgeKeys.knowledgeId, arrayContains: knowledgeId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        khLog('No document found with knowledgeId: $knowledgeId');
        return false;
      }

      var doc = querySnapshot.docs.first;

      // Get existing data
      Map<String, dynamic> existingData = doc.data() as Map<String, dynamic>;
      CreateKnowledgeModel existingModel = CreateKnowledgeModel.fromJson(
        existingData,
        doc.id,
      );

      // KH-CREATE-22: the same rule as create — an 'approved' document that is
      // not scheduled is saved as 'published', so an edit by someone who may
      // publish directly stays on the hub.
      final bool scheduled =
          schedulePublishing ?? existingModel.currentSchedulePublishing;
      final String? effectiveStatus =
          (status ?? '').trim().toLowerCase() == 'approved' && !scheduled
          ? 'published'
          : status;

      // Create updated model using copyWith
      CreateKnowledgeModel updatedModel = existingModel.copyWith(
        knowledgeImage: knowledgeImage,
        nameEnglish: nameEnglish,
        nameArabic: nameArabic,
        descriptionEnglish: descriptionEnglish,
        descriptionArabic: descriptionArabic,
        knowledgeDocumentType: knowledgeDocumentType,
        owningDepartment: owningDepartment,
        limitedDepartments: limitedDepartments,
        schedulePublishing: schedulePublishing,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        imageUrl: imageUrl,
        documentUrl: documentUrl,
        documentFileName: documentFileName,
        timeStamp: timeStamp,
        documentExtension: documentExtension,
        documentSize: documentSize,
        status: effectiveStatus,
        startTime: startTime,
        endTime: endTime,
        // KH-CREATE-03: the caller passes the EDITOR here; it is recorded as
        // an editor, never as the author.
        editedByEmail: createdByEmail,
      );

      // Update the document
      Map<String, dynamic> updatedData = updatedModel.toJson();

      // KH report p.13: an edit of a LIVE document that
      // needs approval must not take it off the hub. The edited version is
      // parked in `pendingEdit`; the live version (and its status) stays as it
      // is until the supervisor approves (applied) or rejects (discarded). See
      // CreateKnowledgeModel.pendingEdit.
      final String liveStatus = existingModel.currentStatus
          .trim()
          .toLowerCase();
      final bool isLive = liveStatus == 'published' || liveStatus == 'approved';
      if (isLive &&
          (effectiveStatus ?? '').trim().toLowerCase() == 'pending_approval') {
        await doc.reference.update({
          CreateKnowledgeKeys.pendingEdit: updatedData,
          CreateKnowledgeKeys.pendingEditAt:
              DateTime.now().millisecondsSinceEpoch,
          CreateKnowledgeKeys.pendingEditBy: createdByEmail ?? '',
          CreateKnowledgeKeys.updatedAt: FieldValue.serverTimestamp(),
        });
        khLog('Edit of live document parked for approval (stays $liveStatus)');
        khSystemLog(
          KhLogAction.submitDocument,
        ); // System Logs §3 — edit sent for review
        return true;
      }

      updatedData[CreateKnowledgeKeys.updatedAt] = FieldValue.serverTimestamp();

      await doc.reference.update(updatedData);
      // System Logs §3: a saved edit is a (re)submission, or a publication
      // when the editor may publish without approval.
      khSystemLog(
        KhLogAction.isPublished(effectiveStatus)
            ? KhLogAction.publishDocument
            : KhLogAction.submitDocument,
      );

      khLog('Knowledge document updated successfully');
      return true;
    } catch (e) {
      khLog('Error updating knowledge hub: $e');
      rethrow;
    }
  }

  /// The documents the Knowledge Hub may show THIS user — asked of Firestore,
  /// not filtered on the device.
  ///
  /// KH-CREATE-06 (critical). The hub used to download the
  /// whole collection (pending, rejected, removed and department-restricted
  /// documents included, with their download links) and hide them on the
  /// phone. Now only `published` documents — plus `approved` ones, so a
  /// scheduled document can go live at its start time (KH-SUBMIT-03) — that
  /// are public or open to [userDepartment] are fetched.
  ///
  /// Relies on the flat `currentStatus` / `isPublic` / `accessDepartments`
  /// fields: every save writes them, and [backfillVisibilityFields] adds them
  /// to documents saved before they existed.
  Future<List<CreateKnowledgeModel>> fetchVisibleKnowledge({
    required String? userDepartment,
  }) async {
    final dept = (userDepartment ?? '').toLowerCase().trim();
    Filter access = Filter(CreateKnowledgeKeys.isPublic, isEqualTo: true);
    if (dept.isNotEmpty) {
      access = Filter.or(
        access,
        Filter(CreateKnowledgeKeys.accessDepartments, arrayContains: dept),
      );
    }
    final snap = await _firestore
        .collection(getBaseUrl(FirebaseCollections.createKnowledge))
        .where(
          Filter.and(
            Filter(
              CreateKnowledgeKeys.currentStatus,
              whereIn: const ['published', 'approved'],
            ),
            access,
          ),
        )
        .get();

    final list = <CreateKnowledgeModel>[];
    lastUnreadableCount = 0;
    for (final doc in snap.docs) {
      try {
        final data = doc.data();
        data[CreateKnowledgeKeys.id] = doc.id;
        list.add(CreateKnowledgeModel.fromJson(data, doc.id));
      } catch (e) {
        // KH-CREATE-21: counted, not silently dropped.
        lastUnreadableCount++;
        khLog('Error parsing document ${doc.id}: $e');
      }
    }
    return list;
  }

  /// One-off migration for KH-CREATE-06: writes `currentStatus`, `isPublic`
  /// and `accessDepartments` on every document that does not have them yet.
  /// Safe to run more than once. Returns how many documents were updated.
  Future<int> backfillVisibilityFields() async {
    final col = _firestore.collection(
      getBaseUrl(FirebaseCollections.createKnowledge),
    );
    final snap = await col.get();
    int updated = 0;
    WriteBatch batch = _firestore.batch();
    int inBatch = 0;
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data.containsKey(CreateKnowledgeKeys.currentStatus) &&
          data.containsKey(CreateKnowledgeKeys.isPublic) &&
          data.containsKey(CreateKnowledgeKeys.accessDepartments)) {
        continue;
      }
      try {
        final model = CreateKnowledgeModel.fromJson(data, doc.id);
        batch.update(doc.reference, model.visibilityFields);
        updated++;
        if (++inBatch == 400) {
          await batch.commit();
          batch = _firestore.batch();
          inBatch = 0;
        }
      } catch (e) {
        khLog('Backfill skipped ${doc.id}: $e');
      }
    }
    if (inBatch > 0) await batch.commit();
    khLog('Backfilled visibility fields on $updated documents');
    return updated;
  }

  /// One-off migration for KH-CREATE-14 / KH-SUBMIT-07: gives every file
  /// action saved before the fix an `employeeId` field.
  ///
  /// [employeeIdByEmail] maps lower-case e-mails to employee IDs. Legacy
  /// `userId` values that are already IDs are copied as they are; an e-mail
  /// with no known employee is kept, and the readers still resolve it. Safe to
  /// run more than once. Returns how many rows were updated.
  Future<int> migrateFileActionEmployeeIds(
    Map<String, String> employeeIdByEmail,
  ) async {
    final col = _firestore.collection(
      getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization),
    );
    final snap = await col.get();
    int updated = 0;
    WriteBatch batch = _firestore.batch();
    int inBatch = 0;
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data.containsKey(DocumentUtilizationModel.keyEmployeeId)) continue;
      final List<String> employeeIds = DocumentUtilizationModel.fromJson(data)
          .employeeId
          .map((String v) {
            final String key = v.toLowerCase().trim();
            return key.contains('@') ? (employeeIdByEmail[key] ?? v) : v;
          })
          .toList();
      batch.update(doc.reference, {
        DocumentUtilizationModel.keyEmployeeId: employeeIds,
      });
      updated++;
      if (++inBatch == 400) {
        await batch.commit();
        batch = _firestore.batch();
        inBatch = 0;
      }
    }
    if (inBatch > 0) await batch.commit();
    khLog('Migrated $updated file actions to employee IDs');
    return updated;
  }

  Future<List<DepartmentModelPro>> fetchAllDepartments() async {
    try {
      CollectionReference knowledgeRef = _firestore.collection(
        getBaseUrl(FirebaseCollections.departmentDirectory),
      );
      QuerySnapshot querySnapshot = await knowledgeRef.get();

      List<DepartmentModelPro> departmentsList = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // Add document ID to the data
          data[KhDepartmentKeys.id] = doc.id;

          DepartmentModelPro model = DepartmentModelPro.fromMap(data);
          departmentsList.add(model);
        } catch (e) {
          khLog('Error parsing document ${doc.id}: $e');
        }
      }

      khLog('Fetched ${departmentsList.length} departments');
      return departmentsList;
    } catch (e) {
      khLog('Error fetching knowledge: $e');
      rethrow;
    }
  }

  /// Fetch knowledge document by custom knowledgeId field (stored as array)
  Future<CreateKnowledgeModel?> fetchKnowledgeByKnowledgeId(
    String knowledgeId,
  ) async {
    try {
      khLog('Searching for knowledgeId: $knowledgeId');

      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          //Create_Knowledge
          .where(CreateKnowledgeKeys.knowledgeId, arrayContains: knowledgeId)
          .limit(1)
          .get();

      khLog('Query returned ${querySnapshot.docs.length} documents');

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data[CreateKnowledgeKeys.id] = doc.id;

        khLog('Knowledge document fetched by knowledgeId: $knowledgeId');
        return CreateKnowledgeModel.fromJson(data, doc.id);
      }

      khLog('No knowledge document found with knowledgeId: $knowledgeId');
      return null;
    } catch (e) {
      khLog('Error fetching knowledge by knowledgeId: $e');
      rethrow;
    }
  }
}

/// Module: knowledge_hub/data/data_source/remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_firebase_services.part.1.dart
/// Description: Methods of `KnowledgeHubFirebaseServices` — split out of `knowledge_hub_firebase_services.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'knowledge_hub_firebase_services.dart';

/// Module: split extension 1 of KnowledgeHubFirebaseServices (kept under 800 LOC, §7).
mixin KnowledgeHubServicesPart1 on KnowledgeHubFirebaseServicesBase {
  /// Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName =
          '${getBaseUrl(FirebaseCollections.knowledgeHubRoot)}/knowledge_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      khLog(downloadUrl);
      khLog('Image Uploaded Successfully');
      return downloadUrl;
    } catch (e) {
      khLog('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload document to Firebase Storage
  Future<String?> uploadDocument(File documentFile, String fileName) async {
    try {
      String filePath =
          '${getBaseUrl(FirebaseCollections.knowledgeHubRoot)}/knowledge_documents/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference storageRef = _storage.ref().child(filePath);
      UploadTask uploadTask = storageRef.putFile(documentFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      khLog('Document Uploaded Successfully');
      return downloadUrl;
    } catch (e) {
      khLog('Error uploading document: $e');
      rethrow;
    }
  }

  Future<bool> createKnowledgeHub(CreateKnowledgeModel model) async {
    try {
      // Reference to Demo/84763782/Create_Knowledge collection
      CollectionReference knowledgeRef = _firestore.collection(
        getBaseUrl(FirebaseCollections.createKnowledge),
      );

      Map<String, dynamic> knowledgeData = model.toJson();

      khLog('Uploading knowledge data: ${knowledgeData.toString()}');

      await knowledgeRef.add(knowledgeData);

      khLog('Data uploaded to document successfully');
      return true;
    } catch (e) {
      khLog('Error creating knowledge hub: $e');
      rethrow;
    }
  }

  /// Uploads a comment attachment to Storage and returns its download URL.
  /// Keeps `FirebaseStorage` out of the presentation layer (CR-KH-S5-04).
  Future<String?> uploadCommentAttachment({
    required File file,
    required String knowledgeId,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref(
        '${getBaseUrl(FirebaseCollections.knowledgeHubRoot)}/knowledge_hub_comments/$knowledgeId/'
        '${DateTime.now().millisecondsSinceEpoch}_$fileName',
      );
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      khLog('Error uploading comment attachment: $e');
      rethrow;
    }
  }

  /// The reason the document was last removed, or null (KH-APPROVE-05).
  ///
  /// Read from `statusReason` via [CreateKnowledgeModel.removalReason] — the
  /// one place the reason is stored. (This used to read a `removalReason`
  /// field nothing writes, and a sibling method read the description list.)
  Future<String?> getRemovalReason(String knowledgeId) async {
    try {
      final q = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where(CreateKnowledgeKeys.knowledgeId, arrayContains: knowledgeId)
          .limit(1)
          .get();
      if (q.docs.isEmpty) return null;
      final reason = CreateKnowledgeModel.fromJson(
        q.docs.first.data(),
        q.docs.first.id,
      ).removalReason;
      return reason.isEmpty ? null : reason;
    } catch (e) {
      khLog('Error getRemovalReason: $e');
      rethrow;
    }
  }

  /// Returns the most recent approval justification, or null.
  Future<String?> getApprovalReason(String knowledgeId) async {
    try {
      final approvalsPath = getBaseUrl(FirebaseCollections.knowledgeApprovals);
      final docSnapshot =
          await _firestore.collection(approvalsPath).doc(knowledgeId).get();
      if (!docSnapshot.exists || docSnapshot.data() == null) return null;
      return _extractLastArrayValue(
        docSnapshot.data()!,
        'approvalJustification',
      );
    } catch (e) {
      khLog('Error getApprovalReason: $e');
      rethrow;
    }
  }

  String? _extractLastArrayValue(Map<String, dynamic> data, String field) {
    final List<dynamic> arr = data[field] ?? [];
    if (arr.isEmpty) return null;
    final value = arr.last?.toString() ?? '';
    return value.isNotEmpty ? value : null;
  }

  /// Persists a notification record under THIS company's Notifications.
  ///
  /// KH-CREATE-18. When the company path was empty this
  /// fell back to the hard-coded `bayanatz` company and wrote the record into
  /// another tenant's data. The path is now built with getBaseUrl like every
  /// other collection, and an unknown company is an error, never a fallback.
  Future<void> saveNotificationRecord(Map<String, dynamic> data) async {
    if (ApiConstants.baseUri.trim().isEmpty) {
      khLog('saveNotificationRecord refused: company path is not set');
      return;
    }
    try {
      await _firestore
          .collection(getBaseUrl(FirebaseCollections.notifications))
          .add(data);
    } catch (e) {
      khLog('Error saving notification record: $e');
    }
  }

  /// `statusReason` padded to the same length as `status`.
  ///
  /// Documents written before `statusReason` existed have no such key, and a
  /// status change that carried no reason leaves a gap, so the two arrays
  /// cannot be assumed to line up. Padding with `''` before appending keeps
  /// "entry N explains status N" true for every document, old or new.
  List<dynamic> _alignedStatusReasons(Map<String, dynamic> data) {
    final statuses = List<dynamic>.from(data[CreateKnowledgeKeys.status] ?? []);
    final reasons = List<dynamic>.from(
      data[CreateKnowledgeKeys.statusReason] ?? [],
    );
    while (reasons.length < statuses.length) {
      reasons.add('');
    }
    return reasons;
  }

  /// Records why a document was edited and resubmitted.
  ///
  /// for the "reason of editing" step on the resubmit dialog.
  /// Called AFTER the edit itself has been written, because the edit appends
  /// the new status and this attaches the reason to that entry.
  ///
  /// Best-effort by design: the edit has already been saved and shown as
  /// successful, so a failure here must not be reported as a failed edit. It
  /// returns false and logs instead.
  Future<bool> attachEditReason({
    required String documentId,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) return false;

    try {
      final querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where(CreateKnowledgeKeys.knowledgeId, arrayContains: documentId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        khLog('⚠️ attachEditReason: no document with knowledgeId $documentId');
        return false;
      }

      final docSnapshot = querySnapshot.docs.first;
      final data = docSnapshot.data();

      // 14/10/2026 — KH report p.13: an edit of a live document is parked in
      // `pendingEdit` and did NOT append a status to the live version, so the
      // reason belongs to the parked edit's own newest status entry.
      if (data[CreateKnowledgeKeys.pendingEdit] is Map) {
        final Map<String, dynamic> edit = Map<String, dynamic>.from(
          data[CreateKnowledgeKeys.pendingEdit] as Map,
        );
        final List<dynamic> st = List<dynamic>.from(
          edit[CreateKnowledgeKeys.status] ?? const [],
        );
        final List<dynamic> rs = List<dynamic>.from(
          edit[CreateKnowledgeKeys.statusReason] ?? const [],
        );
        while (rs.length < st.length) {
          rs.add('');
        }
        if (rs.isEmpty) {
          rs.add(reason.trim());
        } else {
          rs[rs.length - 1] = reason.trim();
        }
        await docSnapshot.reference.update({
          'pendingEdit.statusReason': rs,
          CreateKnowledgeKeys.updatedAt: FieldValue.serverTimestamp(),
        });
        return true;
      }

      final reasons = _alignedStatusReasons(data);

      // The edit has already appended its status entry, so the padding above
      // left a trailing '' that belongs to it — fill that rather than adding
      // one past the end of `status`.
      if (reasons.isNotEmpty) {
        reasons[reasons.length - 1] = reason.trim();
      } else {
        reasons.add(reason.trim());
      }

      await docSnapshot.reference.update({
        CreateKnowledgeKeys.statusReason: reasons,
        CreateKnowledgeKeys.updatedAt: FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      khLog('Error attachEditReason: $e');
      rethrow;
    }
  }

  /// Marks a knowledge document as `removed` with a justification, updating the
  /// parallel arrays in one place. Returns the creator info (for notifying), or
  /// null if the document can't be found / the update fails (CR-KH-S5-04).
  Future<RemoveKnowledgeReasonResult?> removeKnowledgeWithReason({
    required String documentId,
    required String currentUserEmail,
    required String justification,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where(CreateKnowledgeKeys.knowledgeId, arrayContains: documentId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) return null;

      final docSnapshot = querySnapshot.docs.first;
      final docRef = docSnapshot.reference;
      final data = docSnapshot.data();

      String firstOf(String field, String fallback) {
        final list = data[field];
        if (list is List && list.isNotEmpty) return list.first.toString();
        return fallback;
      }

      final creatorEmail = firstOf('createdByEmail', '');
      final documentNameEnglish = firstOf('nameEnglish', 'Document');
      final documentNameArabic = firstOf('nameArabic', documentNameEnglish);

      final createdByEmailArray = List<dynamic>.from(
        data[CreateKnowledgeKeys.createdByEmail] ?? [],
      );
      final statusArray = List<dynamic>.from(
        data[CreateKnowledgeKeys.status] ?? [],
      );
      final timestampsArray = List<dynamic>.from(
        data[CreateKnowledgeKeys.timestamps] ?? [],
      );
      final timeStampArray = List<dynamic>.from(
        data[CreateKnowledgeKeys.timeStamp] ?? [],
      );

      // THE JUSTIFICATION NO LONGER OVERWRITES THE
      // DOCUMENT'S DESCRIPTION.
      //
      // This used to append `justification` to `descriptionArabic` and
      // `descriptionEnglish`. Those are history arrays whose `.last` entry is
      // what the app displays (`CreateKnowledgeModel.currentDescriptionEnglish`),
      // so removing a document REPLACED its description with the reason it was
      // removed — on the card, on the details page, in the approvals list,
      // everywhere. The description was not recoverable from the UI afterwards.
      //
      // The reason now goes in `statusReason`, the array added for it, which
      // runs parallel to `status`: entry N says why status N happened.
      final statusReasonArray = _alignedStatusReasons(data);

      createdByEmailArray.add(currentUserEmail);
      statusArray.add('removed');
      statusReasonArray.add(justification);
      timestampsArray.add(DateTime.now().millisecondsSinceEpoch);
      timeStampArray.add(DateTime.now().toIso8601String());

      await docRef.update({
        CreateKnowledgeKeys.createdByEmail: createdByEmailArray,
        CreateKnowledgeKeys.status: statusArray,
        CreateKnowledgeKeys.currentStatus: statusArray.isEmpty
            ? ''
            : statusArray.last.toString(), // KH-CREATE-06
        CreateKnowledgeKeys.statusReason: statusReasonArray,
        CreateKnowledgeKeys.timestamps: timestampsArray,
        CreateKnowledgeKeys.timeStamp: timeStampArray,
        CreateKnowledgeKeys.updatedAt: FieldValue.serverTimestamp(),
      });
      khSystemLog(KhLogAction.withdrawDocument); // System Logs §3

      return RemoveKnowledgeReasonResult(
        creatorEmail: creatorEmail,
        documentNameEnglish: documentNameEnglish,
        documentNameArabic: documentNameArabic,
      );
    } catch (e) {
      khLog('Error removeKnowledgeWithReason: $e');
      rethrow;
    }
  }

  /// Resolves a supervisor email from THIS company's employee / department
  /// records.
  ///
  /// KH-CREATE-18. This read the TOP-LEVEL `employees` and
  /// `departments` collections, which hold nothing for a company, so it never
  /// found a supervisor and "notify supervisor" silently did nothing. It now
  /// reads the company-scoped collections (built with getBaseUrl), the same
  /// ones the approvals screens use.
  Future<String?> getSupervisorEmailFromFirestore({
    String? employeeId,
    String? departmentId,
  }) async {
    if (ApiConstants.baseUri.trim().isEmpty) return null;
    String? fromList(dynamic v) {
      if (v is String && v.isNotEmpty) return v;
      if (v is List && v.isNotEmpty) {
        final last = v.last?.toString() ?? '';
        return last.isEmpty ? null : last;
      }
      return null;
    }

    try {
      if (employeeId != null && employeeId.isNotEmpty) {
        final col = _firestore.collection(
          getBaseUrl(FirebaseCollections.employeesInfo),
        );
        Map<String, dynamic>? data = (await col.doc(employeeId).get()).data();
        if (data == null) {
          final q = await col
              .where(EmployeeKeys.id, isEqualTo: employeeId)
              .limit(1)
              .get();
          if (q.docs.isNotEmpty) data = q.docs.first.data();
        }
        final s = fromList(data?[EmployeeKeys.supervisor]) ??
            fromList(data?[KhEmployeeFallbackKeys.supervisorEmail]) ??
            fromList(data?[KhEmployeeFallbackKeys.managerEmail]);
        if (s != null) return s;
      }
      if (departmentId != null && departmentId.isNotEmpty) {
        final data = (await _firestore
                .collection(
                  getBaseUrl(FirebaseCollections.departmentDirectory),
                )
                .doc(departmentId)
                .get())
            .data();
        final s = fromList(data?[KhEmployeeFallbackKeys.supervisorEmail]) ??
            fromList(data?[KhEmployeeFallbackKeys.managerEmail]) ??
            fromList(data?[KhEmployeeFallbackKeys.headOfDepartment]);
        if (s != null) return s;
      }
      return null;
    } catch (e) {
      khLog('Error getSupervisorEmailFromFirestore: $e');
      rethrow;
    }
  }

  /// Returns the new document's knowledgeId, or null when the save failed —
  /// the submission notifications carry it so their View opens the document.
  Future<String?> createKnowledgeHubFromParams({
    required String knowledgeImage,
    required String nameEnglish,
    required String nameArabic,
    required String descriptionEnglish,
    required String descriptionArabic,
    required String knowledgeDocumentType,
    required String owningDepartment,
    List<String>? limitedDepartments,
    bool? schedulePublishing,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? startTime,
    String? endTime,
    required String imageUrl,
    required String documentUrl,
    required String documentFileName,
    required String timeStamp,
    required String documentExtension,
    required int documentSize,
    required String createdByEmail,
    required String status,
  }) async {
    try {
      // Normalize the direct-publish status so the document actually appears in
      // the Knowledge Hub, which lists ONLY documents whose latest status is
      // 'published' (see _filterByPublishedStatusAndAccess in the create cubit).
      //
      // A user with the editDocumentWithoutApproval permission bypasses the
      // approval workflow, so the caller passes status 'approved'. Mirroring the
      // approval flow (approvals_firebase_services: schedule ON -> 'approved',
      // which flips to 'published' at its start time; schedule OFF -> 'published'
      // immediately), an approved-but-UNscheduled document must be saved as
      // 'published' — otherwise it is stored as 'approved' and never shows on the
      // home list. Scheduled documents correctly stay 'approved' until their
      // start time, and 'pending'/'draft'/'rejected' are left untouched so the
      // normal approval workflow is unaffected.
      String effectiveStatus = status;
      if (status.toLowerCase().trim() == 'approved' &&
          schedulePublishing != true) {
        effectiveStatus = 'published';
        khLog('ℹ️ Status normalized: approved + no scheduling -> published');
      }

      // Generate Id for new doc
      final knowledgeId = _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .doc();
      // Create model instance using factory
      CreateKnowledgeModel model = CreateKnowledgeModel.createNew(
        knowledgeId: knowledgeId.id, // Genereated ID for the new doc
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
        startTime: startTime,
        endTime: endTime,
        imageUrl: imageUrl,
        documentUrl: documentUrl,
        documentFileName: documentFileName,
        timeStamp: timeStamp,
        documentExtension: documentExtension,
        documentSize: documentSize,
        status: effectiveStatus,
        createdByEmail: createdByEmail,
      );

      // Use the model-based method
      final bool created = await createKnowledgeHub(model);
      // System Logs §3: every new document is a submission; one that goes
      // live at once (no approval needed, no schedule) is also a publication.
      if (created) {
        khSystemLog(KhLogAction.submitDocument);
        if (KhLogAction.isPublished(effectiveStatus)) {
          khSystemLog(KhLogAction.publishDocument);
        }
      }
      return created ? knowledgeId.id : null;
    } catch (e) {
      khLog('Error creating knowledge hub from params: $e');
      rethrow;
    }
  }
}

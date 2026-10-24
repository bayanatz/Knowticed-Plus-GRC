/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: requests_remote_data_source.dart
/// Purpose: Every Firestore call behind the change-request flow.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N01. Four reads and four writes were spread across
/// three pages and the GetX controller. They are collected here unchanged in
/// behaviour — same collections, same document shapes — so the pages can be
/// reduced to dispatching intents.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/settings/se3_company/data/utils/company_collection_paths.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/phone_country_lookup.dart';
import 'package:knowticed_plus/features/settings/se1_profile/domain/entities/personal_profile.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/models/change_request_mapper.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/request_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/request_field_mapping.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';

class RequestsRemoteDataSource {
  RequestsRemoteDataSource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// The format the list screens render; kept alongside the server timestamp
  /// exactly as the submit page wrote it.
  static final DateFormat _displayFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  CollectionReference<Map<String, dynamic>> get _requests => _db
      .doc(RequestCollectionPaths.rolesDoc)
      .collection(RequestCollectionPaths.requestsCollection);

  /// Function Name: [readForEmployee]
  ///
  /// Purpose: Every request raised by one employee, newest first.
  Future<List<ChangeRequest>> readForEmployee(String employeeId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _requests
        .where(ChangeRequestMapper.keyEmployeeId, isEqualTo: employeeId)
        .orderBy(ChangeRequestMapper.keyRequestDate, descending: true)
        .get();

    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            ChangeRequestMapper.fromDocument(doc.id, doc.data()))
        .toList();
  }

  /// Function Name: [read]
  ///
  /// Purpose: One request, or `null` when the document is gone.
  Future<ChangeRequest?> read(String requestId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _requests.doc(requestId).get();

    final Map<String, dynamic>? data = doc.data();
    if (!doc.exists || data == null) return null;
    return ChangeRequestMapper.fromDocument(doc.id, data);
  }

  /// Function Name: [employeeExists]
  ///
  /// Purpose: Whether the employee profile document is present.
  Future<bool> employeeExists(String employeeId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _db.doc(RequestCollectionPaths.employeeDoc(employeeId)).get();
    return doc.exists;
  }

  /// Function Name: [create]
  ///
  /// Purpose: Write one request document with an auto-generated id.
  Future<void> create(ChangeRequest request) {
    return _requests.doc().set(
          ChangeRequestMapper.toSubmission(
            request,
            formattedDate: _displayFormat.format(DateTime.now()),
          ),
        );
  }

  /// Function Name: [markReminderSent]
  ///
  /// Purpose: Stamp the request with the time its requester last sent a
  ///          reminder (21/10/2026) — the once-per-24-hours limit reads it.
  Future<void> markReminderSent(String requestId) =>
      _requests.doc(requestId).update(<String, dynamic>{
        ChangeRequestMapper.keyLastReminderAt: FieldValue.serverTimestamp(),
      });

  /// Function Name: [createAll]
  ///
  /// Purpose: Write several request documents in ONE batch, so a page that
  ///          files two sections (Health Insurance + Emergency Contact) can
  ///          never end up with the first written and the second lost
  ///          (CR-KNP-SET-HR-05, 20/10/2026).
  ///
  /// Returns the new documents' ids, in [requests] order (22/10/2026), so the
  /// "submitted" notification can carry its request's id and View opens it.
  Future<List<String>> createAll(List<ChangeRequest> requests) async {
    final String formattedDate = _displayFormat.format(DateTime.now());
    final WriteBatch batch = _db.batch();
    final List<String> ids = <String>[];
    for (final ChangeRequest request in requests) {
      final DocumentReference<Map<String, dynamic>> ref = _requests.doc();
      ids.add(ref.id);
      batch.set(
        ref,
        ChangeRequestMapper.toSubmission(request, formattedDate: formattedDate),
      );
    }
    await batch.commit();
    return ids;
  }

  /// Function Name: [updateStatus]
  ///
  /// Purpose: Move a request to a new status.
  ///
  /// [reason] (ADDED 30/9/2026, Role QA p.34): the reviewer's reason for the
  /// decision — approval or rejection. Stored on the request when given.
  ///
  /// CHANGED 20/10/2026 (CR-KNP-SET-HR-03): runs in a transaction that
  /// re-reads the request and refuses unless it is still PENDING, so two
  /// reviewers deciding the same request at once cannot both "win".
  Future<void> updateStatus(String requestId, RequestStatus status,
      {String reason = ''}) {
    final DocumentReference<Map<String, dynamic>> ref =
        _requests.doc(requestId);
    return _db.runTransaction<void>((Transaction tx) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await tx.get(ref);
      _requirePending(snapshot);
      tx.update(ref, _decisionFields(status, reason));
    });
  }

  /// Function Name: [approveAtomically]
  ///
  /// Purpose: Apply [changes] to the employee AND mark the request approved in
  ///          ONE transaction (CR-KNP-SET-HR-03, 20/10/2026). Before this the
  ///          profile write and the status write were two separate calls: a
  ///          crash between them left a changed profile with a request still
  ///          pending, which a second reviewer could then approve again, and
  ///          two reviewers could both apply the same request.
  ///
  /// Throws [StateError] when the request is missing or no longer pending,
  /// when the employee document is missing, or when NONE of the fields could
  /// be applied (then nothing is written at all).
  ///
  /// Returns the request field names that could not be applied (the rest
  /// were). An empty list means everything was written.
  Future<List<String>> approveAtomically({
    required String requestId,
    required String employeeId,
    required List<FieldChange> changes,
    String reason = '',
  }) {
    final DocumentReference<Map<String, dynamic>> requestRef =
        _requests.doc(requestId);
    final DocumentReference<Map<String, dynamic>> employeeRef =
        _db.doc(RequestCollectionPaths.employeeDoc(employeeId));

    return _db.runTransaction<List<String>>((Transaction tx) async {
      final DocumentSnapshot<Map<String, dynamic>> requestSnapshot =
          await tx.get(requestRef);
      _requirePending(requestSnapshot);

      // 21/10/2026 (Moataz): a Company Information request changes the
      // COMPANY document, not the requester's employee record (it used to go
      // through the employee path, so an approved company change never
      // showed on the Company Information page).
      final String section =
          requestSnapshot.data()?[ChangeRequestMapper.keySection]?.toString() ??
              '';
      if (section.trim().toLowerCase() == 'company information') {
        final DocumentReference<Map<String, dynamic>> companyRef = _db
            .collection(CompanyCollectionPaths.companies)
            .doc(CompanyCollectionPaths.companyId);
        final DocumentSnapshot<Map<String, dynamic>> companySnapshot =
            await tx.get(companyRef);
        if (!companySnapshot.exists) {
          throw StateError('Company document not found.');
        }
        final ({Map<String, dynamic> update, List<String> skipped}) applied =
            applyChangesToCompany(
          companySnapshot.data() ?? <String, dynamic>{},
          changes,
          Timestamp.now(),
        );
        if (changes.isNotEmpty && applied.skipped.length == changes.length) {
          throw StateError(
            'None of the requested fields could be applied: '
            '${applied.skipped.join(', ')}',
          );
        }
        tx.update(companyRef, applied.update);
        tx.update(requestRef, _decisionFields(RequestStatus.approved, reason));
        return applied.skipped;
      }

      final DocumentSnapshot<Map<String, dynamic>> employeeSnapshot =
          await tx.get(employeeRef);
      if (!employeeSnapshot.exists) {
        throw StateError('Employee document not found for id $employeeId');
      }

      final ({NewEmployeeModelHistory history, List<String> skipped}) applied =
          applyChangesToHistory(
        NewEmployeeModelHistory.fromMap(employeeSnapshot.data()),
        changes,
      );
      if (changes.isNotEmpty && applied.skipped.length == changes.length) {
        throw StateError(
          'None of the requested fields could be applied: '
          '${applied.skipped.join(', ')}',
        );
      }

      tx.update(employeeRef, applied.history.toMap());
      tx.update(requestRef, _decisionFields(RequestStatus.approved, reason));
      return applied.skipped;
    });
  }

  /// Request field → (company document field, value list key). The company
  /// stores every field as `{<valueKey>: [values…], Timestamp: [stamps…]}`;
  /// the current value is the last element (CompanyModel.fromMap).
  static const Map<String, (String, String)> companyFields =
      <String, (String, String)>{
    'companyName': ('Company_Name', 'Company_Name'),
    'taxNumber': ('Tax_Number', 'Tax_Number'),
    'country': ('Country', 'Country'),
    'province': ('Province', 'Province'),
    'city': ('City', 'City'),
    'address': ('Company_Address', 'Address'),
    'industry': ('Company_Industry', 'Company_Industry'),
    'companySize': ('Company_Size', 'Company_Size'),
    'contactFirstName': ('First_Name', 'First_Name'),
    'contactLastName': ('Last_Name', 'Last_Name'),
    'contactEmail': ('Email', 'Email'),
    'contactPhone': ('Phone', 'Phone'),
  };

  /// Function Name: [applyChangesToCompany]
  ///
  /// Purpose: The company-document update for an approved Company Information
  ///          request (ADDED 21/10/2026) — one new value + timestamp appended
  ///          per changed field. Pure, so it is unit-tested without Firestore.
  ///
  /// Returns: the fields to update, and the request field names that have no
  ///          company field (skipped).
  static ({Map<String, dynamic> update, List<String> skipped})
      applyChangesToCompany(
    Map<String, dynamic> company,
    List<FieldChange> changes,
    Timestamp now,
  ) {
    final Map<String, dynamic> update = <String, dynamic>{};
    final List<String> skipped = <String>[];
    for (final FieldChange change in changes) {
      final (String, String)? target = companyFields[change.fieldName];
      if (target == null) {
        skipped.add(change.fieldName);
        continue;
      }
      final (String field, String valueKey) = target;
      final Map<String, dynamic> current = Map<String, dynamic>.from(
        (update[field] ?? company[field] ?? <String, dynamic>{}) as Map,
      );
      // Owner 21/10/2026: the phone value is "+20 1501503767" — split it and append to every parallel list so they stay aligned.
      if (change.fieldName == 'contactPhone') {
        update[field] = _appendCompanyPhone(current, change.newValue, now);
        continue;
      }
      current[valueKey] = <dynamic>[
        ...((current[valueKey] as List?) ?? const <dynamic>[]),
        change.newValue,
      ];
      current['Timestamp'] = <dynamic>[
        ...((current['Timestamp'] as List?) ?? const <dynamic>[]),
        now,
      ];
      update[field] = current;
    }
    return (update: update, skipped: skipped);
  }

  /// Function Name: [_appendCompanyPhone]
  ///
  /// Purpose: Append one phone entry to the company `Phone` object, keeping
  ///          its parallel lists (`Phone`, `Country_Code`, `Country_App`,
  ///          `Timestamp`) the same length. `Country_Code` holds the ISO code
  ///          (e.g. `EG`), as the company view reads it; `Country_App` is
  ///          carried forward from the previous entry.
  static Map<String, dynamic> _appendCompanyPhone(
    Map<String, dynamic> current,
    Object? value,
    Timestamp now,
  ) {
    final String raw = (value ?? '').toString().trim();
    String number = raw;
    String? dial;
    if (raw.startsWith('+')) {
      final int space = raw.indexOf(' ');
      dial = space == -1 ? raw : raw.substring(0, space);
      number = space == -1 ? '' : raw.substring(space + 1).trim();
    }

    List<dynamic> listOf(String key) =>
        List<dynamic>.of((current[key] as List?) ?? const <dynamic>[]);

    final List<dynamic> codes = listOf('Country_Code');
    final List<dynamic> apps = listOf('Country_App');
    final String? previousIso = codes.isEmpty ? null : codes.last?.toString();

    // Keep the previous ISO when it already has this dial code (+1 is shared
    // by several countries); otherwise resolve the dial code to a country.
    String iso = previousIso ?? PersonalProfile.defaultCountryCode;
    if (dial != null &&
        (previousIso == null ||
            PhoneCountryLookup.dialCodeOf(previousIso) != dial)) {
      iso = PhoneCountryLookup.find(dial)?.code ?? iso;
    }

    return <String, dynamic>{
      ...current,
      'Phone': <dynamic>[...listOf('Phone'), number],
      'Country_Code': <dynamic>[...codes, iso],
      'Country_App': <dynamic>[...apps, apps.isEmpty ? '' : apps.last],
      'Timestamp': <dynamic>[...listOf('Timestamp'), now],
    };
  }

  /// The request must exist and still be pending — the one rule every
  /// decision shares (HR-03).
  static void _requirePending(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) {
      throw StateError('This request no longer exists.');
    }
    final RequestStatus current =
        RequestStatus.fromWire(data[ChangeRequestMapper.keyStatus]?.toString());
    if (current != RequestStatus.pending) {
      throw StateError(
        'This request was already ${current.wireValue}; nothing was changed.',
      );
    }
  }

  static Map<String, dynamic> _decisionFields(
      RequestStatus status, String reason) {
    return <String, dynamic>{
      ChangeRequestMapper.keyStatus: status.wireValue,
      ChangeRequestMapper.keyUpdatedAt: FieldValue.serverTimestamp(),
      if (reason.trim().isNotEmpty)
        ChangeRequestMapper.keyDecisionReason: reason.trim(),
    };
  }

  /// Function Name: [applyChangesToEmployee]
  ///
  /// Purpose: Append every approved change to the employee's history document.
  ///
  /// Throws [StateError] when the employee document is missing — the caller
  /// converts that into a [Failure] rather than marking the request approved.
  ///
  /// FIXED 13/8/2026: this looped straight into `updateFieldSynchronized` for
  /// every change. That method ends in `default: throw ArgumentError`, and it
  /// rejects `mobilePhone` unless the value is a `MobilePhone` instance — a
  /// request only ever carries strings. So a request touching the phone, the
  /// country code, or any emergency-contact field threw on the first such
  /// entry, the loop died, and *no* field was written, including the ones that
  /// mapped correctly. Two changes: phone members are folded into a rebuilt
  /// `MobilePhone`, and an unwritable field is now skipped and reported rather
  /// than discarding the rest of the batch.
  ///
  /// Returns the request field names that could not be applied. An empty list
  /// means everything was written.
  Future<List<String>> applyChangesToEmployee({
    required String employeeId,
    required List<FieldChange> changes,
  }) async {
    final DocumentReference<Map<String, dynamic>> employeeRef =
        _db.doc(RequestCollectionPaths.employeeDoc(employeeId));

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await employeeRef.get();
    if (!snapshot.exists) {
      throw StateError('Employee document not found for id $employeeId');
    }

    // CHANGED 9/10/2026 — the append loop moved, unchanged, into the pure
    // [applyChangesToHistory] so the Health / Emergency-contact approval can
    // be unit-tested without Firestore. This method still reads, applies and
    // writes exactly as before.
    final ({NewEmployeeModelHistory history, List<String> skipped}) applied =
        applyChangesToHistory(
      NewEmployeeModelHistory.fromMap(snapshot.data()),
      changes,
    );

    await employeeRef.update(applied.history.toMap());

    return applied.skipped;
  }

  /// Function Name: [applyChangesToHistory]
  ///
  /// Purpose: Append every approved change to an employee history — the pure
  ///          half of [applyChangesToEmployee] (ADDED 9/10/2026).
  ///
  /// Each change goes through `updateFieldSynchronized`, the Employees_Info
  /// append helper: ONE new revision per change, i.e. one new entry in
  /// `timestamps` and one in EVERY synchronized field list (the new value for
  /// the changed field, the last value repeated for the rest). The current
  /// value of every field is therefore its last element, and the lists stay
  /// as long as `timestamps`.
  ///
  /// Parameters:
  /// - [history]: the employee document as read.
  /// - [changes]: the request's field changes.
  ///
  /// Returns: the appended history, and the request field names that could
  ///          not be applied (empty when everything was written).
  static ({NewEmployeeModelHistory history, List<String> skipped})
      applyChangesToHistory(
    NewEmployeeModelHistory history,
    List<FieldChange> changes,
  ) {
    final List<String> skipped = <String>[];

    // Phone members are collected first: `phones`, `countryCode` and
    // `countryApp` are three entries in the request but one object on the
    // model, so they have to be merged before a single write.
    final Map<String, String> phoneMembers = <String, String>{};

    for (final FieldChange change in changes) {
      final String modelField =
          RequestFieldMapping.toModelField(change.fieldName);

      if (RequestFieldMapping.isMobilePhoneField(modelField)) {
        phoneMembers[RequestFieldMapping.mobilePhoneMember(modelField)] =
            change.newValue;
        continue;
      }

      if (!RequestFieldMapping.isKnown(change.fieldName)) {
        skipped.add(change.fieldName);
        continue;
      }

      try {
        history = history.updateFieldSynchronized(modelField, change.newValue);
      } on ArgumentError {
        // The model refused the value (wrong runtime type for this field).
        // One bad entry must not cost the caller the other changes.
        skipped.add(change.fieldName);
      }
    }

    if (phoneMembers.isNotEmpty) {
      history = history.updateFieldSynchronized(
        'mobilePhone',
        _mergedMobilePhone(history, phoneMembers),
      );
    }

    // 9/10/2026: the write moved back into [applyChangesToEmployee].
    return (history: history, skipped: skipped);
  }

  /// Function Name: [_mergedMobilePhone]
  ///
  /// Purpose: Build the `MobilePhone` an approval should store, keeping the
  ///          members the request did not touch.
  ///
  /// The model holds each member as a history list; only the newest entry is
  /// displayed, so a change appends rather than replaces. Mirrors
  /// `_updateMobilePhoneField` in the user-management approval screen, which is
  /// the only other place that writes this object correctly.
  ///
  /// `static` since 9/10/2026 (it never used instance state) so the pure
  /// [applyChangesToHistory] can call it.
  static MobilePhone _mergedMobilePhone(
    NewEmployeeModelHistory history,
    Map<String, String> members,
  ) {
    final MobilePhone current = history.mobilePhone.isNotEmpty
        ? history.mobilePhone.last
        : MobilePhone();

    List<String> appended(List<String>? existing, String? value) {
      final List<String> next = List<String>.of(existing ?? const <String>[]);
      // Owner 21/10/2026: absent member repeats its last value (or '') so every list grows with Timestamp.
      next.add(value ?? (next.isEmpty ? '' : next.last));
      return next;
    }

    return MobilePhone(
      phones: appended(current.phones, members['phones']),
      countryCode: appended(current.countryCode, members['countryCode']),
      countryApp: appended(current.countryApp, members['countryApp']),
      timestamps: List<Timestamp>.of(current.timestamps ?? const <Timestamp>[])
        ..add(Timestamp.now()),
    );
  }
}

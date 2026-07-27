# Assignment Controls (Control Champion) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Control Champion–facing "Assignment Controls" screen — a champion opens it, sees every control they're personally responsible for grouped by workflow status (Pending/Submitted/In Review/Rejected/Approved/Overdue), and can upload evidence, submit, or resubmit after a rejection.

**Architecture:** New Clean Architecture feature `lib/features/grc/assignment_control/` mirroring `control_champion/`'s layout exactly (data/domain/presentation). The Pending list is derived live by joining the existing `ChampionModel.assigningControls` + `ControlModel` (no new writes) with an optional `Assignment_Controls` Firestore document, which is only created the first time a champion actually submits evidence. See the approved design spec for full rationale: `docs/superpowers/specs/2026-07-27-assignment-controls-champion-design.md`.

**Tech Stack:** Flutter, flutter_bloc (Cubit), get_it (DI), cloud_firestore, firebase_storage, dartz (`Either<Failure, T>`), file_picker.

## Global Constraints

- Follow `Code Quality Standards.md`: Clean Architecture layering, snake_case file names, static Firestore key constants on models (never hardcoded literals inline), `Either<Failure, T>` from repositories (no try/catch in UI), functions kept small and named descriptively.
- GRC dialog convention (no SnackBars): confirm dialog (`showConfirmDialog`) before Submit, `showSuccessDialog` after success, `showErrorDialog` on failure — see `lib/core/custom/11_custom_confirm_diaolog.dart`.
- Every mutable Firestore field on the new model is a history `List<T>` (index *i* = one revision), matching `ControlModel`/`ChampionModel`/`GRCModuleModel` exactly, including the `_allSameLength()` invariant assertion.
- Firestore field names must literally match the schema given in the spec (`Submission_ID`, `Control_Champion_Email`, `Department_Manager_Reasons of Rejection`, `Modifier` — singular, not the shared `Modifiers` key — etc.), even where they diverge from this codebase's usual naming, because the user explicitly required schema fidelity.
- No mocking framework exists in this repo (`pubspec.yaml` has no mockito/mocktail) and no GRC repository/data-source has unit tests today — only pure, mock-free logic (the model and the join/derivation resolver) gets unit tests here, using plain `package:flutter_test` `test()`/`group()`/`expect()`.
- Reuse existing widgets/helpers instead of rebuilding them: `showUploadDialog` (`lib/core/custom/10_custom_upload_document.dart`), `CustomTabs` (`lib/core/custom/10-custom_tabs.dart`), `CardStyles`/`ProductWarrantyCard` (`lib/core/custom/16-custom_card_styles.dart`, `lib/core/custom/22-custom_uploaded_document_card.dart`), `currentGrcUserEmail()`/`findControlInPolicy()` (`lib/features/grc/shared/helpers/grc_assignment_lookup.dart`), `customButton` (`lib/features/settings/core_widgets/main_widget/custom_button_widget.dart`).

---

### Task 1: `AssignmentControlEntity` + `AssignmentControlModel`

**Files:**
- Create: `lib/features/grc/assignment_control/domain/entities/assignment_control_status.dart`
- Create: `lib/features/grc/assignment_control/domain/entities/assignment_control_entity.dart`
- Create: `lib/features/grc/assignment_control/data/models/assignment_control_model.dart`
- Test: `test/features/grc/assignment_control/assignment_control_model_test.dart`

**Interfaces:**
- Consumes: nothing from other tasks (this is the foundation).
- Produces: `AssignmentControlStatus` enum (`.value`, `.fromString`), `AssignmentControlEntity` (flat, latest-values-only, same shape convention as `ControlEntity`), `AssignmentControlModel` with `AssignmentControlModel.create(...)`, `copyWithUpdate(...)`, `toJson()`, `AssignmentControlModel.fromJson(...)`, `toEntity()`. Later tasks (2, 4, 5) depend on these exact names/signatures.

- [ ] **Step 1: Write the status enum**

```dart
// lib/features/grc/assignment_control/domain/entities/assignment_control_status.dart
/// Lifecycle status of one Assignment_Controls submission cycle. Only
/// `submitted`, `inReview`, `rejected`, and `approved` are ever persisted by
/// this feature (Pending/Overdue are always derived, never stored — see the
/// design spec) — `pending`/`overdue` exist here only so `fromString` stays
/// total and forward-compatible with the future Approvals/My Audits specs.
enum AssignmentControlStatus {
  pending,
  submitted,
  inReview,
  rejected,
  approved,
  overdue;

  String get value {
    switch (this) {
      case AssignmentControlStatus.pending:
        return 'Pending';
      case AssignmentControlStatus.submitted:
        return 'Submitted';
      case AssignmentControlStatus.inReview:
        return 'In review';
      case AssignmentControlStatus.rejected:
        return 'Rejected';
      case AssignmentControlStatus.approved:
        return 'Approved';
      case AssignmentControlStatus.overdue:
        return 'Overdue';
    }
  }

  static AssignmentControlStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'submitted':
        return AssignmentControlStatus.submitted;
      case 'in review':
        return AssignmentControlStatus.inReview;
      case 'rejected':
        return AssignmentControlStatus.rejected;
      case 'approved':
        return AssignmentControlStatus.approved;
      case 'overdue':
        return AssignmentControlStatus.overdue;
      case 'pending':
      default:
        return AssignmentControlStatus.pending;
    }
  }
}
```

- [ ] **Step 2: Write the flat entity**

```dart
// lib/features/grc/assignment_control/domain/entities/assignment_control_entity.dart
import 'assignment_control_status.dart';

/// Flat (latest-values-only) representation of one Assignment_Controls
/// document, derived from the last index of every history List in
/// [AssignmentControlModel] — same convention as ControlEntity/ChampionEntity.
class AssignmentControlEntity {
  final String submissionId;
  final String controlChampionEmail;
  final String policyId;
  final String controlId;
  final String? controlOwner;
  final String? departmentManager;

  final String submissionDocument;
  final String submissionNote;
  final AssignmentControlStatus status;
  final String? departmentManagerRejectionReason;
  final double? controlScore;
  final String? controlOwnerJustification;
  final String? controlOwnerRejectionReason;

  final String lastModifier;
  final DateTime lastModificationDate;

  const AssignmentControlEntity({
    required this.submissionId,
    required this.controlChampionEmail,
    required this.policyId,
    required this.controlId,
    required this.controlOwner,
    required this.departmentManager,
    required this.submissionDocument,
    required this.submissionNote,
    required this.status,
    required this.departmentManagerRejectionReason,
    required this.controlScore,
    required this.controlOwnerJustification,
    required this.controlOwnerRejectionReason,
    required this.lastModifier,
    required this.lastModificationDate,
  });
}
```

- [ ] **Step 3: Write the failing round-trip test**

```dart
// test/features/grc/assignment_control/assignment_control_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/assignment_control/data/models/assignment_control_model.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';

void main() {
  group('AssignmentControlModel', () {
    test('create() builds a single-revision Submitted record', () {
      final model = AssignmentControlModel.create(
        submissionId: 'c1_champion@x.com',
        controlChampionEmail: 'champion@x.com',
        policyId: 'p1',
        controlId: 'c1',
        controlOwner: 'owner@x.com',
        submissionDocument: 'https://files/evidence1.pdf',
        submissionNote: 'first pass',
        editorEmail: 'champion@x.com',
      );

      expect(model.status, ['Submitted']);
      expect(model.submissionDocument, ['https://files/evidence1.pdf']);
      expect(model.submissionNote, ['first pass']);
      expect(model.modifier, ['champion@x.com']);
      expect(model.departmentManager, isNull);
      expect(model.departmentManagerRejectionReasons, [null]);
      expect(model.controlScore, [null]);
    });

    test('copyWithUpdate() appends a revision and keeps fixed fields', () {
      final created = AssignmentControlModel.create(
        submissionId: 'c1_champion@x.com',
        controlChampionEmail: 'champion@x.com',
        policyId: 'p1',
        controlId: 'c1',
        controlOwner: 'owner@x.com',
        submissionDocument: 'https://files/evidence1.pdf',
        submissionNote: 'first pass',
        editorEmail: 'champion@x.com',
      );

      final resubmitted = created.copyWithUpdate(
        submissionDocument: 'https://files/evidence2.pdf',
        submissionNote: 'fixed the gap',
        status: AssignmentControlStatus.submitted.value,
        editorEmail: 'champion@x.com',
      );

      expect(resubmitted.status, ['Submitted', 'Submitted']);
      expect(resubmitted.submissionDocument,
          ['https://files/evidence1.pdf', 'https://files/evidence2.pdf']);
      expect(resubmitted.controlOwner, 'owner@x.com');
      expect(resubmitted.submissionId, 'c1_champion@x.com');
    });

    test('toJson/fromJson round-trips every field', () {
      final model = AssignmentControlModel.create(
        submissionId: 'c1_champion@x.com',
        controlChampionEmail: 'champion@x.com',
        policyId: 'p1',
        controlId: 'c1',
        controlOwner: 'owner@x.com',
        submissionDocument: 'https://files/evidence1.pdf',
        submissionNote: 'first pass',
        editorEmail: 'champion@x.com',
      );

      final rebuilt = AssignmentControlModel.fromJson(model.toJson());

      expect(rebuilt.submissionId, model.submissionId);
      expect(rebuilt.controlChampionEmail, model.controlChampionEmail);
      expect(rebuilt.policyId, model.policyId);
      expect(rebuilt.controlId, model.controlId);
      expect(rebuilt.controlOwner, model.controlOwner);
      expect(rebuilt.status, model.status);
      expect(rebuilt.submissionDocument, model.submissionDocument);
      expect(rebuilt.submissionNote, model.submissionNote);
      expect(rebuilt.modifier, model.modifier);
    });

    test('toEntity() flattens to the latest revision', () {
      final created = AssignmentControlModel.create(
        submissionId: 'c1_champion@x.com',
        controlChampionEmail: 'champion@x.com',
        policyId: 'p1',
        controlId: 'c1',
        controlOwner: 'owner@x.com',
        submissionDocument: 'https://files/evidence1.pdf',
        submissionNote: 'first pass',
        editorEmail: 'champion@x.com',
      );
      final resubmitted = created.copyWithUpdate(
        submissionDocument: 'https://files/evidence2.pdf',
        submissionNote: 'fixed the gap',
        status: AssignmentControlStatus.submitted.value,
        editorEmail: 'champion@x.com',
      );

      final entity = resubmitted.toEntity();

      expect(entity.submissionDocument, 'https://files/evidence2.pdf');
      expect(entity.submissionNote, 'fixed the gap');
      expect(entity.status, AssignmentControlStatus.submitted);
    });

    test('constructor throws when history Lists have mismatched lengths', () {
      expect(
        () => AssignmentControlModel(
          submissionId: 'c1_champion@x.com',
          controlChampionEmail: 'champion@x.com',
          policyId: 'p1',
          controlId: 'c1',
          controlOwner: null,
          departmentManager: null,
          submissionDocument: ['a', 'b'],
          submissionNote: ['n'],
          status: const ['Submitted'],
          modifier: const ['champion@x.com'],
          modificationDate: [DateTime.now()],
          departmentManagerRejectionReasons: const [null],
          controlScore: const [null],
          controlOwnerJustifications: const [null],
          controlOwnerRejectionReasons: const [null],
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
```

- [ ] **Step 4: Run the tests to verify they fail**

Run: `puro flutter test test/features/grc/assignment_control/assignment_control_model_test.dart`
Expected: FAIL — `assignment_control_model.dart` doesn't exist yet (compile error).

- [ ] **Step 5: Write the model**

```dart
// lib/features/grc/assignment_control/data/models/assignment_control_model.dart
/// Module: Assignment Controls (Control Champion)
/// Description: Firestore model for one Control Champion's submission
///              cycle on a Control, following the same history-list
///              pattern as ControlModel/ChampionModel/GRCModuleModel:
///              every mutable field is a List<T>, index i is one revision
///              (Submit/Reject/Resubmit/Approve). Firestore path:
///              GRC Modules/{Module_ID}/Assignment Controls/{Assignment_Controls_ID}
///              where Assignment_Controls_ID = "{controlId}_{championEmail}".
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-27
/// Dependencies: AssignmentControlEntity, AssignmentControlStatus, GrcFirestoreKeys
library;

import 'package:intl/intl.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:demo_app/features/grc/shared/constants/grc_firestore_keys.dart';

final DateFormat _storageDateFormat = DateFormat('d MMM yyyy', 'en');

class AssignmentControlModel {
  static const String _keySubmissionId = 'Submission_ID';
  static const String _keyControlChampionEmail = 'Control_Champion_Email';
  static const String _keyControlId = 'Control_ID';
  static const String _keyControlOwner = 'Control_Owner';
  static const String _keyDepartmentManager = 'Department_Manager';
  static const String _keySubmissionDocument = 'Submission_Document';
  static const String _keySubmissionNote = 'Submission_Note';
  static const String _keyStatus = 'Status';
  static const String _keyDepartmentManagerRejectionReasons =
      'Department_Manager_Reasons of Rejection';
  static const String _keyControlScore = 'Control_Score';
  static const String _keyControlOwnerJustifications =
      'Control_Owner_Justifications';
  static const String _keyControlOwnerRejectionReasons =
      'Control_Owner_Reasons of Rejection';
  // Deliberately NOT reusing the shared GrcFirestoreKeys.modifiers ('Modifiers')
  // — the schema given for this feature explicitly names this field
  // "Modifier" (singular).
  static const String _keyModifier = 'Modifier';

  final String submissionId;
  final String controlChampionEmail;
  final String policyId;
  final String controlId;
  final String? controlOwner;
  final String? departmentManager;

  final List<String> submissionDocument;
  final List<String> submissionNote;
  final List<String> status; // AssignmentControlStatus.value strings
  final List<String> modifier;
  final List<DateTime> modificationDate;
  final List<String?> departmentManagerRejectionReasons;
  final List<double?> controlScore;
  final List<String?> controlOwnerJustifications;
  final List<String?> controlOwnerRejectionReasons;

  AssignmentControlModel({
    required this.submissionId,
    required this.controlChampionEmail,
    required this.policyId,
    required this.controlId,
    required this.controlOwner,
    required this.departmentManager,
    required this.submissionDocument,
    required this.submissionNote,
    required this.status,
    required this.modifier,
    required this.modificationDate,
    required this.departmentManagerRejectionReasons,
    required this.controlScore,
    required this.controlOwnerJustifications,
    required this.controlOwnerRejectionReasons,
  }) {
    assert(
      _allSameLength(),
      'All AssignmentControlModel Lists must have the same number of elements (same index count)',
    );
  }

  bool _allSameLength() {
    final lengths = <int>{
      submissionDocument.length,
      submissionNote.length,
      status.length,
      modifier.length,
      modificationDate.length,
      departmentManagerRejectionReasons.length,
      controlScore.length,
      controlOwnerJustifications.length,
      controlOwnerRejectionReasons.length,
    };
    return lengths.length == 1;
  }

  /// Builds the first revision of a submission cycle — always Status
  /// "Submitted" (there is no stored "Pending" revision; see design spec).
  /// [departmentManager] is always null for now — no dept-manager lookup
  /// exists yet in this codebase (left for the future Approvals spec).
  factory AssignmentControlModel.create({
    required String submissionId,
    required String controlChampionEmail,
    required String policyId,
    required String controlId,
    required String? controlOwner,
    required String submissionDocument,
    required String submissionNote,
    required String editorEmail,
  }) {
    final now = DateTime.now();
    return AssignmentControlModel(
      submissionId: submissionId,
      controlChampionEmail: controlChampionEmail,
      policyId: policyId,
      controlId: controlId,
      controlOwner: controlOwner,
      departmentManager: null,
      submissionDocument: [submissionDocument],
      submissionNote: [submissionNote],
      status: [AssignmentControlStatus.submitted.value],
      modifier: [editorEmail],
      modificationDate: [now],
      departmentManagerRejectionReasons: const [null],
      controlScore: const [null],
      controlOwnerJustifications: const [null],
      controlOwnerRejectionReasons: const [null],
    );
  }

  /// Appends a new revision to every history List, reusing the previous
  /// value for anything not passed. The fixed fields (submissionId,
  /// controlChampionEmail, policyId, controlId, controlOwner,
  /// departmentManager) are always carried over unchanged — this feature
  /// never mutates them after creation.
  AssignmentControlModel copyWithUpdate({
    String? submissionDocument,
    String? submissionNote,
    String? status,
    String? departmentManagerRejectionReason,
    double? controlScore,
    String? controlOwnerJustification,
    String? controlOwnerRejectionReason,
    required String editorEmail,
  }) {
    final now = DateTime.now();
    return AssignmentControlModel(
      submissionId: submissionId,
      controlChampionEmail: controlChampionEmail,
      policyId: policyId,
      controlId: controlId,
      controlOwner: controlOwner,
      departmentManager: departmentManager,
      submissionDocument: [
        ...this.submissionDocument,
        submissionDocument ?? this.submissionDocument.last,
      ],
      submissionNote: [
        ...this.submissionNote,
        submissionNote ?? this.submissionNote.last,
      ],
      status: [...this.status, status ?? this.status.last],
      modifier: [...modifier, editorEmail],
      modificationDate: [...modificationDate, now],
      departmentManagerRejectionReasons: [
        ...this.departmentManagerRejectionReasons,
        departmentManagerRejectionReason ??
            this.departmentManagerRejectionReasons.last,
      ],
      controlScore: [
        ...this.controlScore,
        controlScore ?? this.controlScore.last,
      ],
      controlOwnerJustifications: [
        ...this.controlOwnerJustifications,
        controlOwnerJustification ?? this.controlOwnerJustifications.last,
      ],
      controlOwnerRejectionReasons: [
        ...this.controlOwnerRejectionReasons,
        controlOwnerRejectionReason ?? this.controlOwnerRejectionReasons.last,
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _keySubmissionId: submissionId,
      _keyControlChampionEmail: controlChampionEmail,
      GrcFirestoreKeys.policyId: policyId,
      _keyControlId: controlId,
      _keyControlOwner: controlOwner,
      _keyDepartmentManager: departmentManager,
      _keySubmissionDocument: submissionDocument,
      _keySubmissionNote: submissionNote,
      _keyStatus: status,
      _keyModifier: modifier,
      GrcFirestoreKeys.modificationDate:
          modificationDate.map((d) => _storageDateFormat.format(d)).toList(),
      _keyDepartmentManagerRejectionReasons: departmentManagerRejectionReasons,
      _keyControlScore: controlScore,
      _keyControlOwnerJustifications: controlOwnerJustifications,
      _keyControlOwnerRejectionReasons: controlOwnerRejectionReasons,
    };
  }

  factory AssignmentControlModel.fromJson(Map<String, dynamic> json) {
    return AssignmentControlModel(
      submissionId: json[_keySubmissionId] as String,
      controlChampionEmail: json[_keyControlChampionEmail] as String,
      policyId: json[GrcFirestoreKeys.policyId] as String,
      controlId: json[_keyControlId] as String,
      controlOwner: json[_keyControlOwner] as String?,
      departmentManager: json[_keyDepartmentManager] as String?,
      submissionDocument: List<String>.from(json[_keySubmissionDocument] ?? []),
      submissionNote: List<String>.from(json[_keySubmissionNote] ?? []),
      status: List<String>.from(json[_keyStatus] ?? []),
      modifier: List<String>.from(json[_keyModifier] ?? []),
      modificationDate: (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      departmentManagerRejectionReasons: List<String?>.from(
          json[_keyDepartmentManagerRejectionReasons] ?? []),
      controlScore: (json[_keyControlScore] as List? ?? [])
          .map((e) => e == null ? null : (e as num).toDouble())
          .toList(),
      controlOwnerJustifications:
          List<String?>.from(json[_keyControlOwnerJustifications] ?? []),
      controlOwnerRejectionReasons:
          List<String?>.from(json[_keyControlOwnerRejectionReasons] ?? []),
    );
  }

  AssignmentControlEntity toEntity() {
    return AssignmentControlEntity(
      submissionId: submissionId,
      controlChampionEmail: controlChampionEmail,
      policyId: policyId,
      controlId: controlId,
      controlOwner: controlOwner,
      departmentManager: departmentManager,
      submissionDocument: submissionDocument.last,
      submissionNote: submissionNote.last,
      status: AssignmentControlStatus.fromString(status.last),
      departmentManagerRejectionReason: departmentManagerRejectionReasons.last,
      controlScore: controlScore.last,
      controlOwnerJustification: controlOwnerJustifications.last,
      controlOwnerRejectionReason: controlOwnerRejectionReasons.last,
      lastModifier: modifier.last,
      lastModificationDate: modificationDate.last,
    );
  }
}
```

- [ ] **Step 6: Run the tests to verify they pass**

Run: `puro flutter test test/features/grc/assignment_control/assignment_control_model_test.dart`
Expected: PASS (5 tests)

- [ ] **Step 7: Commit**

```bash
git add lib/features/grc/assignment_control/domain/entities/assignment_control_status.dart \
        lib/features/grc/assignment_control/domain/entities/assignment_control_entity.dart \
        lib/features/grc/assignment_control/data/models/assignment_control_model.dart \
        test/features/grc/assignment_control/assignment_control_model_test.dart
git commit -m "feat(grc): add AssignmentControlModel/Entity for Assignment Controls"
```

---

### Task 2: Join/derivation resolver (tab computation + owner lookup)

**Files:**
- Create: `lib/features/grc/assignment_control/domain/entities/assignment_control_tab.dart`
- Create: `lib/features/grc/assignment_control/domain/entities/assignment_control_item.dart`
- Create: `lib/features/grc/assignment_control/domain/entities/assignment_control_resolver.dart`
- Test: `test/features/grc/assignment_control/assignment_control_resolver_test.dart`

**Interfaces:**
- Consumes: `AssignmentControlEntity`, `AssignmentControlStatus` (Task 1); `ControlEntity` (`lib/features/grc/control/domain/entities/control_entity.dart`, existing); `AssigningControlEntity` (`lib/features/grc/control/domain/entities/assigning_control.dart`, existing); `OwnerEntity` (`lib/features/grc/control_owner/domain/entities/owner_entity.dart`, existing); `findControlInPolicy` (`lib/features/grc/shared/helpers/grc_assignment_lookup.dart`, existing).
- Produces: `AssignmentControlTab` enum (with `.label` for display), `AssignmentControlItem` class, `computeAssignmentControlTab(...)`, `buildAssignmentControlItems(...)`, `findOwnerEmailForControl(...)` — all consumed by Task 5's Cubit and Task 6's list page.

- [ ] **Step 1: Write the tab enum and item class**

```dart
// lib/features/grc/assignment_control/domain/entities/assignment_control_tab.dart
/// The 6 tabs shown on the Champion's Assignment Controls list. Unlike
/// AssignmentControlStatus, `pending` and `overdue` here are real, always
/// re-derived UI states — see computeAssignmentControlTab.
enum AssignmentControlTab {
  pending,
  submitted,
  inReview,
  rejected,
  approved,
  overdue;

  String get label {
    switch (this) {
      case AssignmentControlTab.pending:
        return 'Pending';
      case AssignmentControlTab.submitted:
        return 'Submitted';
      case AssignmentControlTab.inReview:
        return 'In Review';
      case AssignmentControlTab.rejected:
        return 'Rejected';
      case AssignmentControlTab.approved:
        return 'Approved';
      case AssignmentControlTab.overdue:
        return 'Overdue';
    }
  }
}
```

```dart
// lib/features/grc/assignment_control/domain/entities/assignment_control_item.dart
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';

/// One row on the Champion's Assignment Controls list: a Control this
/// champion is assigned to, its (possibly absent) Assignment_Controls
/// submission, and the tab it currently belongs to.
class AssignmentControlItem {
  final ControlEntity control;
  final AssignmentControlEntity? assignment;
  final AssignmentControlTab tab;

  const AssignmentControlItem({
    required this.control,
    required this.assignment,
    required this.tab,
  });
}
```

- [ ] **Step 2: Write the failing tests**

```dart
// test/features/grc/assignment_control/assignment_control_resolver_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_resolver.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_status.dart';

ControlEntity _control({
  required String id,
  required String policyId,
  required DateTime endDate,
}) {
  final now = DateTime.now();
  return ControlEntity(
    id: id,
    policyId: policyId,
    controlsNameEn: 'Control $id',
    controlsNameAr: 'Control $id',
    controlsNumberEn: 'C-$id',
    controlsNumberAr: 'C-$id',
    controlsDescriptionEn: 'desc',
    controlsDescriptionAr: 'desc',
    controlsDocumentEn: null,
    controlsDocumentAr: null,
    controlsWeight: 10,
    frequency: 'Monthly',
    startDate: now,
    endDate: endDate,
    departments: const [],
    equalWeights: true,
    score: 0,
    status: ControlStatus.active,
    lastModifiedDate: now,
    lastEditor: 'editor@x.com',
  );
}

AssignmentControlEntity _assignment(AssignmentControlStatus status) {
  final now = DateTime.now();
  return AssignmentControlEntity(
    submissionId: 'c1_champion@x.com',
    controlChampionEmail: 'champion@x.com',
    policyId: 'p1',
    controlId: 'c1',
    controlOwner: 'owner@x.com',
    departmentManager: null,
    submissionDocument: 'https://files/e.pdf',
    submissionNote: 'note',
    status: status,
    departmentManagerRejectionReason: null,
    controlScore: null,
    controlOwnerJustification: null,
    controlOwnerRejectionReason: null,
    lastModifier: 'champion@x.com',
    lastModificationDate: now,
  );
}

void main() {
  group('computeAssignmentControlTab', () {
    test('no assignment + endDate in the future -> pending', () {
      final control = _control(
        id: 'c1',
        policyId: 'p1',
        endDate: DateTime.now().add(const Duration(days: 10)),
      );
      final tab = computeAssignmentControlTab(control: control, assignment: null);
      expect(tab, AssignmentControlTab.pending);
    });

    test('no assignment + endDate in the past -> overdue', () {
      final control = _control(
        id: 'c1',
        policyId: 'p1',
        endDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      final tab = computeAssignmentControlTab(control: control, assignment: null);
      expect(tab, AssignmentControlTab.overdue);
    });

    test('assignment Submitted -> submitted tab regardless of endDate', () {
      final control = _control(
        id: 'c1',
        policyId: 'p1',
        endDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      final tab = computeAssignmentControlTab(
        control: control,
        assignment: _assignment(AssignmentControlStatus.submitted),
      );
      expect(tab, AssignmentControlTab.submitted);
    });

    test('assignment Rejected -> rejected tab', () {
      final control = _control(
        id: 'c1',
        policyId: 'p1',
        endDate: DateTime.now().add(const Duration(days: 10)),
      );
      final tab = computeAssignmentControlTab(
        control: control,
        assignment: _assignment(AssignmentControlStatus.rejected),
      );
      expect(tab, AssignmentControlTab.rejected);
    });
  });

  group('buildAssignmentControlItems', () {
    test('joins assigningControls with policyControls and existingAssignments', () {
      final control = _control(
        id: 'c1',
        policyId: 'p1',
        endDate: DateTime.now().add(const Duration(days: 10)),
      );
      final items = buildAssignmentControlItems(
        assigningControls: const [
          AssigningControlEntity(policyId: 'p1', controlId: 'c1'),
        ],
        policyControls: {
          'p1': [control],
        },
        existingAssignments: {},
      );

      expect(items, hasLength(1));
      expect(items.first.control.id, 'c1');
      expect(items.first.assignment, isNull);
      expect(items.first.tab, AssignmentControlTab.pending);
    });

    test('skips a pair whose control cannot be found', () {
      final items = buildAssignmentControlItems(
        assigningControls: const [
          AssigningControlEntity(policyId: 'p1', controlId: 'missing'),
        ],
        policyControls: const {'p1': []},
        existingAssignments: const {},
      );

      expect(items, isEmpty);
    });
  });

  group('findOwnerEmailForControl', () {
    test('returns the email of the owner covering this policy+control', () {
      final owner = OwnerEntity(
        ownerEmail: 'owner@x.com',
        assigningControls: const [
          AssigningControlEntity(policyId: 'p1', controlId: 'c1'),
        ],
        controlOwnerPermissions: const [[]],
        status: OwnerStatus.active,
        createdAt: DateTime.now(),
        modificationDate: DateTime.now(),
        lastModifier: 'x@x.com',
      );

      final email = findOwnerEmailForControl(
        [owner],
        policyId: 'p1',
        controlId: 'c1',
      );

      expect(email, 'owner@x.com');
    });

    test('returns null when no owner covers this policy+control', () {
      final email = findOwnerEmailForControl(
        const [],
        policyId: 'p1',
        controlId: 'c1',
      );
      expect(email, isNull);
    });
  });
}
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `puro flutter test test/features/grc/assignment_control/assignment_control_resolver_test.dart`
Expected: FAIL — `assignment_control_resolver.dart` doesn't exist yet.

- [ ] **Step 4: Write the resolver**

```dart
// lib/features/grc/assignment_control/domain/entities/assignment_control_resolver.dart
/// Module: Assignment Controls (Control Champion)
/// Description: Pure join/derivation logic for the Champion's Assignment
///              Controls list — no persistence, no side effects. See
///              docs/superpowers/specs/2026-07-27-assignment-controls-champion-design.md
///              Section "Building the champion's list".
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-27
library;

import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'assignment_control_entity.dart';
import 'assignment_control_item.dart';
import 'assignment_control_status.dart';
import 'assignment_control_tab.dart';

/// Derives which tab [control] currently belongs to for this champion.
/// [assignment] is null when no Assignment_Controls document has ever been
/// created for this control+champion pair yet (nothing submitted).
AssignmentControlTab computeAssignmentControlTab({
  required ControlEntity control,
  required AssignmentControlEntity? assignment,
}) {
  if (assignment == null) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startOfEnd =
        DateTime(control.endDate.year, control.endDate.month, control.endDate.day);
    return startOfEnd.isBefore(startOfToday)
        ? AssignmentControlTab.overdue
        : AssignmentControlTab.pending;
  }

  switch (assignment.status) {
    case AssignmentControlStatus.submitted:
      return AssignmentControlTab.submitted;
    case AssignmentControlStatus.inReview:
      return AssignmentControlTab.inReview;
    case AssignmentControlStatus.rejected:
      return AssignmentControlTab.rejected;
    case AssignmentControlStatus.approved:
      return AssignmentControlTab.approved;
    case AssignmentControlStatus.pending:
    case AssignmentControlStatus.overdue:
      // Never actually persisted by this feature — defensive fallback only.
      return AssignmentControlTab.pending;
  }
}

/// Joins a champion's [assigningControls] with the already-loaded
/// [policyControls] (policyId -> its Controls) and [existingAssignments]
/// (controlId -> that control's Assignment_Controls doc, if any) into the
/// list of rows the Assignment Controls page renders. A pair whose Control
/// can't be found (e.g. deleted) is silently skipped.
List<AssignmentControlItem> buildAssignmentControlItems({
  required List<AssigningControlEntity> assigningControls,
  required Map<String, List<ControlEntity>> policyControls,
  required Map<String, AssignmentControlEntity> existingAssignments,
}) {
  final items = <AssignmentControlItem>[];
  for (final ac in assigningControls) {
    final control = findControlInPolicy(policyControls, ac.policyId, ac.controlId);
    if (control == null) continue;
    final assignment = existingAssignments[ac.controlId];
    items.add(AssignmentControlItem(
      control: control,
      assignment: assignment,
      tab: computeAssignmentControlTab(control: control, assignment: assignment),
    ));
  }
  return items;
}

/// Finds the email of the Control Owner currently covering [policyId] +
/// [controlId], mirroring how a Champion is resolved for the same pair.
/// Returns null if no owner covers it (Control_Owner then stays null on the
/// created Assignment_Controls document).
String? findOwnerEmailForControl(
  List<OwnerEntity> owners, {
  required String policyId,
  required String controlId,
}) {
  for (final owner in owners) {
    final matches = owner.assigningControls
        .any((ac) => ac.policyId == policyId && ac.controlId == controlId);
    if (matches) return owner.ownerEmail;
  }
  return null;
}
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `puro flutter test test/features/grc/assignment_control/assignment_control_resolver_test.dart`
Expected: PASS (7 tests)

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/assignment_control/domain/entities/assignment_control_tab.dart \
        lib/features/grc/assignment_control/domain/entities/assignment_control_item.dart \
        lib/features/grc/assignment_control/domain/entities/assignment_control_resolver.dart \
        test/features/grc/assignment_control/assignment_control_resolver_test.dart
git commit -m "feat(grc): add Assignment Controls tab-derivation resolver"
```

---

### Task 3: Storage upload method for evidence files

**Files:**
- Modify: `lib/features/grc/policy/data/data_source/policy_storage_data_source.dart`

**Interfaces:**
- Consumes: nothing new (uses the class's existing `_storage` field and private `_buildFileName` helper already in this file).
- Produces: `PolicyStorageDataSource.uploadAssignmentEvidence({required moduleId, required controlId, required championEmail, required documentFile})` → `Future<String>` (download URL). Task 4's repository depends on this exact method name/signature.

- [ ] **Step 1: Add the method**

Add this method to the `PolicyStorageDataSource` class, right after the existing `uploadControlDocument` method (before the `DELETE (shared for any file)` section header):

```dart
  // ------------------------------------------------------------------
  // ASSIGNMENT CONTROL EVIDENCE
  // ------------------------------------------------------------------

  /// function name: [uploadAssignmentEvidence]
  ///
  /// purpose: upload a Control Champion's submitted evidence file to
  ///          Firebase Storage and return its public download URL, to be
  ///          stored as one revision of AssignmentControlModel's
  ///          submissionDocument history list. Stored under a top-level
  ///          folder (not under Policies_Files) since Assignment_Controls
  ///          documents live directly under the Module, not under a Policy.
  ///
  /// parameters:
  ///            [String] moduleId: id of the GRC Module the assignment belongs to
  ///            [String] controlId: id of the Control the evidence is for
  ///            [String] championEmail: email of the champion submitting
  ///            [File] documentFile: the local evidence file to upload
  ///
  /// return type: [Future<String>] - the download URL of the uploaded evidence file, or throws an Exception on failure
  Future<String> uploadAssignmentEvidence({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required File documentFile,
  }) async {
    try {
      final fileName = _buildFileName(documentFile);
      final ref = _storage.ref(
        'Assignment_Controls_Files/$moduleId/$controlId/$championEmail/$fileName',
      );
      final uploadTask = await ref.putFile(documentFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload the Assignment Control evidence: $e');
    }
  }

```

- [ ] **Step 2: Verify it compiles**

Run: `puro flutter analyze lib/features/grc/policy/data/data_source/policy_storage_data_source.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/policy/data/data_source/policy_storage_data_source.dart
git commit -m "feat(grc): add uploadAssignmentEvidence to PolicyStorageDataSource"
```

---

### Task 4: Data source, repository, and use cases

**Files:**
- Create: `lib/features/grc/assignment_control/data/data_source/assignment_control_data_source.dart`
- Create: `lib/features/grc/assignment_control/data/data_source/assignment_control_firebase_data_source.dart`
- Create: `lib/features/grc/assignment_control/domain/repository/assignment_control_repository.dart`
- Create: `lib/features/grc/assignment_control/data/repository/assignment_control_repository_impl.dart`
- Create: `lib/features/grc/assignment_control/domain/use_cases/get_assignment_control_usecase.dart`
- Create: `lib/features/grc/assignment_control/domain/use_cases/submit_evidence_usecase.dart`

**Interfaces:**
- Consumes: `AssignmentControlModel`/`AssignmentControlEntity` (Task 1), `AssignmentControlStatus` (Task 1), `PolicyStorageDataSource.uploadAssignmentEvidence` (Task 3), `Failure`/`FirebaseFailure` (`lib/core/network/failure_model.dart`, existing), `getBaseUrl` (`lib/core/network/get_base_url.dart`, existing).
- Produces: `GetAssignmentControlUseCase.call({required moduleId, required controlId, required championEmail})` → `Future<Either<Failure, AssignmentControlEntity?>>`; `SubmitEvidenceUseCase.call(SubmitEvidenceParams(...))` → `Future<Either<Failure, AssignmentControlEntity>>`. Task 5's Cubit and Task 8's DI wiring depend on these two use case classes and `SubmitEvidenceParams`.

- [ ] **Step 1: Write the data source interface + Firestore implementation**

```dart
// lib/features/grc/assignment_control/data/data_source/assignment_control_data_source.dart
import 'package:demo_app/features/grc/assignment_control/data/models/assignment_control_model.dart';

abstract class AssignmentControlDataSource {
  Future<AssignmentControlModel?> get(String id, {required String moduleId});

  Future<AssignmentControlModel> create(
    AssignmentControlModel model, {
    required String moduleId,
  });

  Future<AssignmentControlModel> update(
    AssignmentControlModel model, {
    required String moduleId,
  });
}
```

```dart
// lib/features/grc/assignment_control/data/data_source/assignment_control_firebase_data_source.dart
/// Module: Assignment Controls (Control Champion)
/// Description: Cloud Firestore implementation of
///              [AssignmentControlDataSource]. Firestore path:
///              GRC Modules/{Module_ID}/Assignment Controls/{Assignment_Controls_ID}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-27

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import 'package:demo_app/features/grc/assignment_control/data/models/assignment_control_model.dart';

import 'assignment_control_data_source.dart';

class AssignmentControlFirebaseDataSource implements AssignmentControlDataSource {
  AssignmentControlFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String get _modulesCollectionPath =>
      '${getBaseUrl('Modules')}/grc/GRC Modules';
  static const String _assignmentControlsSubcollectionPath =
      'Assignment Controls';

  CollectionReference<Map<String, dynamic>> _collection(String moduleId) =>
      _firestore
          .collection(_modulesCollectionPath)
          .doc(moduleId)
          .collection(_assignmentControlsSubcollectionPath);

  @override
  Future<AssignmentControlModel?> get(
    String id, {
    required String moduleId,
  }) async {
    try {
      final doc = await _collection(moduleId).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return AssignmentControlModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch the Assignment Control: $e');
    }
  }

  @override
  Future<AssignmentControlModel> create(
    AssignmentControlModel model, {
    required String moduleId,
  }) async {
    try {
      await _collection(moduleId).doc(model.submissionId).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to create the Assignment Control: $e');
    }
  }

  @override
  Future<AssignmentControlModel> update(
    AssignmentControlModel model, {
    required String moduleId,
  }) async {
    try {
      await _collection(moduleId).doc(model.submissionId).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to update the Assignment Control: $e');
    }
  }
}
```

- [ ] **Step 2: Write the repository contract + implementation**

```dart
// lib/features/grc/assignment_control/domain/repository/assignment_control_repository.dart
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';

abstract class AssignmentControlRepository {
  /// Returns Right(null) — not an error — when no submission has ever been
  /// made for this control+champion pair yet (the Pending/Overdue state).
  Future<Either<Failure, AssignmentControlEntity?>> getAssignmentControl({
    required String moduleId,
    required String controlId,
    required String championEmail,
  });

  Future<Either<Failure, AssignmentControlEntity>> submitEvidence({
    required String moduleId,
    required String policyId,
    required String controlId,
    required String championEmail,
    required String? controlOwnerEmail,
    required File documentFile,
    required String note,
    required String editorEmail,
  });
}
```

```dart
// lib/features/grc/assignment_control/data/repository/assignment_control_repository_impl.dart
/// Module: Assignment Controls (Control Champion)
/// Description: Data-layer implementation of [AssignmentControlRepository].
///              Maps between AssignmentControlModel (persistence) and
///              AssignmentControlEntity (domain), uploads evidence files via
///              [PolicyStorageDataSource], and wraps every result in
///              Either<Failure, T>.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-27

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/assignment_control/data/data_source/assignment_control_data_source.dart';
import 'package:demo_app/features/grc/assignment_control/data/models/assignment_control_model.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:demo_app/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';
import 'package:demo_app/features/grc/policy/data/data_source/policy_storage_data_source.dart';

class AssignmentControlRepositoryImpl implements AssignmentControlRepository {
  AssignmentControlRepositoryImpl({
    required AssignmentControlDataSource dataSource,
    required PolicyStorageDataSource storageDataSource,
  })  : _dataSource = dataSource,
        _storageDataSource = storageDataSource;

  final AssignmentControlDataSource _dataSource;
  final PolicyStorageDataSource _storageDataSource;

  String _docId({required String controlId, required String championEmail}) =>
      '${controlId}_$championEmail';

  @override
  Future<Either<Failure, AssignmentControlEntity?>> getAssignmentControl({
    required String moduleId,
    required String controlId,
    required String championEmail,
  }) async {
    try {
      final model = await _dataSource.get(
        _docId(controlId: controlId, championEmail: championEmail),
        moduleId: moduleId,
      );
      return Right(model?.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssignmentControlEntity>> submitEvidence({
    required String moduleId,
    required String policyId,
    required String controlId,
    required String championEmail,
    required String? controlOwnerEmail,
    required File documentFile,
    required String note,
    required String editorEmail,
  }) async {
    try {
      final id = _docId(controlId: controlId, championEmail: championEmail);
      final documentUrl = await _storageDataSource.uploadAssignmentEvidence(
        moduleId: moduleId,
        controlId: controlId,
        championEmail: championEmail,
        documentFile: documentFile,
      );
      final current = await _dataSource.get(id, moduleId: moduleId);

      final AssignmentControlModel saved;
      if (current == null) {
        final model = AssignmentControlModel.create(
          submissionId: id,
          controlChampionEmail: championEmail,
          policyId: policyId,
          controlId: controlId,
          controlOwner: controlOwnerEmail,
          submissionDocument: documentUrl,
          submissionNote: note,
          editorEmail: editorEmail,
        );
        saved = await _dataSource.create(model, moduleId: moduleId);
      } else {
        final model = current.copyWithUpdate(
          submissionDocument: documentUrl,
          submissionNote: note,
          status: AssignmentControlStatus.submitted.value,
          editorEmail: editorEmail,
        );
        saved = await _dataSource.update(model, moduleId: moduleId);
      }
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
```

- [ ] **Step 3: Write the use cases**

```dart
// lib/features/grc/assignment_control/domain/use_cases/get_assignment_control_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';

class GetAssignmentControlUseCase {
  const GetAssignmentControlUseCase(this._repository);

  final AssignmentControlRepository _repository;

  Future<Either<Failure, AssignmentControlEntity?>> call({
    required String moduleId,
    required String controlId,
    required String championEmail,
  }) {
    return _repository.getAssignmentControl(
      moduleId: moduleId,
      controlId: controlId,
      championEmail: championEmail,
    );
  }
}
```

```dart
// lib/features/grc/assignment_control/domain/use_cases/submit_evidence_usecase.dart
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';

class SubmitEvidenceParams {
  final String moduleId;
  final String policyId;
  final String controlId;
  final String championEmail;
  final String? controlOwnerEmail;
  final File documentFile;
  final String note;
  final String editorEmail;

  const SubmitEvidenceParams({
    required this.moduleId,
    required this.policyId,
    required this.controlId,
    required this.championEmail,
    required this.controlOwnerEmail,
    required this.documentFile,
    required this.note,
    required this.editorEmail,
  });
}

class SubmitEvidenceUseCase {
  const SubmitEvidenceUseCase(this._repository);

  final AssignmentControlRepository _repository;

  Future<Either<Failure, AssignmentControlEntity>> call(
    SubmitEvidenceParams params,
  ) {
    return _repository.submitEvidence(
      moduleId: params.moduleId,
      policyId: params.policyId,
      controlId: params.controlId,
      championEmail: params.championEmail,
      controlOwnerEmail: params.controlOwnerEmail,
      documentFile: params.documentFile,
      note: params.note,
      editorEmail: params.editorEmail,
    );
  }
}
```

- [ ] **Step 4: Verify it compiles**

Run: `puro flutter analyze lib/features/grc/assignment_control`
Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/assignment_control/data/data_source/ \
        lib/features/grc/assignment_control/domain/repository/ \
        lib/features/grc/assignment_control/data/repository/ \
        lib/features/grc/assignment_control/domain/use_cases/
git commit -m "feat(grc): add Assignment Controls data source, repository, use cases"
```

---

### Task 5: `AssignmentControlCubit`

**Files:**
- Create: `lib/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart`
- Create: `lib/features/grc/assignment_control/presentation/controller/assignment_control_state.dart`

**Interfaces:**
- Consumes: `AssignmentControlItem`/`buildAssignmentControlItems`/`findOwnerEmailForControl` (Task 2), `GetAssignmentControlUseCase`/`SubmitEvidenceUseCase`/`SubmitEvidenceParams` (Task 4), and existing `GetChampionUseCase` (`lib/features/grc/control_champion/domain/use_cases/get_champion_usecases.dart`), `GetAllControlsUseCase` (`lib/features/grc/control/domain/use_cases/get_control_usecases.dart`), `GetAllOwnersUseCase` (`lib/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart`), `ValidationError` (`lib/core/network/failure_model.dart`).
- Produces: `AssignmentControlCubit` with `getMyAssignmentControls({required moduleId, required championEmail})` and `submitEvidence({required moduleId, required policyId, required controlId, required championEmail, required documentFile, required note})`; states `AssignmentControlInitial/Loading/ListLoaded(List<AssignmentControlItem>)/ActionSuccess(AssignmentControlEntity)/Failure(String)`. Tasks 6 and 7 (UI) depend on these exact names.

- [ ] **Step 1: Write the state file**

```dart
// lib/features/grc/assignment_control/presentation/controller/assignment_control_state.dart
part of 'assignment_control_cubit.dart';

sealed class AssignmentControlState {}

final class AssignmentControlInitial extends AssignmentControlState {}

final class AssignmentControlLoading extends AssignmentControlState {}

final class AssignmentControlListLoaded extends AssignmentControlState {
  final List<AssignmentControlItem> items;
  AssignmentControlListLoaded(this.items);
}

final class AssignmentControlActionSuccess extends AssignmentControlState {
  final AssignmentControlEntity assignment;
  AssignmentControlActionSuccess(this.assignment);
}

final class AssignmentControlFailure extends AssignmentControlState {
  final String message;
  AssignmentControlFailure(this.message);
}
```

- [ ] **Step 2: Write the cubit**

```dart
// lib/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart
/// Module: Assignment Controls (Control Champion)
/// Description: BLoC Cubit that manages the Champion's Assignment Controls
///              list and Submit-evidence action, mirroring ChampionCubit's
///              shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-27

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_item.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_resolver.dart';
import 'package:demo_app/features/grc/assignment_control/domain/use_cases/get_assignment_control_usecase.dart';
import 'package:demo_app/features/grc/assignment_control/domain/use_cases/submit_evidence_usecase.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/get_champion_usecases.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart';

part 'assignment_control_state.dart';

class AssignmentControlCubit extends Cubit<AssignmentControlState> {
  AssignmentControlCubit({
    required GetChampionUseCase getChampionUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
    required GetAllOwnersUseCase getAllOwnersUseCase,
    required GetAssignmentControlUseCase getAssignmentControlUseCase,
    required SubmitEvidenceUseCase submitEvidenceUseCase,
  })  : _getChampionUseCase = getChampionUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        _getAllOwnersUseCase = getAllOwnersUseCase,
        _getAssignmentControlUseCase = getAssignmentControlUseCase,
        _submitEvidenceUseCase = submitEvidenceUseCase,
        super(AssignmentControlInitial());

  final GetChampionUseCase _getChampionUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
  final GetAllOwnersUseCase _getAllOwnersUseCase;
  final GetAssignmentControlUseCase _getAssignmentControlUseCase;
  final SubmitEvidenceUseCase _submitEvidenceUseCase;

  /// Loads every control this champion is assigned to (via ChampionModel,
  /// no Assignment_Controls doc required), resolves each control's details
  /// and any existing Assignment_Controls submission, then emits the
  /// derived list. A champion with no record yet (ValidationError from
  /// getChampion) is a normal empty state, not a failure.
  Future<void> getMyAssignmentControls({
    required String moduleId,
    required String championEmail,
  }) async {
    emit(AssignmentControlLoading());
    final championResult =
        await _getChampionUseCase.call(championEmail, moduleId: moduleId);

    await championResult.fold(
      (failure) async {
        if (failure is ValidationError) {
          emit(AssignmentControlListLoaded(const []));
        } else {
          emit(AssignmentControlFailure(failure.message));
        }
      },
      (champion) async {
        final policyControls = <String, List<ControlEntity>>{};
        for (final ac in champion.assigningControls) {
          if (policyControls.containsKey(ac.policyId)) continue;
          final controlsResult = await _getAllControlsUseCase.call(
            moduleId: moduleId,
            policyId: ac.policyId,
          );
          controlsResult.fold(
            (_) {},
            (controls) => policyControls[ac.policyId] = controls,
          );
        }

        final existingAssignments = <String, AssignmentControlEntity>{};
        for (final ac in champion.assigningControls) {
          final assignmentResult = await _getAssignmentControlUseCase.call(
            moduleId: moduleId,
            controlId: ac.controlId,
            championEmail: championEmail,
          );
          assignmentResult.fold(
            (_) {},
            (assignment) {
              if (assignment != null) {
                existingAssignments[ac.controlId] = assignment;
              }
            },
          );
        }

        emit(AssignmentControlListLoaded(
          buildAssignmentControlItems(
            assigningControls: champion.assigningControls,
            policyControls: policyControls,
            existingAssignments: existingAssignments,
          ),
        ));
      },
    );
  }

  /// Resolves the current Control Owner for this policy+control (if any),
  /// then submits (creates or resubmits) the evidence.
  Future<void> submitEvidence({
    required String moduleId,
    required String policyId,
    required String controlId,
    required String championEmail,
    required File documentFile,
    required String note,
  }) async {
    emit(AssignmentControlLoading());
    final ownersResult = await _getAllOwnersUseCase.call(moduleId: moduleId);
    final ownerEmail = ownersResult.fold(
      (_) => null,
      (owners) => findOwnerEmailForControl(
        owners,
        policyId: policyId,
        controlId: controlId,
      ),
    );

    final result = await _submitEvidenceUseCase.call(
      SubmitEvidenceParams(
        moduleId: moduleId,
        policyId: policyId,
        controlId: controlId,
        championEmail: championEmail,
        controlOwnerEmail: ownerEmail,
        documentFile: documentFile,
        note: note,
        editorEmail: championEmail,
      ),
    );

    result.fold(
      (failure) => emit(AssignmentControlFailure(failure.message)),
      (assignment) => emit(AssignmentControlActionSuccess(assignment)),
    );
  }
}
```

- [ ] **Step 3: Verify it compiles**

Run: `puro flutter analyze lib/features/grc/assignment_control`
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/assignment_control/presentation/controller/
git commit -m "feat(grc): add AssignmentControlCubit"
```

---

### Task 6: `AssignmentControlsListPage`

**Files:**
- Create: `lib/features/grc/assignment_control/presentation/ui/pages/assignment_controls_list_page.dart`
- Create: `lib/features/grc/assignment_control/presentation/ui/widgets/assignment_control_card.dart`

**Interfaces:**
- Consumes: `AssignmentControlCubit`/states (Task 5), `AssignmentControlItem`/`AssignmentControlTab` (Task 2), existing `GRCModuleEntity` (`lib/features/grc/module/domain/entities/grc_module_entity.dart`), `currentGrcUserEmail` (`lib/features/grc/shared/helpers/grc_assignment_lookup.dart`), `CustomTabs` (`lib/core/custom/10-custom_tabs.dart`), `PaginationAppBar` (`lib/features/home/core_widgets/main_widget/pagination_app_bar.dart`), `CardStyles` (`lib/core/custom/16-custom_card_styles.dart`).
- Produces: `AssignmentControlsListPage(module: GRCModuleEntity)` — Task 8 navigates to this from the module details page; it internally navigates to Task 7's `AssignmentControlDetailsPage`.

- [ ] **Step 1: Write the card widget**

```dart
// lib/features/grc/assignment_control/presentation/ui/widgets/assignment_control_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_item.dart';

class AssignmentControlCard extends StatelessWidget {
  final AssignmentControlItem item;
  final bool isArabic;
  final VoidCallback onTap;

  const AssignmentControlCard({
    super.key,
    required this.item,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final control = item.control;
    return InkWell(
      onTap: onTap,
      borderRadius: CardStyles.radius(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: CardStyles.radius(),
          boxShadow: CardStyles.shadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isArabic ? control.controlsNameAr : control.controlsNameEn,
                    style: CardStyles.value(14),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    isArabic ? control.controlsNumberAr : control.controlsNumberEn,
                    style: CardStyles.label(12),
                  ),
                ],
              ),
            ),
            Text(item.tab.label, style: CardStyles.label(12)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Write the list page**

```dart
// lib/features/grc/assignment_control/presentation/ui/pages/assignment_controls_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:demo_app/core/custom/10-custom_tabs.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_item.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/ui/pages/assignment_control_details_page.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/ui/widgets/assignment_control_card.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';

class AssignmentControlsListPage extends StatelessWidget {
  final GRCModuleEntity module;

  const AssignmentControlsListPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssignmentControlCubit>(
      create: (_) => GetIt.instance<AssignmentControlCubit>()
        ..getMyAssignmentControls(
          moduleId: module.moduleId,
          championEmail: currentGrcUserEmail(),
        ),
      child: _AssignmentControlsListBody(module: module),
    );
  }
}

class _AssignmentControlsListBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _AssignmentControlsListBody({required this.module});

  @override
  State<_AssignmentControlsListBody> createState() =>
      _AssignmentControlsListBodyState();
}

class _AssignmentControlsListBodyState
    extends State<_AssignmentControlsListBody> {
  static const _tabValues = AssignmentControlTab.values;

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [
                  'GRC'.tr,
                  widget.module.localizedName(isArabic: isArabic),
                  'Assignment Controls'.tr,
                ],
              ),
              SizedBox(height: 15.h),
              CustomTabs(
                tabs: _tabValues.map((t) => t.label.tr).toList(),
                selectedValue: _selectedTab,
                onChanged: (v) => setState(() => _selectedTab = v),
              ),
              SizedBox(height: 15.h),
              Expanded(
                child: BlocBuilder<AssignmentControlCubit, AssignmentControlState>(
                  builder: (context, state) {
                    if (state is AssignmentControlFailure) {
                      return Center(child: Text(state.message));
                    }
                    if (state is! AssignmentControlListLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final filtered = state.items
                        .where((i) => i.tab == _tabValues[_selectedTab])
                        .toList();
                    if (filtered.isEmpty) {
                      return Center(child: Text('No controls in this status'.tr));
                    }
                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return AssignmentControlCard(
                          item: item,
                          isArabic: isArabic,
                          onTap: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => BlocProvider.value(
                                value: context.read<AssignmentControlCubit>(),
                                child: AssignmentControlDetailsPage(
                                  item: item,
                                  module: widget.module,
                                ),
                              ),
                              transitionsBuilder: (_, animation, __, child) =>
                                  FadeTransition(opacity: animation, child: child),
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Verify it compiles**

Run: `puro flutter analyze lib/features/grc/assignment_control`
Expected: No issues found (`assignment_control_details_page.dart`, imported above, is written next in Task 7 — analyze after Task 7 if this task is run standalone).

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/assignment_control/presentation/ui/widgets/assignment_control_card.dart \
        lib/features/grc/assignment_control/presentation/ui/pages/assignment_controls_list_page.dart
git commit -m "feat(grc): add AssignmentControlsListPage"
```

---

### Task 7: `AssignmentControlDetailsPage`

**Files:**
- Create: `lib/features/grc/assignment_control/presentation/ui/pages/assignment_control_details_page.dart`

**Interfaces:**
- Consumes: `AssignmentControlCubit`/states (Task 5), `AssignmentControlItem`/`AssignmentControlTab` (Task 2), `showUploadDialog` (`lib/core/custom/10_custom_upload_document.dart`), `showConfirmDialog`/`showSuccessDialog`/`showErrorDialog` (`lib/core/custom/11_custom_confirm_diaolog.dart`), `ProductWarrantyCard` (`lib/core/custom/22-custom_uploaded_document_card.dart`), `customButton` (`lib/features/settings/core_widgets/main_widget/custom_button_widget.dart`), `currentGrcUserEmail` (`lib/features/grc/shared/helpers/grc_assignment_lookup.dart`).
- Produces: `AssignmentControlDetailsPage({required item, required module})` — consumed by Task 6's list page navigation and Task 8's manual verification.

- [ ] **Step 1: Write the page**

```dart
// lib/features/grc/assignment_control/presentation/ui/pages/assignment_control_details_page.dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:demo_app/core/custom/10_custom_upload_document.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/22-custom_uploaded_document_card.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_item.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_tab.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';

class AssignmentControlDetailsPage extends StatefulWidget {
  final AssignmentControlItem item;
  final GRCModuleEntity module;

  const AssignmentControlDetailsPage({
    super.key,
    required this.item,
    required this.module,
  });

  @override
  State<AssignmentControlDetailsPage> createState() =>
      _AssignmentControlDetailsPageState();
}

class _AssignmentControlDetailsPageState
    extends State<AssignmentControlDetailsPage> {
  bool get _isRejected => widget.item.tab == AssignmentControlTab.rejected;

  bool get _canAct =>
      widget.item.tab == AssignmentControlTab.pending ||
      widget.item.tab == AssignmentControlTab.overdue ||
      _isRejected;

  void _onActionPressed(BuildContext context) {
    showUploadDialog(
      context: context,
      dialogTitle: (_isRejected ? 'Edit Evidence' : 'Upload Evidence').tr,
      titleFieldLabel: 'Note'.tr,
      titleFieldHint: 'Add a note (optional)'.tr,
      submitLabel: 'Submit'.tr,
      onSubmit: (file, note) => _confirmSubmit(context, file, note),
    );
  }

  void _confirmSubmit(BuildContext context, PlatformFile file, String note) {
    final cubit = context.read<AssignmentControlCubit>();
    showConfirmDialog(
      context: context,
      title: 'Submit Evidence'.tr,
      subtitle: 'Are you sure you want to submit this evidence?'.tr,
      confirmLabel: 'Submit'.tr,
      cancelLabel: 'Cancel'.tr,
      onConfirm: () => cubit.submitEvidence(
        moduleId: widget.module.moduleId,
        policyId: widget.item.control.policyId,
        controlId: widget.item.control.id,
        championEmail: currentGrcUserEmail(),
        documentFile: File(file.path!),
        note: note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.item.control;
    final assignment = widget.item.assignment;
    final isArabic = context.isArabic;
    final rejectionReason = (assignment?.departmentManagerRejectionReason
                ?.isNotEmpty ==
            true)
        ? assignment!.departmentManagerRejectionReason
        : assignment?.controlOwnerRejectionReason;

    return BlocConsumer<AssignmentControlCubit, AssignmentControlState>(
      listener: (context, state) {
        if (state is AssignmentControlActionSuccess) {
          showSuccessDialog(
            context: context,
            title: 'Evidence Submitted'.tr,
            subtitle: 'Your evidence was submitted successfully'.tr,
          );
          Navigator.pop(context);
        } else if (state is AssignmentControlFailure) {
          showErrorDialog(context: context, subtitle: state.message);
        }
      },
      builder: (context, state) {
        final isSaving = state is AssignmentControlLoading;
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaginationAppBar(
                    screensTitles: [
                      'GRC'.tr,
                      widget.module.localizedName(isArabic: isArabic),
                      'Assignment Controls'.tr,
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    isArabic ? control.controlsNameAr : control.controlsNameEn,
                    style: StyleText.fontSize16Weight600,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isArabic
                        ? control.controlsDescriptionAr
                        : control.controlsDescriptionEn,
                    style: StyleText.fontSize12Weight400,
                  ),
                  SizedBox(height: 15.h),
                  if (rejectionReason != null && rejectionReason.isNotEmpty) ...[
                    Text('Rejection Reason'.tr, style: CardStyles.label(12)),
                    SizedBox(height: 4.h),
                    Text(rejectionReason, style: CardStyles.value(12)),
                    SizedBox(height: 15.h),
                  ],
                  if (assignment != null && assignment.submissionNote.isNotEmpty) ...[
                    Text('Submission Note'.tr, style: CardStyles.label(12)),
                    SizedBox(height: 4.h),
                    Text(assignment.submissionNote, style: CardStyles.value(12)),
                    SizedBox(height: 15.h),
                  ],
                  if (assignment != null && assignment.submissionDocument.isNotEmpty)
                    ProductWarrantyCard(
                      title: 'Evidence'.tr,
                      fileName: assignment.submissionDocument
                          .split('/')
                          .last
                          .split('?')
                          .first,
                      onTapFile: () {},
                    ),
                  const Spacer(),
                  if (_canAct)
                    customButton(
                      title: (_isRejected ? 'Edit' : 'Upload Evidence').tr,
                      function: isSaving ? () {} : () => _onActionPressed(context),
                      width: double.infinity,
                      height: 44.h,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.textButton),
                    ),
                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `puro flutter analyze lib/features/grc/assignment_control`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/assignment_control/presentation/ui/pages/assignment_control_details_page.dart
git commit -m "feat(grc): add AssignmentControlDetailsPage"
```

---

### Task 8: Wire the button, register DI, verify end-to-end

**Files:**
- Modify: `lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart:347-355`
- Modify: `lib/features/grc/grc_get_it.dart`

**Interfaces:**
- Consumes: everything from Tasks 1-7.
- Produces: nothing further (this is the last task) — the "Assignment Controls" button becomes fully functional.

- [ ] **Step 1: Add the new imports to `grc_module_details_page.dart`**

Add near the other `grc/assignment_control`-adjacent imports (after the `control_champion_details_page.dart` import at line 66):

```dart
import 'package:demo_app/features/grc/assignment_control/presentation/ui/pages/assignment_controls_list_page.dart';
```

- [ ] **Step 2: Wire the button**

Replace the "Assignment Controls" `customButton` at [grc_module_details_page.dart:347-355](../../../lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart#L347-L355):

```dart
                        customButton(
                          title: "Assignment Controls".tr,
                          function: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  AssignmentControlsListPage(module: widget.module),
                              transitionsBuilder: (_, animation, __, child) =>
                                  FadeTransition(opacity: animation, child: child),
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          ),
                          width: isTablet ? 180.w : 170.w,
                          height: 38.h,
                          color: AppColors.primary,
                          textStyle: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.textButton),
                        ),
```

- [ ] **Step 3: Register the new dependencies in `grc_get_it.dart`**

Add these imports near the top, grouped with the other data source / repository / use case / cubit imports:

```dart
import 'package:demo_app/features/grc/assignment_control/data/data_source/assignment_control_firebase_data_source.dart';
import 'package:demo_app/features/grc/assignment_control/data/repository/assignment_control_repository_impl.dart';
import 'package:demo_app/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';
import 'package:demo_app/features/grc/assignment_control/domain/use_cases/get_assignment_control_usecase.dart';
import 'package:demo_app/features/grc/assignment_control/domain/use_cases/submit_evidence_usecase.dart';
import 'package:demo_app/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart';
```

Add to the "1. Data Sources" section (after the `GrcRequestFirebaseDataSource` registration):

```dart
  /// class name: [AssignmentControlFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for Assignment Control documents.
  sl.registerLazySingleton<AssignmentControlFirebaseDataSource>(
    () => AssignmentControlFirebaseDataSource(),
  );
```

Add to the "2. Repository" section (after the `GrcRequestRepositoryImpl` registration):

```dart
  /// class name: [AssignmentControlRepositoryImpl] registered as [AssignmentControlRepository]
  /// purpose: orchestrates the Assignment Control data source and Storage
  /// uploads, and maps models to entities.
  sl.registerLazySingleton<AssignmentControlRepository>(
    () => AssignmentControlRepositoryImpl(
      dataSource: sl<AssignmentControlFirebaseDataSource>(),
      storageDataSource: sl<PolicyStorageDataSource>(),
    ),
  );
```

Add to the "3. Use Cases" section (after the `ApplyOwnerReassignmentUseCase` registration):

```dart
  /// class name: [GetAssignmentControlUseCase]
  /// purpose: business logic for fetching a single Assignment Control by
  /// control+champion, or null if none has been submitted yet.
  sl.registerLazySingleton<GetAssignmentControlUseCase>(
    () => GetAssignmentControlUseCase(sl<AssignmentControlRepository>()),
  );

  /// class name: [SubmitEvidenceUseCase]
  /// purpose: business logic for a Champion submitting (or resubmitting)
  /// evidence for one Control.
  sl.registerLazySingleton<SubmitEvidenceUseCase>(
    () => SubmitEvidenceUseCase(sl<AssignmentControlRepository>()),
  );
```

Add to the "4. Cubit (Presentation)" section (after the `ControlPreviousOwnersCubit` registration, before the closing `}`):

```dart

  /// class name: [AssignmentControlCubit]
  /// purpose: presentation-layer state manager for the Champion's
  /// Assignment Controls list and Submit-evidence action. Registered as a
  /// factory so each page gets an independent cubit instance.
  sl.registerFactory<AssignmentControlCubit>(
    () => AssignmentControlCubit(
      getChampionUseCase: sl<GetChampionUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      getAllOwnersUseCase: sl<GetAllOwnersUseCase>(),
      getAssignmentControlUseCase: sl<GetAssignmentControlUseCase>(),
      submitEvidenceUseCase: sl<SubmitEvidenceUseCase>(),
    ),
  );
```

- [ ] **Step 4: Run static analysis across the whole app**

Run: `puro flutter analyze`
Expected: No new issues introduced by this feature (pre-existing unrelated issues, if any, are out of scope).

- [ ] **Step 5: Run the full test suite**

Run: `puro flutter test`
Expected: All tests pass, including the 5 model tests (Task 1) and 7 resolver tests (Task 2).

- [ ] **Step 6: Manual smoke test**

Since this repo has no widget/integration test harness for Firebase-backed screens, verify manually:
1. Run the app (`puro flutter run`), sign in as a user who is a Control Champion on at least one Control (check the `Control Champions` subcollection under a GRC Module in Firestore, or add yourself via the existing "Add Champion" flow first).
2. Open that GRC Module → tap "Assignment Controls".
3. Confirm the control(s) you're assigned to appear under the **Pending** tab (or **Overdue** if the control's end date has passed) with no Firestore write having happened yet — check the `Assignment Controls` subcollection is still empty for that control.
4. Tap into a Pending control → "Upload Evidence" → pick a file, add a note → Submit → confirm.
5. Confirm the success dialog appears, you're returned to the list, and the control now appears under **Submitted**.
6. In Firestore, confirm a new document now exists at `GRC Modules/{moduleId}/Assignment Controls/{controlId}_{yourEmail}` with `Status: ["Submitted"]`, `Submission_Document`/`Submission_Note` populated, and `Control_Owner` populated if an Owner is assigned to that control (or null otherwise).

- [ ] **Step 7: Commit**

```bash
git add lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart \
        lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): wire Assignment Controls button and register DI"
```

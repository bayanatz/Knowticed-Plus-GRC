# Approvals (Department Manager) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Department Manager–facing "Approvals" screen — a manager opens it, sees every Pending request from Champions in their own department, and can Approve (→ Assignment Control moves to `In review`) or Reject (→ back to the Champion, with a mandatory reason) — and wire the Champion's existing Submit flow to create these requests and resolve the manager automatically.

**Architecture:** New Clean Architecture feature `lib/features/grc/approval/` mirroring `assignment_control/`'s layout exactly. A new `Approvals` Firestore subcollection (sibling to `Assignment Controls`, one document per control+champion pair, same history-list pattern) tracks the decision. `AssignmentControlCubit.submitEvidence` (already built) is extended to resolve the Champion's Department Manager (an employee in the same department whose job title starts with "Chief") and to create/reset the linked Approval document to Pending. `AssignmentControlRepository` (already built) gains one new method so the Approvals feature can move the linked Assignment Control to `In review`/`Rejected` without either feature's repository knowing about the other's Firestore model. See `docs/superpowers/specs/2026-07-28-approvals-design.md` for full rationale.

**Tech Stack:** Flutter, flutter_bloc (Cubit), get_it (DI), cloud_firestore, dartz (`Either<Failure, T>`), GetX (`MainCoreEmployeeController`).

## Global Constraints

- Follow `Code Quality Standards.md`: Clean Architecture layering, snake_case file names, static Firestore key constants on models, `Either<Failure, T>` from repositories (no try/catch in UI).
- GRC dialog convention (no SnackBars): `showConfirmDialog` before Approve/Reject, `showCommentDialog` for the mandatory rejection reason (its built-in empty-text validation is exactly the spec's "cannot be empty" rule), `showSuccessDialog`/`showErrorDialog` after.
- `Approval` documents follow the same history-list pattern as `AssignmentControlModel`/`ChampionModel`: every mutable field is a `List<T>`, `copyWithUpdate` appends a revision.
- **Confirmed scope simplification:** the spec's optional "Approval Comment" field is declared on the model (`Approval_Comments`) for schema completeness, but this plan's Approve flow does not collect it via UI (no existing dialog widget in this codebase supports an *optional* free-text submission — `showCommentDialog` always blocks on empty text). Approve calls straight through with `comment: null`. Flag this to the user after Task 9; do not silently build a new dialog widget to work around it.
- No mocking framework exists in this repo — only pure, mock-free logic (models, resolvers) gets unit tests, using plain `package:flutter_test` `test()`/`group()`/`expect()`, matching the Assignment Controls plan's precedent.
- Use `puro flutter analyze` (not bare `flutter`) as the compile-sanity command — this machine's Flutter is at `/Users/bstar/.puro/bin/puro flutter`.

---

### Task 1: `ApprovalStatus` + `ApprovalEntity` + `ApprovalModel`

**Files:**
- Create: `lib/features/grc/approval/domain/entities/approval_status.dart`
- Create: `lib/features/grc/approval/domain/entities/approval_entity.dart`
- Create: `lib/features/grc/approval/data/models/approval_model.dart`
- Test: `test/features/grc/approval/approval_model_test.dart`

**Interfaces:**
- Consumes: nothing from other tasks.
- Produces: `ApprovalStatus` (`.value`, `.fromString`), `ApprovalEntity` (flat), `ApprovalModel.create(...)`/`copyWithUpdate(...)`/`toJson()`/`ApprovalModel.fromJson(...)`/`toEntity()`. Tasks 2, 4, 6, 7 depend on these exact names/signatures.

- [ ] **Step 1: Write the status enum**

```dart
// lib/features/grc/approval/domain/entities/approval_status.dart
/// Lifecycle status of one Approval document (one per control+champion
/// pair — see the design spec's "Approval doc lifecycle" section).
enum ApprovalStatus {
  pending,
  approved,
  rejected;

  String get value {
    switch (this) {
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
    }
  }

  static ApprovalStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'approved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      case 'pending':
      default:
        return ApprovalStatus.pending;
    }
  }
}
```

- [ ] **Step 2: Write the flat entity**

```dart
// lib/features/grc/approval/domain/entities/approval_entity.dart
import 'approval_status.dart';

/// Flat (latest-values-only) representation of one Approval document,
/// derived from the last index of every history List in [ApprovalModel].
class ApprovalEntity {
  final String requestId;
  final String submissionId;
  final ApprovalStatus status;
  final String? reasonOfRejection;
  final String? approvalComment;
  final String lastModifier;
  final DateTime lastModificationDate;

  const ApprovalEntity({
    required this.requestId,
    required this.submissionId,
    required this.status,
    required this.reasonOfRejection,
    required this.approvalComment,
    required this.lastModifier,
    required this.lastModificationDate,
  });
}
```

- [ ] **Step 3: Write the failing round-trip test**

```dart
// test/features/grc/approval/approval_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/approval/data/models/approval_model.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_status.dart';

void main() {
  group('ApprovalModel', () {
    test('create() builds a single-revision Pending record', () {
      final model = ApprovalModel.create(
        requestId: 'c1_champion@x.com',
        submissionId: 'c1_champion@x.com',
        editorEmail: 'champion@x.com',
      );

      expect(model.status, ['Pending']);
      expect(model.reasonsOfRejection, [null]);
      expect(model.approvalComments, [null]);
      expect(model.modifier, ['champion@x.com']);
    });

    test('copyWithUpdate() appends a revision and keeps fixed fields', () {
      final created = ApprovalModel.create(
        requestId: 'c1_champion@x.com',
        submissionId: 'c1_champion@x.com',
        editorEmail: 'champion@x.com',
      );

      final rejected = created.copyWithUpdate(
        status: ApprovalStatus.rejected.value,
        reasonOfRejection: 'Missing evidence.',
        editorEmail: 'manager@x.com',
      );

      expect(rejected.status, ['Pending', 'Rejected']);
      expect(rejected.reasonsOfRejection, [null, 'Missing evidence.']);
      expect(rejected.modifier, ['champion@x.com', 'manager@x.com']);
      expect(rejected.requestId, 'c1_champion@x.com');

      final resetToPending = rejected.copyWithUpdate(
        status: ApprovalStatus.pending.value,
        editorEmail: 'champion@x.com',
      );
      expect(resetToPending.status, ['Pending', 'Rejected', 'Pending']);
    });

    test('toJson/fromJson round-trips every field', () {
      final model = ApprovalModel.create(
        requestId: 'c1_champion@x.com',
        submissionId: 'c1_champion@x.com',
        editorEmail: 'champion@x.com',
      );

      final rebuilt = ApprovalModel.fromJson(model.toJson());

      expect(rebuilt.requestId, model.requestId);
      expect(rebuilt.submissionId, model.submissionId);
      expect(rebuilt.status, model.status);
      expect(rebuilt.reasonsOfRejection, model.reasonsOfRejection);
      expect(rebuilt.approvalComments, model.approvalComments);
      expect(rebuilt.modifier, model.modifier);
    });

    test('toEntity() flattens to the latest revision', () {
      final created = ApprovalModel.create(
        requestId: 'c1_champion@x.com',
        submissionId: 'c1_champion@x.com',
        editorEmail: 'champion@x.com',
      );
      final approved = created.copyWithUpdate(
        status: ApprovalStatus.approved.value,
        approvalComment: 'Looks good.',
        editorEmail: 'manager@x.com',
      );

      final entity = approved.toEntity();

      expect(entity.status, ApprovalStatus.approved);
      expect(entity.approvalComment, 'Looks good.');
      expect(entity.lastModifier, 'manager@x.com');
    });

    test('constructor throws when history Lists have mismatched lengths', () {
      expect(
        () => ApprovalModel(
          requestId: 'c1_champion@x.com',
          submissionId: 'c1_champion@x.com',
          status: const ['Pending', 'Rejected'],
          reasonsOfRejection: const [null],
          approvalComments: const [null],
          modifier: const ['champion@x.com'],
          modificationDate: [DateTime.now()],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
```

- [ ] **Step 4: Run the tests to verify they fail**

Run: `puro flutter test test/features/grc/approval/approval_model_test.dart`
Expected: FAIL — `approval_model.dart` doesn't exist yet (compile error).

- [ ] **Step 5: Write the model**

```dart
// lib/features/grc/approval/data/models/approval_model.dart
/// Module: Approvals (Department Manager)
/// Description: Firestore model for one Department Manager approval
///              decision on a Champion's Assignment Control submission,
///              following the same history-list pattern as
///              AssignmentControlModel: every mutable field is a List<T>,
///              index i is one revision. One document per control+champion
///              pair, reused across resubmission cycles (the linked
///              Assignment_Controls document already preserves the full
///              submission history, so this document only needs to track
///              the decision state, reset to Pending on each resubmit).
///              Firestore path:
///              GRC Modules/{Module_ID}/Approvals/{Approval_ID}
///              where Approval_ID = "{controlId}_{championEmail}".
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
/// Dependencies: ApprovalEntity, ApprovalStatus, GrcFirestoreKeys
library;

import 'package:intl/intl.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_status.dart';
import 'package:demo_app/features/grc/shared/constants/grc_firestore_keys.dart';

final DateFormat _storageDateFormat = DateFormat('d MMM yyyy', 'en');

class ApprovalModel {
  static const String _keyRequestId = 'Request_ID';
  static const String _keySubmissionId = 'Submission_ID';
  static const String _keyStatus = 'Status';
  static const String _keyReasonsOfRejection = 'Reasons_of_Rejection';
  static const String _keyApprovalComments = 'Approval_Comments';
  // Deliberately NOT reusing the shared GrcFirestoreKeys.modifiers
  // ('Modifiers') — the schema given for this feature explicitly names
  // this field "Modifier" (singular), same convention as AssignmentControlModel.
  static const String _keyModifier = 'Modifier';

  final String requestId;
  final String submissionId;

  final List<String> status; // ApprovalStatus.value strings
  final List<String?> reasonsOfRejection;
  final List<String?> approvalComments;
  final List<String> modifier;
  final List<DateTime> modificationDate;

  ApprovalModel({
    required this.requestId,
    required this.submissionId,
    required this.status,
    required this.reasonsOfRejection,
    required this.approvalComments,
    required this.modifier,
    required this.modificationDate,
  }) {
    if (!_allSameLength()) {
      throw ArgumentError(
        'All ApprovalModel Lists must have the same number of elements (same index count)',
      );
    }
  }

  bool _allSameLength() {
    final lengths = <int>{
      status.length,
      reasonsOfRejection.length,
      approvalComments.length,
      modifier.length,
      modificationDate.length,
    };
    return lengths.length == 1;
  }

  /// Builds the first revision — always Status "Pending".
  factory ApprovalModel.create({
    required String requestId,
    required String submissionId,
    required String editorEmail,
  }) {
    final now = DateTime.now();
    return ApprovalModel(
      requestId: requestId,
      submissionId: submissionId,
      status: [ApprovalStatus.pending.value],
      reasonsOfRejection: const [null],
      approvalComments: const [null],
      modifier: [editorEmail],
      modificationDate: [now],
    );
  }

  /// Appends a new revision to every history List, reusing the previous
  /// value for anything not passed. [requestId]/[submissionId] are fixed
  /// fields, always carried over unchanged.
  ApprovalModel copyWithUpdate({
    String? status,
    String? reasonOfRejection,
    String? approvalComment,
    required String editorEmail,
  }) {
    final now = DateTime.now();
    return ApprovalModel(
      requestId: requestId,
      submissionId: submissionId,
      status: [...this.status, status ?? this.status.last],
      reasonsOfRejection: [
        ...this.reasonsOfRejection,
        reasonOfRejection ?? this.reasonsOfRejection.last,
      ],
      approvalComments: [
        ...this.approvalComments,
        approvalComment ?? this.approvalComments.last,
      ],
      modifier: [...modifier, editorEmail],
      modificationDate: [...modificationDate, now],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _keyRequestId: requestId,
      _keySubmissionId: submissionId,
      _keyStatus: status,
      _keyReasonsOfRejection: reasonsOfRejection,
      _keyApprovalComments: approvalComments,
      _keyModifier: modifier,
      GrcFirestoreKeys.modificationDate:
          modificationDate.map((d) => _storageDateFormat.format(d)).toList(),
    };
  }

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      requestId: json[_keyRequestId] as String,
      submissionId: json[_keySubmissionId] as String,
      status: List<String>.from(json[_keyStatus] ?? []),
      reasonsOfRejection: List<String?>.from(json[_keyReasonsOfRejection] ?? []),
      approvalComments: List<String?>.from(json[_keyApprovalComments] ?? []),
      modifier: List<String>.from(json[_keyModifier] ?? []),
      modificationDate: (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
    );
  }

  ApprovalEntity toEntity() {
    return ApprovalEntity(
      requestId: requestId,
      submissionId: submissionId,
      status: ApprovalStatus.fromString(status.last),
      reasonOfRejection: reasonsOfRejection.last,
      approvalComment: approvalComments.last,
      lastModifier: modifier.last,
      lastModificationDate: modificationDate.last,
    );
  }
}
```

- [ ] **Step 6: Run the tests to verify they pass**

Run: `puro flutter test test/features/grc/approval/approval_model_test.dart`
Expected: PASS (5 tests)

- [ ] **Step 7: Commit**

```bash
git add lib/features/grc/approval/domain/entities/approval_status.dart \
        lib/features/grc/approval/domain/entities/approval_entity.dart \
        lib/features/grc/approval/data/models/approval_model.dart \
        test/features/grc/approval/approval_model_test.dart
git commit -m "feat(grc): add ApprovalModel/Entity for Approvals"
```

---

### Task 2: Join/derivation resolver (`ApprovalItem`, `buildApprovalItems`, `findDepartmentManagerEmail`)

**Files:**
- Create: `lib/features/grc/approval/domain/entities/approval_item.dart`
- Create: `lib/features/grc/approval/domain/entities/approval_resolver.dart`
- Test: `test/features/grc/approval/approval_resolver_test.dart`

**Interfaces:**
- Consumes: `ApprovalEntity`/`ApprovalStatus` (Task 1); existing `AssignmentControlEntity` (`lib/features/grc/assignment_control/domain/entities/assignment_control_entity.dart`); existing `ControlEntity`/`PolicyEntity`; existing `EmployeeEntityPro` (`lib/features/employee/domain/entities/employee_entity.dart` — fields used: `email`, `departmentId`, `title`, all `String?` except `email`); existing `findControlInPolicy` (`lib/features/grc/shared/helpers/grc_assignment_lookup.dart`).
- Produces: `ApprovalItem` class, `buildApprovalItems(...)`, `findDepartmentManagerEmail(...)` — consumed by Task 6 (Assignment Controls' submit flow) and Task 7 (`ApprovalCubit`).

- [ ] **Step 1: Write the item class**

```dart
// lib/features/grc/approval/domain/entities/approval_item.dart
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'approval_entity.dart';

/// One row on the Department Manager's Approvals list: a Pending Approval,
/// the Assignment Control it decides, and that control's Control/Policy
/// details.
class ApprovalItem {
  final ApprovalEntity approval;
  final AssignmentControlEntity assignmentControl;
  final ControlEntity control;
  final PolicyEntity policy;

  const ApprovalItem({
    required this.approval,
    required this.assignmentControl,
    required this.control,
    required this.policy,
  });
}
```

- [ ] **Step 2: Write the failing tests**

```dart
// test/features/grc/approval/approval_resolver_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_resolver.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_status.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_status.dart';

EmployeeEntityPro _employee({
  required String email,
  required String? departmentId,
  required String? title,
}) {
  return EmployeeEntityPro(email: email, departmentId: departmentId, title: title);
}

ControlEntity _control({required String id, required String policyId}) {
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
    endDate: now.add(const Duration(days: 10)),
    departments: const [],
    equalWeights: true,
    score: 0,
    status: ControlStatus.active,
    lastModifiedDate: now,
    lastEditor: 'editor@x.com',
  );
}

PolicyEntity _policy({required String id}) {
  final now = DateTime.now();
  return PolicyEntity(
    id: id,
    moduleId: 'm1',
    policyImage: null,
    policyNameEn: 'Policy $id',
    policyNameAr: 'Policy $id',
    policyNumberEn: 'P-$id',
    policyNumberAr: 'P-$id',
    policyDescriptionEn: 'desc',
    policyDescriptionAr: 'desc',
    startDate: now,
    endDate: now,
    policyWeight: 10,
    policyDocumentEn: null,
    policyDocumentAr: null,
    status: PolicyStatus.active,
    lastModifiedDate: now,
    lastEditor: 'editor@x.com',
  );
}

AssignmentControlEntity _assignmentControl({
  required String submissionId,
  required String controlId,
  required String policyId,
  required String championEmail,
  required String? departmentManager,
}) {
  final now = DateTime.now();
  return AssignmentControlEntity(
    submissionId: submissionId,
    controlChampionEmail: championEmail,
    policyId: policyId,
    controlId: controlId,
    controlOwner: null,
    departmentManager: departmentManager,
    submissionDocument: 'https://files/e.pdf',
    submissionNote: 'note',
    status: AssignmentControlStatus.submitted,
    departmentManagerRejectionReason: null,
    controlScore: null,
    controlOwnerJustification: null,
    controlOwnerRejectionReason: null,
    lastModifier: championEmail,
    lastModificationDate: now,
  );
}

ApprovalEntity _approval({required String id, required ApprovalStatus status}) {
  return ApprovalEntity(
    requestId: id,
    submissionId: id,
    status: status,
    reasonOfRejection: null,
    approvalComment: null,
    lastModifier: 'champion@x.com',
    lastModificationDate: DateTime.now(),
  );
}

void main() {
  group('findDepartmentManagerEmail', () {
    test('finds a same-department employee whose title starts with Chief', () {
      final employees = [
        _employee(email: 'champion@x.com', departmentId: 'd1', title: 'Analyst'),
        _employee(email: 'manager@x.com', departmentId: 'd1', title: 'Chief Operations Officer (COO)'),
        _employee(email: 'other@x.com', departmentId: 'd2', title: 'Chief Financial Officer (CFO)'),
      ];

      final email = findDepartmentManagerEmail(employees, championEmail: 'champion@x.com');

      expect(email, 'manager@x.com');
    });

    test('returns null when no Chief-titled peer exists in the department', () {
      final employees = [
        _employee(email: 'champion@x.com', departmentId: 'd1', title: 'Analyst'),
        _employee(email: 'peer@x.com', departmentId: 'd1', title: 'Analyst'),
      ];

      final email = findDepartmentManagerEmail(employees, championEmail: 'champion@x.com');

      expect(email, isNull);
    });

    test('returns null when the champion is not found', () {
      final email = findDepartmentManagerEmail(
        const [],
        championEmail: 'champion@x.com',
      );
      expect(email, isNull);
    });
  });

  group('buildApprovalItems', () {
    test('joins Pending approvals belonging to this manager', () {
      final control = _control(id: 'c1', policyId: 'p1');
      final policy = _policy(id: 'p1');
      final ac = _assignmentControl(
        submissionId: 'c1_champion@x.com',
        controlId: 'c1',
        policyId: 'p1',
        championEmail: 'champion@x.com',
        departmentManager: 'manager@x.com',
      );
      final approval = _approval(id: 'c1_champion@x.com', status: ApprovalStatus.pending);

      final items = buildApprovalItems(
        approvals: [approval],
        assignmentControls: {'c1_champion@x.com': ac},
        policyControls: {
          'p1': [control],
        },
        policies: {'p1': policy},
        managerEmail: 'manager@x.com',
      );

      expect(items, hasLength(1));
      expect(items.first.control.id, 'c1');
      expect(items.first.policy.id, 'p1');
    });

    test('excludes approvals not Pending', () {
      final control = _control(id: 'c1', policyId: 'p1');
      final policy = _policy(id: 'p1');
      final ac = _assignmentControl(
        submissionId: 'c1_champion@x.com',
        controlId: 'c1',
        policyId: 'p1',
        championEmail: 'champion@x.com',
        departmentManager: 'manager@x.com',
      );
      final approval = _approval(id: 'c1_champion@x.com', status: ApprovalStatus.approved);

      final items = buildApprovalItems(
        approvals: [approval],
        assignmentControls: {'c1_champion@x.com': ac},
        policyControls: {'p1': [control]},
        policies: {'p1': policy},
        managerEmail: 'manager@x.com',
      );

      expect(items, isEmpty);
    });

    test('excludes approvals whose Assignment Control belongs to a different manager', () {
      final control = _control(id: 'c1', policyId: 'p1');
      final policy = _policy(id: 'p1');
      final ac = _assignmentControl(
        submissionId: 'c1_champion@x.com',
        controlId: 'c1',
        policyId: 'p1',
        championEmail: 'champion@x.com',
        departmentManager: 'someone-else@x.com',
      );
      final approval = _approval(id: 'c1_champion@x.com', status: ApprovalStatus.pending);

      final items = buildApprovalItems(
        approvals: [approval],
        assignmentControls: {'c1_champion@x.com': ac},
        policyControls: {'p1': [control]},
        policies: {'p1': policy},
        managerEmail: 'manager@x.com',
      );

      expect(items, isEmpty);
    });
  });
}
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `puro flutter test test/features/grc/approval/approval_resolver_test.dart`
Expected: FAIL — `approval_resolver.dart` doesn't exist yet.

- [ ] **Step 4: Write the resolver**

```dart
// lib/features/grc/approval/domain/entities/approval_resolver.dart
/// Module: Approvals (Department Manager)
/// Description: Pure join/derivation logic for the manager's Approvals
///              list, and the Chief-title Department Manager resolution
///              used at Champion submit time — no persistence, no side
///              effects. See docs/superpowers/specs/2026-07-28-approvals-design.md.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
library;

import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'approval_entity.dart';
import 'approval_item.dart';
import 'approval_status.dart';

/// Finds the Department Manager for [championEmail]: another employee
/// sharing the champion's `departmentId` whose `title` starts with "Chief"
/// (case-insensitive). Returns null if the champion isn't found, has no
/// department, or no such peer exists — a valid, expected outcome (the
/// submission still succeeds with `Department_Manager` left null).
String? findDepartmentManagerEmail(
  List<EmployeeEntityPro> employees, {
  required String championEmail,
}) {
  EmployeeEntityPro? champion;
  for (final e in employees) {
    if (e.email == championEmail) {
      champion = e;
      break;
    }
  }
  final departmentId = champion?.departmentId;
  if (departmentId == null) return null;

  for (final e in employees) {
    if (e.email == championEmail) continue;
    if (e.departmentId != departmentId) continue;
    if (e.title?.trim().toLowerCase().startsWith('chief') ?? false) {
      return e.email;
    }
  }
  return null;
}

/// Joins every Pending [approvals] entry with its linked
/// [assignmentControls] (keyed by Assignment_Controls doc id, i.e.
/// [ApprovalEntity.submissionId]), keeping only the ones whose Assignment
/// Control's `departmentManager` matches [managerEmail], then resolves each
/// one's Control/Policy from the already-loaded [policyControls]/[policies]
/// maps. A pair whose Assignment Control, Control, or Policy can't be found
/// is silently skipped.
List<ApprovalItem> buildApprovalItems({
  required List<ApprovalEntity> approvals,
  required Map<String, AssignmentControlEntity> assignmentControls,
  required Map<String, List<ControlEntity>> policyControls,
  required Map<String, PolicyEntity> policies,
  required String managerEmail,
}) {
  final items = <ApprovalItem>[];
  for (final approval in approvals) {
    if (approval.status != ApprovalStatus.pending) continue;
    final assignmentControl = assignmentControls[approval.submissionId];
    if (assignmentControl == null) continue;
    if (assignmentControl.departmentManager != managerEmail) continue;
    final control = findControlInPolicy(
      policyControls,
      assignmentControl.policyId,
      assignmentControl.controlId,
    );
    if (control == null) continue;
    final policy = policies[assignmentControl.policyId];
    if (policy == null) continue;
    items.add(ApprovalItem(
      approval: approval,
      assignmentControl: assignmentControl,
      control: control,
      policy: policy,
    ));
  }
  return items;
}
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `puro flutter test test/features/grc/approval/approval_resolver_test.dart`
Expected: PASS (6 tests)

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/approval/domain/entities/approval_item.dart \
        lib/features/grc/approval/domain/entities/approval_resolver.dart \
        test/features/grc/approval/approval_resolver_test.dart
git commit -m "feat(grc): add Approvals join resolver and department-manager lookup"
```

---

### Task 3: Approval data source

**Files:**
- Create: `lib/features/grc/approval/data/data_source/approval_data_source.dart`
- Create: `lib/features/grc/approval/data/data_source/approval_firebase_data_source.dart`

**Interfaces:**
- Consumes: `ApprovalModel` (Task 1).
- Produces: `AssignmentControlDataSource`-shaped `ApprovalDataSource` with `get`, `create`, `update`, and `getAll` (new — needed for the manager's list, unlike the Champion-only Assignment Controls data source which never needed an unfiltered `getAll`). Task 4 depends on these exact method names/signatures.

- [ ] **Step 1: Write the interface**

```dart
// lib/features/grc/approval/data/data_source/approval_data_source.dart
import 'package:demo_app/features/grc/approval/data/models/approval_model.dart';

abstract class ApprovalDataSource {
  Future<ApprovalModel?> get(String id, {required String moduleId});

  Future<List<ApprovalModel>> getAll({required String moduleId});

  Future<ApprovalModel> create(
    ApprovalModel model, {
    required String moduleId,
  });

  Future<ApprovalModel> update(
    ApprovalModel model, {
    required String moduleId,
  });
}
```

- [ ] **Step 2: Write the Firestore implementation**

```dart
// lib/features/grc/approval/data/data_source/approval_firebase_data_source.dart
/// Module: Approvals (Department Manager)
/// Description: Cloud Firestore implementation of [ApprovalDataSource].
///              Firestore path:
///              GRC Modules/{Module_ID}/Approvals/{Approval_ID}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/network/get_base_url.dart';
import 'package:demo_app/features/grc/approval/data/models/approval_model.dart';

import 'approval_data_source.dart';

class ApprovalFirebaseDataSource implements ApprovalDataSource {
  ApprovalFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String get _modulesCollectionPath =>
      '${getBaseUrl('Modules')}/grc/GRC Modules';
  static const String _approvalsSubcollectionPath = 'Approvals';

  CollectionReference<Map<String, dynamic>> _collection(String moduleId) =>
      _firestore
          .collection(_modulesCollectionPath)
          .doc(moduleId)
          .collection(_approvalsSubcollectionPath);

  @override
  Future<ApprovalModel?> get(String id, {required String moduleId}) async {
    try {
      final doc = await _collection(moduleId).doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return ApprovalModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to fetch the Approval: $e');
    }
  }

  @override
  Future<List<ApprovalModel>> getAll({required String moduleId}) async {
    try {
      final snapshot = await _collection(moduleId).get();
      return snapshot.docs.map((doc) => ApprovalModel.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to fetch the Approvals: $e');
    }
  }

  @override
  Future<ApprovalModel> create(
    ApprovalModel model, {
    required String moduleId,
  }) async {
    try {
      await _collection(moduleId).doc(model.requestId).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to create the Approval: $e');
    }
  }

  @override
  Future<ApprovalModel> update(
    ApprovalModel model, {
    required String moduleId,
  }) async {
    try {
      await _collection(moduleId).doc(model.requestId).set(model.toJson());
      return model;
    } catch (e) {
      throw Exception('Failed to update the Approval: $e');
    }
  }
}
```

- [ ] **Step 3: Verify it compiles**

Run: `puro flutter analyze lib/features/grc/approval`
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/approval/data/data_source/
git commit -m "feat(grc): add Approval Firestore data source"
```

---

### Task 4: Approval repository + use cases

**Files:**
- Create: `lib/features/grc/approval/domain/repository/approval_repository.dart`
- Create: `lib/features/grc/approval/data/repository/approval_repository_impl.dart`
- Create: `lib/features/grc/approval/domain/use_cases/get_all_approvals_usecase.dart`
- Create: `lib/features/grc/approval/domain/use_cases/create_or_update_pending_approval_usecase.dart`
- Create: `lib/features/grc/approval/domain/use_cases/decide_approval_usecase.dart`

**Interfaces:**
- Consumes: `ApprovalModel`/`ApprovalEntity`/`ApprovalStatus` (Task 1), `ApprovalDataSource` (Task 3), `Failure`/`FirebaseFailure`/`ValidationError` (`lib/core/network/failure_model.dart`).
- Produces: `GetAllApprovalsUseCase.call({required moduleId})` → `Future<Either<Failure, List<ApprovalEntity>>>`; `CreateOrUpdatePendingApprovalUseCase.call(CreateOrUpdatePendingApprovalParams(...))` → `Future<Either<Failure, ApprovalEntity>>`; `DecideApprovalUseCase.call(DecideApprovalParams(...))` → `Future<Either<Failure, ApprovalEntity>>`. Task 6 depends on `CreateOrUpdatePendingApprovalUseCase`; Task 7 depends on all three.

- [ ] **Step 1: Write the repository contract**

```dart
// lib/features/grc/approval/domain/repository/approval_repository.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_entity.dart';

abstract class ApprovalRepository {
  Future<Either<Failure, List<ApprovalEntity>>> getAllApprovals({
    required String moduleId,
  });

  /// Creates the Approval doc (first submission) or, if one already exists
  /// for this control+champion pair, appends a fresh "Pending" revision
  /// (a resubmit after a prior rejection).
  Future<Either<Failure, ApprovalEntity>> createOrUpdatePending({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String editorEmail,
  });

  /// Records the manager's decision. [reasonOfRejection] is required when
  /// rejecting; [approvalComment] is an optional extra when approving.
  Future<Either<Failure, ApprovalEntity>> decide({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String status,
    String? reasonOfRejection,
    String? approvalComment,
    required String editorEmail,
  });
}
```

- [ ] **Step 2: Write the implementation**

```dart
// lib/features/grc/approval/data/repository/approval_repository_impl.dart
/// Module: Approvals (Department Manager)
/// Description: Data-layer implementation of [ApprovalRepository]. Maps
///              between ApprovalModel (persistence) and ApprovalEntity
///              (domain), and wraps every result in Either<Failure, T>.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/approval/data/data_source/approval_data_source.dart';
import 'package:demo_app/features/grc/approval/data/models/approval_model.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:demo_app/features/grc/approval/domain/repository/approval_repository.dart';

class ApprovalRepositoryImpl implements ApprovalRepository {
  ApprovalRepositoryImpl({required ApprovalDataSource dataSource})
      : _dataSource = dataSource;

  final ApprovalDataSource _dataSource;

  String _docId({required String controlId, required String championEmail}) =>
      '${controlId}_$championEmail';

  @override
  Future<Either<Failure, List<ApprovalEntity>>> getAllApprovals({
    required String moduleId,
  }) async {
    try {
      final models = await _dataSource.getAll(moduleId: moduleId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApprovalEntity>> createOrUpdatePending({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String editorEmail,
  }) async {
    try {
      final id = _docId(controlId: controlId, championEmail: championEmail);
      final current = await _dataSource.get(id, moduleId: moduleId);

      final ApprovalModel saved;
      if (current == null) {
        final model = ApprovalModel.create(
          requestId: id,
          submissionId: id,
          editorEmail: editorEmail,
        );
        saved = await _dataSource.create(model, moduleId: moduleId);
      } else {
        final model = current.copyWithUpdate(
          status: 'Pending',
          editorEmail: editorEmail,
        );
        saved = await _dataSource.update(model, moduleId: moduleId);
      }
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApprovalEntity>> decide({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String status,
    String? reasonOfRejection,
    String? approvalComment,
    required String editorEmail,
  }) async {
    try {
      final id = _docId(controlId: controlId, championEmail: championEmail);
      final current = await _dataSource.get(id, moduleId: moduleId);
      if (current == null) {
        return Left(ValidationError('Approval not found (id: $id)'));
      }
      final model = current.copyWithUpdate(
        status: status,
        reasonOfRejection: reasonOfRejection,
        approvalComment: approvalComment,
        editorEmail: editorEmail,
      );
      final saved = await _dataSource.update(model, moduleId: moduleId);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
```

- [ ] **Step 3: Write the use cases**

```dart
// lib/features/grc/approval/domain/use_cases/get_all_approvals_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:demo_app/features/grc/approval/domain/repository/approval_repository.dart';

class GetAllApprovalsUseCase {
  const GetAllApprovalsUseCase(this._repository);

  final ApprovalRepository _repository;

  Future<Either<Failure, List<ApprovalEntity>>> call({
    required String moduleId,
  }) {
    return _repository.getAllApprovals(moduleId: moduleId);
  }
}
```

```dart
// lib/features/grc/approval/domain/use_cases/create_or_update_pending_approval_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:demo_app/features/grc/approval/domain/repository/approval_repository.dart';

class CreateOrUpdatePendingApprovalParams {
  final String moduleId;
  final String controlId;
  final String championEmail;
  final String editorEmail;

  const CreateOrUpdatePendingApprovalParams({
    required this.moduleId,
    required this.controlId,
    required this.championEmail,
    required this.editorEmail,
  });
}

class CreateOrUpdatePendingApprovalUseCase {
  const CreateOrUpdatePendingApprovalUseCase(this._repository);

  final ApprovalRepository _repository;

  Future<Either<Failure, ApprovalEntity>> call(
    CreateOrUpdatePendingApprovalParams params,
  ) {
    return _repository.createOrUpdatePending(
      moduleId: params.moduleId,
      controlId: params.controlId,
      championEmail: params.championEmail,
      editorEmail: params.editorEmail,
    );
  }
}
```

```dart
// lib/features/grc/approval/domain/use_cases/decide_approval_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:demo_app/features/grc/approval/domain/repository/approval_repository.dart';

class DecideApprovalParams {
  final String moduleId;
  final String controlId;
  final String championEmail;
  final String status;
  final String? reasonOfRejection;
  final String? approvalComment;
  final String editorEmail;

  const DecideApprovalParams({
    required this.moduleId,
    required this.controlId,
    required this.championEmail,
    required this.status,
    this.reasonOfRejection,
    this.approvalComment,
    required this.editorEmail,
  });
}

class DecideApprovalUseCase {
  const DecideApprovalUseCase(this._repository);

  final ApprovalRepository _repository;

  Future<Either<Failure, ApprovalEntity>> call(DecideApprovalParams params) {
    return _repository.decide(
      moduleId: params.moduleId,
      controlId: params.controlId,
      championEmail: params.championEmail,
      status: params.status,
      reasonOfRejection: params.reasonOfRejection,
      approvalComment: params.approvalComment,
      editorEmail: params.editorEmail,
    );
  }
}
```

- [ ] **Step 4: Verify it compiles**

Run: `puro flutter analyze lib/features/grc/approval`
Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/approval/domain/repository/ \
        lib/features/grc/approval/data/repository/ \
        lib/features/grc/approval/domain/use_cases/
git commit -m "feat(grc): add Approval repository and use cases"
```

---

### Task 5: Extend Assignment Controls — `departmentManager` param + `applyManagerDecision` + raw-id lookup

**Files:**
- Modify: `lib/features/grc/assignment_control/data/models/assignment_control_model.dart`
- Modify: `lib/features/grc/assignment_control/domain/repository/assignment_control_repository.dart`
- Modify: `lib/features/grc/assignment_control/data/repository/assignment_control_repository_impl.dart`
- Modify: `lib/features/grc/assignment_control/domain/use_cases/submit_evidence_usecase.dart`
- Create: `lib/features/grc/assignment_control/domain/use_cases/apply_manager_decision_usecase.dart`
- Create: `lib/features/grc/assignment_control/domain/use_cases/get_assignment_control_by_id_usecase.dart`

**Interfaces:**
- Consumes: existing `AssignmentControlModel`/`AssignmentControlEntity`/`AssignmentControlStatus`/`AssignmentControlDataSource`/`AssignmentControlRepository`.
- Produces: `AssignmentControlModel.create(..., required String? departmentManager)` (signature change — no longer hardcodes null); `SubmitEvidenceParams` gains `required String? departmentManagerEmail`; new `ApplyManagerDecisionUseCase.call(ApplyManagerDecisionParams(...))` → `Future<Either<Failure, AssignmentControlEntity>>`; new `GetAssignmentControlByIdUseCase.call({required moduleId, required String id})` → `Future<Either<Failure, AssignmentControlEntity?>>`. Task 6 depends on the `SubmitEvidenceParams` change; Task 7 depends on both new use cases.

- [ ] **Step 1: Add `departmentManager` to `AssignmentControlModel.create`**

In `lib/features/grc/assignment_control/data/models/assignment_control_model.dart`, replace the `create` factory's signature and body exactly as follows (the only change is the new required param and using it instead of the hardcoded `null`):

```dart
  /// Builds the first revision of a submission cycle — always Status
  /// "Submitted" (there is no stored "Pending" revision; see design spec).
  factory AssignmentControlModel.create({
    required String submissionId,
    required String controlChampionEmail,
    required String policyId,
    required String controlId,
    required String? controlOwner,
    required String? departmentManager,
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
      departmentManager: departmentManager,
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
```

Also delete the old doc comment line above it that says `/// [departmentManager] is always null for now — no dept-manager lookup exists yet in this codebase (left for the future Approvals spec).` (this plan is that spec).

- [ ] **Step 2: Add `applyManagerDecision` and a raw-id getter to `AssignmentControlRepository`**

In `lib/features/grc/assignment_control/domain/repository/assignment_control_repository.dart`, add these two methods to the abstract class (alongside the existing `getAssignmentControl`/`submitEvidence`):

```dart
  /// Fetches an Assignment Control directly by its Firestore doc id (the
  /// same id as [AssignmentControlEntity.submissionId]) — used by the
  /// Approvals feature, which only has that raw id (an
  /// [ApprovalEntity.submissionId]), not the separate controlId/championEmail
  /// pair the other lookup method needs.
  Future<Either<Failure, AssignmentControlEntity?>> getAssignmentControlById({
    required String moduleId,
    required String id,
  });

  /// Records a Department Manager's (or, in a future spec, Control Owner's)
  /// decision by appending one more revision to the Assignment Control.
  /// [newStatus] should be [AssignmentControlStatus.inReview] (Approve) or
  /// [AssignmentControlStatus.rejected] (Reject); [rejectionReason] is
  /// required for the latter.
  Future<Either<Failure, AssignmentControlEntity>> applyManagerDecision({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required AssignmentControlStatus newStatus,
    String? rejectionReason,
    required String editorEmail,
  });
```

Add the import this needs at the top of the file:

```dart
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
```

- [ ] **Step 3: Implement both new methods in `AssignmentControlRepositoryImpl`**

In `lib/features/grc/assignment_control/data/repository/assignment_control_repository_impl.dart`, add these two methods to the class body (after `getAssignmentControl`, before `submitEvidence` is fine):

```dart
  @override
  Future<Either<Failure, AssignmentControlEntity?>> getAssignmentControlById({
    required String moduleId,
    required String id,
  }) async {
    try {
      final model = await _dataSource.get(id, moduleId: moduleId);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssignmentControlEntity>> applyManagerDecision({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required AssignmentControlStatus newStatus,
    String? rejectionReason,
    required String editorEmail,
  }) async {
    try {
      final id = _docId(controlId: controlId, championEmail: championEmail);
      final current = await _dataSource.get(id, moduleId: moduleId);
      if (current == null) {
        return Left(ValidationError('Assignment Control not found (id: $id)'));
      }
      final model = current.copyWithUpdate(
        status: newStatus.value,
        departmentManagerRejectionReason: rejectionReason,
        editorEmail: editorEmail,
      );
      final saved = await _dataSource.update(model, moduleId: moduleId);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
```

Add the import this needs at the top of the file:

```dart
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
```

(This import may already be present from Step 2's usage in the same file if your editor auto-adds it — check before adding a duplicate.)

- [ ] **Step 4: Add `departmentManagerEmail` to `SubmitEvidenceParams`/`SubmitEvidenceUseCase`**

Replace the full contents of `lib/features/grc/assignment_control/domain/use_cases/submit_evidence_usecase.dart` with:

```dart
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
  final String? departmentManagerEmail;
  final File documentFile;
  final String note;
  final String editorEmail;

  const SubmitEvidenceParams({
    required this.moduleId,
    required this.policyId,
    required this.controlId,
    required this.championEmail,
    required this.controlOwnerEmail,
    required this.departmentManagerEmail,
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
      departmentManagerEmail: params.departmentManagerEmail,
      documentFile: params.documentFile,
      note: params.note,
      editorEmail: params.editorEmail,
    );
  }
}
```

- [ ] **Step 5: Thread `departmentManagerEmail` through `AssignmentControlRepository.submitEvidence` and its impl**

In `lib/features/grc/assignment_control/domain/repository/assignment_control_repository.dart`, change the `submitEvidence` signature to add one parameter (right after `controlOwnerEmail`):

```dart
  Future<Either<Failure, AssignmentControlEntity>> submitEvidence({
    required String moduleId,
    required String policyId,
    required String controlId,
    required String championEmail,
    required String? controlOwnerEmail,
    required String? departmentManagerEmail,
    required File documentFile,
    required String note,
    required String editorEmail,
  });
```

In `lib/features/grc/assignment_control/data/repository/assignment_control_repository_impl.dart`, update `submitEvidence`'s signature and its `create` call:

```dart
  @override
  Future<Either<Failure, AssignmentControlEntity>> submitEvidence({
    required String moduleId,
    required String policyId,
    required String controlId,
    required String championEmail,
    required String? controlOwnerEmail,
    required String? departmentManagerEmail,
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
          departmentManager: departmentManagerEmail,
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
```

(Only the signature and the `AssignmentControlModel.create(...)` call changed — the `else` branch is untouched, since `departmentManager` is a fixed field `copyWithUpdate` never takes.)

- [ ] **Step 6: Write the two new use cases**

```dart
// lib/features/grc/assignment_control/domain/use_cases/get_assignment_control_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';

class GetAssignmentControlByIdUseCase {
  const GetAssignmentControlByIdUseCase(this._repository);

  final AssignmentControlRepository _repository;

  Future<Either<Failure, AssignmentControlEntity?>> call({
    required String moduleId,
    required String id,
  }) {
    return _repository.getAssignmentControlById(moduleId: moduleId, id: id);
  }
}
```

```dart
// lib/features/grc/assignment_control/domain/use_cases/apply_manager_decision_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:demo_app/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';

class ApplyManagerDecisionParams {
  final String moduleId;
  final String controlId;
  final String championEmail;
  final AssignmentControlStatus newStatus;
  final String? rejectionReason;
  final String editorEmail;

  const ApplyManagerDecisionParams({
    required this.moduleId,
    required this.controlId,
    required this.championEmail,
    required this.newStatus,
    this.rejectionReason,
    required this.editorEmail,
  });
}

class ApplyManagerDecisionUseCase {
  const ApplyManagerDecisionUseCase(this._repository);

  final AssignmentControlRepository _repository;

  Future<Either<Failure, AssignmentControlEntity>> call(
    ApplyManagerDecisionParams params,
  ) {
    return _repository.applyManagerDecision(
      moduleId: params.moduleId,
      controlId: params.controlId,
      championEmail: params.championEmail,
      newStatus: params.newStatus,
      rejectionReason: params.rejectionReason,
      editorEmail: params.editorEmail,
    );
  }
}
```

- [ ] **Step 7: Verify it compiles**

Run: `puro flutter analyze lib/features/grc/assignment_control`
Expected: No issues found. (This will show errors until Task 6 also updates `AssignmentControlCubit`'s call site — if running this task in isolation, a "not enough positional/named arguments" error at the `SubmitEvidenceParams(...)` call site in `assignment_control_cubit.dart` is expected and resolved by Task 6.)

- [ ] **Step 8: Commit**

```bash
git add lib/features/grc/assignment_control/data/models/assignment_control_model.dart \
        lib/features/grc/assignment_control/domain/repository/assignment_control_repository.dart \
        lib/features/grc/assignment_control/data/repository/assignment_control_repository_impl.dart \
        lib/features/grc/assignment_control/domain/use_cases/submit_evidence_usecase.dart \
        lib/features/grc/assignment_control/domain/use_cases/apply_manager_decision_usecase.dart \
        lib/features/grc/assignment_control/domain/use_cases/get_assignment_control_by_id_usecase.dart
git commit -m "feat(grc): thread Department Manager through Assignment Controls submit + add manager-decision/raw-id lookups"
```

---

### Task 6: Extend `AssignmentControlCubit.submitEvidence`

**Files:**
- Modify: `lib/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart`

**Interfaces:**
- Consumes: `findDepartmentManagerEmail` (Task 2), `CreateOrUpdatePendingApprovalUseCase` (Task 4), the extended `SubmitEvidenceParams` (Task 5), `MainCoreEmployeeController`/`EmployeeEntityPro` (existing — `lib/features/employee/presentation/controller/main_core_employee_controller.dart`, `lib/features/employee/domain/entities/employee_entity.dart`), `Get`/`Get.isRegistered`/`Get.find` (package `get`).
- Produces: `AssignmentControlCubit` constructor gains `required CreateOrUpdatePendingApprovalUseCase createOrUpdatePendingApprovalUseCase`. Task 10's DI wiring depends on this new constructor param.

- [ ] **Step 1: Add the new constructor dependency and imports**

In `lib/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart`, add these imports:

```dart
import 'package:get/get.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_resolver.dart';
import 'package:demo_app/features/grc/approval/domain/use_cases/create_or_update_pending_approval_usecase.dart';
```

Change the constructor and field list to:

```dart
class AssignmentControlCubit extends Cubit<AssignmentControlState> {
  AssignmentControlCubit({
    required GetChampionUseCase getChampionUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
    required GetAllOwnersUseCase getAllOwnersUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required GetAssignmentControlUseCase getAssignmentControlUseCase,
    required SubmitEvidenceUseCase submitEvidenceUseCase,
    required CreateOrUpdatePendingApprovalUseCase createOrUpdatePendingApprovalUseCase,
  })  : _getChampionUseCase = getChampionUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        _getAllOwnersUseCase = getAllOwnersUseCase,
        _getAllPoliciesUseCase = getAllPoliciesUseCase,
        _getAssignmentControlUseCase = getAssignmentControlUseCase,
        _submitEvidenceUseCase = submitEvidenceUseCase,
        _createOrUpdatePendingApprovalUseCase = createOrUpdatePendingApprovalUseCase,
        super(AssignmentControlInitial());

  final GetChampionUseCase _getChampionUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
  final GetAllOwnersUseCase _getAllOwnersUseCase;
  final GetAllPoliciesUseCase _getAllPoliciesUseCase;
  final GetAssignmentControlUseCase _getAssignmentControlUseCase;
  final SubmitEvidenceUseCase _submitEvidenceUseCase;
  final CreateOrUpdatePendingApprovalUseCase _createOrUpdatePendingApprovalUseCase;
```

(`getMyAssignmentControls` is unchanged — leave it exactly as-is.)

- [ ] **Step 2: Extend `submitEvidence`**

Replace the whole `submitEvidence` method with:

```dart
  /// Resolves the current Control Owner and Department Manager for this
  /// policy+control (if any), submits (creates or resubmits) the evidence,
  /// then creates/resets the linked Approval doc to Pending so the manager's
  /// Approvals list picks it up.
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

    final employees = Get.isRegistered<MainCoreEmployeeController>()
        ? (Get.find<MainCoreEmployeeController>().allEmployeesEntities ??
            const <EmployeeEntityPro>[])
        : const <EmployeeEntityPro>[];
    final departmentManagerEmail = findDepartmentManagerEmail(
      employees,
      championEmail: championEmail,
    );

    final result = await _submitEvidenceUseCase.call(
      SubmitEvidenceParams(
        moduleId: moduleId,
        policyId: policyId,
        controlId: controlId,
        championEmail: championEmail,
        controlOwnerEmail: ownerEmail,
        departmentManagerEmail: departmentManagerEmail,
        documentFile: documentFile,
        note: note,
        editorEmail: championEmail,
      ),
    );

    await result.fold(
      (failure) async => emit(AssignmentControlFailure(failure.message)),
      (assignment) async {
        await _createOrUpdatePendingApprovalUseCase.call(
          CreateOrUpdatePendingApprovalParams(
            moduleId: moduleId,
            controlId: controlId,
            championEmail: championEmail,
            editorEmail: championEmail,
          ),
        );
        emit(AssignmentControlActionSuccess(assignment));
      },
    );
  }
```

- [ ] **Step 3: Verify it compiles**

Run: `puro flutter analyze lib/features/grc/assignment_control`
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/assignment_control/presentation/controller/assignment_control_cubit.dart
git commit -m "feat(grc): resolve Department Manager and create the Approval on submit"
```

---

### Task 7: `ApprovalCubit`

**Files:**
- Create: `lib/features/grc/approval/presentation/controller/approval_cubit.dart`
- Create: `lib/features/grc/approval/presentation/controller/approval_state.dart`

**Interfaces:**
- Consumes: `ApprovalItem`/`buildApprovalItems` (Task 2), `GetAllApprovalsUseCase`/`DecideApprovalUseCase` (Task 4), `GetAssignmentControlByIdUseCase`/`ApplyManagerDecisionUseCase` (Task 5), existing `GetAllControlsUseCase`/`GetAllPoliciesUseCase`.
- Produces: `ApprovalCubit` with `getMyApprovals({required moduleId, required managerEmail})`, `approve({required moduleId, required controlId, required championEmail, required managerEmail, String? comment})`, `reject({required moduleId, required controlId, required championEmail, required managerEmail, required String reason})`; states `ApprovalInitial/Loading/ListLoaded(List<ApprovalItem>)/ActionSuccess(ApprovalEntity)/Failure(String)`. Tasks 8 and 9 (UI) depend on these exact names.

- [ ] **Step 1: Write the state file**

```dart
// lib/features/grc/approval/presentation/controller/approval_state.dart
part of 'approval_cubit.dart';

sealed class ApprovalState {}

final class ApprovalInitial extends ApprovalState {}

final class ApprovalLoading extends ApprovalState {}

final class ApprovalListLoaded extends ApprovalState {
  final List<ApprovalItem> items;
  ApprovalListLoaded(this.items);
}

final class ApprovalActionSuccess extends ApprovalState {
  final ApprovalEntity approval;
  ApprovalActionSuccess(this.approval);
}

final class ApprovalFailure extends ApprovalState {
  final String message;
  ApprovalFailure(this.message);
}
```

- [ ] **Step 2: Write the cubit**

```dart
// lib/features/grc/approval/presentation/controller/approval_cubit.dart
/// Module: Approvals (Department Manager)
/// Description: BLoC Cubit that manages the manager's Approvals list and
///              Approve/Reject actions, mirroring AssignmentControlCubit's
///              shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_item.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_resolver.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_status.dart';
import 'package:demo_app/features/grc/approval/domain/use_cases/decide_approval_usecase.dart';
import 'package:demo_app/features/grc/approval/domain/use_cases/get_all_approvals_usecase.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:demo_app/features/grc/assignment_control/domain/use_cases/apply_manager_decision_usecase.dart';
import 'package:demo_app/features/grc/assignment_control/domain/use_cases/get_assignment_control_by_id_usecase.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_usecases.dart';

part 'approval_state.dart';

class ApprovalCubit extends Cubit<ApprovalState> {
  ApprovalCubit({
    required GetAllApprovalsUseCase getAllApprovalsUseCase,
    required GetAssignmentControlByIdUseCase getAssignmentControlByIdUseCase,
    required GetAllControlsUseCase getAllControlsUseCase,
    required GetAllPoliciesUseCase getAllPoliciesUseCase,
    required DecideApprovalUseCase decideApprovalUseCase,
    required ApplyManagerDecisionUseCase applyManagerDecisionUseCase,
  })  : _getAllApprovalsUseCase = getAllApprovalsUseCase,
        _getAssignmentControlByIdUseCase = getAssignmentControlByIdUseCase,
        _getAllControlsUseCase = getAllControlsUseCase,
        _getAllPoliciesUseCase = getAllPoliciesUseCase,
        _decideApprovalUseCase = decideApprovalUseCase,
        _applyManagerDecisionUseCase = applyManagerDecisionUseCase,
        super(ApprovalInitial());

  final GetAllApprovalsUseCase _getAllApprovalsUseCase;
  final GetAssignmentControlByIdUseCase _getAssignmentControlByIdUseCase;
  final GetAllControlsUseCase _getAllControlsUseCase;
  final GetAllPoliciesUseCase _getAllPoliciesUseCase;
  final DecideApprovalUseCase _decideApprovalUseCase;
  final ApplyManagerDecisionUseCase _applyManagerDecisionUseCase;

  /// Loads every Pending Approval whose linked Assignment Control's
  /// Department Manager is [managerEmail], resolving each one's
  /// Control/Policy details for display.
  Future<void> getMyApprovals({
    required String moduleId,
    required String managerEmail,
  }) async {
    emit(ApprovalLoading());
    final approvalsResult = await _getAllApprovalsUseCase.call(moduleId: moduleId);

    await approvalsResult.fold(
      (failure) async => emit(ApprovalFailure(failure.message)),
      (approvals) async {
        final pending =
            approvals.where((a) => a.status == ApprovalStatus.pending).toList();

        final assignmentControls = <String, AssignmentControlEntity>{};
        for (final approval in pending) {
          final result = await _getAssignmentControlByIdUseCase.call(
            moduleId: moduleId,
            id: approval.submissionId,
          );
          result.fold(
            (_) {},
            (assignmentControl) {
              if (assignmentControl != null) {
                assignmentControls[approval.submissionId] = assignmentControl;
              }
            },
          );
        }

        final relevant = assignmentControls.values
            .where((ac) => ac.departmentManager == managerEmail);

        final policyControls = <String, List<ControlEntity>>{};
        for (final ac in relevant) {
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

        final policiesResult = await _getAllPoliciesUseCase.call(moduleId: moduleId);
        final policies = <String, PolicyEntity>{
          for (final p in policiesResult.fold((_) => <PolicyEntity>[], (p) => p))
            p.id: p,
        };

        emit(ApprovalListLoaded(
          buildApprovalItems(
            approvals: pending,
            assignmentControls: assignmentControls,
            policyControls: policyControls,
            policies: policies,
            managerEmail: managerEmail,
          ),
        ));
      },
    );
  }

  Future<void> approve({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String managerEmail,
    String? comment,
  }) async {
    emit(ApprovalLoading());
    final approvalResult = await _decideApprovalUseCase.call(
      DecideApprovalParams(
        moduleId: moduleId,
        controlId: controlId,
        championEmail: championEmail,
        status: ApprovalStatus.approved.value,
        approvalComment: comment,
        editorEmail: managerEmail,
      ),
    );

    await approvalResult.fold(
      (failure) async => emit(ApprovalFailure(failure.message)),
      (approval) async {
        final acResult = await _applyManagerDecisionUseCase.call(
          ApplyManagerDecisionParams(
            moduleId: moduleId,
            controlId: controlId,
            championEmail: championEmail,
            newStatus: AssignmentControlStatus.inReview,
            editorEmail: managerEmail,
          ),
        );
        acResult.fold(
          (failure) => emit(ApprovalFailure(failure.message)),
          (_) => emit(ApprovalActionSuccess(approval)),
        );
      },
    );
  }

  Future<void> reject({
    required String moduleId,
    required String controlId,
    required String championEmail,
    required String managerEmail,
    required String reason,
  }) async {
    emit(ApprovalLoading());
    final approvalResult = await _decideApprovalUseCase.call(
      DecideApprovalParams(
        moduleId: moduleId,
        controlId: controlId,
        championEmail: championEmail,
        status: ApprovalStatus.rejected.value,
        reasonOfRejection: reason,
        editorEmail: managerEmail,
      ),
    );

    await approvalResult.fold(
      (failure) async => emit(ApprovalFailure(failure.message)),
      (approval) async {
        final acResult = await _applyManagerDecisionUseCase.call(
          ApplyManagerDecisionParams(
            moduleId: moduleId,
            controlId: controlId,
            championEmail: championEmail,
            newStatus: AssignmentControlStatus.rejected,
            rejectionReason: reason,
            editorEmail: managerEmail,
          ),
        );
        acResult.fold(
          (failure) => emit(ApprovalFailure(failure.message)),
          (_) => emit(ApprovalActionSuccess(approval)),
        );
      },
    );
  }
}
```

- [ ] **Step 3: Verify it compiles**

Run: `puro flutter analyze lib/features/grc/approval`
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/approval/presentation/controller/
git commit -m "feat(grc): add ApprovalCubit"
```

---

### Task 8: `ApprovalsListPage`

**Files:**
- Create: `lib/features/grc/approval/presentation/ui/pages/approvals_list_page.dart`
- Create: `lib/features/grc/approval/presentation/ui/widgets/approval_card.dart`

**Interfaces:**
- Consumes: `ApprovalCubit`/states (Task 7), `ApprovalItem` (Task 2), existing `GRCModuleEntity`, `currentGrcUserEmail`/`findEmployeeByEmail`/`employeeDisplayName` (`lib/features/grc/shared/helpers/grc_assignment_lookup.dart`), `AppSearchTextField`, `PaginationAppBar`, `CardStyles`.
- Produces: `ApprovalsListPage(module: GRCModuleEntity)` — Task 10 navigates to this from the module details page; it navigates internally to Task 9's `ApprovalDetailsPage`.

- [ ] **Step 1: Write the card widget**

```dart
// lib/features/grc/approval/presentation/ui/widgets/approval_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_item.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';

final DateFormat _cardDateFormat = DateFormat('d MMM yyyy');

class ApprovalCard extends StatelessWidget {
  final ApprovalItem item;
  final bool isArabic;
  final VoidCallback onTap;

  const ApprovalCard({
    super.key,
    required this.item,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final control = item.control;
    final policy = item.policy;
    final championEmail = item.assignmentControl.controlChampionEmail;
    final championName = employeeDisplayName(context, championEmail);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic ? control.controlsNameAr : control.controlsNameEn,
              style: CardStyles.value(14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              '${'Policy Name'.tr}: ${isArabic ? policy.policyNameAr : policy.policyNameEn}',
              style: CardStyles.label(12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              '${'Champion'.tr}: $championName',
              style: CardStyles.label(12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              '${'Champion Email'.tr}: $championEmail',
              style: CardStyles.label(12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              '${'Submission Date'.tr}: ${_cardDateFormat.format(item.assignmentControl.lastModificationDate)}',
              style: CardStyles.label(12),
            ),
          ],
        ),
      ),
    );
  }
}
```

Note: `.tr` requires `import 'package:get/get_utils/src/extensions/internacionalization.dart';` — add it to this file's imports.

- [ ] **Step 2: Write the list page**

```dart
// lib/features/grc/approval/presentation/ui/pages/approvals_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_item.dart';
import 'package:demo_app/features/grc/approval/presentation/controller/approval_cubit.dart';
import 'package:demo_app/features/grc/approval/presentation/ui/pages/approval_details_page.dart';
import 'package:demo_app/features/grc/approval/presentation/ui/widgets/approval_card.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/roles/widgets/filter_bar_item.dart';

class ApprovalsListPage extends StatelessWidget {
  final GRCModuleEntity module;

  const ApprovalsListPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ApprovalCubit>(
      create: (_) => GetIt.instance<ApprovalCubit>()
        ..getMyApprovals(
          moduleId: module.moduleId,
          managerEmail: currentGrcUserEmail(),
        ),
      child: _ApprovalsListBody(module: module),
    );
  }
}

class _ApprovalsListBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _ApprovalsListBody({required this.module});

  @override
  State<_ApprovalsListBody> createState() => _ApprovalsListBodyState();
}

class _ApprovalsListBodyState extends State<_ApprovalsListBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ApprovalItem> _filter(List<ApprovalItem> items, bool isArabic) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((i) {
      final name = isArabic ? i.control.controlsNameAr : i.control.controlsNameEn;
      final policyName = isArabic ? i.policy.policyNameAr : i.policy.policyNameEn;
      return name.toLowerCase().contains(query) ||
          policyName.toLowerCase().contains(query);
    }).toList();
  }

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
                screensTitles: ['GRC'.tr, 'Approvals'.tr],
              ),
              SizedBox(height: 15.h),
              Expanded(
                child: BlocBuilder<ApprovalCubit, ApprovalState>(
                  builder: (context, state) {
                    if (state is ApprovalFailure) {
                      return Center(child: Text(state.message));
                    }
                    if (state is! ApprovalListLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final filtered = _filter(state.items, isArabic);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScrollConfiguration(
                          behavior:
                              ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: 30.sp,
                              children: [
                                FilterBarItem(
                                  title: 'Pending'.tr,
                                  numberOfItems: state.items.length,
                                  isSelected: true,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Row(
                          children: [
                            AppSearchTextField(
                              controller: _searchController,
                              onChanged: (v) => setState(() => _searchQuery = v),
                              hintText: 'Search'.tr,
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        Expanded(
                          child: filtered.isEmpty
                              ? Center(child: Text('No pending approvals'.tr))
                              : GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12.w,
                                    mainAxisSpacing: 12.h,
                                    mainAxisExtent: 150.h,
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final item = filtered[index];
                                    return ApprovalCard(
                                      item: item,
                                      isArabic: isArabic,
                                      onTap: () => Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => BlocProvider.value(
                                            value: context.read<ApprovalCubit>(),
                                            child: ApprovalDetailsPage(
                                              item: item,
                                              module: widget.module,
                                            ),
                                          ),
                                          transitionsBuilder:
                                              (_, animation, __, child) =>
                                                  FadeTransition(
                                                      opacity: animation, child: child),
                                          transitionDuration:
                                              const Duration(milliseconds: 300),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
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

Run: `puro flutter analyze lib/features/grc/approval`
Expected: No issues found (`approval_details_page.dart`, imported above, is written next in Task 9 — analyze after Task 9 if this task is run standalone; the "target of URI doesn't exist" error until then is expected).

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/approval/presentation/ui/widgets/approval_card.dart \
        lib/features/grc/approval/presentation/ui/pages/approvals_list_page.dart
git commit -m "feat(grc): add ApprovalsListPage"
```

---

### Task 9: `ApprovalDetailsPage`

**Files:**
- Create: `lib/features/grc/approval/presentation/ui/pages/approval_details_page.dart`

**Interfaces:**
- Consumes: `ApprovalCubit`/states (Task 7), `ApprovalItem` (Task 2), `showConfirmDialog`/`showCommentDialog`/`showSuccessDialog`/`showErrorDialog` (`lib/core/custom/11_custom_confirm_diaolog.dart`), `ProductWarrantyCard`, `customButton`, `currentGrcUserEmail`/`findEmployeeByEmail`/`employeeDisplayName`.
- Produces: `ApprovalDetailsPage({required item, required module})` — consumed by Task 8's navigation.

- [ ] **Step 1: Write the page**

```dart
// lib/features/grc/approval/presentation/ui/pages/approval_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/custom/22-custom_uploaded_document_card.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_item.dart';
import 'package:demo_app/features/grc/approval/presentation/controller/approval_cubit.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';

final DateFormat _cardDateFormat = DateFormat('d MMM yyyy');

class ApprovalDetailsPage extends StatefulWidget {
  final ApprovalItem item;
  final GRCModuleEntity module;

  const ApprovalDetailsPage({
    super.key,
    required this.item,
    required this.module,
  });

  @override
  State<ApprovalDetailsPage> createState() => _ApprovalDetailsPageState();
}

class _ApprovalDetailsPageState extends State<ApprovalDetailsPage> {
  void _onApprovePressed(BuildContext context) {
    final cubit = context.read<ApprovalCubit>();
    showConfirmDialog(
      context: context,
      title: 'Approve Request'.tr,
      subtitle: 'Approve this request?'.tr,
      confirmLabel: 'Yes'.tr,
      cancelLabel: 'No'.tr,
      onConfirm: () => cubit.approve(
        moduleId: widget.module.moduleId,
        controlId: widget.item.control.id,
        championEmail: widget.item.assignmentControl.controlChampionEmail,
        managerEmail: currentGrcUserEmail(),
      ),
    );
  }

  void _onRejectPressed(BuildContext context) {
    final cubit = context.read<ApprovalCubit>();
    showConfirmDialog(
      context: context,
      title: 'Reject Request'.tr,
      subtitle: 'Reject this request?'.tr,
      confirmLabel: 'Yes'.tr,
      cancelLabel: 'No'.tr,
      onConfirm: () => showCommentDialog(
        context: context,
        title: 'Reason of Rejection'.tr,
        fieldLabel: 'Reason of Rejection'.tr,
        hint: 'Text here'.tr,
        submitLabel: 'Submit'.tr,
        onSubmit: (reason) => cubit.reject(
          moduleId: widget.module.moduleId,
          controlId: widget.item.control.id,
          championEmail: widget.item.assignmentControl.controlChampionEmail,
          managerEmail: currentGrcUserEmail(),
          reason: reason,
        ),
      ),
    );
  }

  Widget _labelValueRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: CardStyles.label(12)),
        Expanded(child: Text(value, style: CardStyles.value(12))),
      ],
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.item.control;
    final policy = widget.item.policy;
    final assignmentControl = widget.item.assignmentControl;
    final isArabic = context.isArabic;
    final championEmail = assignmentControl.controlChampionEmail;
    final championName = employeeDisplayName(context, championEmail);

    return BlocConsumer<ApprovalCubit, ApprovalState>(
      listener: (context, state) {
        if (state is ApprovalActionSuccess) {
          context.read<ApprovalCubit>().getMyApprovals(
                moduleId: widget.module.moduleId,
                managerEmail: currentGrcUserEmail(),
              );
          showSuccessDialog(
            context: context,
            title: 'Request Updated'.tr,
            subtitle: 'The request has been updated successfully'.tr,
          );
          Navigator.pop(context);
        } else if (state is ApprovalFailure) {
          showErrorDialog(context: context, subtitle: state.message);
        }
      },
      builder: (context, state) {
        final isSaving = state is ApprovalLoading;
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
                      'Approvals'.tr,
                      isArabic ? control.controlsNameAr : control.controlsNameEn,
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Expanded(
                    child: ListView(
                      children: [
                        Text('Policy Details'.tr, style: StyleText.fontSize16Weight600),
                        SizedBox(height: 8.h),
                        _sectionCard(children: [
                          Text(
                            isArabic ? policy.policyNameAr : policy.policyNameEn,
                            style: StyleText.fontSize16Weight600,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            isArabic
                                ? policy.policyDescriptionAr
                                : policy.policyDescriptionEn,
                            style: CardStyles.value(12),
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Text('Control Details'.tr, style: StyleText.fontSize16Weight600),
                        SizedBox(height: 8.h),
                        _sectionCard(children: [
                          Text(
                            isArabic ? control.controlsNameAr : control.controlsNameEn,
                            style: StyleText.fontSize16Weight600,
                          ),
                          SizedBox(height: 8.h),
                          _labelValueRow(
                            'Description'.tr,
                            isArabic
                                ? control.controlsDescriptionAr
                                : control.controlsDescriptionEn,
                          ),
                        ]),
                        SizedBox(height: 15.h),
                        Text('Champion & Submission'.tr,
                            style: StyleText.fontSize16Weight600),
                        SizedBox(height: 8.h),
                        _sectionCard(children: [
                          _labelValueRow('Champion'.tr, championName),
                          SizedBox(height: 8.h),
                          _labelValueRow('Champion Email'.tr, championEmail),
                          SizedBox(height: 8.h),
                          _labelValueRow(
                            'Submission Date'.tr,
                            _cardDateFormat.format(assignmentControl.lastModificationDate),
                          ),
                          SizedBox(height: 12.h),
                          if (assignmentControl.submissionNote.isNotEmpty) ...[
                            _labelValueRow(
                                'Submission Notes'.tr, assignmentControl.submissionNote),
                            SizedBox(height: 12.h),
                          ],
                          if (assignmentControl.submissionDocument.isNotEmpty)
                            ProductWarrantyCard(
                              fileName: assignmentControl.submissionDocument
                                  .split('/')
                                  .last
                                  .split('?')
                                  .first,
                              onTapFile: () {},
                            ),
                        ]),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: customButton(
                                title: 'Reject'.tr,
                                function: isSaving
                                    ? () {}
                                    : () => _onRejectPressed(context),
                                height: 44.h,
                                color: AppColors.red,
                                textStyle: StyleText.fontSize16Weight500
                                    .copyWith(color: AppColors.textButton),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: customButton(
                                title: 'Approve'.tr,
                                function: isSaving
                                    ? () {}
                                    : () => _onApprovePressed(context),
                                height: 44.h,
                                color: AppColors.primary,
                                textStyle: StyleText.fontSize16Weight500
                                    .copyWith(color: AppColors.textButton),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                      ],
                    ),
                  ),
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

Run: `puro flutter analyze lib/features/grc/approval`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/approval/presentation/ui/pages/approval_details_page.dart
git commit -m "feat(grc): add ApprovalDetailsPage"
```

---

### Task 10: Wire the button, register DI, verify end-to-end

**Files:**
- Modify: `lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart:172-179`
- Modify: `lib/features/grc/grc_get_it.dart`

**Interfaces:**
- Consumes: everything from Tasks 1-9.
- Produces: nothing further — the "Approvals" button becomes fully functional, and the Champion's existing Submit flow now creates Approval requests and resolves the Department Manager.

- [ ] **Step 1: Add the import and wire the button**

In `lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart`, add near the other page imports:

```dart
import 'package:demo_app/features/grc/approval/presentation/ui/pages/approvals_list_page.dart';
```

Replace the "Approvals" `customButton` (currently `function: () {}`, read the actual current file first — the exact line numbers may have drifted; search for the string `"Approvals".tr` to find it, there is only one such button):

```dart
                    customButton(
                      title: "Approvals".tr,
                      function: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) =>
                              ApprovalsListPage(module: widget.module),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      ),
                      width: 120.w,
                      height: 38.h,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.textButton),
                    ),
```

- [ ] **Step 2: Register the new dependencies in `grc_get_it.dart`**

Add these imports near the existing `assignment_control` imports:

```dart
import 'package:demo_app/features/grc/approval/data/data_source/approval_firebase_data_source.dart';
import 'package:demo_app/features/grc/approval/data/repository/approval_repository_impl.dart';
import 'package:demo_app/features/grc/approval/domain/repository/approval_repository.dart';
import 'package:demo_app/features/grc/approval/domain/use_cases/create_or_update_pending_approval_usecase.dart';
import 'package:demo_app/features/grc/approval/domain/use_cases/decide_approval_usecase.dart';
import 'package:demo_app/features/grc/approval/domain/use_cases/get_all_approvals_usecase.dart';
import 'package:demo_app/features/grc/approval/presentation/controller/approval_cubit.dart';
import 'package:demo_app/features/grc/assignment_control/domain/use_cases/apply_manager_decision_usecase.dart';
import 'package:demo_app/features/grc/assignment_control/domain/use_cases/get_assignment_control_by_id_usecase.dart';
```

Add to the "1. Data Sources" section (after `AssignmentControlFirebaseDataSource`'s registration):

```dart
  /// class name: [ApprovalFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for Approval documents.
  sl.registerLazySingleton<ApprovalFirebaseDataSource>(
    () => ApprovalFirebaseDataSource(),
  );
```

Add to the "2. Repository" section (after `AssignmentControlRepositoryImpl`'s registration):

```dart
  /// class name: [ApprovalRepositoryImpl] registered as [ApprovalRepository]
  /// purpose: orchestrates the Approval data source and maps models to entities.
  sl.registerLazySingleton<ApprovalRepository>(
    () => ApprovalRepositoryImpl(dataSource: sl<ApprovalFirebaseDataSource>()),
  );
```

Add to the "3. Use Cases" section (after `SubmitEvidenceUseCase`'s registration):

```dart
  /// class name: [GetAssignmentControlByIdUseCase]
  /// purpose: business logic for fetching an Assignment Control directly
  /// by its raw Firestore doc id (used by the Approvals feature).
  sl.registerLazySingleton<GetAssignmentControlByIdUseCase>(
    () => GetAssignmentControlByIdUseCase(sl<AssignmentControlRepository>()),
  );

  /// class name: [ApplyManagerDecisionUseCase]
  /// purpose: business logic for recording a Department Manager's
  /// Approve/Reject decision on an Assignment Control.
  sl.registerLazySingleton<ApplyManagerDecisionUseCase>(
    () => ApplyManagerDecisionUseCase(sl<AssignmentControlRepository>()),
  );

  /// class name: [GetAllApprovalsUseCase]
  /// purpose: business logic for fetching every Approval in a module.
  sl.registerLazySingleton<GetAllApprovalsUseCase>(
    () => GetAllApprovalsUseCase(sl<ApprovalRepository>()),
  );

  /// class name: [CreateOrUpdatePendingApprovalUseCase]
  /// purpose: business logic for creating or resetting to Pending the
  /// Approval linked to a Champion's submission.
  sl.registerLazySingleton<CreateOrUpdatePendingApprovalUseCase>(
    () => CreateOrUpdatePendingApprovalUseCase(sl<ApprovalRepository>()),
  );

  /// class name: [DecideApprovalUseCase]
  /// purpose: business logic for recording a manager's Approve/Reject
  /// decision on an Approval.
  sl.registerLazySingleton<DecideApprovalUseCase>(
    () => DecideApprovalUseCase(sl<ApprovalRepository>()),
  );
```

Update the existing `AssignmentControlCubit` registration in the "4. Cubit (Presentation)" section to pass the new dependency:

```dart
  sl.registerFactory<AssignmentControlCubit>(
    () => AssignmentControlCubit(
      getChampionUseCase: sl<GetChampionUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      getAllOwnersUseCase: sl<GetAllOwnersUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      getAssignmentControlUseCase: sl<GetAssignmentControlUseCase>(),
      submitEvidenceUseCase: sl<SubmitEvidenceUseCase>(),
      createOrUpdatePendingApprovalUseCase: sl<CreateOrUpdatePendingApprovalUseCase>(),
    ),
  );
```

(Read the file first to find this exact block — search for `AssignmentControlCubit(` — and add only the new last line inside it; do not duplicate the existing lines.)

Add the new `ApprovalCubit` registration at the end of the "4. Cubit (Presentation)" section, before the function's closing `}`:

```dart

  /// class name: [ApprovalCubit]
  /// purpose: presentation-layer state manager for the Department
  /// Manager's Approvals list and Approve/Reject actions. Registered as a
  /// factory so each page gets an independent cubit instance.
  sl.registerFactory<ApprovalCubit>(
    () => ApprovalCubit(
      getAllApprovalsUseCase: sl<GetAllApprovalsUseCase>(),
      getAssignmentControlByIdUseCase: sl<GetAssignmentControlByIdUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      decideApprovalUseCase: sl<DecideApprovalUseCase>(),
      applyManagerDecisionUseCase: sl<ApplyManagerDecisionUseCase>(),
    ),
  );
```

- [ ] **Step 3: Run static analysis across the whole app**

Run: `puro flutter analyze`
Expected: No new errors introduced by this feature (pre-existing unrelated issues, if any, are out of scope).

- [ ] **Step 4: Run the full test suite**

Run: `puro flutter test`
Expected: All tests pass, including the new model/resolver tests from Tasks 1 and 2, plus the pre-existing Assignment Controls tests (unaffected by this plan's changes to that feature's signatures, since those tests never construct `AssignmentControlModel.create(...)` or `SubmitEvidenceParams(...)` directly — confirm this by reading `test/features/grc/assignment_control/assignment_control_model_test.dart` before running, and update any call site there that now needs the new required `departmentManager`/`departmentManagerEmail` params if one exists).

- [ ] **Step 5: Manual smoke test**

1. Ensure at least one employee in the same department as a test Champion has a job title starting with "Chief" (e.g. edit an employee's title to "Chief Operations Officer (COO)" via the existing employee-management UI, in the same department as your Champion).
2. As that Champion, submit evidence for a Pending control (per the existing Assignment Controls smoke test).
3. In Firestore, confirm the `Assignment_Controls` doc's `Department_Manager` field is now populated with that Chief-titled employee's email, and a new `Approvals` doc exists at `GRC Modules/{moduleId}/Approvals/{controlId}_{championEmail}` with `Status: ["Pending"]`.
4. Sign in as that Chief-titled manager, open the same GRC Module → "Approvals" → confirm the submitted request appears with the right Policy/Control/Champion details.
5. Tap into it → Approve → confirm the success dialog, and in Firestore confirm the `Approvals` doc's `Status` is now `["Pending","Approved"]` and the linked `Assignment_Controls` doc's `Status` is now `[..., "In review"]`.
6. Repeat with a second submission → Reject with a reason → confirm the `Approvals` doc's `Reasons_of_Rejection` has the reason at the matching index, and the `Assignment_Controls` doc's `Status` is `[..., "Rejected"]` with `Department_Manager_Reasons of Rejection` populated — then confirm the Champion sees it in their Rejected tab (existing Assignment Controls UI).

- [ ] **Step 6: Commit**

```bash
git add lib/features/grc/module/presentation/ui/pages/grc_module_details_page.dart \
        lib/features/grc/grc_get_it.dart
git commit -m "feat(grc): wire Approvals button and register DI"
```

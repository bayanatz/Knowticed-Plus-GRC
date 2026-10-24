// [module-file:grc] — deleted when the grc module is split out
/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_grc.dart
/// Purpose: Showcase GRC data: 21 modules (6 active and fully filled, 5
///          inactive, 5 scheduled, 5 removed) with their policies, controls,
///          champions, owners, evidence submissions, approvals, My Audit
///          records, reassignment requests and comment threads.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Every record is written with the module's own models (`GRCModuleModel`,
/// `PolicyModel`, `ControlModel`, `ChampionModel`, `OwnerModel`,
/// `AssignmentControlModel`, `ApprovalModel`, `MyAuditModel`,
/// `GrcRequestModel`) under `GrcFirebasePaths`, with fixed `showcase_` ids,
/// so a second run overwrites the same documents.
///
/// How the signed-in user appears (so every screen has data):
///   * module owner of the six active modules (Approvals shows all evidence,
///     plus the Reassign and Give Score tabs);
///   * control champion of the `c*` controls (Assigning Controls);
///   * control owner of the `o*` controls (My Audit);
///   * department manager of the `o*` controls.
/// Evidence situations (the letter after the owner/champion prefix):
///   H pending (not yet submitted) · A submitted · B rejected by the manager
///   C approved by the manager, waiting for the owner · D owner approved,
///   waiting for the score · E scored · F rejected by the owner · I and G
///   overdue (never submitted).
/// Invariant kept: every Control Owner document has exactly one permission
/// entry per control of its latest revision.
library;

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/grc/grc10_request/data/models/grc_request_model.dart';
import 'package:knowticed_plus/features/grc/grc10_request/domain/entities/grc_request_type.dart';
import 'package:knowticed_plus/features/grc/grc11_module/data/models/grc_module_model.dart';
import 'package:knowticed_plus/features/grc/grc11_module/domain/entities/grc_module_status.dart';
import 'package:knowticed_plus/features/grc/grc12_my_audit/data/models/my_audit_model.dart';
import 'package:knowticed_plus/features/grc/grc12_my_audit/domain/entities/my_audit_status.dart';
import 'package:knowticed_plus/features/grc/grc13_policy/data/models/policy_model.dart';
import 'package:knowticed_plus/features/grc/grc13_policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/grc2_approval/data/models/approval_model.dart';
import 'package:knowticed_plus/features/grc/grc2_approval/domain/entities/approval_status.dart';
import 'package:knowticed_plus/features/grc/grc4_assignment_control/data/models/assignment_control_model.dart';
import 'package:knowticed_plus/features/grc/grc4_assignment_control/domain/entities/assignment_control_status.dart';
import 'package:knowticed_plus/features/grc/grc5_control/data/models/assigning_control_model.dart';
import 'package:knowticed_plus/features/grc/grc5_control/data/models/control_model.dart';
import 'package:knowticed_plus/features/grc/grc5_control/domain/entities/control_department_weight.dart';
import 'package:knowticed_plus/features/grc/grc5_control/domain/entities/control_frequency.dart';
import 'package:knowticed_plus/features/grc/grc5_control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/grc6_control_champion/data/models/champion_model.dart';
import 'package:knowticed_plus/features/grc/grc6_control_champion/domain/entities/champion_status.dart';
import 'package:knowticed_plus/features/grc/grc7_control_owner/data/models/owner_model.dart';
import 'package:knowticed_plus/features/grc/grc7_control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/grc7_control_owner/domain/entities/owner_status.dart';
import 'package:knowticed_plus/features/grc/helpers/constants/grc_firebase_paths.dart';
import 'package:knowticed_plus/features/grc/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_grc_data.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

/// Collects every write in batches of at most 400 operations.
class _Writer {
  _Writer(this._fs);

  final FirebaseFirestore _fs;
  final List<WriteBatch> _batches = <WriteBatch>[];
  int _inLast = 0;
  int count = 0;

  WriteBatch batch([int need = 1]) {
    if (_batches.isEmpty || _inLast + need > 400) {
      _batches.add(_fs.batch());
      _inLast = 0;
    }
    _inLast += need;
    count += need;
    return _batches.last;
  }

  void set(
      DocumentReference<Map<String, dynamic>> ref, Map<String, dynamic> data) {
    batch().set(ref, data);
  }

  Future<int> commit() async {
    for (final WriteBatch b in _batches) {
      await b.commit();
    }
    return count;
  }
}

/// One evidence submission with its decisions.
class _Sub {
  _Sub(this.kind, this.index);

  /// A B C D E F (see the library comment).
  final String kind;
  final int index;
  late DateTime firstSubmitted;
  late DateTime submitted;
  DateTime? rejectedAt;
  late DateTime managerAt;
  late DateTime ownerAt;
  late DateTime scoredAt;
  bool resub = false;
  late String doc1;
  late String doc2;
  late Bi note1;
  late Bi note2;
  late Bi managerReject;
  late Bi managerApprove;
  late Bi ownerReject;
  late Bi justification;
}

/// One control and everything the screens read about it.
class _Ctl {
  _Ctl(this.id, this.policyId, this.name, this.number, this.slot, this.status);

  final String id;
  final String policyId;
  final Bi name;
  final String number;
  final String slot;
  ControlStatus status;
  int ci = 0;
  String frequency = 'Monthly';
  late DateTime created;
  late DateTime start;
  late DateTime end;
  List<String> depts = <String>[];
  double weight = 100;
  int score = 0;
  DateTime? scoreDate;
  String? champion;
  String? owner;
  String? manager;
  bool noScore = false;
  _Sub? sub;
  String? prevChampion;
  String? prevOwner;
  DateTime? reassignAt;
  bool reassignChampion = true;
}

class _Pol {
  _Pol(this.id, this.spec, this.index);

  final String id;
  final GrcPolicySpec spec;
  final int index;
  late DateTime created;
  late DateTime start;
  late DateTime end;
  double weight = 0;
  double score = 0;
  String number = '';
  String? docEn;
  String? docAr;
  final List<_Ctl> controls = <_Ctl>[];

  bool get scoped =>
      spec.kind == GrcPolicyKind.active || spec.kind == GrcPolicyKind.scheduled;
}

/// A stretch during which one person holds one control.
class _Iv {
  _Iv(this.policyId, this.controlId, this.start, this.end);

  final String policyId;
  final String controlId;
  final DateTime start;
  final DateTime? end;
}

abstract final class ShowcaseGrc {
  /// Writes the GRC showcase and returns the number of documents written.
  static Future<int> seed({
    required FirebaseFirestore firestore,
    required ShowcasePerson me,
    required bool isArabic,
    required DateTime now,
  }) async {
    final _Gen gen = _Gen(fs: firestore, me: me, isArabic: isArabic, now: now);
    gen.run();
    return gen.w.commit();
  }
}

class _Gen {
  _Gen({
    required this.fs,
    required this.me,
    required this.isArabic,
    required this.now,
  })  : w = _Writer(fs),
        y = now.year,
        meEmail =
            currentGrcUserEmail().isNotEmpty ? currentGrcUserEmail() : me.email,
        depts = _departments(isArabic) {
    others = <String>[
      for (final ShowcasePerson p in ShowcaseCommon.people)
        if (p.email.isNotEmpty &&
            p.email.toLowerCase() != me.email.toLowerCase() &&
            p.email.toLowerCase() != meEmail.toLowerCase())
          p.email,
    ];
    if (others.isEmpty) others = <String>['reviewer@bayanatz.com'];
  }

  final FirebaseFirestore fs;
  final ShowcasePerson me;
  final bool isArabic;
  final DateTime now;
  final _Writer w;
  final int y;
  final String meEmail;
  final List<String> depts;
  late List<String> others;

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  // ── small helpers ────────────────────────────────────────────────────
  static List<String> _departments(bool isArabic) {
    try {
      if (Get.isRegistered<MainCoreDepartmentCubit>()) {
        final MainCoreDepartmentCubit c = Get.find<MainCoreDepartmentCubit>();
        final List<String> names =
            isArabic ? c.departmentsArabicName : c.departmentsEnglishName;
        final List<String> clean = <String>[
          for (final String n in names)
            if (n.trim().isNotEmpty) n.trim(),
        ];
        if (clean.length >= 3) return clean.take(8).toList();
      }
    } catch (_) {
      // Fall through to the built-in names.
    }
    return <String>[
      for (final Bi d in GrcShowcaseData.fallbackDepartments) d.of(isArabic),
    ];
  }

  String em(int i) => others[i % others.length];

  int idxOf(String email) {
    final int i = ShowcaseCommon.people
        .indexWhere((ShowcasePerson p) => p.email == email);
    return i < 0 ? 0 : i;
  }

  static int _r(int a, int b, int mod) {
    int h = (a * 73856093) ^ (b * 19349663) ^ 0x5bd1e995;
    h = (h ^ (h >> 13)) * 1274126177;
    h = h ^ (h >> 16);
    return h.abs() % mod;
  }

  DateTime d(int m, int day, [int yearOffset = 0]) =>
      DateTime(y + yearOffset, m, day);

  DateTime only(DateTime t) => DateTime(t.year, t.month, t.day);

  DateTime past(DateTime t) {
    final DateTime limit = now.subtract(const Duration(days: 1));
    return t.isAfter(limit) ? limit : t;
  }

  DateTime plus(DateTime t, int days) => t.add(Duration(days: days));

  String doc(String folder, String file) =>
      'https://firebasestorage.googleapis.com/v0/b/knowticed-v2-scheme.firebasestorage.app/o/'
      '$folder%2F${DateTime(y).millisecondsSinceEpoch + _r(file.length, 3, 9000000) * 1000}_$file?alt=media';

  String slug(String s) => s
      .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  CollectionReference<Map<String, dynamic>> col(String path) =>
      fs.collection(path);

  // ═══════════════════════════════════════════════════════════════════
  // Entry
  // ═══════════════════════════════════════════════════════════════════
  void run() {
    for (int mi = 0; mi < GrcShowcaseData.modules.length; mi++) {
      module(mi, GrcShowcaseData.modules[mi]);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // One module
  // ═══════════════════════════════════════════════════════════════════
  void module(int mi, GrcModuleSpec s) {
    final String moduleId = ShowcaseCommon.id('grc_module', mi + 1);
    final DateTime created = d(s.createdMonth, s.createdDay);
    final DateTime activation = s.activationMonth != null
        ? d(s.activationMonth!, s.activationDay!, s.activationNextYear ? 1 : 0)
        : plus(created, 4);

    final List<_Pol> pols = <_Pol>[
      for (int k = 0; k < s.policies.length; k++)
        policy(mi, k, s, created, activation),
    ];
    distributePolicyWeights(pols);

    final List<_Ctl> ctls = s.isFull
        ? fullControls(mi, s, pols, created)
        : lightControls(mi, s, pols, created);
    for (final _Ctl c in ctls) {
      pols.firstWhere((_Pol p) => p.id == c.policyId).controls.add(c);
    }
    for (final _Pol p in pols) {
      distributeControlWeights(p);
    }
    final List<_Ctl> reassigned = <_Ctl>[];
    if (s.isFull) {
      planReassignments(mi, s, ctls, reassigned);
      for (final _Ctl c in ctls) {
        buildSubmission(mi, c, ctls);
      }
    }
    for (final _Pol p in pols) {
      p.score = policyScore(p);
    }
    final double moduleScore = pols
        .where((_Pol p) => p.scoped)
        .fold<double>(0, (double a, _Pol p) => a + p.score);

    writeModule(mi, s, moduleId, created, activation, moduleScore);
    for (final _Pol p in pols) {
      writePolicy(mi, moduleId, p, s);
      for (final _Ctl c in p.controls) {
        writeControl(mi, moduleId, p, c);
      }
    }
    writeAssignees(mi, moduleId, ctls, created);
    if (s.isFull) {
      writeSubmissions(mi, moduleId, ctls);
      writeRequests(mi, s, moduleId, ctls);
      writeDepartmentThreads(mi, moduleId, pols, ctls, created);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Policies
  // ═══════════════════════════════════════════════════════════════════
  _Pol policy(int mi, int k, GrcModuleSpec s, DateTime moduleCreated,
      DateTime activation) {
    final GrcPolicySpec spec = s.policies[k];
    final _Pol p =
        _Pol(ShowcaseCommon.id('grc_m${mi + 1}_pol', k + 1), spec, k);
    p.number = '${s.code}-P-${(k + 1).toString().padLeft(3, '0')}';
    switch (spec.kind) {
      case GrcPolicyKind.active:
        p.created = past(plus(moduleCreated, 2 + k % 4));
        p.start = s.kind == GrcModuleKind.scheduled ? activation : d(1, 1);
        p.end = d(12, 31, 1);
      case GrcPolicyKind.inactive:
        p.created = past(plus(moduleCreated, 3 + k % 5));
        p.start = d(1, 1);
        p.end = d(12, 31, 1);
      case GrcPolicyKind.expired:
        p.created = past(plus(moduleCreated, 4 + k % 5));
        p.start = d(1, 1, -1);
        p.end = <DateTime>[d(3, 31), d(6, 30), d(9, 15)][k % 3];
      case GrcPolicyKind.scheduled:
        final DateTime base =
            s.kind == GrcModuleKind.scheduled ? activation : d(11, 15 + k % 10);
        p.start = base;
        p.end = DateTime(base.year + 2, base.month, base.day)
            .subtract(const Duration(days: 1));
        final DateTime c = DateTime(y, 9, 4 + k % 12);
        p.created =
            past(c.isBefore(moduleCreated) ? plus(moduleCreated, 1) : c);
      case GrcPolicyKind.draft:
        p.start = d(1, 1, 1);
        p.end = d(12, 31, 1);
        final DateTime c = DateTime(y, 10, 1 + k % 12);
        p.created =
            past(c.isBefore(moduleCreated) ? plus(moduleCreated, 1) : c);
    }
    if (p.created.isBefore(moduleCreated)) p.created = plus(moduleCreated, 1);
    if (spec.kind != GrcPolicyKind.draft) {
      final bool en = (mi + k) % 7 != 3;
      final bool ar = (mi + k) % 11 != 5;
      final String file = slug(spec.name.en);
      p.docEn = en ? doc('Policies_Files', '${file}_EN.pdf') : null;
      p.docAr = ar ? doc('Policies_Files', '${file}_AR.pdf') : null;
      if (!en && !ar) p.docEn = doc('Policies_Files', '${file}_EN.pdf');
    }
    return p;
  }

  void distributePolicyWeights(List<_Pol> pols) {
    // New (scheduled) policies carry a small weight until they are running,
    // so they do not pull the module score down before they start.
    final List<_Pol> scoped = pols.where((_Pol p) => p.scoped).toList();
    final List<_Pol> running = scoped
        .where((_Pol p) => p.spec.kind != GrcPolicyKind.scheduled)
        .toList();
    final List<_Pol> upcoming = scoped
        .where((_Pol p) => p.spec.kind == GrcPolicyKind.scheduled)
        .toList();
    if (running.isEmpty) {
      for (final _Pol p in upcoming) {
        p.weight = (100 ~/ upcoming.length).toDouble();
      }
      if (upcoming.isNotEmpty) {
        upcoming.last.weight +=
            (100 - (100 ~/ upcoming.length) * upcoming.length).toDouble();
      }
    } else {
      final int each = upcoming.isEmpty
          ? 0
          : (upcoming.length >= 4 ? 2 : (upcoming.length >= 2 ? 3 : 4));
      for (final _Pol p in upcoming) {
        p.weight = each.toDouble();
      }
      final int left = 100 - each * upcoming.length;
      final int base = left ~/ running.length;
      final int rem = left - base * running.length;
      for (int i = 0; i < running.length; i++) {
        running[i].weight = (base + (i < rem ? 1 : 0)).toDouble();
      }
    }
    for (final _Pol p in pols) {
      if (!p.scoped) p.weight = 5;
    }
  }

  void distributeControlWeights(_Pol p) {
    const Set<ControlStatus> scoped = <ControlStatus>{
      ControlStatus.active,
      ControlStatus.scheduled,
      ControlStatus.unassigned,
    };
    final List<_Ctl> inScope =
        p.controls.where((_Ctl c) => scoped.contains(c.status)).toList();
    if (inScope.isNotEmpty) {
      final int base = 100 ~/ inScope.length;
      final int rem = 100 - base * inScope.length;
      for (int i = 0; i < inScope.length; i++) {
        inScope[i].weight = (base + (i < rem ? 1 : 0)).toDouble();
      }
    }
    for (final _Ctl c in p.controls) {
      if (!scoped.contains(c.status)) c.weight = 100;
    }
  }

  double policyScore(_Pol p) {
    const Set<ControlStatus> scoped = <ControlStatus>{
      ControlStatus.active,
      ControlStatus.scheduled,
      ControlStatus.unassigned,
    };
    double grade = 0;
    for (final _Ctl c in p.controls) {
      if (scoped.contains(c.status)) grade += c.score * c.weight / 100;
    }
    return double.parse((grade * p.weight / 100).toStringAsFixed(2));
  }

  // ═══════════════════════════════════════════════════════════════════
  // Controls
  // ═══════════════════════════════════════════════════════════════════
  int baseScore(int mi, int ci) {
    final int key = mi * 1000 + ci;
    if (_r(key, 1, 100) < 9) return 36 + _r(key, 2, 13);
    return 60 + _r(key, 3, 36);
  }

  Bi controlName(GrcModuleSpec s, int n) => GrcShowcaseData
      .controls[(s.controlOffset + n) % GrcShowcaseData.controls.length];

  _Ctl newControl(int mi, GrcModuleSpec s, _Pol pol, int ci, String slot) {
    final ControlStatus status = switch (slot) {
      'un' => ControlStatus.unassigned,
      'sc' => ControlStatus.scheduled,
      'dr' => ControlStatus.draft,
      'in' => ControlStatus.inactive,
      'ex' => ControlStatus.expired,
      _ => ControlStatus.active,
    };
    final _Ctl c = _Ctl(
      ShowcaseCommon.id('grc_m${mi + 1}_ctl', ci + 1),
      pol.id,
      controlName(s, ci),
      '${s.code}-C-${(ci + 1).toString().padLeft(3, '0')}',
      slot,
      status,
    )..ci = ci;
    c.frequency = ControlFrequency.values[_r(mi * 1000 + ci, 7, 6)].value;

    // Window.
    switch (slot) {
      case 'cH':
        c.start = d(10, 1);
        c.end = d(11, 30);
      case 'cI':
      case 'oG':
        c.start = d(8, 1);
        c.end = d(9, 30);
      case 'sc':
        c.start = d(11, 15);
        c.end = d(11, 14, 1);
      case 'dr':
        c.start = d(1, 1, 1);
        c.end = d(12, 31, 1);
      case 'ex':
        c.start = d(1, 1, -1);
        c.end = <DateTime>[d(3, 31), d(6, 30), d(9, 15)][ci % 3];
      default:
        c.start = d(1, 1);
        c.end = d(12, 31);
    }

    // Created, on a small grid after the module (or after the policy).
    final List<int> grid =
        mi == 0 ? const <int>[6, 12, 20, 28] : const <int>[6, 25, 50, 75];
    final DateTime mc = d(s.createdMonth, s.createdDay);
    if (slot == 'sc' || slot == 'dr') {
      c.created = past(plus(pol.created, 1 + ci % 3));
    } else {
      c.created = past(plus(mc, grid[ci % 4]));
    }
    if (c.created.isBefore(pol.created)) c.created = plus(pol.created, 1);

    // Departments.
    final int nd = depts.length;
    final int b = (ci + mi) % nd;
    c.depts = <String>[depts[b]];
    if (ci % 4 == 0 && nd > 3) c.depts.add(depts[(b + 3) % nd]);

    // People.
    switch (slot) {
      case 'cH':
      case 'cA':
      case 'cB':
      case 'cC':
      case 'cD':
      case 'cE':
      case 'cI':
        c.champion = meEmail;
        c.owner = em(ci % 3);
        c.manager = em(1 + ci % 2);
      case 'oC':
      case 'oD':
      case 'oE':
      case 'oF':
      case 'oG':
        c.owner = meEmail;
        c.champion = em(3 + ci % 5);
        c.manager = meEmail;
      case 'gD':
      case 'gE':
        c.owner = em(0);
        c.champion = em(3 + (ci + 2) % 5);
        c.manager = em(1 + ci % 2);
        c.noScore = true;
      case 'bg':
      case 'sc':
      case 'in':
      case 'ex':
        c.champion = em(3 + ci % 5);
        c.owner = em(ci % 3);
    }

    // Score of the current cycle.
    switch (c.status) {
      case ControlStatus.active:
        c.score = baseScore(mi, ci);
      case ControlStatus.inactive:
        c.score = 55 + _r(mi * 1000 + ci, 4, 25);
      case ControlStatus.expired:
        c.score = 68 + _r(mi * 1000 + ci, 5, 22);
      case ControlStatus.scheduled:
        // Carried over from the previous cycle.
        c.score = 58 + _r(mi * 1000 + ci, 6, 28);
      case ControlStatus.draft:
      case ControlStatus.unassigned:
        c.score = 0;
    }
    return c;
  }

  List<_Ctl> fullControls(
      int mi, GrcModuleSpec s, List<_Pol> pols, DateTime created) {
    final List<_Pol> active =
        pols.where((_Pol p) => p.spec.kind == GrcPolicyKind.active).toList();
    const List<String> order = <String>[
      'cH',
      'cA',
      'cB',
      'cC',
      'cD',
      'cE',
      'cI',
      'oC',
      'oD',
      'oE',
      'oF',
      'oG',
      'gD',
      'gE',
      'bg',
      'un',
    ];
    int maxCount = 0;
    for (final int v in s.slots.values) {
      if (v > maxCount) maxCount = v;
    }
    final List<String> slotList = <String>[];
    for (int r = 0; r < maxCount; r++) {
      for (final String k in order) {
        if (r < (s.slots[k] ?? 0)) slotList.add(k);
      }
    }
    final List<_Ctl> out = <_Ctl>[];
    int ci = 0;
    for (int i = 0; i < slotList.length; i++) {
      out.add(newControl(mi, s, active[i % active.length], ci++, slotList[i]));
    }
    for (final _Pol p in pols) {
      final String? slot = switch (p.spec.kind) {
        GrcPolicyKind.scheduled => 'sc',
        GrcPolicyKind.draft => 'dr',
        GrcPolicyKind.inactive => 'in',
        GrcPolicyKind.expired => 'ex',
        GrcPolicyKind.active => null,
      };
      if (slot != null) out.add(newControl(mi, s, p, ci++, slot));
    }
    return out;
  }

  List<_Ctl> lightControls(
      int mi, GrcModuleSpec s, List<_Pol> pols, DateTime created) {
    final List<_Ctl> out = <_Ctl>[];
    int ci = 0;
    for (int k = 0; k < pols.length; k++) {
      final int count = k == 0 ? 2 : 1;
      for (int j = 0; j < count; j++) {
        final String slot = switch (pols[k].spec.kind) {
          GrcPolicyKind.scheduled => 'sc',
          GrcPolicyKind.draft => 'dr',
          GrcPolicyKind.inactive => 'in',
          GrcPolicyKind.expired => 'ex',
          GrcPolicyKind.active => 'bg',
        };
        final _Ctl c = newControl(mi, s, pols[k], ci++, slot);
        c.depts = <String>[depts[s.departmentIndex % depts.length]];
        out.add(c);
      }
    }
    return out;
  }

  // ═══════════════════════════════════════════════════════════════════
  // Reassignments (they become approved requests and assignment history)
  // ═══════════════════════════════════════════════════════════════════
  void planReassignments(
      int mi, GrcModuleSpec s, List<_Ctl> ctls, List<_Ctl> out) {
    final List<_Ctl> bg = ctls.where((_Ctl c) => c.slot == 'bg').toList();
    final int n =
        s.requestsPerStatus < bg.length ? s.requestsPerStatus : bg.length;
    for (int k = 0; k < n; k++) {
      final _Ctl c = bg[k];
      c.reassignChampion = k.isEven;
      c.reassignAt = past(plus(c.created, 25 + (k * 9) % 30));
      if (c.reassignChampion) {
        c.prevChampion = c.champion;
        String next = em(3 + (c.ci + 2) % 5);
        if (next == c.champion) next = em(3 + (c.ci + 3) % 5);
        c.champion = next;
      } else {
        c.prevOwner = c.owner;
        String next = em((c.ci + 1) % 3);
        if (next == c.owner) next = em((c.ci + 2) % 3);
        c.owner = next;
      }
      out.add(c);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Evidence submissions
  // ═══════════════════════════════════════════════════════════════════
  static const Map<String, String> _kindOfSlot = <String, String>{
    'cA': 'A',
    'cB': 'B',
    'cC': 'C',
    'cD': 'D',
    'cE': 'E',
    'oC': 'C',
    'oD': 'D',
    'oE': 'E',
    'oF': 'F',
    'gD': 'D',
    'gE': 'E',
  };

  void buildSubmission(int mi, _Ctl c, List<_Ctl> all) {
    final String? kind = _kindOfSlot[c.slot];
    if (kind == null) return;
    final int i = all.indexOf(c);
    final _Sub s = _Sub(kind, i);
    final int key = mi * 1000 + i;
    final DateTime latest = now.subtract(const Duration(days: 16));
    if (kind == 'A') {
      s.submitted =
          DateTime(now.year, now.month, now.day, 8 + i % 8, (i * 17) % 60)
              .subtract(Duration(days: 3 + (i * 5) % 25));
    } else {
      final DateTime from = plus(c.created, kind == 'E' ? 9 : 5);
      // Spread over the months of the year (clamped to what is possible).
      final int month = 1 + (i * 3 + mi) % 10;
      DateTime at = DateTime(y, month, 3 + (i * 11) % 22);
      if (at.isBefore(from)) at = plus(from, i % 4);
      if (at.isAfter(latest)) at = plus(latest, -(i % 5));
      s.submitted =
          DateTime(at.year, at.month, at.day, 8 + i % 8, (i * 17) % 60);
    }
    s.resub = kind == 'E' && i % 3 == 0;
    s.firstSubmitted = s.resub ? plus(s.submitted, -3) : s.submitted;
    s.rejectedAt = s.resub ? plus(s.submitted, -2) : null;
    s.managerAt = plus(s.submitted, 1 + i % 3);
    s.ownerAt = plus(s.managerAt, 1 + i % 4);
    s.scoredAt = plus(s.ownerAt, 1 + i % 2);
    final String file = slug(c.name.en);
    final String mon = _months[s.submitted.month - 1];
    final String ext = <String>['pdf', 'pdf', 'xlsx', 'docx'][i % 4];
    s.doc1 = doc('Assignment_Controls_Files',
        s.resub ? '${file}_v1_$mon.$ext' : '${file}_$mon.$ext');
    s.doc2 = doc('Assignment_Controls_Files', '${file}_v2_$mon.$ext');
    s.note1 = GrcShowcaseData.submissionNotes[_r(key, 21, 8)];
    s.note2 = GrcShowcaseData.submissionNotes[(_r(key, 21, 8) + 5) % 8];
    s.managerReject = GrcShowcaseData.managerRejections[_r(key, 22, 6)];
    s.managerApprove = GrcShowcaseData.managerApprovals[_r(key, 23, 5)];
    s.ownerReject = GrcShowcaseData.ownerRejections[_r(key, 24, 5)];
    s.justification = GrcShowcaseData.scoreJustifications[_r(key, 25, 8)];
    c.sub = s;
    if (kind == 'E') c.scoreDate = s.scoredAt;
  }

  // ═══════════════════════════════════════════════════════════════════
  // Writers: module, policy, control
  // ═══════════════════════════════════════════════════════════════════
  List<String> moduleOwnersFor(int mi, GrcModuleSpec s, int rev, int revs) {
    if (!s.isFull) return <String>[em(mi)];
    switch (mi) {
      case 0:
        return rev == 0 ? <String>[meEmail] : <String>[meEmail, em(0)];
      case 1:
        if (rev == 0) return <String>[em(0)];
        return rev == revs - 1 ? <String>[meEmail] : <String>[em(0), meEmail];
      case 2:
        return rev == 0 ? <String>[em(1)] : <String>[meEmail];
      default:
        return <String>[meEmail];
    }
  }

  void writeModule(int mi, GrcModuleSpec s, String moduleId, DateTime created,
      DateTime activation, double finalScore) {
    final List<DateTime> dates = <DateTime>[created];
    if (s.kind == GrcModuleKind.removed) {
      dates.add(d(s.removedMonth!, 12));
    } else if (s.isFull) {
      for (final DateTime t in <DateTime>[
        plus(created, 10),
        d(3, 31),
        d(6, 30),
        d(9, 30),
      ]) {
        if (t.isAfter(dates.last) &&
            !t.isAfter(now.subtract(const Duration(days: 1)))) {
          dates.add(t);
        }
      }
    } else {
      dates.add(past(plus(created, 20 + mi % 9)));
    }
    final int n = dates.length;
    final double top = s.kind == GrcModuleKind.removed
        ? 0
        : double.parse(finalScore.toStringAsFixed(2));
    String statusAt(int i) {
      switch (s.kind) {
        case GrcModuleKind.active:
          return GrcModuleStatus.active.value;
        case GrcModuleKind.scheduled:
          return GrcModuleStatus.scheduled.value;
        case GrcModuleKind.inactive:
          return i == n - 1
              ? GrcModuleStatus.inactive.value
              : GrcModuleStatus.active.value;
        case GrcModuleKind.removed:
          return i == n - 1
              ? GrcModuleStatus.removed.value
              : GrcModuleStatus.active.value;
      }
    }

    final String dept = depts[s.departmentIndex % depts.length];
    final GRCModuleModel model = GRCModuleModel(
      moduleId: moduleId,
      moduleImage: List<String?>.filled(n, null),
      moduleNameEn: List<String>.filled(n, s.name.en),
      moduleNameAr: List<String>.filled(n, s.name.ar),
      moduleDescriptionEn: List<String>.filled(n, s.description.en),
      moduleDescriptionAr: List<String>.filled(n, s.description.ar),
      moduleOwningDepartment: List<String>.filled(n, dept),
      moduleActivationDate: List<DateTime>.filled(n, activation),
      moduleOwners: <String>[
        for (int i = 0; i < n; i++) jsonEncode(moduleOwnersFor(mi, s, i, n)),
      ],
      status: <String>[for (int i = 0; i < n; i++) statusAt(i)],
      score: <double>[
        for (int i = 0; i < n; i++)
          i == 0 || !s.isFull
              ? (i == n - 1 ? top : 0)
              : double.parse(
                  (top * (0.55 + 0.45 * (i / (n - 1)))).toStringAsFixed(2)),
      ],
      modificationDate: dates,
      modifiers: <String>[
        for (int i = 0; i < n; i++) i.isEven ? meEmail : em(0)
      ],
    );
    w.set(
        col(GrcFirebasePaths.modulesCollection).doc(moduleId), model.toJson());
  }

  List<DateTime> revisionDates(DateTime first, int n, int gap) {
    final List<DateTime> out = <DateTime>[first];
    for (int i = 1; i < n; i++) {
      final DateTime t = plus(first, gap * i);
      if (t.isAfter(now.subtract(const Duration(days: 1)))) break;
      out.add(t);
    }
    return out;
  }

  void writePolicy(int mi, String moduleId, _Pol p, GrcModuleSpec s) {
    final bool major = p.spec.kind == GrcPolicyKind.active ||
        p.spec.kind == GrcPolicyKind.inactive ||
        p.spec.kind == GrcPolicyKind.expired;
    final List<DateTime> dates =
        revisionDates(p.created, major ? 4 : 2, major ? 45 : 7);
    final int n = dates.length;
    final String statusValue = switch (p.spec.kind) {
      GrcPolicyKind.active => PolicyStatus.active.value,
      GrcPolicyKind.scheduled => PolicyStatus.scheduled.value,
      GrcPolicyKind.draft => PolicyStatus.draft.value,
      GrcPolicyKind.inactive => PolicyStatus.inactive.value,
      GrcPolicyKind.expired => PolicyStatus.expired.value,
    };
    final Bi desc =
        GrcShowcaseData.policyDescriptions[_r(mi * 100 + p.index, 31, 4)];
    final bool weightMoved = n >= 2 && p.scoped && p.index % 3 == 1;
    final PolicyModel model = PolicyModel(
      id: p.id,
      moduleId: moduleId,
      policyImage: List<String?>.filled(n, null),
      policyNameEn: List<String>.filled(n, p.spec.name.en),
      policyNameAr: List<String>.filled(n, p.spec.name.ar),
      policyNumberEn: List<String>.filled(n, p.number),
      policyNumberAr: List<String>.filled(n, p.number),
      policyDescriptionEn: List<String>.filled(n, desc.en),
      policyDescriptionAr: List<String>.filled(n, desc.ar),
      startDate: List<DateTime>.filled(n, p.start),
      endDate: List<DateTime>.filled(n, p.end),
      policyWeight: <double>[
        for (int i = 0; i < n; i++)
          weightMoved && i == 0 ? p.weight + 5 : p.weight,
      ],
      policyDocumentEn: <String?>[
        for (int i = 0; i < n; i++) i == 0 && n > 1 ? null : p.docEn,
      ],
      policyDocumentAr: <String?>[
        for (int i = 0; i < n; i++) i == 0 && n > 1 ? null : p.docAr,
      ],
      status: <String>[
        for (int i = 0; i < n; i++)
          p.spec.kind == GrcPolicyKind.active && i == 0 && n > 2
              ? PolicyStatus.draft.value
              : statusValue,
      ],
      score: <double>[
        for (int i = 0; i < n; i++)
          i == n - 1
              ? p.score
              : double.parse(
                  (p.score * (0.6 + 0.4 * (i / (n - 1)))).toStringAsFixed(2)),
      ],
      lastModifiedDate: dates,
      editors: <String>[for (int i = 0; i < n; i++) i.isEven ? meEmail : em(0)],
    );
    w.set(col(GrcFirebasePaths.moduleSub(moduleId, 'Policies')).doc(p.id),
        model.toJson());
  }

  void writeControl(int mi, String moduleId, _Pol p, _Ctl c) {
    // Revision dates.
    final List<DateTime> dates = <DateTime>[c.created];
    switch (c.status) {
      case ControlStatus.draft:
        break;
      case ControlStatus.scheduled:
        dates.add(past(plus(c.created, 12)));
      case ControlStatus.inactive:
      case ControlStatus.expired:
        final int stop = c.status == ControlStatus.expired
            ? c.end.month
            : (c.created.month + 3).clamp(1, 9);
        for (int m = c.created.month + 1; m <= stop; m++) {
          dates.add(DateTime(y, m, 4 + (c.ci * 3 + m * 5) % 17));
        }
        dates.add(plus(dates.last, 6));
      case ControlStatus.active:
      case ControlStatus.unassigned:
        for (int m = c.created.month + 1; m <= now.month; m++) {
          int day = 4 + (c.ci * 3 + m * 5) % 17;
          if (m == now.month && day > now.day - 1) day = now.day - 1;
          dates.add(DateTime(y, m, day < 1 ? 1 : day));
        }
    }
    final DateTime? sd = c.scoreDate;
    if (sd != null) {
      dates.removeWhere((DateTime t) => t.isAfter(sd));
      if (dates.last != sd) dates.add(sd);
    }
    final List<DateTime> fixed = <DateTime>[dates.first];
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].isAfter(fixed.last)) fixed.add(dates[i]);
    }
    final int n = fixed.length;

    final int slope = 1 + _r(mi * 1000 + c.ci, 5, 3);
    int scoreAt(int i) {
      if (i == n - 1) return c.score;
      if (c.score == 0) return 0;
      final int wobble = i.isEven ? 0 : _r(mi * 1000 + c.ci, i, 5) - 2;
      return (c.score - (n - 1 - i) * slope + wobble).clamp(5, 100);
    }

    String statusAt(int i) {
      final ControlStatus fin = c.status;
      if ((fin == ControlStatus.active || fin == ControlStatus.unassigned) &&
          i == 0 &&
          n >= 3) {
        return ControlStatus.draft.value;
      }
      return fin.value;
    }

    final bool weightMoved =
        n >= 4 && c.ci % 6 == 2 && c.status == ControlStatus.active;
    final Bi desc =
        GrcShowcaseData.controlDescriptions[_r(mi * 1000 + c.ci, 41, 3)];
    final String descEn = desc.en.replaceFirst('%', c.name.en);
    final String descAr = desc.ar.replaceFirst('%', c.name.ar);

    final ControlModel model = ControlModel(
      id: c.id,
      policyId: c.policyId,
      controlsNameEn: List<String>.filled(n, c.name.en),
      controlsNameAr: List<String>.filled(n, c.name.ar),
      controlsNumberEn: List<String>.filled(n, c.number),
      controlsNumberAr: List<String>.filled(n, c.number),
      controlsDescriptionEn: List<String>.filled(n, descEn),
      controlsDescriptionAr: List<String>.filled(n, descAr),
      controlsDocumentEn: List<String?>.filled(n, null),
      controlsDocumentAr: List<String?>.filled(n, null),
      controlsWeight: <double>[
        for (int i = 0; i < n; i++)
          weightMoved && i < 2
              ? (c.weight > 4 ? c.weight - 3 : c.weight + 3)
              : c.weight,
      ],
      frequency: List<String>.filled(n, c.frequency),
      startDate: List<DateTime>.filled(n, c.start),
      endDate: List<DateTime>.filled(n, c.end),
      departments: List<List<DepartmentWeight>>.filled(
          n, DepartmentWeight.equalSplit(c.depts)),
      equalWeights: List<bool>.filled(n, true),
      score: <int>[for (int i = 0; i < n; i++) scoreAt(i)],
      status: <String>[for (int i = 0; i < n; i++) statusAt(i)],
      lastModifiedDate: fixed,
      editors: <String>[
        for (int i = 0; i < n; i++) i == 0 || i % 3 != 0 ? meEmail : em(0),
      ],
    );
    w.set(col(GrcFirebasePaths.controlsOf(moduleId, p.id)).doc(c.id),
        model.toJson());
  }

  // ═══════════════════════════════════════════════════════════════════
  // Champions and owners (one document per person, with their history)
  // ═══════════════════════════════════════════════════════════════════
  void writeAssignees(
      int mi, String moduleId, List<_Ctl> ctls, DateTime moduleCreated) {
    final Map<String, List<_Iv>> champions = <String, List<_Iv>>{};
    final Map<String, List<_Iv>> owners = <String, List<_Iv>>{};
    final Set<String> noScore = <String>{};
    for (final _Ctl c in ctls) {
      final DateTime start = only(plus(c.created, 1));
      void add(Map<String, List<_Iv>> m, String? person, DateTime from,
          DateTime? to) {
        if (person == null) return;
        m
            .putIfAbsent(person, () => <_Iv>[])
            .add(_Iv(c.policyId, c.id, from, to));
      }

      final DateTime? t = c.reassignAt == null ? null : only(c.reassignAt!);
      add(champions, c.prevChampion, start, t);
      add(champions, c.champion, c.prevChampion != null ? t! : start, null);
      add(owners, c.prevOwner, start, t);
      add(owners, c.owner, c.prevOwner != null ? t! : start, null);
      if (c.noScore) noScore.add('${c.policyId}/${c.id}');
    }

    champions.forEach((String email, List<_Iv> ivs) {
      final List<DateTime> dates = boundaries(ivs);
      final List<List<AssigningControlModel>> revs =
          <List<AssigningControlModel>>[
        for (final DateTime t in dates) heldAt(ivs, t),
      ];
      if (revs.last.isEmpty) return;
      final ChampionModel model = ChampionModel(
        championEmail: email,
        assigningControls: revs,
        status: List<String>.filled(dates.length, ChampionStatus.active.value),
        modificationDate: dates,
        modifiers: List<String>.filled(dates.length, meEmail),
      );
      w.set(
          col(GrcFirebasePaths.moduleSub(moduleId, 'Control Champions'))
              .doc(email),
          model.toJson());
    });

    owners.forEach((String email, List<_Iv> ivs) {
      final List<DateTime> dates = boundaries(ivs);
      final List<List<AssigningControlModel>> revs =
          <List<AssigningControlModel>>[
        for (final DateTime t in dates) heldAt(ivs, t),
      ];
      if (revs.last.isEmpty) return;
      final OwnerModel model = OwnerModel(
        ownerEmail: email,
        assigningControls: revs,
        status: List<String>.filled(dates.length, OwnerStatus.active.value),
        // Exactly one entry per control of the latest revision.
        controlOwnerPermissions: <List<String>>[
          for (final AssigningControlModel a in revs.last)
            noScore.contains('${a.policyId}/${a.controlId}')
                ? <String>[kOwnerScoreByModuleOwner]
                : <String>[],
        ],
        modificationDate: dates,
        modifiers: List<String>.filled(dates.length, meEmail),
      );
      w.set(
          col(GrcFirebasePaths.moduleSub(moduleId, 'Control Owners'))
              .doc(email),
          model.toJson());
    });
  }

  List<DateTime> boundaries(List<_Iv> ivs) {
    final Set<DateTime> set = <DateTime>{};
    for (final _Iv i in ivs) {
      set.add(i.start);
      if (i.end != null) set.add(i.end!);
    }
    final List<DateTime> out = set.toList()..sort();
    return out;
  }

  List<AssigningControlModel> heldAt(List<_Iv> ivs, DateTime t) =>
      <AssigningControlModel>[
        for (final _Iv i in ivs)
          if (!i.start.isAfter(t) && (i.end == null || t.isBefore(i.end!)))
            AssigningControlModel(policyId: i.policyId, controlId: i.controlId),
      ];

  // ═══════════════════════════════════════════════════════════════════
  // Submissions: assignment control, approval, my audit, threads
  // ═══════════════════════════════════════════════════════════════════
  void writeSubmissions(int mi, String moduleId, List<_Ctl> ctls) {
    final String acPath =
        GrcFirebasePaths.moduleSub(moduleId, 'Assignment Controls');
    final String apPath = GrcFirebasePaths.moduleSub(moduleId, 'Approvals');
    final String auPath = GrcFirebasePaths.moduleSub(moduleId, 'My Audit');
    for (final _Ctl c in ctls) {
      final _Sub? s = c.sub;
      if (s == null) continue;
      final String id = '${c.id}_${c.champion}';
      w.set(col(acPath).doc(id), assignmentModel(c, s, id).toJson());
      w.set(col(apPath).doc(id), approvalModel(c, s, id).toJson());
      if (s.kind != 'A' && s.kind != 'B') {
        w.set(col(auPath).doc(id), auditModel(c, s, id).toJson());
      }
      // Approval inquiries: every pending and rejected one, one in three of
      // the rest.
      if (s.kind == 'A' || s.kind == 'B' || s.index % 3 == 0) {
        final List<Bi> lines = GrcShowcaseData.approvalThreads[
            (s.index + mi) % GrcShowcaseData.approvalThreads.length];
        ShowcaseCommon.addThread(
          batch: w.batch(lines.length),
          firestore: fs,
          collectionPath: '$apPath/$id/Inquiries',
          filterFields: const <String, dynamic>{},
          threadKey: 'grc_m${mi + 1}_ap_${s.index.toString().padLeft(3, '0')}',
          lines: lines,
          speakers: <int>[idxOf(c.manager ?? meEmail), idxOf(c.champion!)],
          start: s.submitted.add(const Duration(hours: 3)),
          isArabic: isArabic,
        );
      }
      // My Audit inquiries: every audited control of the signed-in owner.
      if (c.owner == meEmail && s.kind != 'A' && s.kind != 'B') {
        final List<Bi> lines = GrcShowcaseData
            .auditThreads[(s.index + mi) % GrcShowcaseData.auditThreads.length];
        ShowcaseCommon.addThread(
          batch: w.batch(lines.length),
          firestore: fs,
          collectionPath:
              '${GrcFirebasePaths.modulesCollection}/$moduleId/My_Audit_Inquiries',
          filterFields: <String, dynamic>{
            'Policy_ID': c.policyId,
            'Control_ID': c.id,
            'Champion_Email': c.champion,
          },
          threadKey: 'grc_m${mi + 1}_au_${s.index.toString().padLeft(3, '0')}',
          lines: lines,
          speakers: <int>[0, idxOf(c.champion!)],
          start: s.managerAt.add(const Duration(hours: 5)),
          isArabic: isArabic,
        );
      }
    }
  }

  AssignmentControlModel assignmentModel(_Ctl c, _Sub s, String id) {
    final String champ = c.champion!;
    final String mgr = c.manager ?? meEmail;
    final String own = c.owner ?? meEmail;
    final List<String> status = <String>[];
    final List<String> docs = <String>[];
    final List<String> notes = <String>[];
    final List<String> modifier = <String>[];
    final List<DateTime> at = <DateTime>[];
    final List<String?> reasons = <String?>[];
    final List<double?> scores = <double?>[];
    final List<String?> justs = <String?>[];
    String curDoc = '';
    String curNote = '';
    String? curReason;
    String? curJust;
    double? curScore;
    void add(AssignmentControlStatus st, DateTime when, String by,
        {String? docUrl,
        String? note,
        String? reason,
        String? just,
        double? score}) {
      if (docUrl != null) curDoc = docUrl;
      if (note != null) curNote = note;
      if (reason != null) curReason = reason;
      if (just != null) curJust = just;
      if (score != null) curScore = score;
      status.add(st.value);
      docs.add(curDoc);
      notes.add(curNote);
      modifier.add(by);
      at.add(when);
      reasons.add(curReason);
      scores.add(curScore);
      justs.add(curJust);
    }

    final bool ar = isArabic;
    add(AssignmentControlStatus.submitted, s.firstSubmitted, champ,
        docUrl: s.doc1, note: s.note1.of(ar));
    switch (s.kind) {
      case 'B':
        add(AssignmentControlStatus.rejected, s.managerAt, mgr,
            reason: s.managerReject.of(ar));
      case 'C':
      case 'D':
        add(AssignmentControlStatus.inReview, s.managerAt, mgr);
      case 'E':
        if (s.resub) {
          add(AssignmentControlStatus.rejected, s.rejectedAt!, mgr,
              reason: s.managerReject.of(ar));
          add(AssignmentControlStatus.submitted, s.submitted, champ,
              docUrl: s.doc2, note: s.note2.of(ar));
        }
        add(AssignmentControlStatus.inReview, s.managerAt, mgr);
        add(AssignmentControlStatus.approved, s.scoredAt, own,
            just: s.justification.of(ar), score: c.score.toDouble());
      case 'F':
        add(AssignmentControlStatus.inReview, s.managerAt, mgr);
        add(AssignmentControlStatus.rejected, s.ownerAt, own,
            reason: s.ownerReject.of(ar));
    }
    final int n = status.length;
    return AssignmentControlModel(
      submissionId: id,
      controlChampionEmail: champ,
      policyId: c.policyId,
      controlId: c.id,
      controlOwner: c.owner,
      departmentManager: c.manager,
      submissionDocument: docs,
      submissionNote: notes,
      status: status,
      modifier: modifier,
      modificationDate: at,
      departmentManagerRejectionReasons: reasons,
      controlScore: scores,
      controlOwnerJustifications: justs,
      controlOwnerRejectionReasons: List<String?>.filled(n, null),
    );
  }

  ApprovalModel approvalModel(_Ctl c, _Sub s, String id) {
    final String champ = c.champion!;
    final String mgr = c.manager ?? meEmail;
    final bool ar = isArabic;
    final List<String> status = <String>[];
    final List<String?> reasons = <String?>[];
    final List<String?> comments = <String?>[];
    final List<String> modifier = <String>[];
    final List<DateTime> at = <DateTime>[];
    String? curReason;
    String? curComment;
    void add(ApprovalStatus st, DateTime when, String by,
        {String? reason, String? comment}) {
      if (reason != null) curReason = reason;
      if (comment != null) curComment = comment;
      status.add(st.value);
      reasons.add(curReason);
      comments.add(curComment);
      modifier.add(by);
      at.add(when);
    }

    add(ApprovalStatus.pending, s.firstSubmitted, champ);
    switch (s.kind) {
      case 'B':
        add(ApprovalStatus.rejected, s.managerAt, mgr,
            reason: s.managerReject.of(ar));
      case 'E':
        if (s.resub) {
          add(ApprovalStatus.rejected, s.rejectedAt!, mgr,
              reason: s.managerReject.of(ar));
          add(ApprovalStatus.pending, s.submitted, champ);
        }
        add(ApprovalStatus.approved, s.managerAt, mgr,
            comment: s.managerApprove.of(ar));
      case 'C':
      case 'D':
      case 'F':
        add(ApprovalStatus.approved, s.managerAt, mgr,
            comment: s.managerApprove.of(ar));
    }
    return ApprovalModel(
      requestId: id,
      submissionId: id,
      status: status,
      reasonsOfRejection: reasons,
      approvalComments: comments,
      modifier: modifier,
      modificationDate: at,
    );
  }

  MyAuditModel auditModel(_Ctl c, _Sub s, String id) {
    final String mgr = c.manager ?? meEmail;
    final String own = c.owner ?? meEmail;
    final bool ar = isArabic;
    final List<String> status = <String>[];
    final List<double?> scores = <double?>[];
    final List<String?> justs = <String?>[];
    final List<String?> rejects = <String?>[];
    final List<String> modifier = <String>[];
    final List<DateTime> at = <DateTime>[];
    double? curScore;
    String? curJust;
    String? curReject;
    void add(MyAuditStatus st, DateTime when, String by,
        {double? score, String? just, String? reject}) {
      if (score != null) curScore = score;
      if (just != null) curJust = just;
      if (reject != null) curReject = reject;
      status.add(st.value);
      scores.add(curScore);
      justs.add(curJust);
      rejects.add(curReject);
      modifier.add(by);
      at.add(when);
    }

    add(MyAuditStatus.pending, s.managerAt, mgr);
    switch (s.kind) {
      case 'D':
        add(MyAuditStatus.outstanding, s.ownerAt, own);
      case 'E':
        add(MyAuditStatus.outstanding, s.ownerAt, own);
        add(MyAuditStatus.scored, s.scoredAt, own,
            score: c.score.toDouble(), just: s.justification.of(ar));
      case 'F':
        add(MyAuditStatus.rejected, s.ownerAt, own,
            reject: s.ownerReject.of(ar));
    }
    return MyAuditModel(
      auditId: id,
      requestId: id,
      submissionId: id,
      status: status,
      controlScore: scores,
      controlOwnerJustifications: justs,
      controlOwnerReasonsOfRejection: rejects,
      modifier: modifier,
      modificationDate: at,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Reassignment requests
  // ═══════════════════════════════════════════════════════════════════
  void writeRequests(
      int mi, GrcModuleSpec s, String moduleId, List<_Ctl> ctls) {
    final int n = s.requestsPerStatus;
    if (n == 0) return;
    final List<_Ctl> reassigned =
        ctls.where((_Ctl c) => c.reassignAt != null).toList();
    final List<_Ctl> pool = ctls
        .where((_Ctl c) =>
            c.reassignAt == null &&
            (c.slot == 'gD' || c.slot == 'gE' || c.slot == 'bg'))
        .toList();
    if (pool.isEmpty) return;
    final CollectionReference<Map<String, dynamic>> coll =
        col(GrcFirebasePaths.moduleSub(moduleId, 'Requests'));
    int seq = 1;
    String other(String current, int seed) {
      for (int t = 0; t < others.length; t++) {
        final String cand = others[(seed + t) % others.length];
        if (cand != current) return cand;
      }
      return current;
    }

    void put({
      required String status,
      required bool champion,
      required String current,
      required String next,
      required _Ctl ctl,
      required String requestedBy,
      required DateTime requestDate,
      required Bi note,
      DateTime? decisionDate,
      String? decidedBy,
      String? rejection,
      DateTime? startDate,
      DateTime? endDate,
      DateTime? appliedAt,
    }) {
      final String id = ShowcaseCommon.id('grc_m${mi + 1}_req', seq++);
      final GrcRequestModel m = GrcRequestModel(
        id: id,
        moduleId: moduleId,
        type: champion
            ? GrcRequestType.reassignChampion.value
            : GrcRequestType.reassignOwner.value,
        status: status,
        requestedBy: requestedBy,
        requestDate: requestDate,
        note: note.of(isArabic),
        rejectionReason: rejection,
        decidedBy: decidedBy,
        decisionDate: decisionDate,
        currentChampionEmail: champion ? current : null,
        newChampionEmail: champion ? next : null,
        currentOwnerEmail: champion ? null : current,
        newOwnerEmail: champion ? null : next,
        controls: <AssigningControlModel>[
          AssigningControlModel(policyId: ctl.policyId, controlId: ctl.id),
        ],
        startDate: startDate,
        endDate: endDate,
        appliedAt: appliedAt,
      );
      w.set(coll.doc(id), m.toJson());
    }

    final String coOwner = mi == 0 ? em(0) : meEmail;
    String by(int k, String current) => mi == 0 && k < 5 ? meEmail : current;
    String decider(String requestedBy) =>
        requestedBy == meEmail ? coOwner : meEmail;

    // Approved: the reassignments that are already in the assignment history.
    for (int k = 0; k < n && k < reassigned.length; k++) {
      final _Ctl c = reassigned[k];
      final DateTime start = only(c.reassignAt!);
      final String next = c.reassignChampion ? c.champion! : c.owner!;
      final String current =
          c.reassignChampion ? c.prevChampion! : c.prevOwner!;
      final String requestedBy = by(k, current);
      put(
        status: 'approved',
        champion: c.reassignChampion,
        current: current,
        next: next,
        ctl: c,
        requestedBy: requestedBy,
        requestDate: plus(start, -6),
        note: GrcShowcaseData.requestNotes[(k + mi) % 6],
        decisionDate: plus(start, -3),
        decidedBy: decider(requestedBy),
        startDate: start,
        endDate: k % 3 == 2 ? plus(start, 120) : null,
        appliedAt: start,
      );
    }
    // Pending, rejected and canceled.
    for (int st = 0; st < 3; st++) {
      for (int k = 0; k < n; k++) {
        final _Ctl c = pool[(k * 3 + st * 2) % pool.length];
        final bool champion = (k + st).isEven;
        final String current = champion ? c.champion! : c.owner!;
        final String next = other(current, k + st * 3 + 1);
        final Bi note = GrcShowcaseData.requestNotes[(k + st * 2 + mi) % 6];
        if (st == 0) {
          final String requestedBy = by(k, current);
          final DateTime start = plus(only(now), 4 + k % 10);
          put(
            status: 'pending',
            champion: champion,
            current: current,
            next: next,
            ctl: c,
            requestedBy: requestedBy,
            requestDate: now.subtract(Duration(days: 2 + (k * 3) % 14)),
            note: note,
            startDate: start,
            endDate: k.isEven ? plus(start, 90) : null,
          );
        } else if (st == 1) {
          final String requestedBy = by(k, current);
          final DateTime requested =
              DateTime(y, 2 + (k * 2) % 8, 6 + (k * 5) % 18);
          put(
            status: 'rejected',
            champion: champion,
            current: current,
            next: next,
            ctl: c,
            requestedBy: requestedBy,
            requestDate: requested,
            note: note,
            decisionDate: plus(requested, 2),
            decidedBy: decider(requestedBy),
            rejection: GrcShowcaseData.requestRejections[k % 3].of(isArabic),
            startDate: plus(requested, 9),
          );
        } else {
          final DateTime requested =
              DateTime(y, 3 + (k * 3) % 7, 4 + (k * 7) % 20);
          put(
            status: 'canceled',
            champion: champion,
            current: current,
            next: next,
            ctl: c,
            requestedBy: meEmail,
            requestDate: requested,
            note: note,
            decisionDate: plus(requested, 1),
            decidedBy: meEmail,
            startDate: plus(requested, 10),
          );
        }
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Reporting and audit: department inquiries
  // ═══════════════════════════════════════════════════════════════════
  void writeDepartmentThreads(int mi, String moduleId, List<_Pol> pols,
      List<_Ctl> ctls, DateTime created) {
    final String path =
        '${GrcFirebasePaths.modulesCollection}/$moduleId/Department_Inquiries';
    int seq = 0;
    void thread(
        String department, String policyId, String controlId, int speaker) {
      final List<Bi> lines = GrcShowcaseData.departmentThreads[
          (seq + mi) % GrcShowcaseData.departmentThreads.length];
      final DateTime start = DateTime(y, 3 + (seq * 2) % 7, 3 + (seq * 5) % 24,
          9 + seq % 6, (seq * 13) % 60);
      ShowcaseCommon.addThread(
        batch: w.batch(lines.length),
        firestore: fs,
        collectionPath: path,
        filterFields: <String, dynamic>{
          'Department': department,
          'Policy_ID': policyId,
          'Control_ID': controlId,
        },
        threadKey: 'grc_m${mi + 1}_dp_${seq.toString().padLeft(2, '0')}',
        lines: lines,
        speakers: <int>[0, speaker],
        start:
            start.isAfter(now) ? now.subtract(const Duration(days: 20)) : start,
        isArabic: isArabic,
      );
      seq++;
    }

    // The default view (all departments, no policy, no control).
    thread('All', '', '', idxOf(em(0)));
    for (int k = 0; k < depts.length && k < (mi == 0 ? 6 : 3); k++) {
      thread(depts[k], '', '', idxOf(em(2 + k)));
    }
    final List<_Pol> active =
        pols.where((_Pol p) => p.spec.kind == GrcPolicyKind.active).toList();
    for (int k = 0; k < active.length && k < (mi == 0 ? 5 : 2); k++) {
      thread('All', active[k].id, '', idxOf(em(k + 3)));
      if (active[k].controls.isNotEmpty) {
        thread(
            'All', active[k].id, active[k].controls.first.id, idxOf(em(k + 4)));
      }
    }
  }
}

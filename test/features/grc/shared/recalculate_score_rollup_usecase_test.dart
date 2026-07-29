import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/shared/use_cases/recalculate_score_rollup_usecase.dart';

ControlEntity _control({
  required int score,
  required double weight,
  ControlStatus status = ControlStatus.active,
}) {
  final now = DateTime.now();
  return ControlEntity(
    id: 'c',
    policyId: 'p',
    controlsNameEn: 'c',
    controlsNameAr: 'c',
    controlsNumberEn: 'c',
    controlsNumberAr: 'c',
    controlsDescriptionEn: 'd',
    controlsDescriptionAr: 'd',
    controlsDocumentEn: null,
    controlsDocumentAr: null,
    controlsWeight: weight,
    frequency: 'Monthly',
    startDate: now,
    endDate: now,
    departments: const [],
    equalWeights: true,
    score: score,
    status: status,
    lastModifiedDate: now,
    lastEditor: 'editor@x.com',
  );
}

PolicyEntity _policy({
  required double score,
  required double weight,
  PolicyStatus status = PolicyStatus.active,
}) {
  final now = DateTime.now();
  return PolicyEntity(
    id: 'p',
    moduleId: 'm',
    policyImage: null,
    policyNameEn: 'p',
    policyNameAr: 'p',
    policyNumberEn: 'p',
    policyNumberAr: 'p',
    policyDescriptionEn: 'd',
    policyDescriptionAr: 'd',
    startDate: now,
    endDate: now,
    policyWeight: weight,
    policyDocumentEn: null,
    policyDocumentAr: null,
    status: status,
    score: score,
    lastModifiedDate: now,
    lastEditor: 'editor@x.com',
  );
}

void main() {
  group('computePolicyScore', () {
    test('matches the reported real-world scenario: one Control at 100% '
        'weight, Policy at 30% of its Module', () {
      final controls = [_control(score: 80, weight: 100)];
      expect(computePolicyScore(controls, 30), 24);
    });

    test('multi-control Policy grade is weighted by the Policy\'s own share',
        () {
      final controls = [
        _control(score: 80, weight: 50),
        _control(score: 100, weight: 25),
        _control(score: 60, weight: 25),
      ];
      // Controls-only grade is 80 (40+25+15); at 25% Policy weight -> 20.
      expect(computePolicyScore(controls, 25), 20);
    });

    test('a Policy weighted at 100% reproduces the plain Controls grade', () {
      final controls = [
        _control(score: 80, weight: 50),
        _control(score: 100, weight: 25),
        _control(score: 60, weight: 25),
      ];
      expect(computePolicyScore(controls, 100), 80);
    });

    test('excludes Draft controls', () {
      final controls = [
        _control(score: 80, weight: 50),
        _control(score: 100, weight: 25),
        _control(score: 999, weight: 25, status: ControlStatus.draft),
      ];
      // Controls grade excluding Draft: 40+25=65; at 50% Policy weight -> 32.5.
      expect(computePolicyScore(controls, 50), 32.5);
    });

    test('excludes Inactive and Expired controls, matching '
        'hasControlWeightIssue\'s weight-scoped statuses', () {
      final controls = [
        _control(score: 80, weight: 50),
        _control(score: 100, weight: 25),
        _control(score: 999, weight: 25, status: ControlStatus.inactive),
        _control(score: 999, weight: 25, status: ControlStatus.expired),
      ];
      expect(computePolicyScore(controls, 100), 65);
    });

    test('includes Unassigned controls', () {
      final controls = [
        _control(score: 80, weight: 50),
        _control(score: 100, weight: 25),
        _control(score: 60, weight: 25, status: ControlStatus.unassigned),
      ];
      expect(computePolicyScore(controls, 100), 80);
    });

    test('empty list yields 0 regardless of Policy weight', () {
      expect(computePolicyScore(const [], 30), 0);
    });
  });

  group('computeModuleScore', () {
    test('sums Policy scores directly, matching the reported real-world '
        'scenario (Policy.score is already its own weighted share)', () {
      final policies = [_policy(score: 24, weight: 30)];
      expect(computeModuleScore(policies), 24);
    });

    test('sums multiple already-weighted Policy scores without applying '
        'policyWeight again', () {
      final policies = [
        _policy(score: 20, weight: 25),
        _policy(score: 25, weight: 25),
        _policy(score: 30, weight: 50),
      ];
      expect(computeModuleScore(policies), 75);
    });

    test('excludes everything except Active/Scheduled', () {
      final policies = [
        _policy(score: 20, weight: 25),
        _policy(score: 25, weight: 25, status: PolicyStatus.scheduled),
        _policy(score: 999, weight: 50, status: PolicyStatus.draft),
      ];
      expect(computeModuleScore(policies), 20 + 25);
    });

    test('empty list yields 0', () {
      expect(computeModuleScore(const []), 0);
    });
  });
}

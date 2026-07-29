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
    test('matches the worked example from the design spec', () {
      final controls = [
        _control(score: 80, weight: 50),
        _control(score: 100, weight: 25),
        _control(score: 60, weight: 25),
      ];
      expect(computePolicyScore(controls), 80);
    });

    test('excludes Draft controls', () {
      final controls = [
        _control(score: 80, weight: 50),
        _control(score: 100, weight: 25),
        _control(score: 999, weight: 25, status: ControlStatus.draft),
      ];
      expect(computePolicyScore(controls), 40 + 25);
    });

    test('empty list yields 0', () {
      expect(computePolicyScore(const []), 0);
    });
  });

  group('computeModuleScore', () {
    test('matches the worked example from the design spec', () {
      final policies = [
        _policy(score: 80, weight: 25),
        _policy(score: 100, weight: 25),
        _policy(score: 60, weight: 50),
      ];
      expect(computeModuleScore(policies), 75);
    });

    test('excludes everything except Active/Scheduled', () {
      final policies = [
        _policy(score: 80, weight: 25),
        _policy(score: 100, weight: 25, status: PolicyStatus.scheduled),
        _policy(score: 999, weight: 50, status: PolicyStatus.draft),
      ];
      expect(computeModuleScore(policies), 20 + 25);
    });

    test('empty list yields 0', () {
      expect(computeModuleScore(const []), 0);
    });
  });
}

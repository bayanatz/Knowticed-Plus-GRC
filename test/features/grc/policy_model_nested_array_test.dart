import 'package:demo_app/features/grc/data/models/control_model.dart';
import 'package:demo_app/features/grc/data/models/policy_model.dart';
import 'package:demo_app/features/grc/domain/entities/policy_status.dart';
import 'package:flutter_test/flutter_test.dart';

/// Firestore rejects any value where a List's direct elements are
/// themselves Lists (nested arrays), even if those inner Lists eventually
/// contain Maps. This walks a JSON-like structure and fails as soon as it
/// finds an array directly inside another array.
void expectNoNestedArrays(dynamic value, {String path = r'$'}) {
  if (value is List) {
    for (var i = 0; i < value.length; i++) {
      final item = value[i];
      expect(
        item is List,
        isFalse,
        reason: 'Nested array found at $path[$i] — Firestore does not '
            'support an array directly containing another array.',
      );
      expectNoNestedArrays(item, path: '$path[$i]');
    }
  } else if (value is Map) {
    value.forEach((key, v) => expectNoNestedArrays(v, path: '$path.$key'));
  }
}

void main() {
  test('PolicyModel.toJson() must not produce Firestore nested arrays', () {
    final control = ControlModel.create(
      id: 'c1',
      controlsNameEn: 'Control 1',
      controlsNameAr: 'التحكم 1',
      controlsDescriptionEn: 'desc',
      controlsDescriptionAr: 'وصف',
      controlsDocument: 'doc.pdf',
      controlsWeight: 1.0,
      frequency: 'monthly',
      editorId: 'editor-1',
    );

    final policy = PolicyModel.create(
      id: 'p1',
      moduleId: 'module-1',
      image: 'image.png',
      policyNameEn: 'Policy 1',
      policyNameAr: 'سياسة 1',
      policyNumberEn: 'P-1',
      policyNumberAr: 'س-1',
      policyDescriptionEn: 'desc',
      policyDescriptionAr: 'وصف',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
      policyWeight: 1.0,
      policyDocument: 'doc.pdf',
      controls: [control],
      status: PolicyStatus.draft,
      editorId: 'editor-1',
    );

    expectNoNestedArrays(policy.toJson());
  });

  test('PolicyModel round-trips through toJson/fromJson', () {
    final control = ControlModel.create(
      id: 'c1',
      controlsNameEn: 'Control 1',
      controlsNameAr: 'التحكم 1',
      controlsDescriptionEn: 'desc',
      controlsDescriptionAr: 'وصف',
      controlsDocument: 'doc.pdf',
      controlsWeight: 1.0,
      frequency: 'monthly',
      editorId: 'editor-1',
    );

    final policy = PolicyModel.create(
      id: 'p1',
      moduleId: 'module-1',
      image: 'image.png',
      policyNameEn: 'Policy 1',
      policyNameAr: 'سياسة 1',
      policyNumberEn: 'P-1',
      policyNumberAr: 'س-1',
      policyDescriptionEn: 'desc',
      policyDescriptionAr: 'وصف',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
      policyWeight: 1.0,
      policyDocument: 'doc.pdf',
      controls: [control],
      status: PolicyStatus.draft,
      editorId: 'editor-1',
    ).copyWithUpdate(
      controls: [control, control],
      editorId: 'editor-2',
    );

    final rebuilt = PolicyModel.fromJson(policy.toJson());

    expect(rebuilt.controls.length, policy.controls.length);
    expect(rebuilt.controls[0].length, policy.controls[0].length);
    expect(rebuilt.controls[1].length, policy.controls[1].length);
    expect(rebuilt.controls[1][0].id, control.id);
    expect(rebuilt.controls[1][0].controlsNameEn.last, 'Control 1');
  });
}

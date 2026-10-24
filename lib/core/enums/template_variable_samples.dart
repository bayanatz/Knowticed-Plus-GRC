/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: template_variable_samples.dart
/// Purpose: Placeholder values for demo / test data.
/// Author: Knowticed Plus team
/// Created at: 27/9/2026
///
/// Every notification and calendar event asserts that a value is supplied for
/// each `{{placeholder}}` it declares. The "Apply all modules" demo seeder
/// sends EVERY event, so it needs a believable value for ANY variable without
/// a hand-written map per event. [sampleValue] derives one from the key:
/// dates become a real date, counts a number, names and documents a
/// real-looking value (see `realistic`).
library;

import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';

extension TemplateVariableSample on TemplateVariable {
  /// A believable demo value for this placeholder.
  String sampleValue({DateTime? now}) {
    final DateTime today = now ?? DateTime.now();
    final String k = key;
    final String lower = k.toLowerCase();

    if (lower.contains('date')) {
      // 22/10/2026: "granted" / "submission" dates are in the past ("You were
      // given this role on …"), the rest two weeks ahead.
      final int shift = lower.startsWith('old')
          ? 0
          : (lower.contains('granted') || lower.contains('submission'))
              ? -7
              : 14;
      return DateFormat('dd/MM/yyyy', 'en')
          .format(today.add(Duration(days: shift)));
    }
    if (k == 'time') return DateFormat('hh:mm a', 'en').format(today);
    if (k == 'minutes') return '15';
    if (lower.contains('count')) return '3';
    if (lower.contains('score')) return lower.startsWith('old') ? '70' : '85';
    if (lower.contains('weight')) return lower.startsWith('old') ? '10' : '20';
    if (lower.contains('status')) {
      return lower.startsWith('old') ? 'Pending' : 'Approved';
    }
    if (k == 'channel') return 'Email';
    if (k == 'permissionLevel') return 'Editor';

    // 22/10/2026 (Moataz: "Demo Employee asked to update Demo Document" is not
    // something to show a client): real-looking values for the placeholders a
    // card is likely to print, before the generic fallback below.
    const Map<String, String> realistic = <String, String>{
      'employeeName': 'Noura Al-Qahtani',
      'requesterName': 'Khalid Al-Otaibi',
      'approverName': 'Faisal Al-Harbi',
      'userName': 'Reem Al-Shehri',
      'recipientName': 'Sara Al-Dosari',
      'senderName': 'Omar Al-Zahrani',
      'ownerName': 'Lama Al-Mutairi',
      'controlChampionName': 'Noura Al-Qahtani',
      'controlOwnerName': 'Faisal Al-Harbi',
      'currentChampionName': 'Noura Al-Qahtani',
      'newChampionName': 'Omar Al-Zahrani',
      'newOwnerName': 'Lama Al-Mutairi',
      'departmentManagerName': 'Khalid Al-Otaibi',
      'uploadedByUserName': 'Reem Al-Shehri',
      'addedByName': 'Khalid Al-Otaibi',
      'removedByName': 'Khalid Al-Otaibi',
      'createdByName': 'Noura Al-Qahtani',
      'deletedByName': 'Faisal Al-Harbi',
      'voterName': 'Sara Al-Dosari',
      'cancelledBy': 'Khalid Al-Otaibi',
      'departmentName': 'Data Governance and Quality',
      'documentName': 'Data Governance Policy 2026',
      'policyName': 'Data Retention Policy',
      'controlName': 'Data Classification Control',
      'oldControlName': 'Data Classification Control',
      'newControlName': 'Data Classification and Labelling',
      'moduleName': 'Data Governance',
      'frameworkName': 'National Data Management Framework',
      'formName': 'Media Accreditation Request',
      'serviceName': 'Dataset Publication Request',
      'toDoName': 'Prepare the quarterly data quality report',
      'groupName': 'Data Stewards',
      'oldGroupName': 'Data Stewards',
      'newGroupName': 'Data Governance Team',
      'chatName': 'Data Governance Team',
      'databaseName': 'Citizen Services Statistics',
      'tableName': 'Monthly Volumes',
      'columnName': 'Completion Time',
      'fileName': 'Quality Scorecard Q3.pdf',
      'companyName': 'Bayanatz',
      'roleName': 'Department Manager',
      'permissionName': 'Export Reports',
      'optionName': 'Option A',
      'pollQuestion': 'Which day suits the data council meeting?',
      'messagePreview': 'Please review the updated policy before Sunday.',
      'feedbackType': 'Comment',
      'requestType': 'Leave Request',
      'rejectionReason': 'The attached document does not match the request.',
      'requestStatus': 'Approved',
    };
    final String? known = realistic[k];
    if (known != null) return known;

    // camelCase -> "Demo Service" / "Demo Rejection Reason".
    final String words = k
        .replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .split(' ')
        .where((w) => w.toLowerCase() != 'name')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
    return words;
  }
}

extension TemplateVariableSampleSet on Iterable<TemplateVariable> {
  /// `{variable: sampleValue}` for every placeholder in this set.
  Map<TemplateVariable, String> toSampleValues({DateTime? now}) => {
        for (final TemplateVariable v in this) v: v.sampleValue(now: now),
      };
}

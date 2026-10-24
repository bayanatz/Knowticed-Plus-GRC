/// Module: services / sv3_create_master_services / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: step2_validation_texts.dart
/// Purpose: Builds the translated Step 2 cell messages that the master
///          upload cubit returns (Create R3: the cubit has no BuildContext
///          and no hardcoded English texts).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

import 'package:flutter/widgets.dart';
import 'package:knowticed_plus/features/services/sv3_create_master_services/data/models/master_upload_models.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [step2ValidationTexts]
///
/// Purpose: The Step 2 cell messages in the reader's language.
Step2ValidationMessages step2ValidationTexts(BuildContext context) {
  final s = S.of(context);
  return Step2ValidationMessages(
    required: s.required,
    invalidEmailFormat: s.invalidEmailFormat,
    emailDoesNotExist: s.emailDoesNotExist,
    emailsCommaSeparated: s.emailsCommaSeparated,
    commaAtStartOrEnd: s.commaAtStartOrEnd,
    emptyEmail: s.emptyEmail,
    invalidState: s.svcUploadInvalidState,
    invalidRequestedDate: s.svcUploadInvalidRequestedDate,
  );
}

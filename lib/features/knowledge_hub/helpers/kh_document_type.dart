/// Module: knowledge_hub/data/utils
///
///*************************** FILE INFO ****************************///
/// File Name: kh_document_type.dart
/// Description: A stored document type key (e.g. `video_recording`) as text
///              in the UI language, from the translation files.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'package:flutter/widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class KhDocumentType {
  const KhDocumentType._();

  /// [type] in the UI language; an unknown type is shown as stored.
  static String label(BuildContext context, String type) {
    final S s = S.of(context);
    switch (type.toLowerCase().replaceAll(' ', '_')) {
      case 'presentation':
        return s.presentation;
      case 'form':
        return s.form;
      case 'report':
        return s.report;
      case 'booklet':
        return s.booklet;
      case 'video_recording':
        return s.khDocTypeVideoRecording;
      case 'letter':
        return s.letter;
      case 'mandate':
        return s.mandate;
      case 'policy':
        return s.policy;
      case 'frame_work':
        return s.khDocTypeFrameWork;
      case 'workshop':
        return s.khDocTypeWorkshop;
      case 'guidelines':
        return s.guidelines;
      case 'other':
        return s.other;
      default:
        return type;
    }
  }
}

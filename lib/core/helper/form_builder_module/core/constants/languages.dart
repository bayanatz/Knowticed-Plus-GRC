// Objectives: This file is responsible for providing the translations of the application.
// Available languages now --> English, Arabic

import 'package:get/get.dart';

part 'package:demo_app/core/helper/form_builder_module/core/constants/languages_enUS1.dart';
part 'package:demo_app/core/helper/form_builder_module/core/constants/languages_enUS2.dart';
part 'package:demo_app/core/helper/form_builder_module/core/constants/languages_arEG1.dart';
part 'package:demo_app/core/helper/form_builder_module/core/constants/languages_arEG2.dart';

class FormBuilderLanguages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {..._enUS1, ..._enUS2},
        'ar_EG': {..._arEG1, ..._arEG2},
      };
}

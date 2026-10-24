/// Module: form_builder_module/presentation
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_router.dart
/// Description: `FormBuilderRouter`, the one route table of the Form
///              Builder's nested Navigator, built from the [Routes]
///              constants (Share rule 5). Each route also provides the
///              cubits only its page uses.
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/constants/app_routes.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/ui/pages/home_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/pages/form_editor_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb3_form_details/presentation/controller/form_details_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb3_form_details/presentation/ui/pages/form_details_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/presentation/ui/pages/submissions_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/pages/result_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/pages/uploaded_media_page.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/pages/share_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/controller/pdf_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/ui/pages/convert_pdf_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb7_convert_pdf/presentation/utils/pdf_page_keys.dart';
import 'package:knowticed_plus/features/form_builder/form_builder_get_it.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// The arguments of [Routes.submissionsScreen] when the form is opened to be
/// filled out from its details page.
typedef FillOutRouteArgs = ({FormEntity model, bool isFillMode});

/// The one route table of the Form Builder's nested Navigator.
class FormBuilderRouter {
  const FormBuilderRouter._();

  /// The nested Navigator's initial route (the Form Builder home). Kept
  /// here, so `Routes` in core stays as it is.
  static const String initialRoute = '/';

  /// Method Name: [onGenerateRoute]
  ///
  /// Purpose: builds the page of a named route.
  ///
  /// Parameters:
  /// - [settings]: the route name and its arguments.
  ///
  /// Returns: the route; an error page for an unknown name.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
      case Routes.home:
      case null:
        return _page(settings, const FormBuilderHomeScreen());

      case Routes.formDetailsScreen:
        final FormEntity form = settings.arguments as FormEntity;
        return _page(
          settings,
          _withPdf(
            form,
            BlocProvider<FormDetailsCubit>(
              create: (context) => FormDetailsCubit(
                form: form,
                homeCubit: context.read<HomeCubit>(),
              ),
              child: FormDetailsScreen(model: form),
            ),
          ),
        );

      // Create a form, or edit / restore one (phone and tablet).
      case Routes.create:
        return _page(
          settings,
          FormEditorScreen(formModel: settings.arguments as FormEntity?),
        );

      case Routes.resultScreen:
        return _page(
          settings,
          ResultScreen(form: settings.arguments as FormEntity),
        );

      case Routes.submissionsScreen:
        final Object? args = settings.arguments;
        if (args is FillOutRouteArgs) {
          return _page(
            settings,
            FormSubmissionsScreen(
              model: args.model,
              isFillMode: args.isFillMode,
            ),
          );
        }
        return _page(
          settings,
          FormSubmissionsScreen(model: args as FormEntity),
        );

      case Routes.shareScreen:
        return _page(
          settings,
          FormShareScreen(form: settings.arguments as FormEntity),
        );

      case Routes.convertPdf:
        final FormEntity form = settings.arguments as FormEntity;
        return _page(
          settings,
          _withPdf(form, ConvertPdfScreen(formModel: form)),
        );

      // FB-SHARE-02: "Uploaded Documents" is a route of this router too.
      case Routes.uploadedMediaPage:
        return _page(settings, const UploadedMediaPage());

      default:
        return _page(settings, _UnknownRoutePage(name: settings.name));
    }
  }

  static MaterialPageRoute<dynamic> _page(
    RouteSettings settings,
    Widget page,
  ) => MaterialPageRoute<dynamic>(settings: settings, builder: (_) => page);

  /// [child] with its own PdfCubit and page keys, opened for [form]'s pages.
  static Widget _withPdf(FormEntity form, Widget child) {
    return RepositoryProvider<PdfPageKeys>(
      create: (_) => PdfPageKeys()..reset(form.pages.length),
      child: BlocProvider<PdfCubit>(
        create: (_) => FormBuilderCubits.pdf()..initialize(form.pages.length),
        child: child,
      ),
    );
  }
}

/// Shown for a route name the router does not know.
class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).error),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: withHaptic(
            () => Navigator.of(context).pop(),
            HapticLevel.low,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.red),
            const SizedBox(height: 16),
            Text(
              S.of(context).routeNotFound,
              style: StyleText.fontSize18Weight600,
            ),
            const SizedBox(height: 8),
            Text(name ?? '', style: StyleText.fontSize14Weight400),
            const SizedBox(height: 24),
            customButton(
              title: S.of(context).goBack,
              function: () => Navigator.of(context).pop(),
              wrapContent: true,
            ),
          ],
        ),
      ),
    );
  }
}

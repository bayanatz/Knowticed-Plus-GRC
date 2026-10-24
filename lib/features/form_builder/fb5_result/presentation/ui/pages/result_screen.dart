/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: result_screen.dart
/// Description: `ResultScreen` page, state and UI of the `ResultScreen` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_log_service.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_no_permission.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/pages/analytics_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/pages/user_screen.dart';

import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder/helpers/breadcrumb_nav.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/switch_card_widget.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_title_padding.dart';
import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';

/// The Results page of a form (Users or Analytics). Shows the notices the ResultCubit emits.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    FormBuilderLogService.log(FormBuilderLogService.actionViewFormResults);
    // FB-FILL-05: the cubit no longer receives a ticker; the Users view owns
    // its own TabController.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResultCubit>().initialize(widget.form);
    });
  }

  /// Shows a [ResultNotice] the cubit emitted (export outcome, department
  /// warning). Dialogs belong to the page, not the cubit.
  Future<void> _showNotice(BuildContext context, ResultNotice notice) async {
    switch (notice.type) {
      case ResultNoticeType.exported:
        AppDialogs.downloadingExcelSuccessfully(context);
        break;
      case ResultNoticeType.exportFailed:
        await CustomDialogManager.showMessage(
          context: context,
          lottiePath: AppAssets.lottieWarning,
          title: S.of(context).exportFailed,
          subtitle: notice.message,
        );
        break;
      case ResultNoticeType.warning:
        await AppDialogs.showError(context, notice.message);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // One header for both form factors, drawn by
    // SideFrameMasterServices, replacing the CustomAppBar / PaginationAppBar
    // pair. The phone title was also wrong: it said "Fill Out Form" on the
    // Result screen. The crumbs move out of the ResultLoaded branch so the
    // header survives the loading and error states.
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).detailsOfTitle(widget.form.getTitle),
        thirdTitle: S.of(context).result,
        onFirstTap: breadcrumbPop(context, 2),
        onSecondTap: breadcrumbPop(context, 1),
        child: SingleChildScrollView(
          child: BlocConsumer<ResultCubit, ResultState>(
            listenWhen: (previous, current) =>
                current is ResultLoaded &&
                current.notice != null &&
                (previous is! ResultLoaded ||
                    previous.notice?.id != current.notice!.id),
            listener: (context, state) =>
                _showNotice(context, (state as ResultLoaded).notice!),
            builder: (context, state) {
              if (state is ResultLoading) {
                return const CircleProgressMaster();
              }

              if (state is ResultError) {
                return Center(child: Text(state.message));
              }

              if (state is! ResultLoaded) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 0 on a vertical tablet — see formBuilderTopGap.
                  verticalSpace(formBuilderTopGap(context, 15)),
                  const SwitchCardWidget(),
                  _getCardScreen(state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // The Users / Analytics switch card was gated, but
  // the content under it was not: a role with neither switch still saw both.
  Widget _getCardScreen(ResultLoaded state) {
    final bool users = FormBuilderAccess.canSeeUsersView;
    final bool analytics = FormBuilderAccess.canSeeAnalytics;
    if (state.isUser && users) return UserScreen(form: widget.form);
    if (!state.isUser && analytics) return AnalyticsScreen();
    // The selected view is not allowed — show the one that is, if any.
    if (users) return UserScreen(form: widget.form);
    if (analytics) return AnalyticsScreen();
    return const FormBuilderNoPermission();
  }
}

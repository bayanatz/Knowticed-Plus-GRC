/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: user_screen.dart
/// Description: `UserScreen` page, state and UI of the `UserScreen` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_no_permission.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/constants/app_routes.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/upload_media_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/upload_media_state.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/pages/pending_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/pages/submissions_result_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/pages/uploaded_media_page.dart';
import 'package:knowticed_plus/features/form_builder/helpers/category_filter_card.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// The Users view: the Pending / Submissions tabs (this page owns the TabController).
class UserScreen extends StatefulWidget {
  const UserScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with SingleTickerProviderStateMixin {
  /// The Pending / Submissions tabs. Owned here (FB-FILL-05 / Results rule
  /// 8): created once with this page's own ticker and disposed with it.
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final ResultState resultState = context.read<ResultCubit>().state;
    final bool pending =
        resultState is! ResultLoaded || resultState.isPendingScreen;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: pending ? 0 : 1,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _initMedia());
  }

  /// Gives the Uploaded Documents cubit the form and its submitted people.
  void _initMedia() {
    if (!mounted) return;
    final ResultState resultState = context.read<ResultCubit>().state;
    if (resultState is! ResultLoaded || resultState.formEntity == null) return;
    context.read<UploadMediaCubit>().initialize(
      form: resultState.formEntity!,
      submittedUsers: resultState.submittedUsers,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);

    return BlocConsumer<ResultCubit, ResultState>(
      // The submitted people arrive after the page opens; the Uploaded
      // Documents cubit is refreshed when they do.
      listenWhen: (previous, current) =>
          current is ResultLoaded &&
          (previous is! ResultLoaded ||
              previous.submittedUsers != current.submittedUsers),
      listener: (context, _) => _initMedia(),
      builder: (context, resultState) {
        if (resultState is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<UploadMediaCubit, UploadMediaState>(
          builder: (context, mediaState) {
            final isHasMedia = mediaState is UploadMediaLoaded
                ? mediaState.isHasMedia
                : false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(20),
                Row(
                  children: [
                    // TABS ARE NOT PERMISSION-GATED — AND MUST NOT BE (19/8/2026).
                    //
                    // This is what threw
                    // "RangeError (length): Invalid value: Valid value range is
                    // empty: 0" in _TabBarState.build and then painted the whole
                    // Result page red.
                    //
                    // The TabController (owned by this page) has length 2,
                    // but the two `TabletCategoryFilterCard`s
                    // here were each behind their own `isHasPermission` check.
                    // TabBar requires tabs.length == controller.length: a role
                    // missing pendingSubmissions/viewSubmissions produced a
                    // controller expecting 2 tabs and a list holding 0 or 1, and
                    // TabBar indexed straight off the end. The 98531px Row
                    // overflow underneath was just the ErrorWidget that replaced
                    // the failed TabBar sizing itself to infinity.
                    //
                    // So a permission check on a tab can never stand alone —
                    // it has to change the controller's length too. Gate the tab
                    // list and the `length:` from one shared list, or not at all.
                    //
                    // FLEXIBLE, NOT A BARE TabBar: a Row hands its children
                    // unbounded width, so a scrollable TabBar sizes to its full
                    // intrinsic width and overflows once the labels outgrow the
                    // window. Flexible (loose) lets it keep its natural width
                    // when there is room and scroll internally when there is not.
                    // Large-screen bug report p.12: a tab whose switch is off
                    // is not drawn. With both allowed it is the TabBar below;
                    // with one allowed that tab is shown on its own (no
                    // TabBar, so the controller's length is never at odds
                    // with the tab list — see the note above).
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child:
                            (!(FormBuilderAccess.canSeePendingSubmissions &&
                                FormBuilderAccess.canViewSubmissions))
                            ? FormBuilderAccess.canSeePendingSubmissions
                                  ? TabletCategoryFilterCard(
                                      name: S.current.pending,
                                      count: resultState.pendingUsers.length,
                                      selected: true,
                                    )
                                  : TabletCategoryFilterCard(
                                      name: S.current.submissions,
                                      count: resultState.submittedUsers.length,
                                      selected: true,
                                    )
                            : _buildTabBar(context, resultState),
                      ),
                    ),
                    if (isTablet &&
                        !resultState.isPendingScreen &&
                        isHasMedia &&
                        FormBuilderAccess.canDownloadFormDigitalAssets)
                      _buildUploadedDocsButtonTablet(context),
                  ],
                ),
                verticalSpace(0.h),
                if (!isTablet &&
                    !resultState.isPendingScreen &&
                    isHasMedia &&
                    FormBuilderAccess.canDownloadFormDigitalAssets)
                  _buildUploadedDocsRowPhone(context),
                verticalSpace(20),
                _getScreen(resultState),
              ],
            );
          },
        );
      },
    );
  }

  /// The Pending / Submissions tabs (both allowed).
  Widget _buildTabBar(BuildContext context, ResultLoaded resultState) {
    return TabBar(
      controller: _tabController,
      overlayColor: WidgetStateProperty.all(AppColors.transparent),
      tabAlignment: TabAlignment.start,
      onTap: (value) => context.read<ResultCubit>().onChangeTab(value),
      labelPadding: const EdgeInsetsDirectional.only(end: 30),
      isScrollable: true,
      splashFactory: NoSplash.splashFactory,
      indicatorColor: AppColors.transparent,
      indicatorPadding: EdgeInsets.zero,
      dividerHeight: 0,
      dividerColor: AppColors.transparent,
      tabs: [
        TabletCategoryFilterCard(
          name: S.current.pending,
          count: resultState.pendingUsers.length,
          selected: resultState.isPendingScreen,
        ),
        TabletCategoryFilterCard(
          name: S.current.submissions,
          count: resultState.submittedUsers.length,
          selected: !resultState.isPendingScreen,
        ),
      ],
    );
  }

  /// Uploaded Documents on a tablet (opens over the Results page).
  Widget _buildUploadedDocsButtonTablet(BuildContext context) {
    return customButtonWithSvg(
      title: S.current.uploadedDocuments,
      image: AppAssets.downloadPdf,
      function: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return UploadedMediaPage();
            },
          ),
        );
      },
      textStyle: StyleText.fontSize14Weight500.copyWith(
        color: AppColors.textButton,
      ),
      color: AppColors.primary,
      colorBorder: AppColors.primary,
      svgColor: AppColors.textButton,
      widthImage: 16,
      heightImage: 16,
    );
  }

  /// Uploaded Documents on a phone (a route of the module).
  Widget _buildUploadedDocsRowPhone(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        customButtonWithSvg(
          title: S.current.uploadedDocuments,
          image: AppAssets.downloadPdf,
          function: () {
            context.FormNavigateTo(Routes.uploadedMediaPage);
          },
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.textButton,
          ),
          color: AppColors.primary,
          colorBorder: AppColors.primary,
          svgColor: AppColors.textButton,
          widthImage: 16,
          heightImage: 16,
        ),
      ],
    );
  }

  // The tabs themselves cannot be gated (see the note
  // on the TabBar above), so the CONTENT of each tab is: Pending Submissions
  // and View Submissions are child switches of Users in Role Management.
  Widget _getScreen(ResultLoaded state) {
    if (state.isPendingScreen) {
      return FormBuilderAccess.canSeePendingSubmissions
          ? const PendingScreen()
          : const FormBuilderNoPermission();
    }
    return FormBuilderAccess.canViewSubmissions
        ? SubmissionsResultScreen(form: widget.form)
        : const FormBuilderNoPermission();
  }
}

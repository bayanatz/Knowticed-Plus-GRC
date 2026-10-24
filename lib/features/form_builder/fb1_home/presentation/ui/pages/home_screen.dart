/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_home_screen.dart
/// Description: `FormBuilderHomeScreen` page, `_kTitleToTabsGap` constant, `_kTitlePaddingBottom` constant and 7 more.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 22/10/2026 — a notification's form opens on entry
///          (`FormBuilderRecordTarget`).
library;

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/layout/custom_gridview_with_animation.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_cubit.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/ui/widgets/home_grid_item_view.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/ui/widgets/search_form_publish_tablet.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/presentation/controller/home_state.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_title_padding.dart';
import 'package:knowticed_plus/features/form_builder/presentation/navigation/form_builder_shortcut.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_permissions.dart';
import 'package:knowticed_plus/core/constants/app_routes.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb3_form_details/presentation/ui/pages/form_details_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb4_submissions/presentation/ui/pages/submissions_screen.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/pages/result_screen.dart';
import 'package:knowticed_plus/features/form_builder/presentation/navigation/form_builder_record_target.dart';
import 'package:knowticed_plus/features/notification/domain/routing/pending_notification_record.dart';

class FormBuilderHomeScreen extends StatefulWidget {
  const FormBuilderHomeScreen({super.key});

  @override
  State<FormBuilderHomeScreen> createState() => _FormBuilderHomeScreenState();
}

/// ── Figma spec: MESBAH / node 7444-37189 (Form Builder home, 1024 frame) ────
///
/// Every number below is read off that node, measured from the frame origin:
///
///   sidebar          x 0,   w 66
///   content column   x 96          → 30 clear of the sidebar (the page's
///                                    horizontal padding, already 30.sp)
///   page title       y 149, h 20   → bottom 169
///   tab row          y 199, h 45   → 30 below the title, bottom 244
///   action row       y 264, h 38   → 20 below the tabs,  bottom 302
///   card grid        y 317         → 15 below the action row
///   card             282 × 80, 15 between columns and 15 between rows
///                                    (columns at x 96 / 393 / 690 = +297
///                                     each, rows at y 317 / 412 = +95)
const double _kTabsToActionRowGap = 20;
const double _kActionRowToGridGap = 15;
const double _kCardGap = 15;

/// Chip keys, in the SAME ORDER as `HomeCubit.selectedTabIndex`
/// (0 Publish, 1 Draft, 2 Requested, 3 Submissions, 4 Deleted). The row is
/// the app's shared `StatusChipFilter`; a chip tap calls
/// `HomeCubit.onChangeTab`.
///
/// Keys are fixed English identifiers, deliberately NOT the labels: the labels
/// come from `S.of(context)` and change with the app language, and a key that
/// moves when the user switches to Arabic would stop matching `selectedKey`.
const List<String> _kTabKeys = [
  'publish',
  'draft',
  'requested',
  'submissions',
  'deleted',
];

class _FormBuilderHomeScreenState extends State<FormBuilderHomeScreen>
    with SingleTickerProviderStateMixin {
  late bool isPortrait;

  // Animation controller for grid items
  late AnimationController _gridAnimationController;

  /// Cached in [initState]: `context.read` is illegal in [dispose] (the
  /// element is already deactivated — "Looking up a deactivated widget's
  /// ancestor is unsafe").
  late final HomeCubit _homeCubit;
  int _lastItemCount = 0;
  bool _isAnimationScheduled = false; // Prevent double animation
  bool _isFirstLoad = true; // Track first data load

  @override
  void initState() {
    super.initState();

    // Initialize grid animation controller with proper duration
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500), // MUCH SLOWER: 2.5 seconds
      vsync: this,
      value: 0.0,
    );

    //  HomeCubit
    _homeCubit = context.read<HomeCubit>();
    _homeCubit.initialize();

    // 22/10/2026 — a notification's View names its form: open that form.
    // It replaces the tab shortcut the same notification arms (the form's
    // own tab goes under it instead).
    final PendingNotificationRecord? record = PendingNotificationRecord.take(
      Modules.formBuilder,
    );
    // Bug report p.2: the Home "Forms" card opens the module at a tab or
    // straight into Create Form.
    final FormBuilderShortcut? shortcut = FormBuilderShortcuts.take();
    if (record != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openRecord(record));
    } else if (shortcut != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _applyShortcut(shortcut),
      );
    }
    // Also react while already alive (tablet / desktop keep
    // this screen mounted in the side rail).
    FormBuilderShortcuts.notifier.addListener(_onShortcut);
  }

  void _onShortcut() {
    // Phones push a fresh Form Builder page, whose initState takes the
    // shortcut; only the side-rail (>= 600 wide) instance listens.
    if (!mounted || kpIsPhoneLayout(context)) return;
    final FormBuilderShortcut? shortcut = FormBuilderShortcuts.take();
    if (shortcut == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Close only pages opened ON TOP of this screen (details, create, …),
      // so the shortcut lands on the right screen.
      final ModalRoute<dynamic>? self = ModalRoute.of(context);
      if (self != null && !self.isCurrent) {
        Navigator.of(context).popUntil((route) => route == self);
      }
      _applyShortcut(shortcut);
    });
  }

  Future<void> _applyShortcut(FormBuilderShortcut shortcut) async {
    if (!mounted) return;
    final int? tabIndex = FormBuilderShortcuts.tabIndexOf(shortcut);
    if (tabIndex == null) {
      // FB-HOME-02: the shortcut opened Create without checking the Create
      // New Form permission.
      if (!FormBuilderAccess.canCreateForm) return;
      context.FormNavigateTo(Routes.create);
      return;
    }
    // Wait for the first load, so the tab opens with its forms already
    // loaded.
    await _homeCubit.waitUntilLoaded();
    if (!mounted || _homeCubit.isClosed) return;
    _homeCubit.onChangeTab(tabIndex);
  }

  /// Opens the form a notification is about, once the lists have loaded,
  /// with its own tab underneath so Back lands on that list.
  Future<void> _openRecord(PendingNotificationRecord record) async {
    if (!mounted) return;
    // 22/10/2026 — the phone took ~40 s to load the lists; the 20 s default
    // gave up and the form never opened.
    await _homeCubit.waitUntilLoaded(timeout: const Duration(seconds: 60));
    if (!mounted || _homeCubit.isClosed) return;
    final FormBuilderRecordTarget? target = FormBuilderRecordTarget.resolve(
      formId: record.recordId,
      pageKey: record.pageKey,
      published: _homeCubit.publishFormModels,
      requested: _homeCubit.requestedFormModels,
      submitted: _homeCubit.submissionsFormModels,
    );
    if (target == null) return;
    _homeCubit.onChangeTab(target.tabIndex);

    final NavigatorState navigator = Navigator.of(context);
    final FormEntity form = target.form;
    switch (target.screen) {
      case FormBuilderRecordScreen.results:
        // Results open from the form's details; Back goes the same way.
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => FormDetailsScreen(model: form),
          ),
        );
        // The new response is on the Submissions tab, not the default Pending.
        ResultCubit.openOnTab = 1;
        navigator.push(
          MaterialPageRoute<void>(builder: (_) => ResultScreen(form: form)),
        );
      case FormBuilderRecordScreen.details:
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => FormDetailsScreen(model: form),
          ),
        );
      case FormBuilderRecordScreen.form:
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => FormSubmissionsScreen(model: form),
          ),
        );
    }
  }

  // Initialize slide animations for grid items
  void _playAnimation(int itemCount) {
    // Prevent double animation trigger
    if (_isAnimationScheduled) {
      return;
    }

    _isAnimationScheduled = true;

    // Stop any running animation
    if (_gridAnimationController.isAnimating) {
      _gridAnimationController.stop();
    }
    _gridAnimationController.reset();

    // Start animation after delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _gridAnimationController.forward().then((_) {
          _isAnimationScheduled = false; // Reset flag when animation completes
        });
      }
    });

    _lastItemCount = itemCount;
  }

  @override
  void dispose() {
    FormBuilderShortcuts.notifier.removeListener(_onShortcut);
    _gridAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Every page in this module now draws its header with
    // SideFrameMasterServices. This screen used to build two different headers
    // (CustomAppBar on phone, PaginationAppBar inside the body on tablet); the
    // frame handles both form factors itself, so there is one header again.
    //
    // Home is the module root, so it passes a single crumb and no tap.
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // The frame scrolls the content itself on mobile; on tablet it hands the
    // child a bounded height, so the scroll view stays here.
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Owner 21/10/2026: "Test notifications & calendar" banner removed from the page (UI only; FormBuilderTestButton and its senders are kept).
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final cubit = context.read<HomeCubit>();

            // The count box is a
            // perfect 45.sp square in every orientation. StatusChipFilter
            // defaults to 35.sp on a phone, and the row was 45.h, which is
            // not the same number as 45.sp — so the box is pinned here and
            // the row uses the same unit.
            return StatusChipFilter(
              selectedKey: _kTabKeys[cubit.selectedTabIndex],
              onSelected: (key) => _onFilterSelected(key, cubit),
              items: [
                // The first chip was the literal
                // 'Publish' while its four neighbours were localized,
                // so the Arabic tab row read "Publish | مسودة | ...".
                // All five now come from FormStatus.label.
                StatusChipItem(
                  key: _kTabKeys[0],
                  label: FormStatus.publish.label,
                  count: cubit.publishFormModels.length,
                ),
                StatusChipItem(
                  key: _kTabKeys[1],
                  label: FormStatus.drafts.label,
                  count: cubit.draftFormModels.length,
                ),
                StatusChipItem(
                  key: _kTabKeys[2],
                  label: FormStatus.requestedForms.label,
                  count: cubit.requestedFormModels.length,
                ),
                StatusChipItem(
                  key: _kTabKeys[3],
                  label: FormStatus.submissions.label,
                  count: cubit.submissionsFormModels.length,
                ),
                StatusChipItem(
                  key: _kTabKeys[4],
                  label: FormStatus.deleted.label,
                  count: cubit.deleteFormModels.length,
                ),
              ],
            );
          },
        ),
        verticalSpace(_kTabsToActionRowGap),
        const SearchFormPublishTablet(),
        verticalSpace(_kActionRowToGridGap),
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final cubit = context.read<HomeCubit>();

            if (state is HomeLoading) {
              // Bug report #15: centred in the page, not pinned under the
              // search bar.
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: const Center(child: CircleProgressMaster()),
              );
            }

            if (state is HomeError) {
              // FB-HOME-10 / FB-HOME-27: the load failed; say so and offer a
              // retry instead of showing an empty grid.
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message, style: StyleText.fontSize14Weight400),
                      verticalSpace(15),
                      customButton(
                        title: S.of(context).retry,
                        function: () => cubit.getForms(),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (cubit.shownFormModels.isEmpty) {
              // Bug report p.33: less space between the art and the label,
              // and the pair centred in the page like the loading spinner
              // above (it sat high, under the search bar).
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LottieBuilder.asset(
                        height: 220.h,
                        AppAssets.noData,
                        frameRate: const FrameRate(120),
                      ),
                      verticalSpace(8),
                      Text(
                        S.of(context).noFormFound,
                        style: StyleText.fontSize18Weight600,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Trigger animation on first load or when count changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && cubit.shownFormModels.isNotEmpty) {
                final currentCount = cubit.shownFormModels.length;

                if ((_isFirstLoad || _lastItemCount != currentCount) &&
                    !_isAnimationScheduled) {
                  _isFirstLoad = false; // Mark first load as complete
                  _playAnimation(currentCount);
                }
              }
            });

            // The
            // gap between the search row and the cards was far bigger than
            // _kActionRowToGridGap because a GridView with no padding of its
            // own silently adds the device's top safe-area inset (the iPad
            // status bar) above the first row. That hidden inset is removed
            // here, so the gap is now just _kActionRowToGridGap — about half
            // of what it was.
            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: AnimatedCustomGridView(
                animationDuration: const Duration(
                  milliseconds: 700,
                ), // Each item animates for 1 second
                staggerDelay: const Duration(
                  milliseconds: 100,
                ), // 200ms delay between each item
                itemCount: cubit.shownFormModels.length,
                crossAxisCount: _getCrossAxisCount(context),
                // Figma card is 282 × 80. Was 100.h, which stretched the
                // card 25% taller than the design and left the 60 × 60
                // thumbnail floating inside it.
                // Figma 7444-37393: the Publish / Draft / Deleted card is
                // 282 × 80. The Requested and Submissions cards have their
                // own (taller) layout and keep 100.
                mainAxisExtent:
                    (cubit.selectedTabIndex == 2 || cubit.selectedTabIndex == 3)
                        ? 100.sp
                        : 80.sp,
                height: MediaQuery.of(context).size.height * 0.7,
                // In
                // portrait tablet the 21 end inset left the cards short of
                // the search / Create Form row above them. They now run the
                // full width so both edges line up with the row.
                // Owner 21/10/2026: landscape too — the 21 end inset left the
                // cards ~15 short of Create Form's end edge.
                // 24/10/2026 (owner): the phone too — the cards run the full
                // width (the 17 end inset left a strip beside them).
                margin: EdgeInsets.zero,
                mainAxisSpacing: _kCardGap,
                crossAxisSpacing: _kCardGap,
                curve: Curves.easeOut,
                itemBuilder: (context, index) {
                  return HomeGridItemView(
                    model: cubit.shownFormModels[index],
                    index: index,
                    gridAnimationController: null, // Not needed anymore
                    slideAnimations: null, // Not needed anymore
                  );
                },
              ),
            );
          },
        ),
      ],
    );

    return ContextExtension(context).isTablett
        ? SingleChildScrollView(child: content)
        : content;
  }

  /// Chip tap → cubit tab change → the same staggered grid animation the
  /// TabBar's `onTap` used to fire.
  ///
  /// `onChangeTab` also updates `selectedTab` and `shownFormModels` and
  /// re-applies the current sort.
  ///
  /// The 250ms delay is inherited from the TabBar, and matters: it lets the
  /// cubit emit its new state and the grid rebuild with the new list before the
  /// stagger starts, so items animate in rather than snapping into place.
  void _onFilterSelected(String key, HomeCubit cubit) {
    final int index = _kTabKeys.indexOf(key);
    if (index == -1 || index == cubit.selectedTabIndex) return;

    cubit.onChangeTab(index);

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _isFirstLoad = false; // Mark that we're no longer on first load
        _playAnimation(cubit.shownFormModels.length);
      }
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Owner 21/10/2026: 5 cards per row on the large horizontal view (desktop/web window, landscape, 1200+ wide); iPad and phone keep their counts.
    final bool isDesktop = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
    if (isDesktop &&
        ContextExtension(context).isLandscape &&
        screenWidth > 1200) {
      return 5;
    }

    if (screenWidth > 3600) {
      return 5;
    } else if (screenWidth > 2400) {
      return 4;
    } else if (screenWidth <= 2400 && screenWidth > 1200) {
      return 3;
    } else if (screenWidth > 600 && screenWidth < 1200) {
      return 2;
    }
    return 1; // Default for phone
  }
}

/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: share_screen.dart
/// Description: `FormShareScreen` page, state and UI of the `FormShareScreen` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder/helpers/breadcrumb_nav.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Keep for .tr translations
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/helpers/person_state_view.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/share_state.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/search_bar_share_widget.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_title_padding.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/mappers/person_entity_factory.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/share_actions.dart';

class FormShareScreen extends StatefulWidget {
  const FormShareScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<FormShareScreen> createState() => _FormShareScreenState();
}

class _FormShareScreenState extends State<FormShareScreen>
    with TickerProviderStateMixin {
  late AnimationController _gridAnimationController;
  late AnimationController _previousGridAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _gridAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _previousGridAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // Initialize the ShareCubit with the form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShareCubit>().selectForm(widget.form);
      // Start animations after loading
      Future.delayed(const Duration(milliseconds: 100), () {
        _gridAnimationController.forward();
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        _previousGridAnimationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    _previousGridAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S
            .of(context)
            .detailsOfTitle(_getTitle(widget.form.formHeadModel, context)),
        thirdTitle: S.of(context).share,
        onFirstTap: breadcrumbPop(context, 2),
        onSecondTap: breadcrumbPop(context, 1),
        child: BlocBuilder<ShareCubit, ShareState>(
          builder: (context, state) {
            // Show loading indicator while initializing
            if (state is ShareInitial || state is! ShareLoaded) {
              return const CircleProgressMaster();
            }

            final loadedState = state;

            // The frame scrolls the content itself on mobile; on tablet it hands
            // the child a bounded height, so the scroll view stays here.
            final Widget content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).employeeInformation,
                  style: StyleText.fontSize18Weight500,
                ),
                verticalSpace(8),
                SearchBarShareWidget(form: widget.form),
                verticalSpace(15),
                // FB-SHARE-11: the access list could not be read.
                if (loadedState.accessListError != null) ...[
                  _AccessListError(message: loadedState.accessListError!),
                  verticalSpace(15),
                ],
                // One list in the normal employee
                // order — people it was already sent to stay in their own
                // place with a "Sent" tag instead of being moved to the end.
                _buildDataWidget(context, loadedState),
                verticalSpace(15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // FB-SHARE-11: disabled until the access list loads.
                    IgnorePointer(
                      ignoring: !loadedState.isAccessListLoaded,
                      child: Opacity(
                        opacity: loadedState.isAccessListLoaded ? 1 : 0.5,
                        child: customButton(
                          title: S.of(context).review,
                          function: () {
                            final ShareCubit shareCubit = context
                                .read<ShareCubit>();
                            shareCubit.newSelectedSearch("");
                            AppDialogs.shareAccessDialog(context, () {
                              ShareActions.grantAccess(context, shareCubit);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpace(15),
              ],
            );

            return ContextExtension(context).isTablett
                ? SingleChildScrollView(child: content)
                : content;
          },
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 3600) {
      return 5;
    } else if (screenWidth > 2400) {
      return 4;
    } else if (screenWidth <= 2400 && screenWidth > 1200) {
      return 3;
    } else if (screenWidth > 600 && screenWidth < 1200) {
      return 2;
    }
    return 1;
  }

  /// Everyone in one grid, in the same order as the employee list:
  /// selectable people and people the form was already sent to.
  Widget _buildDataWidget(BuildContext context, ShareLoaded state) {
    final Map<String, int> order = {};
    final employees =
        context
            .read<ShareCubit>()
            .mainCoreEmployeeController
            .allEmployeesEntities ??
        [];
    for (int i = 0; i < employees.length; i++) {
      final id = PersonEntityFactory.fromEmployeeEntity(employees[i]).id;
      order.putIfAbsent(id, () => i);
    }

    final entries = <({PersonEntity person, bool sent})>[
      for (final p in state.filteredPersons) (person: p, sent: false),
      for (final p in state.filteredPreviousSelectedPersons)
        (person: p, sent: true),
    ];
    // Stable sort by employee order; unknown ids keep their relative place.
    final indexed = entries.asMap().entries.toList()
      ..sort((a, b) {
        final oa = order[a.value.person.id] ?? (1 << 30) + a.key;
        final ob = order[b.value.person.id] ?? (1 << 30) + b.key;
        final c = oa.compareTo(ob);
        return c != 0 ? c : a.key.compareTo(b.key);
      });
    final sorted = indexed.map((e) => e.value).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 75.h,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final entry = sorted[index];
        return _buildAnimatedGridItem(
          index: index,
          controller: _gridAnimationController,
          child: FormPersonStateView(
            person: entry.person,
            isSent: entry.sent,
            onTap: entry.sent
                ? () {} // already has access — nothing to toggle
                : () {
                    final i = state.filteredPersons.indexOf(entry.person);
                    if (i != -1) {
                      context.read<ShareCubit>().togglePersonSelection(
                        i,
                        false,
                      );
                    }
                  },
          ),
        );
      },
    );
  }

  /// Builds an animated grid item with slide-in animation
  Widget _buildAnimatedGridItem({
    required int index,
    required AnimationController controller,
    required Widget child,
  }) {
    // Stagger the animation based on index
    final delay = index * 0.05; // 50ms delay between items

    final animation =
        Tween<Offset>(
          begin: const Offset(-1.0, 0.0), // Slide from left
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              delay.clamp(0.0, 1.0),
              (delay + 0.5).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        );

    final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay.clamp(0.0, 1.0),
          (delay + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeIn,
        ),
      ),
    );

    return SlideTransition(
      position: animation,
      child: FadeTransition(opacity: opacityAnimation, child: child),
    );
  }

  String _getTitle(FormHeadData formHeadModel, BuildContext context) =>
      formHeadModel.titleFor(arabic: context.isArabic);
}

/// FB-SHARE-11: the access list could not be read; shows the message and a
/// Retry button.
class _AccessListError extends StatelessWidget {
  const _AccessListError({required this.message});

  /// The translated message.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: StyleText.fontSize14Weight400.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        horizontalSpace(8),
        customButton(
          title: S.of(context).retry,
          wrapContent: true,
          function: () => context.read<ShareCubit>().retryAccessList(),
        ),
      ],
    );
  }
}

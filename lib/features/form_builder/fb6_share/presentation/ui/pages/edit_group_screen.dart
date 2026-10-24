/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: edit_group_screen.dart
/// Description: `EditGroupScreen` page.
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
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_state.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder/helpers/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder/helpers/person_state_view.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/group_image_picker.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/filter_row.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/group_info.dart';
import 'package:knowticed_plus/features/form_builder/presentation/ui/widgets/form_builder_title_padding.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/ui/widgets/share_actions.dart';

class EditGroupScreen extends StatelessWidget {
  const EditGroupScreen({super.key, required this.form});

  final FormEntity form;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).detailsOfTitle(form.getTitle),
        thirdTitle: S.of(context).group,
        fourthTitle: S.of(context).editGroup,
        onFirstTap: breadcrumbPop(context, 3),
        onSecondTap: breadcrumbPop(context, 2),
        onThirdTap: breadcrumbPop(context, 1),
        child: BlocBuilder<FormsGroupCubit, FormsGroupState>(
          builder: (context, state) {
            if (state is! FormsGroupLoaded) {
              return const CircleProgressMaster();
            }

            // The frame scrolls the content itself on mobile; on tablet it hands
            // the child a bounded height, so the scroll view stays here.
            final Widget content = SafeArea(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    // 0 on a vertical tablet — see formBuilderTopGap.
                    verticalSpace(formBuilderTopGap(context, 30)),
                    // No Expanded here: SideFrameMasterServices scrolls this
                    // content on mobile, so children must size themselves.
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GroupImagePicker(),
                            verticalSpace(15),
                            GroupInfo(),
                            if (ContextExtension(context).isTablett) ...[
                              verticalSpace(15),
                              Text(
                                S.of(context).EmployeeInformation,
                                style: StyleText.fontSize18Weight500,
                              ),
                            ],
                            verticalSpace(8),
                            FilterRow(),
                            verticalSpace(15),
                            _buildDataWidget(context, state),
                            verticalSpace(15),
                          ],
                        ),
                      ),
                    ),
                    verticalSpace(15),
                    _buildActionRow(context),
                    verticalSpace(15),
                  ],
                ),
              ),
            );

            return ContextExtension(context).isTablett
                ? SingleChildScrollView(child: content)
                : content;
          },
        ),
      ),
    );
  }

  /// Discard Changes and Save.
  Widget _buildActionRow(BuildContext context) {
    return Row(
      textDirection: TextDirection
          .ltr, // X-73: Cancel left, action right in both languages

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          // Bug report p.55: localized, and the standard
          // secondary button (light grey, white text).
          title: S.of(context).discardChanges,
          color: AppColors.darkGrey,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.text,
          ),
          function: () {
            context.pop();
            context.pop();
          },
        ),
        customButton(
          title: S.of(context).save,
          function: () {
            // Bug report p.56 / large-screen p.11: group name
            // and description are required — the empty fields
            // show their error and nothing is saved.
            if (!context.read<FormsGroupCubit>().validateGroupInfo()) {
              return;
            }
            AppDialogs.editGroupWarningDialog(context, () {
              ShareActions.editGroup(
                context,
                context.read<FormsGroupCubit>(),
              ).then((_) {
                if (context.mounted) {
                  context.pop();
                  context.pop();
                }
              });
            });
          },
        ),
      ],
    );
  }

  Widget _buildDataWidget(BuildContext context, FormsGroupLoaded state) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
          context,
        ),
        mainAxisSpacing: 16.sp,
        crossAxisSpacing: 16.sp,
        mainAxisExtent: 73.h,
      ),
      itemCount: state.filteredPersons.length,
      itemBuilder: (context, index) {
        return FormPersonStateView(
          isEdit: true,
          color: AppColors.background,
          person: state.filteredPersons[index],
          onTap: () {
            context.read<FormsGroupCubit>().dropPerson(
              state.filteredPersons[index],
            );
          },
        );
      },
    );
  }
}

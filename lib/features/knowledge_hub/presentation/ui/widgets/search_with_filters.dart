/// Module: knowledge_hub/presentation/ui/widgets
///
/// ************************* FILE INFO *************************** ///
/// File Name: search_with_filters.dart
/// Description: Contains the bar of search and filtering in home page.
/// Author: Amr Mesbah
/// Created at: 3/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/knowledge_hub_permissions.dart';
import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hubssections_enum.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/presentation/ui/pages/creating_knowledge_hub.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/filter_search_dialog.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

// ========== ANIMATED BUTTON STATE ==========
class _AnimatedButtonState extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedButtonState({required this.child, required this.onTap});

  @override
  State<_AnimatedButtonState> createState() => __AnimatedButtonStateState();
}

class __AnimatedButtonStateState extends State<_AnimatedButtonState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInBack));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await _controller.forward();
    widget.onTap();
    // Reset animation after navigation for when user comes back
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: hapticDown(_onTap, HapticLevel.low),
      onTap: _onTap,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
      ),
    );
  }
}

// ========== SEARCH WITH FILTERS WIDGET ==========
Widget searchWithFilters(
  BuildContext context, {
  required TextEditingController searchController,
  required Function(String) onSearchChanged,
  required List<DepartmentModelPro> departments,
}) {
  final bool isMobile = ContextExtension(context).isPhone;
  // KH vertical report p.1: on tablet the Filter and Create-new-knowledge
  // buttons show the icon only (like phone), with a tooltip so the label
  // stays reachable. Desktop / large screens keep the labelled buttons.
  final bool isTabletDevice = !isMobile &&
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
  final bool iconOnly = isMobile || isTabletDevice;
  final bool canCreate = KnowledgeHubAccess.has(
    section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
    permission: KnowledgeHubPermissions.createKnowledgeHub,
  );

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // `active` = yellow fill only while the dialog's own criteria are
      // applied; a department tab never lights it.
      CustomFilterIcon(
        title: S.of(context).filter,
        iconOnly: iconOnly,
        size: 38.sp, // same height as the search field
        active: _isDialogFilterActive(context.read<CreateKnowledgeCubit>()),
        onTap: () => _openFilterDialog(context, departments),
      ),
      if (canCreate) ...[
        SizedBox(width: 10.w),
        _AnimatedButtonState(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => KnowledgeHubDI.createKnowledgeCubit(),
                  child: CreatingKnowledgeHub(),
                ),
              ),
            );
          },
          child: _buildCreateButton(context, iconOnly: iconOnly),
        ),
      ],
    ],
  );
}

/// Whether a filter from the FilterSearchDialog is applied (document type,
/// status, publish-date range, or a department chosen IN the dialog — the
/// department tabs set the same field and must not light the button). This
/// widget is rebuilt by the outer BlocBuilder<CreateKnowledgeCubit>, so
/// applyFilters()/resetFilters() refresh it.
bool _isDialogFilterActive(CreateKnowledgeCubit cubit) {
  final String? dept = cubit.selectedOwningDepartment;
  return (cubit.selectedDocumentType?.isNotEmpty ?? false) ||
      (cubit.selectedOwningStatus?.isNotEmpty ?? false) ||
      cubit.selectedPublishFromDate != null ||
      cubit.selectedPublishToDate != null ||
      (cubit.owningDepartmentFromFilterDialog &&
          dept != null &&
          dept.isNotEmpty);
}

void _openFilterDialog(
  BuildContext context,
  List<DepartmentModelPro> departments,
) {
  showAppDialog(
    context: context,
    builder: (ctx) => Center(
      child: BlocProvider.value(
        value: context.read<CreateKnowledgeCubit>(),
        child: FilterSearchDialog(departments: departments, isAdmin: true),
      ),
    ),
  );
}

/// "Create New Knowledge" — 38.sp square (icon only) on phones and tablets.
Widget _buildCreateButton(BuildContext context, {required bool iconOnly}) {
  return Tooltip(
    message: iconOnly ? S.of(context).create_new_knowledge : '',
    child: Container(
      height: 38.sp,
      width: iconOnly ? 38.sp : 220.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: CustomSvgImage(
              assetPath:
                  'assets/icons_assets/knowledge_hub_assets/ic_module_knowledge_create.svg',
              height: 20.h,
              width: 20.w,
              fit: BoxFit.cover,
              color: AppColors.textButton,
            ),
          ),
          if (!iconOnly) ...[
            SizedBox(width: 5.w),
            Text(
              S.of(context).create_new_knowledge,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.textButton,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Module: knowledge_hub/kh4_submissions/presentation/ui/pages
/// ************************* FILE INFO *************************** ///
/// File Name: submissions_screen.dart
/// Description: Submissions screen — Submissions (S4) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/ui/widgets/category_list.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/ui/widgets/inner_status_section.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/ui/widgets/search_section.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/ui/widgets/submitted_documents_view.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_states.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class SubmissionsScreen extends StatefulWidget {
  const SubmissionsScreen({super.key});

  @override
  State<SubmissionsScreen> createState() => _SubmissionsScreenState();
}

class _SubmissionsScreenState extends State<SubmissionsScreen> {
  int selectedIndex = 0;
  int selectedInnerIndex = 0;
  final searchCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _initializeUserData() {
    final cubit = context.read<SubmissionsCubit>();

    // The signed-in employee, injected into the cubit.
    final String userEmail = cubit.people.signedInEmail;

    // KH-CREATE-07: no ConstantVar fallback — it kept the PREVIOUS user's
    // e-mail after an account switch. Only the signed-in employee is used.

    if (userEmail.isNotEmpty) {
      cubit.setCurrentUserEmail(userEmail);
      khLog('✅ User email set in submissions: $userEmail');
    } else {
      khLog('❌ Could not set user email in submissions');
    }

    // Fetch submissions first
    // KH-SUBMIT-09: the "about to expire" warning was re-sent on EVERY visit
    // from here (no "already sent" check). It is now sent only by the sweep
    // that remembers what it sent (knowledge_hub_notification_scheduler).
    cubit.fetchMySubmissions();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      // top: false — the app shell header already sits under the status bar;
      // the extra inset pushed the page title down (KH vertical report p.1/3/5/12/21).
      body: SafeArea(
        top: false,
        child: SideFrameMasterServices(
          titleText: S.of(context).knowledge_hub,
          secondTitle: S.of(context).submissions,
          onFirstTap: () => Navigator.of(context).pop(),
          child: BlocListener<SubmissionsCubit, SubmissionsStates>(
            listener: _handleIndexChanges,
            // Scroll only where the frame doesn't, so one
            // scroll view (not two nested ones) handles the drag.
            child: SideFrameScrollableBody(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  categoryList(
                    context,
                    isMobile: isMobile,
                    selectedIndex: selectedIndex,
                  ),
                  SizedBox(height: 25.h),
                  searchWithStatusFilters(
                    context,
                    searchCategoryController: searchCategoryController,
                  ),
                  SizedBox(height: 15.h),
                  innerStatusSection(
                    context,
                    selectedInnerIndex: selectedInnerIndex,
                    lighMode: lightMode,
                  ),
                  SizedBox(height: 10.h),
                  SubmittedDocumentsView(isMobile: isMobile),
                  SizedBox(height: 20.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleIndexChanges(BuildContext context, SubmissionsStates state) {
    if (state is ChangeIndexSuccessState) {
      setState(() {
        selectedIndex = state.index;
        khLog('Selected index: $selectedIndex');
      });
    }
    if (state is ChangeInnerIndexSuccessState) {
      setState(() {
        selectedInnerIndex = state.index;
        khLog('Selected inner index: $selectedInnerIndex');
      });
    }
  }
}

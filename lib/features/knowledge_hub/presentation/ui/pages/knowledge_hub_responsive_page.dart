/// Module: knowledge_hub_module / presentation/ui/pages/knowledge_hub_responsive_page.dart
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_responsive_page.dart
/// Description: Module entry point — provides every Knowledge Hub cubit and picks
///          the mobile / tablet layout.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 22/10/2026 — a notification's document opens on entry
///          (`KnowledgeHubRecordOpener`).
/// Updated: 1/9/2026 — became stateful so the module can run its time-driven
///          notification sweep once per session on entry. See below.
library;

import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/custom/layout/custom_responsive.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/notifications/knowledge_hub_notification_scheduler.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh2_view_knowledge_hub/presentation/ui/pages/view_knowledge_hub.dart';
// the notification deep-link landing. See [pendingSection].
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/ui/pages/submissions_screen.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/ui/pages/approvals_screen.dart';
import 'package:knowticed_plus/features/notification/domain/routing/notification_deep_link.dart';
import 'package:knowticed_plus/features/notification/domain/routing/pending_notification_record.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/pages/knowledge_hub_record_opener.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';

/// ─── WHY THIS IS STATEFUL ────────────────────────────────────────────────
///
/// Three of the notifications in §1.1 of "Knowticed Plus — Notification &
/// Validation" are due because of the CLOCK, not because of a user action:
/// the 14-day expiry warning, the archival notice, and the pending-review
/// reminder. This app has no server-side scheduler, so nothing was raising
/// them — the templates existed in Notification Control and no code could
/// ever send them.
///
/// Opening the module is the natural hook: it is the moment Knowledge Hub
/// data is being loaded anyway, so one extra collection read costs little,
/// and it guarantees the sweep runs on a device that is online with a
/// logged-in user. [KnowledgeHubNotificationScheduler] guards itself against
/// running twice in a session and writes a per-document marker so ten people
/// opening the module do not send the same warning ten times.
///
/// It is fire-and-forget: the sweep must never delay the first frame, and a
/// failure is silent to the user — the next module open retries.
class KnowledgeHubPage extends StatefulWidget {
  const KnowledgeHubPage({super.key});

  /// The screen to open on top of the module landing, left here by the
  /// notification inbox before it selects this module in the drawer.
  ///
  /// with the deep-link router. Submissions and Approvals are
  /// not tabs of the landing page — they are separate screens pushed from the
  /// two buttons on `ViewKnowledgeHub`, each with its own `BlocProvider`. So a
  /// deep link cannot be expressed as an index; it is a push scheduled for
  /// after the landing page's first frame, which also gives the reader a back
  /// button to the module rather than stranding them.
  ///
  /// Same shape as `RoleScreenHost.pendingInitialTab`.
  ///
  /// ⚠️ Read-and-cleared on the first build, used or not.
  static NotificationKnowledgeHubSection? pendingSection;

  @override
  State<KnowledgeHubPage> createState() => _KnowledgeHubPageState();
}

class _KnowledgeHubPageState extends State<KnowledgeHubPage> {
  @override
  void initState() {
    super.initState();
    _runNotificationSweep();
  }

  /// Raise anything that fell due since the last time somebody opened the
  /// module. Deliberately not awaited.
  void _runNotificationSweep() {
    KnowledgeHubNotificationScheduler.sweep(
      actingUserEmail: KnowledgeHubDI.people.signedInEmail,
      isArabic: KhLocale.isArabicNow,
    );
  }

  /// Function Name: [_consumeDeepLink]
  ///
  /// Purpose: Open the screen a notification pointed at, once the landing page
  /// has been laid out.
  ///
  /// Called once, from [_KhLanding]'s initState (rule 10: no side effects in
  /// build). Read-and-clear FIRST, so the link is used at most once.
  /// Deliberately post-frame — the landing page has to exist before
  /// something is stacked on it.
  void _consumeDeepLink(BuildContext context) {
    final NotificationKnowledgeHubSection? section =
        KnowledgeHubPage.pendingSection;
    KnowledgeHubPage.pendingSection = null;

    // 22/10/2026 — the notification names its document: open that document
    // (with its own list under it) instead of the bare section.
    final PendingNotificationRecord? record = PendingNotificationRecord.take(
      Modules.knowledgeHub,
    );
    if (record != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !context.mounted) return;
        KnowledgeHubRecordOpener.open(context, record);
      });
      return;
    }
    if (section == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !context.mounted) return;

      // Each screen owns its cubit, exactly as `submissions_button.dart` and
      // `approvals_button.dart` build them. Do NOT route to them bare: both
      // read a cubit that the module root does not hand down through a push.
      final Widget target = switch (section) {
        NotificationKnowledgeHubSection.submissions => BlocProvider(
            create: (_) => KnowledgeHubDI.submissionsCubit(),
            child: SubmissionsScreen(),
          ),
        NotificationKnowledgeHubSection.approvals => BlocProvider(
            create: (_) => KnowledgeHubDI.approvalsCubit(),
            child: ApprovalsScreen(),
          ),
      };

      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => target));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => KnowledgeHubDI.createKnowledgeCubit(),
        ),
        BlocProvider(create: (context) => KnowledgeHubDI.submissionsCubit()),
        BlocProvider(create: (context) => KnowledgeHubDI.dashboardCubit()),
        BlocProvider(create: (context) => KnowledgeHubDI.approvalsCubit()),
        BlocProvider(create: (context) => KnowledgeHubDI.analyticsCubit()),
        BlocProvider(create: (context) => KnowledgeHubDI.commentsCubit()),
      ],
      child: ResponsiveHelper(
        //  Solve
        //
        // The Builder / route builder are what give `_consumeDeepLink` a
        // context BELOW the MultiBlocProvider above and — on tablet — below
        // this module's own Navigator, so the pushed screen lands inside the
        // module instead of over the whole shell.
        mobileWidget: _KhLanding(onFirstFrame: _consumeDeepLink),
        tabletWidget: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => _KhLanding(onFirstFrame: _consumeDeepLink),
            );
          },
        ),
      ),
    );
  }
}

/// The module landing page. Its own State gives the deep-link push a context
/// below the providers (and, on tablet, below the module's Navigator) and runs
/// it once from initState instead of from a build method.
class _KhLanding extends StatefulWidget {
  const _KhLanding({required this.onFirstFrame});

  /// Opens the screen a notification pointed at, if any.
  final void Function(BuildContext context) onFirstFrame;

  @override
  State<_KhLanding> createState() => _KhLandingState();
}

class _KhLandingState extends State<_KhLanding> {
  @override
  void initState() {
    super.initState();
    widget.onFirstFrame(context);
  }

  @override
  Widget build(BuildContext context) => ViewKnowledgeHub();
}

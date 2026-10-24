/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_screen.dart
/// Purpose: Responsive social / general information screen (phone + tablet in
///          one page).
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE2-N04/N08/N11/N14: the blanket
///          `ignore_for_file` is gone; the page consumes the cubit's one-shot
///          states instead of the controller firing `Get.dialog` /
///          `Get.snackbar` at it; the messages are localized and themed; the
///          hardcoded "Social" title comes from S.of(context); the RTL padding
///          reads the locale from the tree instead of `Get.locale`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/social_permissions.dart';
import 'package:knowticed_plus/features/settings/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/academic_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/skill_entry.dart';
import 'package:knowticed_plus/features/settings/se2_social/presentation/controller/social_controller.dart';
import 'package:knowticed_plus/features/settings/se2_social/presentation/ui/widgets/sections/academic_history.dart';
import 'package:knowticed_plus/features/settings/se2_social/presentation/ui/widgets/sections/bio.dart';
import 'package:knowticed_plus/features/settings/se2_social/presentation/ui/widgets/sections/hobbies.dart';
import 'package:knowticed_plus/features/settings/se2_social/presentation/ui/widgets/sections/skills.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  late final SettingsController _settingsController;
  late final SocialController _socialController;

  @override
  void initState() {
    super.initState();
    _settingsController = Get.find<SettingsController>();
    _socialController = _settingsController.socialController;
    _socialController.restartController();

    if (_settingsController.employee == null) {
      _settingsController.getEmployee().then((_) {
        // Owner 21/10/2026: the page may have closed while the employee loaded.
        if (!mounted) return;
        _socialController.restartController();
        _syncHasChanges();
      });
    }

    _syncHasChanges();
  }

  // ── Update button enablement (24/8/2026) ─────────────────────────────────
  //
  // The button is inert until something actually differs from what is stored.
  // `SocialController.hasChanges` already answers that — it diffs the draft
  // against the loaded profile — but it cannot simply be read during build,
  // for one specific reason:
  //
  // `setBio` / `setSkill` / `setHobby` / `setAcademicEntry` deliberately do NOT
  // emit. The controller's own comment says why: rebuilding on every keystroke
  // fights the cursor. So a text edit changes `hasChanges` WITHOUT any state
  // arriving here, and a button gated on the cubit alone would stay grey until
  // the user happened to add or remove a row.
  //
  // Hence a separate notifier. Only the button listens to it, so a keystroke
  // repaints the button and nothing else — the four section cards, and the
  // TextEditingControllers living in their State, are never rebuilt.

  final ValueNotifier<bool> _hasChanges = ValueNotifier<bool>(false);

  void _syncHasChanges() {
    final bool value = _socialController.hasChanges;
    if (_hasChanges.value != value) _hasChanges.value = value;
  }

  @override
  void dispose() {
    _hasChanges.dispose();
    super.dispose();
  }

  // ── Role permissions ───────────────────────────────────────────────────
  // Same check the org-chart profile card already uses
  // (custom_personal_Info_Container.dart): the employee's role decides which
  // of these sections they may see and edit. Resolved per call rather than
  // held in a field so a role refresh mid-session is picked up.

  /// Function Name: [_can]
  ///
  /// Purpose: Whether the signed-in employee's role grants [permission] under
  ///          Settings > Social Permissions.
  ///
  /// Parameters:
  /// - [permission]: The social permission to test.
  ///
  /// Returns: [bool] true when the switch is on for this role.
  bool _can(SocialPermissions permission) =>
      Get.find<MainCoreEmployeeController>().isHasPermission(
        module: Modules.settings,
        section: SettingsPermissionsSections.socialPermissions,
        permission: permission,
      );

  /// Master switch: with Share Social Information off there is nothing on this
  /// screen to show or save, so the whole body goes — including the update
  /// button, which would otherwise sit alone on an empty page.
  bool get _canSeeSocial => _can(SocialPermissions.shareSocialInformation);

  bool get _canSeeAcademicHistory => _can(SocialPermissions.academicHistory);

  /// One permission covers both sections — Skills and Hobbies travel together.
  bool get _canSeeSkillsHobbies => _can(SocialPermissions.skillsHobbies);

  /// 21/10/2026 (Moataz): set by a press on Update while an academic row the
  /// user started is still missing a field — only then do its empty fields
  /// turn red. Opening the page no longer shows errors.
  bool _submitted = false;

  Future<void> _onUpdatePressed() async {
    if (_socialController.incompleteAcademicRows.isNotEmpty) {
      setState(() => _submitted = true);
      _showMessage(
          context, S.of(context).fillAllRequiredFields, AppColors.primary);
      return;
    }
    await _socialController.updateAllSocialInformation();

    // Cross-feature refresh: the org-chart profile card renders the same
    // skills/hobbies. Flagged as coupling in CR-SKEL-SE2-N15 and left in place
    // — removing it would leave that card stale until the app restarts.
    final MainCoreEmployeeController mainCoreEmployeeController =
        Get.find<MainCoreEmployeeController>();
    await mainCoreEmployeeController.getAllNewEmployees();
    mainCoreEmployeeController.update(<String>['employee_profile']);
  }

  /// One place for the feedback the controller used to raise itself with
  /// `Get.snackbar`, using localized text and theme colours (N11, N12).
  void _onStateChanged(BuildContext context, SocialState state) {
    // Covers add/remove of a row (those DO publish) and the reload after a
    // successful save, which resets the diff baseline back to "no changes".
    // Safe here: a listener runs outside the build phase.
    _syncHasChanges();

    switch (state) {
      case SocialSaved():
        if (_submitted) setState(() => _submitted = false);
        // X-136 / item 107: the core success dialog (5 s), not a page copy.
        CustomDialogManager.showSuccess(
          context: context,
          lottiePath:
              'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
          title: S.of(context).Successful,
          subtitle: S.of(context).dataHasBeenSavedSuccessfully,
        );
        break;
      case SocialNoChanges():
        _showMessage(context, S.of(context).noChangeFound, AppColors.orange);
        break;
      case SocialError():
        // The raw failure text is not shown: it is a Firestore message, not
        // something a user can act on.
        _showMessage(context, S.of(context).error, AppColors.primary);
        break;
      case SocialInitial():
      case SocialEditing():
      case SocialSaving():
        break;
    }
  }

  void _showMessage(BuildContext context, String message, Color background) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.textButton),
          ),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialController, SocialState>(
      bloc: _socialController,
      listener: _onStateChanged,
      builder: (BuildContext context, SocialState state) {
        return ContextExtension(context).isPhone
            ? _buildPhone(context, state)
            : _buildTablet(context, state);
      },
    );
  }

  /// The four editable cards. Values come down from the cubit's draft; edits go
  /// back up through it — no widget touches the controller's internals
  /// (CR-SKEL-SE2-N18).

  /// The four setters below are wrapped rather than passed straight through:
  /// they are the ones that do not emit, so this is the only place that can
  /// notice a typed edit.

  Widget _bio() => Bio(
        bio: _socialController.profile.bio,
        bioInArabic: _socialController.profile.bioInArabic,
        onChanged: (String value) {
          _socialController.setBio(value);
          _syncHasChanges();
        },
        // 21/10/2026 (Moataz): the Arabic bio has its own field.
        onArabicChanged: (String value) {
          _socialController.setBioInArabic(value);
          _syncHasChanges();
        },
      );

  Widget _academicHistory() => AcademicHistory(
        entries: _socialController.academicHistory,
        errorRows: _submitted
            ? _socialController.incompleteAcademicRows
            : const <int>{},
        onEntryChanged: (int index, AcademicEntry entry) {
          _socialController.setAcademicEntry(index, entry);
          _syncHasChanges();
          // X-136 (21/10/2026): the setter does not emit, so the page did
          // not rebuild and the dropdown / date fell back to "Choose…".
          setState(() {});
        },
        onAdd: _socialController.addAcademicEntry,
        onRemove: _socialController.removeAcademicEntry,
      );

  Widget _skills() => Skills(
        skills: _socialController.skills,
        onSkillChanged: (int index, SkillEntry entry) {
          _socialController.setSkill(index, entry);
          _syncHasChanges();
        },
        onAdd: _socialController.addSkill,
        onRemove: _socialController.removeSkill,
      );

  Widget _hobbies() => Hobbies(
        hobbies: _socialController.hobbies,
        onHobbyChanged: (int index, String value) {
          _socialController.setHobby(index, value);
          _syncHasChanges();
        },
        onAdd: _socialController.addHobby,
        onRemove: _socialController.removeHobby,
      );

  /// The update button, greyed out and untappable until [_hasChanges] is true.
  ///
  /// Opacity + IgnorePointer + a grey fill — the same disabled treatment the
  /// request preview pages and the health edit page use, so a dead button looks
  /// the same everywhere in Settings.
  /// X-138 (21/10/2026): required fields — Graduation From, University and
  /// Graduation Year of every academic record.
  Widget _buildUpdateButton({required bool isSaving}) {
    final bool isPhone = kpIsPhoneLayout(context);
    return ValueListenableBuilder<bool>(
      valueListenable: _hasChanges,
      builder: (BuildContext context, bool hasChanges, _) {
        // 21/10/2026: enabled on any change; an incomplete academic row is
        // caught on press (see [_onUpdatePressed]) instead of greying the
        // button out with no reason shown.
        final bool enabled = hasChanges && !isSaving;
        // R-3: disabled = grey, black text, 50% opacity.
        return Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: IgnorePointer(
            ignoring: !enabled,
            child: customButtonWithSvg(
              fixedWidth: isPhone ? 200.sp : 250.w,
              title: S.of(context).updateSocialInformation,
              function: _onUpdatePressed,
              color: enabled ? AppColors.primary : AppColors.grey,
              colorBorder: AppColors.transparent,
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.textButton,
              ),
              image: 'assets/icons_assets/main_icons_assets/ic_action_edit.svg',
              svgColor: AppColors.textButton,
              widthImage: 18.w,
              heightImage: 18.h,
            ),
          ),
        );
      },
    );
  }

  /// Thin line between two sections inside the shared phone card.
  Widget _sectionDivider() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        child: Divider(
          height: 1,
          thickness: 1,
          color: AppColors.background,
        ),
      );

  /// Phone design (formerly social_screen_mobile.dart)
  Widget _buildPhone(BuildContext context, SocialState state) {
    final bool isSaving = state is SocialSaving;

    // D-202 / X-138 (21/10/2026): the sections scroll, the single page
    // action is PINNED at the bottom, centred.
    return SideFrameMasterServices(
      titleText: S.of(context).settings,
      onFirstTap: () => Navigator.of(context).maybePop(),
      secondTitle: S.of(context).socialInformation,
      child: SideFrameBoundedBody(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_canSeeSocial) ...<Widget>[
                      // D-223 / item 115 (21/10/2026): ONE box with Bio,
                      // Academic History, Skills and Hobbies inside, split
                      // by thin dividers.
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _bio(),
                            if (_canSeeAcademicHistory || _canSeeSkillsHobbies)
                              _sectionDivider(),
                            if (_canSeeAcademicHistory) _academicHistory(),
                            if (_canSeeAcademicHistory && _canSeeSkillsHobbies)
                              _sectionDivider(),
                            if (_canSeeSkillsHobbies) ...<Widget>[
                              _skills(),
                              _sectionDivider(),
                              _hobbies(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_canSeeSocial) ...<Widget>[
              SizedBox(height: 16.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[_buildUpdateButton(isSaving: isSaving)],
              ),
              SizedBox(height: 16.sp),
            ],
          ],
        ),
      ),
    );
  }

  /// Tablet design (formerly general_information.dart -> SocialScreen)
  Widget _buildTablet(BuildContext context, SocialState state) {
    final bool isSaving = state is SocialSaving;

    return Column(
      children: <Widget>[
        // Flexible, not a bare SizedBox. In a Column a non-flexible child is
        // laid out with UNBOUNDED height, so `height: 490.h` was taken
        // literally and the update button plus the two spacers below pushed
        // the Column past its parent — the 16px overflow. Wrapped, the
        // SizedBox still asks for 490.h and gets it whenever there is room,
        // but clamps to what is left instead of overflowing. The height is
        // unchanged; the inner scroll view keeps the content reachable either
        // way.
        // CHANGED 18/10/2026 (Moataz: big empty area under the button on
        // iPad / desktop): the card is Expanded instead of a fixed height,
        // so it fills the right-hand pane and the button sits 15 above the
        // bottom edge. The inner scroll view keeps every field reachable.
        // D-183 (18/10/2026): the card ends after its last field (D-146
        // inset) — Flexible, not Expanded; it still scrolls when longer.
        Flexible(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(scrollbars: false),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (_canSeeSocial) ...<Widget>[
                            _bio(),
                            SizedBox(height: 16.sp),
                            if (_canSeeAcademicHistory)
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 16.sp),
                                child: _academicHistory(),
                              ),
                            if (_canSeeSkillsHobbies) ...<Widget>[
                              Padding(
                                padding: EdgeInsets.all(16.sp),
                                child: _skills(),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: _hobbies(),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        if (_canSeeSocial)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildUpdateButton(isSaving: isSaving),
            ],
          ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

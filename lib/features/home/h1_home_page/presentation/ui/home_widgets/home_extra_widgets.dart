/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_extra_widgets.dart
/// Description: The four Adding Widget cards Figma shows that had no
///          `HomeComponents` value at all — `EmployeeMessagesWidget`,
///          `GroupMessagesWidget`, `FormsSubmission` and `LowStocks`.
/// Author: Amr Mesbah
/// Created at: 23/8/2026
///
/// Source: Figma file BuJXLizpGcK5eHVBqQomXc, Settings > Home Layout >
/// Adding Widget, iPad Horizontal View (node 4717:68984). Figures are the
/// placeholder values from the Figma frames, like the rest of the picker.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/helper/history_value.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/grc/helpers/grc_messaging.dart'; // [module:grc]
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_widget_settings.dart';
import 'package:knowticed_plus/core/helper/employee_helper.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/widget_settings/home_picker_dialog.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';
import 'package:knowticed_plus/features/home/helpers/role_access.dart';

/// One recent conversation partner shown on a Messages card.
class _ChatPeer {
  const _ChatPeer({required this.id, required this.name, this.photo});

  /// Employee email (= messaging user id) or group id.
  final String id;
  final String name;
  final String? photo;
}

/// Reads the signed-in employee's recent chats from the Messages module's
/// own collections (18/10/2026 — both cards showed a hard-coded
/// "Moataz Handousa" ×4 and "Group Name", Moataz: "fill out all the
/// application").
abstract final class _RecentChats {
  static String get _me =>
      (AppControllers.employee.employeeEntity?.email ?? '').trim();

  static int _millis(Object? raw) {
    if (raw is Timestamp) return raw.millisecondsSinceEpoch;
    if (raw is num) return raw.toInt();
    if (raw is String) {
      return DateTime.tryParse(raw)?.millisecondsSinceEpoch ?? 0;
    }
    return 0;
  }

  /// Up to [count] colleagues, newest conversation first.
  static Future<List<_ChatPeer>> people(bool isArabic, {int count = 4}) async {
    final String me = _me;
    if (me.isEmpty) return const <_ChatPeer>[];
    final QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
        .instance
        .collection(getBaseUrl('Modules/messages/Connections/$me/Last Message'))
        .get();
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snap.docs
        .toList()
      ..sort((a, b) => _millis(b.data()['Last_Message_Time'])
          .compareTo(_millis(a.data()['Last_Message_Time'])));
    final List<EmployeeEntityPro> all =
        AppControllers.employee.allEmployeesEntities ?? <EmployeeEntityPro>[];
    final List<_ChatPeer> out = <_ChatPeer>[];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
      final String id = doc.id.toLowerCase();
      if (id == me.toLowerCase()) continue;
      // A chat that was opened but never had a message (Message_Type 13 =
      // MessageTypes.none) is not a conversation — Direct Message hides it too.
      final Object? type = doc.data()['Message_Type'];
      if (type == null || type == 13 || doc.data()['Message_Id'] == null) {
        continue;
      }
      EmployeeEntityPro? match;
      for (final EmployeeEntityPro e in all) {
        if ((e.email ?? '').toLowerCase() == id) {
          match = e;
          break;
        }
      }
      if (match == null) continue;
      out.add(_person(match, isArabic, fallbackId: doc.id));
      if (out.length == count) break;
    }
    return out;
  }

  /// [emails] (the Employee Messages gear's pick), in that order; people no
  /// longer in the company are skipped.
  static List<_ChatPeer> chosen(List<String> emails, bool isArabic) {
    final List<EmployeeEntityPro> all =
        AppControllers.employee.allEmployeesEntities ?? <EmployeeEntityPro>[];
    final List<_ChatPeer> out = <_ChatPeer>[];
    for (final String email in emails) {
      for (final EmployeeEntityPro e in all) {
        if ((e.email ?? '').toLowerCase() == email.toLowerCase()) {
          out.add(_person(e, isArabic, fallbackId: email));
          break;
        }
      }
    }
    return out;
  }

  /// 22/10/2026 — Owner: first AND LAST name under the photo (was first +
  /// middle, X-132 20/10/2026 — empty for anyone without a middle name).
  static _ChatPeer _person(EmployeeEntityPro e, bool isArabic,
      {required String fallbackId}) {
    final String first =
        isArabic && (e.firstNameInArabic ?? '').trim().isNotEmpty
            ? e.firstNameInArabic!
            : (e.firstName ?? '');
    final String last = isArabic && (e.lastNameInArabic ?? '').trim().isNotEmpty
        ? e.lastNameInArabic!
        : (e.lastName ?? '');
    return _ChatPeer(
        id: e.email ?? fallbackId,
        name: FormatHelper.capitalize('${first.trim()} ${last.trim()}'.trim()),
        photo: e.photo);
  }

  /// Every group the employee is a member of, newest first (the Group
  /// Messages gear lists them).
  static Future<List<_ChatPeer>> groups(bool isArabic) async {
    final String me = _me;
    if (me.isEmpty) return const <_ChatPeer>[];
    final QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
        .instance
        .collection(getBaseUrl('Modules/messages/Messaging Groups'))
        .where('Is_Deleted', isEqualTo: false)
        .where('Current_Existing_Members', arrayContains: me)
        .get();
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snap.docs
        .toList()
      ..sort((a, b) => _millis(b.data()['Creation_Time'])
          .compareTo(_millis(a.data()['Creation_Time'])));
    return <_ChatPeer>[
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in docs)
        _groupPeer(doc.id, doc.data(), isArabic),
    ];
  }

  static _ChatPeer _groupPeer(
      String id, Map<String, dynamic> d, bool isArabic) {
    final String ar = historyLast(d['Group_Name_Ar']);
    final String name =
        isArabic && ar.trim().isNotEmpty ? ar : historyLast(d['Group_Name']);
    final String image = historyLast(d['Group_Image']);
    return _ChatPeer(id: id, name: name, photo: image.isEmpty ? null : image);
  }
}

/// Function Name: [homeMessagingGroupItems]
///
/// Purpose: The signed-in employee's groups, newest first — the choices of
/// the Group Messages picker.
Future<List<HomePickItem>> homeMessagingGroupItems(bool isArabic) async {
  final HomePickerCacheEntry cache =
      isArabic ? HomePickerCache.groupsAr : HomePickerCache.groupsEn;
  final List<HomePickItem>? cached = cache.fresh;
  if (cached != null) return cached;
  final List<_ChatPeer> groups = await _RecentChats.groups(isArabic);
  return cache.store(<HomePickItem>[
    for (final _ChatPeer g in groups)
      HomePickItem(id: g.id, name: g.name, photo: g.photo, isGroup: true),
  ]);
}

/// Function Name: [homeMessagingPeopleItems]
///
/// Purpose: Every colleague (the signed-in employee left out), by name, with
/// their department — the choices of the Employee Messages picker.
List<HomePickItem> homeMessagingPeopleItems(BuildContext context) {
  final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final String me = _RecentChats._me.toLowerCase();
  final List<HomePickItem> out = <HomePickItem>[];
  for (final EmployeeEntityPro e
      in AppControllers.employee.allEmployeesEntities ??
          <EmployeeEntityPro>[]) {
    final String email = (e.email ?? '').trim();
    if (email.isEmpty || email.toLowerCase() == me) continue;
    final _ChatPeer p = _RecentChats._person(e, isArabic, fallbackId: email);
    String department = '';
    if ((e.departmentId ?? '').isNotEmpty) {
      try {
        department = EmployeeHelper.getEmployeeLocalizeDepartment(
            employee: e, context: context);
      } catch (_) {}
    }
    out.add(HomePickItem(
      id: p.id,
      name: p.name,
      photo: p.photo,
      departmentId: e.departmentId ?? '',
      departmentName: department,
    ));
  }
  return out
    ..sort((HomePickItem a, HomePickItem b) => a.name.compareTo(b.name));
}

/// Width of a contacts card showing [count] people or groups: 100 per
/// contact, 12 between, the 16 padding each side; never under the narrow
/// card (Owner 21/10/2026: the card is as wide as what it shows).
double _contactsCardWidth(int count) {
  final int n = count < 1 ? 1 : count;
  final double w = 100.0 * n + 12.0 * (n - 1) + 32;
  return w < kHomeWidgetNarrowWidth ? kHomeWidgetNarrowWidth : w;
}

/// One row of contacts (people or groups), 100 each, 12 apart.
///
/// 22/10/2026: on a phone four contacts (436) are wider than the screen and
/// the row spilled 113 px past the card. Where the row does not fit it now
/// scales down to the card (FittedBox, never up); IntrinsicHeight keeps the
/// stretched cells, which need a finite height inside the FittedBox.
Widget _contactsRow(List<Widget> contacts) => FittedBox(
    fit: BoxFit.scaleDown,
    child: IntrinsicHeight(
        child: Row(
      // Centred in the card (Owner 21/10/2026).
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < contacts.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: 12.w),
          // At least 100, wider when the name needs it — the full name, no
          // "…" (Owner 21/10/2026: "I have a clear name, why 3 dots?").
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 100.w),
            child: IntrinsicWidth(child: contacts[i]),
          ),
        ],
      ],
    )));

/// Function Name: [openHomeMessagesModule]
///
/// Purpose: Open the Messages module from a home card: the drawer on
/// tablet / desktop; on the phone its bottom-bar tab, or the page pushed
/// over Home when Messages is not in the bar. Groups have no direct-open
/// bridge, so a group's Messages button lands here too.
void openHomeMessagesModule(BuildContext context) {
  final drawer = AppControllers.drawerOrNull;
  if (drawer != null) {
    final int index = drawer.allowedDrawerModules.indexOf(Modules.messages);
    if (index != -1) drawer.updateSelectedIndex(index);
    return;
  }
  if (!Get.isRegistered<NavBarCubit>()) return;
  final List<Modules> bar = Get.find<NavBarCubit>().navBarModules;
  if (bar.contains(Modules.messages)) {
    RoleAccess.controller.jumpToTab(bar.indexOf(Modules.messages));
  } else {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      pageTransitionAnimation: PageTransitionAnimation.fade,
      withNavBar: true,
      screen: Modules.messages.widget,
    );
  }
}

/// The group icon (Figma "Users Group Rounded", same as the picker),
/// centred in the avatar circle.
class _GroupGlyph extends StatelessWidget {
  const _GroupGlyph();

  @override
  Widget build(BuildContext context) => Center(
        child: CustomSvgImage(
          assetPath: kHomeGroupIcon,
          width: 18.r,
          height: 18.r,
          color: AppColors.secondaryText,
        ),
      );
}

/// One avatar + name + Messages button, repeated across the contacts card.
class _MessageContact extends StatelessWidget {
  final String name;

  /// Network photo; null/empty shows the default avatar, or the plain grey
  /// circle Figma uses for a group when [isGroup].
  final String? photo;
  final bool isGroup;
  final VoidCallback? onTap;

  const _MessageContact({
    required this.name,
    this.photo,
    this.isGroup = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final bool hasPhoto = (photo ?? '').startsWith('http');
    return Column(
      // 12:30: photo at the top, button on the bottom inset.
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: hasPhoto
              ? Image.network(
                  photo!,
                  width: 32.r,
                  height: 32.r,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => isGroup
                      ? const _GroupGlyph()
                      : CustomSvgImage(
                          assetPath: HomeWidgetSvg.avatar,
                          width: 32.r,
                          height: 32.r,
                          fit: BoxFit.cover,
                        ),
                )
              : isGroup
                  // Owner 21/10/2026: a group with no picture showed an
                  // empty black circle — the Messages group icon instead.
                  ? const _GroupGlyph()
                  : CustomSvgImage(
                      assetPath: HomeWidgetSvg.avatar,
                      width: 32.r,
                      height: 32.r,
                      fit: BoxFit.cover,
                    ),
        ),
        SizedBox(height: 4.r),
        // Owner item 194 (21/10/2026): nothing under 12 on the tablet.
        Text(
          name,
          style: CardStyles.label(12),
          maxLines: 1,
          softWrap: false,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.r),
        HomeCardButton(label: l.messages, onTap: onTap),
      ],
    );
  }
}

/// Figma: the four-employee contacts card — the four most recent
/// conversation partners; Messages opens that chat.
class EmployeeMessagesWidget extends StatefulWidget {
  /// Carried for parity with every other component widget.
  final HomeComponentModel model;

  const EmployeeMessagesWidget({super.key, required this.model});

  @override
  State<EmployeeMessagesWidget> createState() => _EmployeeMessagesWidgetState();
}

class _EmployeeMessagesWidgetState extends State<EmployeeMessagesWidget> {
  Future<List<_ChatPeer>>? _peers;
  bool? _peersArabic;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    // The names are resolved in the language active when they load, so a
    // switch to Arabic must load them again (Moataz 22/10/2026: names stayed
    // English after switching).
    if (_peersArabic != null && _peersArabic != ar) _peers = null;
    _peersArabic = ar;
    // Owner 21/10/2026: the people picked in the gear, else the most
    // recent chats.
    final List<String> picked = widget.model.widgetSettings
        .list(HomeSettingKey.people, const <String>[]);
    _peers ??= picked.isNotEmpty
        ? Future<List<_ChatPeer>>.value(_RecentChats.chosen(picked, ar))
        : _RecentChats.people(ar).catchError((Object _) => const <_ChatPeer>[]);
  }

  @override
  void didUpdateWidget(covariant EmployeeMessagesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The gear saved another pick: load again.
    if (oldWidget.model.settings != widget.model.settings) {
      _peers = null;
      didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final int picked = widget.model.widgetSettings
        .list(HomeSettingKey.people, const <String>[]).length;
    return HomeWidgetCard(
      title: l.employeeMessages,
      icon: HomeWidgetSvg.messages,
      // As wide as the people it shows: the pick, else 4 recent chats.
      width: _contactsCardWidth(picked > 0 ? picked : 4),
      child: FutureBuilder<List<_ChatPeer>>(
        future: _peers,
        builder: (context, snap) {
          final List<_ChatPeer> peers = snap.data ?? const <_ChatPeer>[];
          if (snap.connectionState == ConnectionState.done && peers.isEmpty) {
            return Center(
              child: Text(l.noDataAvailable, style: CardStyles.label(12)),
            );
          }
          return _contactsRow(<Widget>[
            if (peers.isEmpty)
              for (int i = 0; i < (picked > 0 ? picked : 4); i++)
                const _MessageContact(name: '—')
            else
              for (final _ChatPeer p in peers)
                _MessageContact(
                  name: p.name,
                  photo: p.photo,
                  onTap: () => openGrcChat(context, p.id), // [module:grc|onTap: null,]
                ),
          ]);
        },
      ),
    );
  }
}

/// Figma: the single-group messages card — the employee's newest group;
/// Messages opens the Messages module.
class GroupMessagesWidget extends StatefulWidget {
  final HomeComponentModel model;

  const GroupMessagesWidget({super.key, required this.model});

  @override
  State<GroupMessagesWidget> createState() => _GroupMessagesWidgetState();
}

class _GroupMessagesWidgetState extends State<GroupMessagesWidget> {
  Future<List<_ChatPeer>>? _groups;
  bool? _groupsArabic;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    if (_groupsArabic != null && _groupsArabic != ar) _groups = null;
    _groupsArabic = ar;
    _groups ??=
        _RecentChats.groups(ar).catchError((Object _) => const <_ChatPeer>[]);
  }

  List<String> get _picked =>
      widget.model.widgetSettings.list(HomeSettingKey.groups, const <String>[]);

  /// The gear's groups (1–4, in pick order) the employee is still in; none
  /// picked = the newest group.
  List<_ChatPeer> _shown(List<_ChatPeer> groups) {
    if (groups.isEmpty) return const <_ChatPeer>[];
    final List<_ChatPeer> out = <_ChatPeer>[
      for (final String id in _picked)
        ...groups.where((_ChatPeer g) => g.id == id),
    ];
    return out.isEmpty ? <_ChatPeer>[groups.first] : out;
  }

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final int picked = _picked.length;
    return HomeWidgetCard(
      title: l.groupMessages,
      icon: HomeWidgetSvg.messages,
      // As wide as the groups it shows (Owner 21/10/2026).
      width: _contactsCardWidth(picked > 0 ? picked : 1),
      child: FutureBuilder<List<_ChatPeer>>(
        future: _groups,
        builder: (context, snap) {
          final List<_ChatPeer> shown =
              _shown(snap.data ?? const <_ChatPeer>[]);
          if (snap.connectionState == ConnectionState.done && shown.isEmpty) {
            return Center(
              child: Text(l.noDataAvailable, style: CardStyles.label(12)),
            );
          }
          return _contactsRow(<Widget>[
            if (shown.isEmpty)
              const _MessageContact(name: '—', isGroup: true)
            else
              for (final _ChatPeer g in shown)
                _MessageContact(
                  name: g.name,
                  photo: g.photo,
                  isGroup: true,
                  onTap: () => openHomeMessagesModule(context),
                ),
          ]);
        },
      ),
    );
  }
}

/// Figma: "Low Stocks" — reorder thresholds, a remaining-stock bar, and the
/// products currently under their reorder level.
class LowStocks extends StatelessWidget {
  final HomeComponentModel model;

  const LowStocks({super.key, required this.model});

  /// Units left against the reorder quantity, as Figma labels them.
  static const int _left = 30;
  static const int _reorderLevel = 40;
  static const int _reorderQuantity = 100;

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    return HomeWidgetCard(
      title: l.lowStocks,
      icon: HomeWidgetSvg.lowStock,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${l.reorderLevel} $_reorderLevel',
                  style: CardStyles.label(12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '${l.reorderQuantity} $_reorderQuantity',
                  style: CardStyles.label(12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.r),
          Row(
            children: <Widget>[
              Text(
                '$_left ${l.left}',
                style: CardStyles.value(14).copyWith(color: AppColors.red),
              ),
              const Spacer(),
              Text('$_reorderQuantity', style: CardStyles.label(12)),
            ],
          ),
          SizedBox(height: 2.r),
          Stack(
            children: <Widget>[
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _left / _reorderQuantity,
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.r),
          // Products under the threshold. The first reads as selected, the
          // rest as plain chips, exactly as Figma draws the row.
          Row(
            children: <Widget>[
              for (int i = 0; i < 4; i++) ...<Widget>[
                if (i > 0) SizedBox(width: 4.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: i == 0 ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      l.productName,
                      style: CardStyles.label(12).copyWith(
                        color: i == 0 ? AppColors.textButton : AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

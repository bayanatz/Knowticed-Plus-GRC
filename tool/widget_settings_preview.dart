// Preview harness for the home widget settings gear (D-242) — NOT part of the
// app. Shows the REAL Home Layout wrappers (red minus + gear), the REAL cards
// and the REAL settings dialog on a simulator without Firebase or a sign-in:
//
//   flutter run -d <device> -t tool/widget_settings_preview.dart
//   (--dart-define=KP_LOCALE=ar for Arabic, --dart-define=KP_DARK=true for dark)
//
// The data is demo data (a handful of requests and to-dos) so every setting
// visibly changes a card.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/base_repository/home_base_repository.dart';
import 'package:knowticed_plus/features/home/h1_home_page/domain/enums/home_components.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_state.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/services_home_stats_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/add_component_wrapper.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/remove_component_wrapper.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_log_service.dart';
import 'package:knowticed_plus/features/todo/domain/base_repository/todo_base_repository.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/generated/l10n.dart';

const String _kLocale = String.fromEnvironment('KP_LOCALE', defaultValue: 'en');
const bool _kDark = bool.fromEnvironment('KP_DARK');

class _FakeServicesRepo implements CreateServicesRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHomeRepo implements HomeBaseRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PreviewServicesStats extends ServicesHomeStatsCubit {
  _PreviewServicesStats() : super(repository: _FakeServicesRepo());

  @override
  void ensureLoaded() {}
}

class _TodoRepo implements TodoBaseRepository {
  _TodoRepo(this.todos);
  final List<TodoEntity> todos;

  @override
  Stream<List<TodoEntity>> watchTodos({required String ownerEmail}) async* {
    yield todos;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Access implements TodoAccess {
  @override
  String get currentUserEmail => 'demo@knowticed.com';
  @override
  bool get canView => true;
  @override
  bool get canEdit => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Log implements TodoLogService {
  @override
  void log(String action) {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ServiceRequestRecord _req(String name, String dept, String state, int daysAgo,
        {double? sla, String me = 'demo@knowticed.com', String by = 'x@y.z'}) =>
    ServiceRequestRecord(
      stateKey: state,
      createdAt: DateTime.now().subtract(Duration(days: daysAgo)),
      requesterEmail: by == 'me' ? me : by,
      requesterDepartmentId: dept,
      owningDepartmentId: dept,
      slaUsed: sla,
      summary: ServiceRequestSummary(
        nameEnglish: name,
        nameArabic: name,
        departmentEnglish: dept,
        departmentArabic: dept,
      ),
    );

List<ServiceRequestRecord> _records() => <ServiceRequestRecord>[
      _req('Laptop Replacement', 'IT', 'pending', 1, sla: 0.9, by: 'me'),
      _req('VPN Access', 'IT', 'inprogress', 2, sla: 0.85),
      _req('Office Supplies', 'Operations', 'pending', 3, sla: 0.4),
      _req('Annual Leave', 'HR', 'approved', 5),
      _req('Badge Reissue', 'HR', 'branchsla', 8),
      _req('Parking Permit', 'Operations', 'rejected', 12, by: 'me'),
      _req('Software License', 'IT', 'done', 20),
      _req('Desk Move', 'Operations', 'cancel', 40),
      _req('Training Request', 'HR', 'pending', 45, sla: 0.2),
      _req('Travel Booking', 'Finance', 'approved', 70, by: 'me'),
      _req('Expense Claim', 'Finance', 'branchsla', 90),
    ];

List<TodoEntity> _todos() {
  final DateTime now = DateTime.now();
  TodoEntity t(String name, TodoPriority p, int endDays,
          {bool done = false, int made = 1}) =>
      TodoEntity(
        id: name,
        ownerEmail: 'demo@knowticed.com',
        name: name,
        priority: p,
        isDone: done,
        endAt: now.add(Duration(days: endDays)),
        createdAt: now.subtract(Duration(days: made)),
      );
  return <TodoEntity>[
    t('Prepare quarterly report', TodoPriority.high, 0, made: 1),
    t('Call supplier', TodoPriority.low, 3, made: 2),
    t('Book meeting room', TodoPriority.medium, -2, done: true, made: 3),
    t('Review contracts', TodoPriority.high, -1, made: 4),
    t('Plan team offsite', TodoPriority.medium, 10, made: 5),
    t('Update onboarding guide', TodoPriority.low, 6, made: 6),
    t('Renew licences', TodoPriority.high, 20, made: 7),
  ];
}

Size _design(double w, double h) {
  if (w >= 1920) return const Size(1920, 1080);
  if (w >= 1366) return const Size(1366, 768);
  if (w >= 768) return w > h ? const Size(1024, 768) : const Size(768, 1024);
  return w > h ? const Size(812, 375) : const Size(375, 812);
}

/// Registers the fakes the cards read. [dark] / [locale] default to the
/// `--dart-define`s; the screenshot test passes its own.
Future<void> initWidgetSettingsPreview({bool? dark, String? locale}) async {
  await GetStorage.init();
  if (!Get.isRegistered<HapticController>()) Get.put(HapticController());
  // Not AppTheme.initTheme: that forces a Get app update, which a test run
  // does not allow outside a test body. The brand colours are the defaults.
  AppTheme.isDark = dark ?? _kDark;
  AppColors.currentThemeColors =
      AppTheme.isDark ? AppTheme.darkThemeColors : AppTheme.lightThemeColors;
  final GetIt it = GetIt.instance;
  if (!it.isRegistered<TodoBaseRepository>()) {
    it
      ..registerSingleton<TodoBaseRepository>(_TodoRepo(_todos()))
      ..registerSingleton<TodoAccess>(_Access())
      ..registerSingleton<TodoLogService>(_Log());
  }
  await S.load(Locale(locale ?? _kLocale));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initWidgetSettingsPreview();
  runApp(const WidgetSettingsPreviewApp());
}

class WidgetSettingsPreviewApp extends StatelessWidget {
  const WidgetSettingsPreviewApp({super.key, this.locale, this.dark});

  final String? locale;
  final bool? dark;

  String get _loc => locale ?? _kLocale;
  bool get _isDark => dark ?? _kDark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
      final Size m = MediaQuery.sizeOf(context);
      return ScreenUtilInit(
        minTextAdapt: true,
        splitScreenMode: true,
        ensureScreenSize: true,
        designSize: _design(m.width, m.height),
        builder: (BuildContext _, Widget? __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _isDark ? AppColors.darkTheme : AppColors.lightTheme,
          locale: Locale(_loc),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<ServicesHomeStatsCubit>(create: (_) {
                final _PreviewServicesStats s = _PreviewServicesStats();
                // ignore: invalid_use_of_visible_for_testing_member
                s.debugLoad(
                  records: _records(),
                  mine: _records()
                      .where((ServiceRequestRecord r) =>
                          r.requesterEmail == 'demo@knowticed.com')
                      .toList(),
                  departments: const <ServiceDepartmentOption>[
                    ServiceDepartmentOption(
                        id: 'IT', nameEnglish: 'IT', nameArabic: 'IT'),
                    ServiceDepartmentOption(
                        id: 'HR', nameEnglish: 'HR', nameArabic: 'HR'),
                    ServiceDepartmentOption(
                        id: 'Operations',
                        nameEnglish: 'Operations',
                        nameArabic: 'Operations'),
                  ],
                  services: 14,
                );
                return s;
              }),
              BlocProvider<AppHomeCubit>(create: (_) {
                final AppHomeCubit cubit =
                    AppHomeCubit(homeRepository: _FakeHomeRepo());
                int i = 0;
                for (final HomeComponents c in _placed) {
                  cubit.editComponent(c.getModel(
                      rowNumber: 1 + i ~/ 4, columnNumber: 1 + i % 4));
                  i++;
                }
                cubit.selectComponentToEdit(rowIndex: 3, columnIndex: 1);
                return cubit;
              }),
            ],
            child: const _PreviewPage(),
          ),
        ),
      );
    });
  }
}

const List<HomeComponents> _placed = <HomeComponents>[
  HomeComponents.requestedService,
  HomeComponents.serviceActions,
  HomeComponents.serviceStatus,
  HomeComponents.myServices,
  HomeComponents.nearBreachedSLA,
  HomeComponents.serviceOverview,
  HomeComponents.myRequestServices,
  HomeComponents.myTodoList,
  HomeComponents.myTodoStatus,
  HomeComponents.myTodoBox,
];

class _PreviewPage extends StatefulWidget {
  const _PreviewPage();

  @override
  State<_PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<_PreviewPage> {
  bool picker = false;

  @override
  Widget build(BuildContext context) {
    final AppHomeCubit cubit = context.read<AppHomeCubit>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 8.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      picker
                          ? 'Adding Widget (preview)'
                          : 'Home Layout (preview)',
                      style: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.text),
                    ),
                  ),
                  TextButton(
                    key: const ValueKey<String>('toggle'),
                    onPressed: () => setState(() => picker = !picker),
                    child: Text(picker ? 'Home Layout' : 'Adding Widget'),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: SingleChildScrollView(
                  child: BlocBuilder<AppHomeCubit, HomeState>(
                    builder: (BuildContext context, HomeState _) {
                      final List<HomeComponentModel> models = picker
                          ? cubit.readyToAddComponent
                              .where((HomeComponentModel m) =>
                                  _placed.contains(m.component))
                              .toList()
                          : <HomeComponentModel>[
                              for (int i = 0; i < _placed.length; i++)
                                if (cubit.getEditedComponent(
                                        rowIndex: 1 + i ~/ 4,
                                        columnIndex: 1 + i % 4) !=
                                    null)
                                  cubit.getEditedComponent(
                                      rowIndex: 1 + i ~/ 4,
                                      columnIndex: 1 + i % 4)!,
                            ];
                      // Home Layout: the SAME grid as edit_home_page.dart —
                      // 1 / 2 / 4 cells per line, every card fills its cell.
                      final double panel =
                          MediaQuery.sizeOf(context).width - 30.w;
                      final bool portrait = MediaQuery.orientationOf(context) ==
                          Orientation.portrait;
                      final int perLine = panel < 600
                          ? 1
                          : (portrait ? 2 : HomeCardMetrics.columns);
                      final double cellW =
                          HomeCardMetrics.cellWidth(panel, perLine);
                      return Wrap(
                        spacing: HomeCardMetrics.gap,
                        runSpacing: HomeCardMetrics.gap,
                        children: <Widget>[
                          for (final HomeComponentModel m in models)
                            picker
                                ? SizedBox(
                                    width: cellW,
                                    child: AddComponentWrapper(
                                      model: m,
                                      component: HomeGridCell(
                                        width: cellW,
                                        inset: HomeCardMetrics.badgeInset,
                                        child: m.component.widget(m)!,
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: cellW,
                                    child: RemoveComponentWrapper(
                                      model: m,
                                      component: HomeGridCell(
                                        width: cellW,
                                        inset: HomeCardMetrics.badgeInset,
                                        child: m.component.widget(m)!,
                                      ),
                                    ),
                                  ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

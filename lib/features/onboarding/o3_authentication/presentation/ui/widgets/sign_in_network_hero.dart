/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: sign_in_network_hero.dart
/// Description: "Org Network" hero panel for the sign-in screen — Knowticed sits at the top
///          and branches into every module, ordered by what supports what. Lights flow
///          along the lines, modules ping in turn, and the whole network reacts to the form.
/// Created at: 24/10/2026 (Moataz: "use my icons, show me the org network first")
/// Updated: 24/10/2026 (Moataz: "too normal, 1980 — more animated, dark, no white boxes,
///          one logo"): glowing orbs with yellow icons, flowing dashes and comets, stars.
/// Updated: 24/10/2026 (Moataz: "different colours left and right, the circle kills the
///          logo — use the white logo"): same ground as the form, the theme's own logo.
/// Updated: 24/10/2026 (Moataz: "all the modules, with the hierarchy — what helps the
///          other"; "the pulses are too much"): all 19 modules in four layers drawn from
///          the real imports between the feature folders; one calm light per line.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/helper/knowticed_logo.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Set to false to bring back the photo panel. Nothing else needs to change.
const bool kSignInNetworkHero = true;

/// What the sign-in form is doing, so the network can react to it.
enum SignInHeroMode {
  /// Nothing focused.
  idle,

  /// A field has focus: the whole network lights up.
  active,

  /// Sign In was pressed: every module lights in turn, top to bottom.
  waking,
}

const Color _white = Color(0xFFFFFFFF);
const Color _black = Color(0xFF000000);

/// Every colour the scene uses, for one theme. The ground itself is the same
/// `AppColors.background` as the form, so the two halves read as one surface.
class _Palette {
  _Palette({required this.dark, required Color brand})
      : glow = brand,
        line = dark
            ? brand
            : HSLColor.fromColor(brand).withLightness(0.40).toColor(),
        icon = dark ? brand : const Color(0xFF26262B),
        ink = dark ? _white : _black,
        wakeHead = dark
            ? _white
            : HSLColor.fromColor(brand).withLightness(0.34).toColor(),
        orbHi = dark
            ? _white.withValues(alpha: 0.16)
            : brand.withValues(alpha: 0.38),
        orbLo = dark
            ? _white.withValues(alpha: 0.03)
            : brand.withValues(alpha: 0.08),
        orbBorder = dark
            ? _white.withValues(alpha: 0.2)
            : _black.withValues(alpha: 0.14);

  final bool dark;
  final Color glow; // the big soft yellow washes (always the brand yellow)
  final Color line; // flowing light, rings, lit borders
  final Color icon; // module icons
  final Color ink; // labels, stars, resting lines
  final Color wakeHead; // the bright comet on Sign In
  final Color orbHi;
  final Color orbLo;
  final Color orbBorder;
}

// ───────────────────────────────────────────────────────────────────────────
// The map. Layers come from the real `import` links between the feature
// folders (24/10/2026): Roles, Settings and Notifications are used by almost
// every module, so they sit right under Knowticed. Calendar and Home read from
// Time Tracker, To-Do, Form Builder and GRC, so they sit at the bottom.
// ───────────────────────────────────────────────────────────────────────────

// Design space the tree is drawn in; it is scaled to fit the panel.
const double _designW = 680;
const double _designH = 840;
const Offset _rootPoint = Offset(340, 82);
const List<double> _tierY = <double>[250, 420, 590, 760];

/// Risk Management's own icon (supplied by Moataz 24/10/2026).
const String _riskIcon =
    'assets/icons_assets/main_icons_assets/ic_module_risk_management.svg';

/// Optical size corrections, judged on screen. The new icon set is drawn to
/// one weight and one size, so only the older Home icon (which read larger)
/// still needs one.
const Map<String, double> _iconZoom = <String, double>{};

class _Mod {
  const _Mod(this.id, this.tier, this.x, this.label);
  final String id;
  final int tier; // 1 = foundations … 4 = overview
  final double x;
  final String Function(S) label;

  Offset get center => Offset(x, _tierY[tier - 1]);
}

const List<_Mod> _mods = <_Mod>[
  // 1 · foundations everything stands on
  _Mod('roles', 1, 170, _lRoles),
  _Mod('notification', 1, 510, _lNotifications),
  // 2 · structure, people, data
  _Mod('hr', 2, 57, _lHr),
  _Mod('orgChart', 2, 170, _lOrgChart),
  _Mod('services', 2, 283, _lServices),
  _Mod('formBuilder', 2, 397, _lFormBuilder),
  _Mod('messages', 2, 510, _lMessages),
  _Mod('database', 2, 623, _lDatabase),
  // 3 · everyday work and governance
  _Mod('timeTracker', 3, 50, _lTimeTracker),
  _Mod('todo', 3, 146, _lToDo),
  _Mod('tasks', 3, 243, _lTasks),
  _Mod('crm', 3, 340, _lCrm),
  _Mod('grc', 3, 437, _lGrc),
  _Mod('knowledgeHub', 3, 534, _lKnowledgeHub),
  _Mod('inventory', 3, 630, _lInventory),
  // 4 · overview and assessment
  _Mod('calendar', 4, 195, _lCalendar),
  _Mod('qiyas', 4, 420, _lQiyas),
  _Mod('risk', 4, 560, _lRisk),
];

String _lRoles(S s) => s.roles;
String _lNotifications(S s) => s.notifications;
String _lHr(S s) => s.hr;
String _lOrgChart(S s) => s.orgChart;
String _lServices(S s) => s.services;
String _lFormBuilder(S s) => s.formBuilder;
String _lMessages(S s) => s.messages;
String _lDatabase(S s) => s.database;
String _lTimeTracker(S s) => s.timeTracker;
String _lToDo(S s) => s.toDo;
String _lTasks(S s) => s.tasks;
String _lCrm(S s) => s.crm;
String _lGrc(S s) => s.grc;
String _lKnowledgeHub(S s) => s.knowledgeHub;
String _lInventory(S s) => s.inventory;
String _lCalendar(S s) => s.calendar;
String _lQiyas(S s) => s.qiyas;
String _lRisk(S s) => s.riskManagement;

/// The module's icon from the app's single source (`Modules.iconPath`), so the
/// map shows exactly what the side menu, bottom bar and Home widgets show (R-22).
/// Org Chart, CRM, Time Tracker and Notifications still have their older icon
/// until the new ones arrive.
String _iconOf(String id) {
  switch (id) {
    case 'roles':
      return Modules.roles.iconPath;
    case 'notification':
      return Modules.notification.iconPath;
    case 'hr':
      return Modules.hr.iconPath;
    case 'orgChart':
      return Modules.employees.iconPath;
    case 'services':
      return Modules.services.iconPath;
    case 'formBuilder':
      return Modules.formBuilder.iconPath;
    case 'messages':
      return Modules.messages.iconPath;
    case 'database':
      return Modules.database.iconPath;
    case 'timeTracker':
      return Modules.timeTracker.iconPath;
    case 'tasks':
      return Modules.tasks.iconPath;
    case 'todo':
      return Modules.todo.iconPath;
    case 'crm':
      return Modules.crm.iconPath;
    case 'grc':
      return Modules.grc.iconPath;
    case 'knowledgeHub':
      return Modules.knowledgeHub.iconPath;
    case 'inventory':
      return Modules.inventory.iconPath;
    case 'calendar':
      return Modules.events.iconPath;
    case 'qiyas':
      return Modules.qiyas.iconPath;
    default:
      return _riskIcon;
  }
}

/// "A helps B": the line runs from A down to B.
const List<List<String>> _links = <List<String>>[
  <String>['root', 'roles'],
  <String>['root', 'notification'],
  // foundations → structure, people, data
  <String>['roles', 'hr'],
  <String>['roles', 'orgChart'],
  <String>['roles', 'services'],
  <String>['notification', 'services'],
  <String>['notification', 'messages'],
  <String>['notification', 'formBuilder'],
  <String>['notification', 'database'],
  // structure → everyday work and governance
  <String>['hr', 'timeTracker'],
  <String>['orgChart', 'timeTracker'],
  <String>['orgChart', 'todo'],
  <String>['orgChart', 'tasks'],
  // CRM: customers come in through Services, are owned by the people in the
  // Org Chart and are talked to through Messages (the code has CRM standing
  // alone, so these are product links, not imports).
  <String>['orgChart', 'crm'],
  <String>['services', 'crm'],
  <String>['messages', 'crm'],
  <String>['formBuilder', 'grc'],
  <String>['messages', 'grc'],
  <String>['messages', 'knowledgeHub'],
  <String>['database', 'inventory'],
  // work and governance → overview and assessment
  <String>['grc', 'qiyas'],
  <String>['grc', 'risk'],
  <String>['timeTracker', 'calendar'],
  <String>['todo', 'calendar'],
  <String>['tasks', 'calendar'],
  <String>['crm', 'calendar'], // customer meetings and follow-ups
];

class _Edge {
  _Edge({
    required this.from,
    required this.to,
    required this.delay,
    required this.period,
    required this.phase,
    required this.wakeStart,
    required this.wakeDur,
  }) : path = _curve(from, to);

  final Offset from;
  final Offset to;
  final double delay; // seconds before it starts to grow on open
  final double period; // seconds a light takes to travel it
  final double phase; // 0..1 so the lights are not in step
  final double wakeStart; // seconds into the Sign In cascade
  final double wakeDur;
  final Path path;

  static Path _curve(Offset a, Offset b) {
    final double mid = (a.dy + b.dy) / 2;
    return Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(a.dx, mid, b.dx, mid, b.dx, b.dy);
  }
}

/// When the Sign In cascade reaches each module (seconds into it).
final Map<String, double> _flashAt = <String, double>{};

/// Total length of the Sign In cascade, in seconds.
const double _wakeTotal = 2.8;

List<_Edge> _buildEdges() {
  final Map<String, _Mod> byId = <String, _Mod>{
    for (final _Mod m in _mods) m.id: m
  };
  final Map<int, int> perTier = <int, int>{};
  final List<_Edge> edges = <_Edge>[];
  int n = 0;
  for (final List<String> l in _links) {
    final _Mod child = byId[l[1]]!;
    final bool fromRoot = l[0] == 'root';
    final Offset from = fromRoot
        ? Offset(_rootPoint.dx, _rootPoint.dy + 52)
        : byId[l[0]]!.center + const Offset(0, 62); // below the parent's name
    final Offset to = child.center + const Offset(0, -34);
    final int k = perTier[child.tier] = (perTier[child.tier] ?? -1) + 1;
    final double ws = 0.1 + 0.5 * (child.tier - 1) + 0.035 * k;
    edges.add(_Edge(
      from: from,
      to: to,
      delay: 0.3 * (child.tier - 1) + 0.03 * k,
      period: 3.2 + ((n * 7) % 12) * 0.13,
      phase: (n * 0.29 + 0.15) % 1,
      wakeStart: ws,
      wakeDur: 0.55,
    ));
    _flashAt[child.id] = math.min(_flashAt[child.id] ?? 99, ws + 0.55);
    n++;
  }
  return edges;
}

final List<_Edge> _edges = _buildEdges();

class _Star {
  const _Star(
      this.x, this.y, this.r, this.speed, this.twinkle, this.phase, this.alpha);
  final double x;
  final double y;
  final double r;
  final double speed;
  final double twinkle;
  final double phase;
  final double alpha;
}

final List<_Star> _stars = () {
  final math.Random rnd = math.Random(11);
  return List<_Star>.generate(
    80,
    (int i) => _Star(
      rnd.nextDouble(),
      rnd.nextDouble(),
      0.6 + rnd.nextDouble() * 1.4,
      0.004 + rnd.nextDouble() * 0.01,
      0.5 + rnd.nextDouble() * 1.6,
      rnd.nextDouble() * 6.28,
      0.2 + rnd.nextDouble() * 0.35,
    ),
  );
}();

class SignInNetworkHero extends StatefulWidget {
  const SignInNetworkHero({super.key, required this.mode});

  final ValueListenable<SignInHeroMode> mode;

  @override
  State<SignInNetworkHero> createState() => _SignInNetworkHeroState();
}

class _SignInNetworkHeroState extends State<SignInNetworkHero>
    with TickerProviderStateMixin {
  /// Seconds the opening sequence lasts.
  static const double _enterTotal = 3.0;

  /// Free-running clock for lights, pings and bobbing (3600 s, never seen to wrap).
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3600),
  );

  /// Plays once on open: the core flares, lines grow, modules pop in.
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (_enterTotal * 1000).round()),
  );

  /// 0 → 1 while a field has focus.
  late final AnimationController _active = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  /// Runs once per Sign In press; modules light in turn as it advances.
  late final AnimationController _wake = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (_wakeTotal * 1000).round()),
  );

  @override
  void initState() {
    super.initState();
    widget.mode.addListener(_onMode);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the system "reduce motion" setting: show the finished frame.
    if (MediaQuery.of(context).disableAnimations) {
      _loop.stop();
      _enter.value = 1;
    } else {
      if (!_loop.isAnimating) _loop.repeat();
      if (_enter.status == AnimationStatus.dismissed) _enter.forward();
    }
  }

  void _onMode() {
    final SignInHeroMode m = widget.mode.value;
    if (m == SignInHeroMode.idle) {
      _active.reverse();
      _wake.value = 0;
    } else {
      _active.forward();
      if (m == SignInHeroMode.waking) _wake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.mode.removeListener(_onMode);
    _loop.dispose();
    _enter.dispose();
    _active.dispose();
    _wake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final _Palette p = _Palette(dark: dark, brand: AppColors.primary);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double w = box.maxWidth;
        final double h = box.maxHeight;
        final double scale = math.min(w / _designW, h / _designH) * 0.94;
        final Offset origin =
            Offset((w - _designW * scale) / 2, (h - _designH * scale) / 2);
        Offset at(Offset p) => origin + p * scale;

        return ClipRect(
          child: ColoredBox(
            // Same ground as the form beside it.
            color: AppColors.background,
            child: AnimatedBuilder(
              animation:
                  Listenable.merge(<Listenable>[_loop, _enter, _active, _wake]),
              builder: (BuildContext context, _) {
                final double sec = _loop.value * 3600;
                final double enterSec = _enter.value * _enterTotal;
                final double active = Curves.easeOut.transform(_active.value);
                final double wakeSec = _wake.value * _wakeTotal;
                final double drift = math.sin(sec / 16 * 2 * math.pi);
                final double washes = dark ? 1.0 : 1.35;

                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _glow(
                        p.glow,
                        (0.22 + 0.08 * active) * washes,
                        w * 0.9,
                        Offset(w * 0.05 + drift * w * 0.05,
                            -h * 0.20 + drift * h * 0.03)),
                    // The washes stay fully inside the panel so none of them is
                    // cut into a hard edge where the panel meets the form.
                    _glow(p.glow, 0.10 * washes, w * 0.6,
                        Offset(w * 0.08 - drift * w * 0.04, h * 0.68)),
                    _glow(p.glow, 0.06 * washes, w * 0.55,
                        Offset(w * 0.38 + drift * w * 0.04, h * 0.35)),
                    CustomPaint(
                      size: Size(w, h),
                      painter: _ScenePainter(
                        origin: origin,
                        scale: scale,
                        enterSec: enterSec,
                        sec: sec,
                        active: active,
                        wakeSec: wakeSec,
                        p: p,
                      ),
                    ),
                    for (int i = 0; i < _mods.length; i++)
                      _node(_mods[i], i, s, at(_mods[i].center), scale,
                          enterSec, sec, active, wakeSec, p),
                    _root(at(_rootPoint), scale, enterSec, sec, active, p),
                    // Soft fade into the page at the bottom, so the glows do
                    // not end in a visible line (phone: the form sits below).
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: h * 0.12,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                AppColors.background.withValues(alpha: 0),
                                AppColors.background,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _glow(Color color, double alpha, double d, Offset topLeft) {
    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      child: IgnorePointer(
        child: Container(
          width: d,
          height: d,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: <Color>[
              color.withValues(alpha: alpha.clamp(0.0, 1.0)),
              color.withValues(alpha: 0),
            ]),
          ),
        ),
      ),
    );
  }

  /// Pop-in factor (0..1+) for something that starts [delay] s after the page opens.
  double _pop(double enterSec, double delay) =>
      Curves.easeOutBack.transform(((enterSec - delay) / 0.7).clamp(0.0, 1.0));

  Widget _node(
    _Mod m,
    int index,
    S s,
    Offset c,
    double scale,
    double enterSec,
    double sec,
    double active,
    double wakeSec,
    _Palette p,
  ) {
    final int inTier =
        _mods.where((_Mod o) => o.tier == m.tier).toList().indexOf(m);
    final double pop =
        _pop(enterSec, 0.3 * (m.tier - 1) + 0.35 + 0.04 * inTier);
    final double bob =
        math.sin(sec / 5 * 2 * math.pi + index * 1.3) * 3.5 * scale;
    final double flash =
        ((wakeSec - (_flashAt[m.id] ?? 99)) / 0.4).clamp(0.0, 1.0);
    final double lit = math.max(active, flash);
    final double d = 58 * scale;
    final double fs = math.max(8.5, 11.5 * scale);

    return Positioned(
      left: c.dx - 80 * scale,
      top: c.dy - d / 2 - 30 * scale,
      width: 160 * scale,
      child: Opacity(
        opacity: pop.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, bob),
          child: Transform.scale(
            scale: 0.6 + 0.4 * pop,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: d + 60 * scale,
                  height: d + 60 * scale,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        width: d,
                        height: d,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.35, -0.45),
                            radius: 1.0,
                            colors: <Color>[
                              Color.lerp(p.orbHi, p.glow.withValues(alpha: 0.6),
                                  flash)!,
                              Color.lerp(p.orbLo,
                                  p.glow.withValues(alpha: 0.14), flash)!,
                            ],
                          ),
                          // No outline on a light ground (Moataz 24/10/2026):
                          // the soft fill and glow carry the circle.
                          border: p.dark
                              ? Border.all(
                                  color: Color.lerp(p.orbBorder, p.line, lit)!,
                                  width: 1.2,
                                )
                              : null,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: p.glow.withValues(
                                  alpha: (p.dark ? 0.07 : 0.14) + 0.45 * lit),
                              blurRadius: (14 + 20 * lit) * scale,
                              spreadRadius: 1.5 * lit * scale,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            CustomSvgImage(
                              assetPath: _iconOf(m.id),
                              width: 26 * scale * (_iconZoom[m.id] ?? 1.0),
                              height: 26 * scale * (_iconZoom[m.id] ?? 1.0),
                              fit: BoxFit.contain,
                              color: p.icon,
                            ),
                            if (m.id == 'timeTracker')
                              // A real hand ticking round the clock icon.
                              CustomPaint(
                                size: Size.square(26 * scale),
                                painter: _ClockHandPainter(
                                  angle: sec / 12 * 2 * math.pi,
                                  color: p.icon,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, -26 * scale),
                  // No names on a phone (Moataz 24/10/2026); elsewhere a long
                  // name shrinks to fit instead of being cut.
                  child: (scale < 0.65)
                      ? const SizedBox.shrink()
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            m.label(s),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: fs,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              color: p.ink.withValues(alpha: 0.55 + 0.35 * lit),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The only logo on the screen: the theme's own file (white in dark mode),
  /// no disc behind it, on a soft glow with rings that breathe outward.
  Widget _root(Offset c, double scale, double enterSec, double sec,
      double active, _Palette p) {
    final double pop = _pop(enterSec, 0);
    final double core = 92 * scale;
    final double pulse = 1 + 0.05 * math.sin(sec / 3.5 * 2 * math.pi);
    // A burst of rings as the page opens, then a slow heartbeat.
    final double burstT = ((enterSec - 0.15) / 1.4).clamp(0.0, 1.0);
    final double speed = 4.2 - 1.6 * active;
    return Positioned(
      left: c.dx - core * 2.2,
      top: c.dy - core * 2.2,
      width: core * 4.4,
      height: core * 4.4,
      child: Opacity(
        opacity: pop.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.6 + 0.4 * pop,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if (burstT > 0 && burstT < 1)
                Transform.scale(
                  scale: 1 + 2.6 * burstT,
                  child: Container(
                    width: core,
                    height: core,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: p.line.withValues(alpha: 0.9 * (1 - burstT)),
                          width: 2),
                    ),
                  ),
                ),
              for (int i = 0; i < 2; i++)
                _ring(core, p.line, ((sec / speed) + i * 0.5) % 1,
                    0.22 + 0.3 * active),
              Transform.scale(
                scale: pulse,
                child: Container(
                  width: core * 1.9,
                  height: core * 1.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: <Color>[
                      p.glow.withValues(alpha: p.dark ? 0.30 : 0.45),
                      p.glow.withValues(alpha: p.dark ? 0.10 : 0.18),
                      p.glow.withValues(alpha: 0),
                    ], stops: const <double>[
                      0.0,
                      0.5,
                      1.0
                    ]),
                  ),
                ),
              ),
              // The logo file has the yellow badge on its right, so the K disc
              // sits left of the file's centre. Shift the file right by that
              // gap so the disc is exactly on the line where the arrows start
              // (disc centre is 0.392 of the dark file's width, 0.375 of the
              // light file's).
              Transform.translate(
                offset: Offset(core * 1.05 * (p.dark ? 0.108 : 0.125), 0),
                child: CustomSvgImage.natural(
                  assetPath: knowticedLogoAsset(lightMode: !p.dark),
                  width: core * 1.05,
                  height: core * 1.05,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ring(double d, Color color, double t, double strength) {
    return Transform.scale(
      scale: 1 + 1.5 * t,
      child: Container(
        width: d,
        height: d,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: strength * (1 - t)),
            width: 1.3,
          ),
        ),
      ),
    );
  }
}

class _ClockHandPainter extends CustomPainter {
  _ClockHandPainter({required this.angle, required this.color});
  final double angle;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double len = size.width * 0.3;
    canvas.drawLine(
      c,
      c + Offset(math.sin(angle) * len, -math.cos(angle) * len),
      Paint()
        ..color = color
        // Same weight as the icon's own lines (about 3.4% of its box) so the
        // hand scales down with the icon; a fixed 1.6 looked heavy on a phone,
        // where the icon is only ~10 px wide.
        ..strokeWidth = math.max(0.5, size.width * 0.034)
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ClockHandPainter old) => old.angle != angle;
}

/// Stars, the lines, the soft flowing dashes and one calm light per line.
class _ScenePainter extends CustomPainter {
  _ScenePainter({
    required this.origin,
    required this.scale,
    required this.enterSec,
    required this.sec,
    required this.active,
    required this.wakeSec,
    required this.p,
  });

  final Offset origin;
  final double scale;
  final double enterSec;
  final double sec;
  final double active;
  final double wakeSec;
  final _Palette p;

  @override
  void paint(Canvas canvas, Size size) {
    // Stars drift slowly upward and twinkle (in screen space).
    final Paint star = Paint();
    final double starBoost = p.dark ? 1.0 : 0.55;
    for (final _Star s in _stars) {
      final double y = (((s.y - sec * s.speed) % 1) + 1) % 1;
      final double a = s.alpha *
          starBoost *
          (0.45 + 0.55 * math.sin(sec * s.twinkle + s.phase));
      star.color = p.ink.withValues(alpha: a.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(s.x * size.width, y * size.height), s.r, star);
    }

    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale);

    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = Color.lerp(p.ink.withValues(alpha: 0.12),
          p.line.withValues(alpha: 0.38), active)!;
    final Paint flow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final Paint glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final Paint dot = Paint();
    final double live = ((enterSec - 2.2) / 0.6).clamp(0.0, 1.0);

    for (final _Edge e in _edges) {
      final PathMetric m = e.path.computeMetrics().first;
      final double grow = Curves.easeInOutCubic
          .transform(((enterSec - (0.25 + e.delay)) / 1.4).clamp(0.0, 1.0));
      if (grow <= 0) continue;
      final double upTo = m.length * grow;
      canvas.drawPath(m.extractPath(0, upTo), base);

      if (live > 0) {
        // Faint dashes drift down the line.
        flow.color = p.line.withValues(alpha: (0.18 + 0.25 * active) * live);
        const double dash = 12;
        const double gap = 48;
        double d = -((sec * 26 + e.phase * 60) % (dash + gap));
        for (; d < upTo; d += dash + gap) {
          final double a = math.max(0.0, d);
          final double b = math.min(d + dash, upTo);
          if (b > a) canvas.drawPath(m.extractPath(a, b), flow);
        }
        // One light per line, then a rest before the next one.
        final double u = (sec / (e.period * 1.5) + e.phase * 2) % 2;
        if (u < 1) {
          _comet(canvas, m, u, 0.12, p.line, 4.2, live * (0.5 + 0.4 * active),
              glow, dot);
        }
      }

      // Sign In: a bright comet shoots down every line in turn.
      final double wt = (wakeSec - e.wakeStart) / e.wakeDur;
      if (wt > 0 && wt < 1) {
        _comet(canvas, m, Curves.easeIn.transform(wt), 0.28, p.wakeHead, 7, 1,
            glow, dot);
      }
    }
    canvas.restore();
  }

  void _comet(Canvas canvas, PathMetric m, double t, double tail, Color color,
      double r, double alpha, Paint glow, Paint dot) {
    const int steps = 10;
    for (int i = 0; i < steps; i++) {
      final double tt = t - i * tail / steps;
      if (tt < 0 || tt > 1) continue;
      final Offset pos = m.getTangentForOffset(m.length * tt)!.position;
      final double fade = (1 - i / steps) * alpha;
      final double rr = r * (1 - i * 0.07);
      if (i < 3) {
        // Tighter and softer on a light ground, where a big dark-amber glow
        // reads as a smudge.
        glow.color = color.withValues(alpha: (p.dark ? 0.6 : 0.35) * fade);
        canvas.drawCircle(pos, rr * (p.dark ? 1.5 : 1.2), glow);
      }
      dot.color = color.withValues(alpha: fade);
      canvas.drawCircle(pos, rr * 0.7, dot);
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => true;
}

/// Fades and slides its child up after [delay] — used to bring the form in
/// piece by piece when the sign-in page opens.
class SignInRise extends StatefulWidget {
  const SignInRise({super.key, required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  State<SignInRise> createState() => _SignInRiseState();
}

class _SignInRiseState extends State<SignInRise> {
  bool _shown = false;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timer != null || _shown) return;
    if (MediaQuery.of(context).disableAnimations) {
      _shown = true;
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) setState(() => _shown = true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _shown ? Offset.zero : const Offset(0, 0.07),
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _shown ? 1 : 0,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Module: core/helper
///
///*************************** FILE INFO ****************************///
/// File Name: offline_builder.dart
/// Description: `kOfflineDebounceDuration` constant, `OfflineBuilder` widget, state and UI of the `OfflineBuilder` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

import 'package:grc_module/core/helper/internet_reachability_stub.dart'
    if (dart.library.io) 'internet_reachability_io.dart';

export 'package:connectivity_plus/connectivity_plus.dart'
    show ConnectivityResult;

/// Replaces the `flutter_offline` package (6 Oct 2026).
///
/// flutter_offline 6.0.0 is its latest release and still pulls in
/// network_info_plus 7.x, which applies the Kotlin Gradle Plugin and blocks
/// `android.builtInKotlin=true`. It only ever used connectivity_plus for this
/// widget, so this is the same widget on connectivity_plus directly: same name,
/// same `connectivityBuilder(context, List<ConnectivityResult>, child)`
/// signature, same 3-second debounce. Call sites only change their import.
const Duration kOfflineDebounceDuration = Duration(seconds: 3);

class OfflineBuilder extends StatefulWidget {
  const OfflineBuilder({
    super.key,
    required this.connectivityBuilder,
    this.debounceDuration = kOfflineDebounceDuration,
    this.builder,
    this.child,
    this.errorBuilder,
  }) : assert(
          (builder == null) != (child == null),
          'You should specify either a builder or a child',
        );

  /// Builds the online / offline UI around [child].
  final Widget Function(
    BuildContext context,
    List<ConnectivityResult> connectivity,
    Widget child,
  ) connectivityBuilder;

  /// Debounce for flapping networks. The first value is never delayed.
  final Duration debounceDuration;

  final WidgetBuilder? builder;
  final Widget? child;

  /// Shown if the platform reports an error. Without one, the child is shown
  /// as if online rather than crashing the tree.
  final WidgetBuilder? errorBuilder;

  @override
  State<OfflineBuilder> createState() => _OfflineBuilderState();
}

/// How often a confirmed-offline state is re-checked against the internet.
const Duration kOfflineRecheckInterval = Duration(seconds: 5);

/// FIXED 14/10/2026 — "Can't Connect .. Check Internet" over a working
/// connection (macOS desktop).
///
/// 1. connectivity_plus reports interface state, not reachability. On macOS it
///    says `none` while online (startup, wake from sleep, VPN / Private Relay,
///    USB-Ethernet). A `none` is now only believed after a real lookup fails.
/// 2. The one-shot `checkConnectivity()` could resolve AFTER the stream's
///    newer value and overwrite it with a stale `none`; with no further
///    network change the banner then stayed forever. The one-shot answer is
///    now ignored once the stream has spoken.
/// 3. While offline the internet is re-checked every
///    [kOfflineRecheckInterval], so the banner clears on its own.
class _OfflineBuilderState extends State<OfflineBuilder> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounce;
  Timer? _recheck;
  List<ConnectivityResult>? _current;
  Object? _error;
  bool _streamDelivered = false;
  int _resolveSeq = 0;

  static const List<ConnectivityResult> _online = [ConnectivityResult.other];

  @override
  void initState() {
    super.initState();
    _connectivity.checkConnectivity().then((value) {
      // The stream is always newer than this one-shot answer.
      if (!_streamDelivered) _resolve(value);
    }, onError: _setError);
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onStream,
      onError: _setError,
    );
  }

  void _onStream(List<ConnectivityResult> value) {
    _streamDelivered = true;
    // Like flutter_offline: the first value goes straight through, later
    // changes wait for the network to settle.
    if (_current == null) {
      _resolve(value);
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () => _resolve(value));
  }

  /// Applies [value], but checks a reported `none` against the internet first.
  Future<void> _resolve(List<ConnectivityResult> value) async {
    final int seq = ++_resolveSeq;
    if (!value.contains(ConnectivityResult.none)) {
      _stopRecheck();
      _setNow(value);
      return;
    }
    // Do not blank the app while we check: optimistic until proven offline.
    if (_current == null) _setNow(_online);
    final bool? reachable = await hasInternetAccess();
    if (!mounted || seq != _resolveSeq) return; // a newer value won
    if (reachable == true) {
      _stopRecheck();
      _setNow(_online);
    } else {
      _setNow(value);
      if (reachable == false) _startRecheck();
    }
  }

  void _startRecheck() {
    _recheck?.cancel();
    _recheck = Timer.periodic(kOfflineRecheckInterval, (_) async {
      final int seq = _resolveSeq;
      final bool? reachable = await hasInternetAccess();
      if (!mounted || seq != _resolveSeq) return;
      if (reachable == true) {
        _stopRecheck();
        _setNow(_online);
      }
    });
  }

  void _stopRecheck() {
    _recheck?.cancel();
    _recheck = null;
  }

  void _setNow(List<ConnectivityResult> value) {
    if (!mounted) return;
    setState(() {
      _current = value;
      _error = null;
    });
  }

  void _setError(Object error) {
    if (!mounted) return;
    setState(() => _error = error);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _recheck?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = widget.child ?? widget.builder!(context);
    if (_error != null) {
      return widget.errorBuilder?.call(context) ??
          widget.connectivityBuilder(
              context,
              const [
                ConnectivityResult.other,
              ],
              child);
    }
    if (_current == null) return const SizedBox();
    return widget.connectivityBuilder(context, _current!, child);
  }
}

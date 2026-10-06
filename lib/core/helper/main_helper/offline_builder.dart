import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

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

class _OfflineBuilderState extends State<OfflineBuilder> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounce;
  List<ConnectivityResult>? _current;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _connectivity.checkConnectivity().then(_setNow, onError: _setError);
    _subscription = _connectivity.onConnectivityChanged.listen(
      _setDebounced,
      onError: _setError,
    );
  }

  void _setNow(List<ConnectivityResult> value) {
    if (!mounted) return;
    setState(() {
      _current = value;
      _error = null;
    });
  }

  void _setDebounced(List<ConnectivityResult> value) {
    // Like flutter_offline: the first value goes straight through, later
    // changes wait for the network to settle.
    if (_current == null) return _setNow(value);
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () => _setNow(value));
  }

  void _setError(Object error) {
    if (!mounted) return;
    setState(() => _error = error);
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
            const [ConnectivityResult.other],
            child,
          );
    }
    if (_current == null) return const SizedBox();
    return widget.connectivityBuilder(context, _current!, child);
  }
}

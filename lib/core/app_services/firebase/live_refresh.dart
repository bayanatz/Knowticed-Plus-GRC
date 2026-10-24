import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Keeps one-shot `.get()` loaders live without rewriting them as streams.
///
/// Listens to one or more Firestore queries/collections and calls [onChange]
/// (debounced) whenever any of them changes after the first snapshot. The
/// first snapshot of every listener is skipped because the caller has just
/// loaded the same data with `.get()`.
///
/// Usage inside a cubit:
/// ```dart
/// final _live = LiveRefresh();
/// Future<void> load() async {
///   ...existing get() logic...
///   _live.watchPaths([collectionPath], () => load());
/// }
/// @override
/// Future<void> close() { _live.dispose(); return super.close(); }
/// ```
/// Calling [watchPaths] / [watchQuery] again with the same paths is a no-op, so it is safe to
/// call at the end of every load.
class LiveRefresh {
  LiveRefresh({this.debounce = const Duration(milliseconds: 400)});

  final Duration debounce;
  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> _subs =
      [];
  final Set<String> _keys = {};
  // One debounce timer per callback, so watches with different callbacks
  // never cancel each other.
  final Map<void Function(), Timer> _timers = Map.identity();
  bool _disposed = false;

  /// Watches whole collections by path (e.g. `Demo/DM-003/Modules/x/Items`).
  void watchPaths(Iterable<String> collectionPaths, void Function() onChange) {
    // 20/10/2026: no Firebase app (widget tests, a fake remote) = nothing to
    // watch. FirebaseFirestore.instance threw [core/no-app] here and failed
    // ~300 Time Tracker / Home tests once the shared employee and department
    // controllers started watching their collections.
    if (_disposed || Firebase.apps.isEmpty) return;
    final db = FirebaseFirestore.instance;
    for (final path in collectionPaths) {
      watchQuery(path, db.collection(path), onChange);
    }
  }

  /// Watches a filtered query or collection group; [key] de-duplicates
  /// repeated calls (use something stable such as path + filter values).
  void watchQuery(
    String key,
    Query<Map<String, dynamic>> query,
    void Function() onChange,
  ) {
    if (_disposed) return;
    {
      if (!_keys.add(key)) return;
      var first = true;
      _subs.add(
        query.snapshots().listen(
          (snap) {
            if (first) {
              first = false;
              return;
            }
            // Our own pending writes fire twice (local + server ack); one
            // reload is enough, so wait for the debounce window.
            _timers[onChange]?.cancel();
            _timers[onChange] = Timer(debounce, () {
              _timers.remove(onChange);
              if (!_disposed) onChange();
            });
          },
          onError: (Object _) {},
        ),
      );
    }
  }

  void dispose() {
    _disposed = true;
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _keys.clear();
  }
}

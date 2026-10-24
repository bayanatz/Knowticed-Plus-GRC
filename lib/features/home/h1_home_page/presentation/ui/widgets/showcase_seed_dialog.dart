/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_seed_dialog.dart
/// Purpose: Owner-only dialog behind "🧪 Fill showcase data": runs
///          `ShowcaseSeeder.run` and lists each module's result as it
///          finishes (documents written, or the error).
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Only reachable from the `kOwnerTools` debug menu, so it is plain Material
/// (not shown to clients).
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_audit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_seeder.dart';

Future<void> showShowcaseSeedDialog(BuildContext context) {
  final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ShowcaseSeedDialog(isArabic: isArabic),
  );
}

class _ShowcaseSeedDialog extends StatefulWidget {
  const _ShowcaseSeedDialog({required this.isArabic});

  final bool isArabic;

  @override
  State<_ShowcaseSeedDialog> createState() => _ShowcaseSeedDialogState();
}

class _ShowcaseSeedDialogState extends State<_ShowcaseSeedDialog> {
  final List<ShowcaseModuleResult> _results = <ShowcaseModuleResult>[];
  bool _running = true;
  String? _fatal;

  @override
  void initState() {
    super.initState();
    ShowcaseSeeder.run(
      isArabic: widget.isArabic,
      onProgress: (ShowcaseModuleResult r) {
        if (mounted) setState(() => _results.add(r));
      },
    ).catchError((Object e) {
      if (mounted) setState(() => _fatal = '$e');
      return <ShowcaseModuleResult>[];
    }).whenComplete(() {
      if (mounted) setState(() => _running = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int total =
        _results.fold(0, (int a, ShowcaseModuleResult r) => a + r.count);
    return AlertDialog(
      title: Text(_running ? 'Filling showcase data…' : 'Showcase data'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_running) const LinearProgressIndicator(),
            if (_fatal != null) Text('Stopped: $_fatal'),
            for (final ShowcaseModuleResult r in _results)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(r.error == null
                    ? '✓ ${r.module}: ${r.count} documents'
                    : '✗ ${r.module}: ${r.error}'),
              ),
            if (!_running) ...<Widget>[
              const SizedBox(height: 12),
              Text('$total documents written.'),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        if (!_running)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
      ],
    );
  }
}

/// Owner-only, read-only: lists the non-showcase entries (see
/// `ShowcaseAudit`) to the debug console and shows a per-area summary.
Future<void> showShowcaseAuditDialog(BuildContext context) async {
  final String email =
      Get.find<MainCoreEmployeeController>().employeeEntity?.email ?? '';
  final Future<List<String>> run = ShowcaseAudit.run(ownerEmail: email);
  await showDialog<void>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: const Text('Non-showcase entries (read only)'),
      content: SizedBox(
        width: 460,
        child: FutureBuilder<List<String>>(
          future: run,
          builder: (BuildContext _, AsyncSnapshot<List<String>> snap) {
            if (!snap.hasData) return const LinearProgressIndicator();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final String line in snap.data!) Text(line),
                const SizedBox(height: 8),
                const Text('Details were printed to the console (AUDIT|…).'),
              ],
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close')),
      ],
    ),
  );
}

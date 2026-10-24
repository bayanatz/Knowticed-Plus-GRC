/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: analytics_screen.dart
/// Description: `AnalyticsScreen` page, state and UI of the `AnalyticsScreen` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_analytics_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/address_analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/address_analytics_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/analytics_main_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/utils/analytics_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// The Analytics view: one card per field that has analytics.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // Build the analytics when the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildAnalytics());
  }

  /// Builds the analytics from the form and its submitted people.
  void _buildAnalytics() {
    if (!mounted) return;
    final ResultState state = context.read<ResultCubit>().state;
    if (state is! ResultLoaded || state.formEntity == null) return;
    context.read<ResultAnalyticsCubit>().getAnalyticsData(
          form: state.formEntity!,
          submittedUsers: state.submittedUsers,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResultCubit, ResultState>(
      // Rebuilt when the submitted people (re)load.
      listenWhen: (previous, current) =>
          current is ResultLoaded &&
          (previous is! ResultLoaded ||
              previous.submittedUsers != current.submittedUsers),
      listener: (context, _) => _buildAnalytics(),
      builder: (context, state) {
        // Also the circle while the users are loading,
        // so "no submissions" only shows when there really are none.
        if (state is! ResultLoaded || state.isLoadingUsers) {
          return const CircleProgressMaster();
        }

        if (state.submittedUsers.isEmpty) {
          return Center(
            child: Column(
              children: [
                CustomEmptyState(
                  lottiePath: AppAssets.noData,
                  size: 400,
                  verticalPadding: 0,
                ),
                verticalSpace(20),
                Text(
                  S.of(context).noSubmissionsFound,
                  style: StyleText.fontSize16Weight500,
                ),
              ],
            ),
          );
        }

        return BlocBuilder<ResultAnalyticsCubit, ResultAnalyticsState>(
          builder: (context, analytics) => Column(
            spacing: 10.h,
            children: [
              verticalSpace(10),
              ..._buildCards(context, analytics.analyticsData),
            ],
          ),
        );
      },
    );
  }

  /// Large-screen bug report p.8: two donut-chart questions in a row share
  /// one line on a large screen instead of each filling the full width with
  /// an empty middle. Everything else keeps its own full-width line.
  List<Widget> _buildCards(BuildContext context, List<AnalyticsEntity> data) {
    final bool pairDonuts = MediaQuery.of(context).size.width >= 1200;
    bool isDonut(AnalyticsEntity e) =>
        e.type != FormFieldType.address &&
        AnalyticsHelper.doughnutChartAnalytics(e.type);

    final List<Widget> cards = <Widget>[];
    for (int i = 0; i < data.length; i++) {
      final AnalyticsEntity entity = data[i];
      if (entity.type == FormFieldType.address) {
        cards.add(AddressAnalyticsWidget(
          key: ValueKey<String>('analytics_$i'),
          data: entity as AddressAnalyticsEntity,
        ));
        continue;
      }
      if (pairDonuts &&
          isDonut(entity) &&
          i + 1 < data.length &&
          isDonut(data[i + 1])) {
        final AnalyticsEntity next = data[i + 1];
        cards.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AnalyticsMainWidget(
                  key: ValueKey<String>('analytics_$i'), data: entity),
            ),
            horizontalSpace(10),
            Expanded(
              child: AnalyticsMainWidget(
                  key: ValueKey<String>('analytics_${i + 1}'), data: next),
            ),
          ],
        ));
        i++;
        continue;
      }
      cards.add(AnalyticsMainWidget(
          key: ValueKey<String>('analytics_$i'), data: entity));
    }
    return cards;
  }
}

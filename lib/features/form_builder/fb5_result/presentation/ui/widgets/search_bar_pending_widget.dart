/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: search_bar_pending_widget.dart
/// Description: `SearchBarPendingWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/results_department_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';

/// Search box and Department filter of the Pending tab.
class SearchBarPendingWidget extends StatefulWidget {
  const SearchBarPendingWidget({super.key});

  @override
  State<SearchBarPendingWidget> createState() => _SearchBarPendingWidgetState();
}

class _SearchBarPendingWidgetState extends State<SearchBarPendingWidget> {
  /// The search box text. Owned by this widget, not the cubit.
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ResultCubit>().state;
    _searchController = TextEditingController(
        text: state is ResultLoaded ? state.searchQuery : '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;

    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, state) {
        if (state is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<ResultCubit>();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildSearchBar(context, widthScreen, cubit, state),
            if (ContextExtension(context).isTablett) ...[
              _buildSpace(context),
              // Multi-select Department filter (12/10/2026).
              const ResultsDepartmentFilter(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSpace(BuildContext context) {
    double space = ContextExtension(context).isPhone ? 10 : 15;
    return horizontalSpace(space);
  }

  Widget _buildSearchBar(
    BuildContext context,
    double widthScreen,
    ResultCubit cubit,
    ResultLoaded state,
  ) {
    return AppSearchTextField(
      controller: _searchController,
      onChanged: cubit.search,
    );
  }
}

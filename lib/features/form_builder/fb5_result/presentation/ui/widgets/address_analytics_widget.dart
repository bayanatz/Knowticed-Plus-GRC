/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: address_analytics_widget.dart
/// Description: `AddressAnalyticsWidget` widget, state and UI of the `AddressAnalyticsWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/charts/custom_bar_chart_card.dart';
import 'package:knowticed_plus/core/custom/charts/custom_chart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/domain/entities/address_analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/address_analytics_table_builder.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/text_field_analytics.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/ui/widgets/table/default_data_table.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The analytics card of an Address field (charts per part, and a table).
class AddressAnalyticsWidget extends StatefulWidget {
  const AddressAnalyticsWidget({required this.data, super.key});
  final AddressAnalyticsEntity data;

  @override
  State<AddressAnalyticsWidget> createState() => _AddressAnalyticsWidgetState();
}

class _AddressAnalyticsWidgetState extends State<AddressAnalyticsWidget> {
  bool isShowAggregated = false;
  bool isShowTabulated = false;

  @override
  Widget build(BuildContext context) {
    if (isShowAggregated) {
      return Column(
        spacing: 10.h,
        children: [
          for (int chartIndex = 0;
              chartIndex < widget.data.addressItems!.length;
              chartIndex++)
            _buildChartGraph(chartIndex),
        ],
      );
    } else if (isShowTabulated) {
      return _tableWidget();
    } else {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            verticalSpace(10),
            TextFieldAnalytics(entity: widget.data)
          ],
        ),
      );
    }
  }

  Widget _buildHeader() {
    bool isTablet = !kpIsPhoneLayout(context);

    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, state) {
        if (state is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Row(
              spacing: 10.w,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.sp),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: CustomSvgImage.natural(
                          assetPath: widget.data.type.icon,
                          height: 16.sp,
                          width: 16.sp,
                          color: AppColors.textButton,
                        ),
                      ),
                      horizontalSpace(5),
                      Expanded(
                        child: Text(
                          FormatHelper.capitalize(widget.data.title),
                          style: StyleText.fontSize14Weight500
                              .copyWith(color: AppColors.secondaryBlack),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                  child: Row(
                    children: [
                      Text(
                        isTablet
                            ? S.of(context).totalResponse
                            : S.of(context).total2,
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.secondaryBlack),
                      ),
                      Text(
                        '${state.submittedUsers.length}/${state.submittedUsers.length + state.pendingUsers.length}',
                        style: StyleText.fontSize14Weight600,
                      )
                    ],
                  ),
                ),
                if (isTablet) _buildHeaderActions()
              ],
            ),
            if (!isTablet) verticalSpace(10),
            if (!isTablet) _buildHeaderActions()
          ],
        );
      },
    );
  }

  Row _buildHeaderActions() {
    bool isTablet = !kpIsPhoneLayout(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        customButton(
          function: () {
            setState(() {
              isShowAggregated = true;
              isShowTabulated = false;
              widget.data.isAggregated = !widget.data.isAggregated!;
            });
          },
          title: S.of(context).aggregated,
        ),
        if (isTablet) horizontalSpace(10),
        if (isTablet)
          customButton(
            function: () {
              setState(() {
                isShowAggregated = false;
                isShowTabulated = !isShowTabulated;
              });
            },
            title: (isShowTabulated)
                ? S.of(context).untabulated
                : S.of(context).tabulated,
          )
      ],
    );
  }

  /// (vertical bug report p.31 — "equalize all these bar
  /// charts' size and apply the chart style above"): each address part
  /// (country / state / city …) was a Syncfusion ColumnChart whose bar width
  /// was a FRACTION of its slot, so a chart with one value drew one fat bar
  /// and a chart with four drew four hairlines, on a 0-0.2-0.4 decimal axis.
  /// They are now the same core BarChartCard the other bar questions use:
  /// fixed 14-wide bars, whole-number axis, same card chrome, English digits.
  Widget _buildChartGraph(int chartIndex) {
    return BarChartCard(
      title: FormatHelper.capitalize(widget.data.addressItems![chartIndex]),
      dotIcon: widget.data.type.icon,
      trailing: _buildChartActions(chartIndex),
      width: double.infinity,
      westernDigits: true,
      bars: [
        for (final d in widget.data.addressChartData![chartIndex])
          ChartData(label: d.text, value: d.values),
      ],
    );
  }

  Widget _tableWidget() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          verticalSpace(10),
          DefaultDataTable(
            columns: widget.data.dataColumns(),
            rows: widget.data.dataCells(),
          )
        ],
      ),
    );
  }

  Widget _buildChartActions(int chartIndex) {
    if (chartIndex == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          customButton(
            function: () {
              setState(() {
                isShowAggregated = false;
                widget.data.isAggregated = !widget.data.isAggregated!;
              });
            },
            title: S.of(context).unaggregated,
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}

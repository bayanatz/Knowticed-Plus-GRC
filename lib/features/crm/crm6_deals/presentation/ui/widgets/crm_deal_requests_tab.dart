// ****************** FILE INFO ******************
// File Name: crm_deal_requests_tab.dart
// Purpose: Requests tab content for Deal Details page with status badges, search/sort/filter bar, Export, Grid/Table view switchers matching Figma screenshots
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_view_mode_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_quote_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_request_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_deal_requests_cubit.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_deal_requests_state.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_request_details_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_request_card.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_requests_filter_badges_bar.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_requests_table_view.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

class CrmDealRequestsTab extends StatefulWidget {
  final String clientId;
  final String dealId;
  final String dealTitle;

  const CrmDealRequestsTab({
    super.key,
    required this.clientId,
    required this.dealId,
    required this.dealTitle,
  });

  @override
  State<CrmDealRequestsTab> createState() => _CrmDealRequestsTabState();
}

class _CrmDealRequestsTabState extends State<CrmDealRequestsTab> {
  final TextEditingController _searchController = TextEditingController();
  CrmRequestStatus _selectedStatusFilter = CrmRequestStatus.all;
  bool _isGridView = false;
  late final CrmDealRequestsCubit _cubit;

  static const List<String> _sortOptions = <String>[
    'Recent',
    'Oldest',
    'Quote No',
    'Status',
  ];

  @override
  void initState() {
    super.initState();
    _cubit = CrmDealRequestsCubit()
      ..load(clientId: widget.clientId, dealId: widget.dealId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  List<CrmDealRequestModel> _filteredRequests(
      List<CrmClientQuoteRecordModel> quotes) {
    return quotes.map(_requestFromQuote).where((CrmDealRequestModel req) {
      if (_selectedStatusFilter != CrmRequestStatus.all &&
          req.status != _selectedStatusFilter) {
        return false;
      }
      if (_searchController.text.trim().isNotEmpty) {
        final String q = _searchController.text.trim().toLowerCase();
        final bool matchesQuote = req.quoteNo.toLowerCase().contains(q);
        final bool matchesStatus = req.status.labelEn.toLowerCase().contains(q);
        if (!matchesQuote && !matchesStatus) return false;
      }
      return true;
    }).toList();
  }

  CrmDealRequestModel _requestFromQuote(CrmClientQuoteRecordModel quote) =>
      CrmDealRequestModel(
        id: quote.id,
        no: quote.version,
        quoteNo: quote.quoteNo,
        version: 'V${quote.version}',
        status: quote.status == 'approved'
            ? CrmRequestStatus.approved
            : quote.status == 'reject'
                ? CrmRequestStatus.reject
                : CrmRequestStatus.pending,
        createdDate:
            '${quote.quoteDate.day}/${quote.quoteDate.month}/${quote.quoteDate.year}',
        validUntil:
            '${quote.validUntil.day}/${quote.validUntil.month}/${quote.validUntil.year}',
        productsCategory: _lineText(quote.productLines, 'Category_Name_En'),
        products: _lineText(quote.productLines, 'Name_En'),
        quantity: _lineText(quote.productLines, 'Quantity'),
        productDiscount: _moneyLine(quote.productLines, 'Discount'),
        productTax: _moneyLine(quote.productLines, 'Tax'),
        productTotal: _moneyLine(quote.productLines, 'Total'),
        servicesCategory: _lineText(quote.serviceLines, 'Category_Name_En'),
        services: _lineText(quote.serviceLines, 'Name_En'),
        serviceDiscount: _moneyLine(quote.serviceLines, 'Discount'),
        serviceTax: _moneyLine(quote.serviceLines, 'Tax'),
        serviceTotal: _moneyLine(quote.serviceLines, 'Total'),
        paymentTerms: _termText(quote.paymentTerm),
        deliveryTerms: _termText(quote.deliveryTerm),
        note: quote.noteEn,
        noteAr: quote.noteAr,
        totalFormatted: '${quote.currency} ${quote.grandTotal}',
      );

  String _lineText(List<Map<String, dynamic>> lines, String key) => lines
      .map((Map<String, dynamic> line) => '${line[key] ?? ''}'.trim())
      .where((String value) => value.isNotEmpty)
      .join(', ');

  String _moneyLine(List<Map<String, dynamic>> lines, String key) => lines
      .map((Map<String, dynamic> line) => '${line[key] ?? ''}'.trim())
      .where((String value) => value.isNotEmpty)
      .join(', ');

  String _termText(Map<String, dynamic> term) =>
      '${term['Text_En'] ?? term['Name_En'] ?? term['Text_Ar'] ?? term['Name_Ar'] ?? ''}';

  void _navigateToDetails(CrmDealRequestModel req) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CrmRequestDetailsPage(
          dealTitle: widget.dealTitle.isNotEmpty
              ? widget.dealTitle
              : 'ERP System Deal',
          clientId: widget.clientId,
          dealId: widget.dealId,
          quoteId: req.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocProvider<CrmDealRequestsCubit>.value(
        value: _cubit,
        child: BlocBuilder<CrmDealRequestsCubit, CrmDealRequestsState>(
          builder: (BuildContext context, CrmDealRequestsState state) {
            final List<CrmDealRequestModel> displayList =
                _filteredRequests(state.requests);
            if (state.isLoading) {
              return const Center(child: CircleProgressMaster());
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // ── 1. KPI Filter Badges Bar via StatusChipFilter ──────────────────────
                CrmRequestsFilterBadgesBar(
                  selectedStatus: _selectedStatusFilter,
                  onStatusSelected: (CrmRequestStatus status) =>
                      setState(() => _selectedStatusFilter = status),
                  allCount: state.requests.length,
                  pendingCount: state.requests
                      .where((quote) => quote.status == 'pending')
                      .length,
                  approvedCount: state.requests
                      .where((quote) => quote.status == 'approved')
                      .length,
                  rejectCount: state.requests
                      .where((quote) => quote.status == 'reject')
                      .length,
                ),

                SizedBox(height: 18.sp),

                // ── 2. Search, Filter & Sort Bar ──────────────────────────────────────
                CustomSearchFilterSortBar<String, String>(
                  searchController: _searchController,
                  onSearchChanged: (_) => setState(() {}),
                  searchHint: 'Search',
                  showFilter: true,
                  onFilterTap: () {
                    CrmControlDialogs.showSuccessDialog(
                      context: context,
                      title: 'Filter Requests',
                      subtitle: 'Filter options dialog.',
                    );
                  },
                  showSort: true,
                  sortItems: _sortOptions,
                  selectedSort: 'Recent',
                  sortLabelBuilder: (String item) => item,
                  onSortChanged: (String? sort) {},
                  fillColor: AppColors.white,
                ),

                SizedBox(height: 14.sp),

                // ── 3. Secondary Toolbar (Export + Grid/Table Toggle) ─────────────────
                _buildViewToggleBar(),

                SizedBox(height: 16.sp),

                // ── 4. Main Content: Grid View or Table View ──────────────────────────
                if (displayList.isEmpty)
                  Container(
                    height: 200.sp,
                    alignment: Alignment.center,
                    child: Text(
                      FormatHelper.localizedString(
                        englishName: 'No requests found.',
                        arabicName: 'لا توجد طلبات.',
                      ),
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  )
                else
                  BounceSwitcher(
                    triggerValue: _isGridView,
                    child: _isGridView
                        ? _buildGridView(displayList)
                        : CrmRequestsTableView(
                            requests: displayList,
                            onRequestTap: _navigateToDetails,
                          ),
                  ),
              ],
            );
          },
        ),
      );

  Widget _buildViewToggleBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        customButtonWithSvg(
          title: FormatHelper.localizedString(
            englishName: 'Export',
            arabicName: 'تصدير',
          ),
          image: AppAssets.export,
          widthImage: 14.sp,
          heightImage: 14.sp,
          colorBorder: Colors.transparent,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
          ),
          function: () {
            CrmControlDialogs.showSuccessDialog(
              context: context,
              title: 'Export Requests',
              subtitle: 'Exporting requests to Excel sheet.',
            );
          },
        ),
        SizedBox(width: 12.sp),
        customViewModeButton(
          mode: ViewMode.grid,
          isSelected: _isGridView,
          color: AppColors.white,
          function: () => setState(() => _isGridView = true),
        ),
        SizedBox(width: 8.sp),
        customViewModeButton(
          mode: ViewMode.list,
          isSelected: !_isGridView,
          color: AppColors.white,
          function: () => setState(() => _isGridView = false),
        ),
      ],
    );
  }

  Widget _buildGridView(List<CrmDealRequestModel> list) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 94.sp,
            crossAxisSpacing: 12.sp,
            mainAxisSpacing: 12.sp,
          ),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            final CrmDealRequestModel item = list[index];
            return CrmRequestCard(
              request: item,
              onTap: () => _navigateToDetails(item),
            );
          },
        );
      },
    );
  }
}

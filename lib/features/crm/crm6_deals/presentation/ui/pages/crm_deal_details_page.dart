// ****************** FILE INFO ******************
// File Name: crm_deal_details_page.dart
// Purpose: Deal Details full page container hosting Overview, Products, Services, and other deal tabs with CustomTabs and CustomDeleteIcon
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_tabs.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_deal_details_cubit.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_deal_details_state.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_activities_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_overview_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_products_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_quotes_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_requests_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_services_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_contract_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_documents_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_timeline_tab.dart';

class CrmDealDetailsPage extends StatefulWidget {
  final String clientId;
  final CrmClientDealModel deal;

  const CrmDealDetailsPage({
    super.key,
    required this.clientId,
    required this.deal,
  });

  @override
  State<CrmDealDetailsPage> createState() => _CrmDealDetailsPageState();
}

class _CrmDealDetailsPageState extends State<CrmDealDetailsPage> {
  int _selectedTabIndex = 0;
  late String _currentStage;
  late final CrmClientDealDetailsCubit _detailsCubit;
  List<CrmDealStageModel> _stages = <CrmDealStageModel>[];

  static const List<String> _tabTitles = <String>[
    'Overview',
    'Products',
    'Services',
    'Quotes',
    'Requests',
    'Activities',
    'Timeline',
    'Documents',
    'Contract',
  ];

  @override
  void initState() {
    super.initState();
    _currentStage = widget.deal.stage;
    _detailsCubit = CrmClientDealDetailsCubit()
      ..init(clientId: widget.clientId, dealId: widget.deal.id);
  }

  @override
  void dispose() {
    _detailsCubit.close();
    super.dispose();
  }

  String _getStageLabel(String key) {
    if (_stages.isNotEmpty) {
      for (final CrmDealStageModel s in _stages) {
        if (s.id.toLowerCase() == key.toLowerCase() ||
            s.nameEn.toLowerCase() == key.toLowerCase()) {
          return FormatHelper.localizedString(
            englishName: s.nameEn,
            arabicName: s.nameAr,
          );
        }
      }
    }
    return key.isNotEmpty ? key : 'New';
  }

  void _onStageSelected(String stageKey) {
    if (_stages.isEmpty) {
      return;
    }
    final CrmDealStageModel stage = _stages.firstWhere(
      (CrmDealStageModel item) => item.id == stageKey,
      orElse: () => _stages.first,
    );
    _detailsCubit.moveStage(stage);
  }

  void _onDeleteDeal() {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Delete Deal',
        arabicName: 'حذف الصفقة',
      ),
      subtitle: FormatHelper.localizedString(
        englishName:
            'Are you sure you want to delete this deal? This action cannot be undone.',
        arabicName:
            'هل أنت متأكد من رغبتك في حذف هذه الصفقة؟ لا يمكن التراجع عن هذا الإجراء.',
      ),
      onConfirm: () async {
        final bool archived = await _detailsCubit.archive();
        if (archived && mounted) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String dealTitle = widget.deal.dealNameEn.isNotEmpty
        ? widget.deal.dealNameEn
        : (widget.deal.dealNameAr.isNotEmpty
            ? widget.deal.dealNameAr
            : 'ERP System Deal');

    return BlocProvider<CrmClientDealDetailsCubit>.value(
      value: _detailsCubit,
      child: BlocListener<CrmClientDealDetailsCubit, CrmClientDealDetailsState>(
        listener: (BuildContext context, CrmClientDealDetailsState state) {
          if (state.stages.isNotEmpty || state.deal != null) {
            setState(() {
              _stages = state.stages;
              _currentStage = state.deal?.currentStageId ?? _currentStage;
            });
          }
          if (state.errorMessage != null) {
            CrmControlDialogs.showErrorDialog(
                context: context,
                title: 'Deal operation failed',
                subtitle: state.errorMessage!);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            titleText: FormatHelper.localizedString(
              englishName: 'Client Profile',
              arabicName: 'ملف العميل',
            ),
            secondTitle: FormatHelper.localizedString(
              englishName: 'Deals',
              arabicName: 'الصفقات',
            ),
            thirdTitle: dealTitle,
            onFirstTap: () => Navigator.pop(context),
            onSecondTap: () => Navigator.pop(context),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // ── 1. Top Controls Bar: Stage Dropdown + CustomDeleteIcon ────
                  _buildTopControlsBar(context),

                  SizedBox(height: 20.sp),

                  // ── 2. Reusable CustomTabs Bar ──────────────────────────────
                  CustomTabs(
                    tabs: _tabTitles,
                    selectedValue: _selectedTabIndex,
                    spacing: 24.sp,
                    onChanged: (int index) =>
                        setState(() => _selectedTabIndex = index),
                  ),

                  SizedBox(height: 24.sp),

                  // ── 3. Active Tab Content ───────────────────────────────────────
                  _buildActiveTabContent(context),

                  SizedBox(height: 24.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopControlsBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Stage Selector Dropdown Button
        PopupMenuButton<String>(
          tooltip: '', // no hover "Show menu" bubble (18/10/2026)

          onSelected: _onStageSelected,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          itemBuilder: (BuildContext context) {
            if (_stages.isNotEmpty) {
              return _stages.map((CrmDealStageModel s) {
                return PopupMenuItem<String>(
                  value: s.id,
                  child: Text(
                    FormatHelper.localizedString(
                      englishName: s.nameEn,
                      arabicName: s.nameAr,
                    ),
                    style: StyleText.fontSize14Weight400,
                  ),
                );
              }).toList();
            }
            return <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'new',
                child: Text('New', style: StyleText.fontSize14Weight400),
              ),
              PopupMenuItem<String>(
                value: 'discovery',
                child: Text('Discovery', style: StyleText.fontSize14Weight400),
              ),
              PopupMenuItem<String>(
                value: 'qualified',
                child: Text('Qualified', style: StyleText.fontSize14Weight400),
              ),
              PopupMenuItem<String>(
                value: 'proposal',
                child: Text('Proposal', style: StyleText.fontSize14Weight400),
              ),
              PopupMenuItem<String>(
                value: 'won',
                child: Text('Closed Won', style: StyleText.fontSize14Weight400),
              ),
            ];
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _getStageLabel(_currentStage),
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.sp),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.white,
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ),

        // Pre-built Custom Delete Button
        CustomDeleteIcon(
          title: FormatHelper.localizedString(
            englishName: 'Delete',
            arabicName: 'حذف',
          ),
          color: const Color(0xFFDC2626),
          borderColor: Colors.transparent,
          svgColor: AppColors.white,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
          onTap: _onDeleteDeal,
        ),
      ],
    );
  }

  Widget _buildActiveTabContent(BuildContext context) {
    switch (_selectedTabIndex) {
      case 0:
        return CrmDealOverviewTab(
          deal: widget.deal,
          onSave: () {},
        );
      case 1:
        return CrmDealProductsTab(deal: widget.deal);
      case 2:
        return CrmDealServicesTab(deal: widget.deal);
      case 3:
        return CrmDealQuotesTab(deal: widget.deal, clientId: widget.clientId);
      case 4:
        return CrmDealRequestsTab(
          clientId: widget.clientId,
          dealId: widget.deal.id,
          dealTitle: widget.deal.dealNameEn,
        );
      case 5:
        return CrmDealActivitiesTab(deal: widget.deal);
      case 6:
        return CrmDealTimelineTab(deal: widget.deal);
      case 7:
        return CrmDealDocumentsTab(deal: widget.deal);
      case 8:
        return CrmDealContractTab(deal: widget.deal);
      default:
        return Container(
          padding: EdgeInsets.all(32.sp),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Text(
            'No items in this section yet.',
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
        );
    }
  }
}

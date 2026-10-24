// ****************** FILE INFO ******************
// File Name: crm_request_details_page.dart
// Purpose: Live persisted quote approval request details and decisions.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/current_user_context.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_quote_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_quote_details_cubit.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_quote_details_state.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_products_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_services_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_terms_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_request_dialogs.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

class CrmRequestDetailsPage extends StatefulWidget {
  final String dealTitle;
  final String clientId;
  final String dealId;
  final String quoteId;
  const CrmRequestDetailsPage(
      {super.key,
      required this.dealTitle,
      required this.clientId,
      required this.dealId,
      required this.quoteId});
  @override
  State<CrmRequestDetailsPage> createState() => _CrmRequestDetailsPageState();
}

class _CrmRequestDetailsPageState extends State<CrmRequestDetailsPage> {
  late final CrmClientQuoteDetailsCubit _cubit;
  @override
  void initState() {
    super.initState();
    _cubit = CrmClientQuoteDetailsCubit()
      ..load(
          clientId: widget.clientId,
          dealId: widget.dealId,
          quoteId: widget.quoteId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _approve() async {
    final bool confirmed =
        await CrmRequestDialogs.showApproveConfirmationDialog(context: context);
    if (confirmed && mounted) {
      await _decide('approved');
    }
  }

  Future<void> _reject() async {
    if (!await CrmRequestDialogs.showRejectConfirmationDialog(
            context: context) ||
        !mounted) {
      return;
    }
    final String? reason =
        await CrmRequestDialogs.showRejectReasonDialog(context: context);
    if (reason != null && mounted) {
      await _decide('reject', reason);
    }
  }

  Future<void> _decide(String decision, [String reason = '']) async {
    if (_cubit.state.isSaving) return;
    showLoadingIndicator();
    final bool saved = await _cubit.decideRequest(
        decision: decision,
        rejectReason: reason,
        decidedBy: CurrentUserContext.email ?? 'system');
    hideLoadingIndicator();
    if (!mounted) return;
    if (saved) {
      await CrmControlDialogs.showSuccessDialog(
        context: context,
        title: decision == 'approved' ? 'Request Approved' : 'Request Rejected',
        subtitle: 'The request decision was saved successfully.',
      );
    } else {
      await CrmControlDialogs.showErrorDialog(
        context: context,
        title: 'Request',
        subtitle:
            _cubit.state.errorMessage ?? 'The request could not be updated.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => BlocProvider<
          CrmClientQuoteDetailsCubit>.value(
      value: _cubit,
      child:
          BlocBuilder<CrmClientQuoteDetailsCubit, CrmClientQuoteDetailsState>(
              builder: (_, state) {
        if (state.isLoading && state.quote == null) {
          return const Scaffold(body: Center(child: CircleProgressMaster()));
        }
        final CrmClientQuoteRecordModel? quote = state.quote;
        if (quote == null) {
          return Scaffold(
              body: Center(
                  child: Text(state.errorMessage ?? 'Request not found.',
                      style: StyleText.fontSize16Weight500)));
        }
        return Scaffold(
            backgroundColor: AppColors.background,
            body: SideFrameMasterServices(
                titleText: widget.dealTitle,
                secondTitle: 'Requests',
                thirdTitle: quote.quoteNo,
                onFirstTap: () => Navigator.pop(context),
                onSecondTap: () => Navigator.pop(context),
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      _decision(quote),
                      SizedBox(height: 16.sp),
                      _overview(quote),
                      SizedBox(height: 16.sp),
                      CrmQuoteProductsTab(
                          items: quote.productLines
                              .map((line) =>
                                  QuoteProductLineItemModel.fromSnapshot(
                                      line, quote.currency))
                              .toList(),
                          subtotalValue: _money(quote.subtotal, quote.currency),
                          taxesValue: _money(quote.taxTotal, quote.currency),
                          discountValue:
                              '-${_money(quote.discountTotal, quote.currency)}',
                          totalValue: _money(quote.grandTotal, quote.currency)),
                      SizedBox(height: 16.sp),
                      CrmQuoteServicesTab(
                          items: quote.serviceLines
                              .map((line) =>
                                  QuoteServiceLineItemModel.fromSnapshot(
                                      line, quote.currency))
                              .toList(),
                          subtotalValue: _money(quote.subtotal, quote.currency),
                          taxesValue: _money(quote.taxTotal, quote.currency),
                          discountValue:
                              '-${_money(quote.discountTotal, quote.currency)}',
                          totalValue: _money(quote.grandTotal, quote.currency)),
                      SizedBox(height: 16.sp),
                      CrmQuoteTermsTab(
                          initialPaymentTerm: _term(quote.paymentTerm),
                          initialDeliveryTerm: _term(quote.deliveryTerm),
                          initialNoteEn: quote.noteEn,
                          initialNoteAr: quote.noteAr,
                          attachments: quote.attachments),
                      if (quote.status == 'pending') ...<Widget>[
                        SizedBox(height: 24.sp),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              customButton(
                                  title: 'Reject',
                                  color: AppColors.red,
                                  textColor: AppColors.white,
                                  function: _reject),
                              customButton(
                                  title: 'Approve',
                                  color: AppColors.primary,
                                  textColor: AppColors.black,
                                  function: _approve)
                            ])
                      ],
                      SizedBox(height: 32.sp),
                    ]))));
      }));

  Widget _decision(CrmClientQuoteRecordModel quote) => CrmSectionCard(
      title: 'Decision',
      showHideToggle: false,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Status: ${quote.status}',
                style: StyleText.fontSize14Weight500),
            if (quote.decisionBy.isNotEmpty)
              Text('By: ${quote.decisionBy}',
                  style: StyleText.fontSize12Weight400),
            if (quote.rejectReason.isNotEmpty)
              Text('Reason: ${quote.rejectReason}',
                  style: StyleText.fontSize12Weight400)
          ]));
  Widget _overview(CrmClientQuoteRecordModel quote) => CrmSectionCard(
      title: 'Quote Details',
      showHideToggle: true,
      child: Column(children: <Widget>[
        CustomTextField(
            label: 'Quote Number',
            initialValue: quote.quoteNo,
            readOnly: true,
            fillColor: AppColors.background),
        SizedBox(height: 12.sp),
        CustomTextField(
            label: 'Valid Until',
            initialValue: _date(quote.validUntil),
            readOnly: true,
            fillColor: AppColors.background)
      ]));
  String _date(DateTime value) => '${value.day}/${value.month}/${value.year}';
  String _money(double value, String currency) => '$currency $value';
  String _term(Map<String, dynamic> value) =>
      '${value['Text_En'] ?? value['Name_En'] ?? value['Text_Ar'] ?? value['Name_Ar'] ?? ''}';
}

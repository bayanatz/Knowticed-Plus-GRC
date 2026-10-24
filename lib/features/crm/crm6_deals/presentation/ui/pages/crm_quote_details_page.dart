// ****************** FILE INFO ******************
// File Name: crm_quote_details_page.dart
// Purpose: Live Firebase-backed quote details with editing and version drafting.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_tabs.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/features/crm/data/legacy_core/custom/custom_status_dropdown_button_99.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/routing/crm_routes/crm_routes.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_quote_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_quote_details_cubit.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_quote_details_state.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_documents_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_products_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_services_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_terms_tab.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';

class CrmQuoteDetailsPage extends StatefulWidget {
  final String clientId;
  final String dealId;
  final String quoteId;
  const CrmQuoteDetailsPage(
      {super.key,
      required this.clientId,
      required this.dealId,
      required this.quoteId});
  @override
  State<CrmQuoteDetailsPage> createState() => _CrmQuoteDetailsPageState();
}

class _CrmQuoteDetailsPageState extends State<CrmQuoteDetailsPage> {
  late final CrmClientQuoteDetailsCubit _cubit;
  final TextEditingController _validUntil = TextEditingController();
  final TextEditingController _noteEn = TextEditingController();
  final TextEditingController _noteAr = TextEditingController();
  int _tab = 0;
  bool _editing = false;
  static const List<String> _tabs = <String>[
    'Overview',
    'Products',
    'Services',
    'Terms',
    'Documents',
  ];

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
    _validUntil.dispose();
    _noteEn.dispose();
    _noteAr.dispose();
    _cubit.close();
    super.dispose();
  }

  void _sync(CrmClientQuoteRecordModel quote) {
    if (!_editing) {
      _validUntil.text = _date(quote.validUntil);
      _noteEn.text = quote.noteEn;
      _noteAr.text = quote.noteAr;
    }
  }

  Future<void> _save(CrmClientQuoteRecordModel quote) async {
    final DateTime? validUntil = _parseDate(_validUntil.text);
    if (validUntil == null) {
      await CrmControlDialogs.showErrorDialog(
          context: context,
          title: 'Quote',
          subtitle: 'Enter a valid expiry date.');
      return;
    }
    showLoadingIndicator();
    final bool saved = await _cubit.saveEdit(
        validUntil: validUntil,
        noteEn: _noteEn.text,
        noteAr: _noteAr.text,
        paymentTerm: quote.paymentTerm,
        deliveryTerm: quote.deliveryTerm,
        attachments: quote.attachments,
        changedBy: '');
    hideLoadingIndicator();
    if (!mounted) return;
    if (!saved) {
      await CrmControlDialogs.showErrorDialog(
          context: context,
          title: 'Quote',
          subtitle: _cubit.state.errorMessage ?? 'Quote could not be updated.');
      return;
    }
    setState(() => _editing = false);
    await CrmControlDialogs.showSuccessDialog(
        context: context,
        title: 'Quote Updated',
        subtitle: 'Quote details were saved successfully.');
  }

  Future<void> _createVersion(CrmClientQuoteRecordModel quote) =>
      CrmControlDialogs.showSaveDialog(
          context: context,
          title: 'Create Version',
          subtitle:
              'A new draft will be created from version ${quote.version}.',
          onConfirm: () => Navigator.pushNamed(context, CrmRoutes.addQuote,
                  arguments: <String, dynamic>{
                    'clientId': quote.clientId,
                    'dealId': quote.dealId,
                    'sourceQuoteId': quote.id
                  }));

  Future<void> _delete() async {
    await CrmControlDialogs.showRemoveDialog(
        context: context,
        title: 'Delete Quote',
        subtitle: 'This quote will be permanently deleted.',
        onConfirm: () async {
          final bool deleted = await _cubit.delete('');
          if (mounted && deleted) Navigator.pop(context);
        });
  }

  void _createContract(CrmClientQuoteRecordModel quote) {
    Navigator.pushNamed(context, CrmRoutes.createContract,
        arguments: <String, dynamic>{
          'clientId': quote.clientId,
          'dealId': quote.dealId,
          'quoteId': quote.id,
        });
  }

  @override
  Widget build(BuildContext context) =>
      BlocProvider<CrmClientQuoteDetailsCubit>.value(
          value: _cubit,
          child: BlocConsumer<CrmClientQuoteDetailsCubit,
              CrmClientQuoteDetailsState>(
            listener: (_, state) {
              if (state.quote != null) {
                _sync(state.quote!);
              }
            },
            builder: (BuildContext context, CrmClientQuoteDetailsState state) {
              if (state.isLoading && state.quote == null) {
                return const Scaffold(
                    body: Center(child: CircleProgressMaster()));
              }
              if (state.quote == null) {
                return Scaffold(
                    body: Center(
                        child: Text(state.errorMessage ?? 'Quote not found.',
                            style: StyleText.fontSize16Weight500)));
              }
              final quote = state.quote!;
              return Scaffold(
                  backgroundColor: AppColors.background,
                  body: SideFrameMasterServices(
                      titleText: 'Deals',
                      secondTitle: quote.quoteNo,
                      thirdTitle: 'Quote Details',
                      onFirstTap: () => Navigator.pop(context),
                      onSecondTap: () => Navigator.pop(context),
                      child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                            _header(quote),
                            SizedBox(height: 18.sp),
                            CustomTabs(
                                tabs: _tabs,
                                selectedValue: _tab,
                                spacing: 22.sp,
                                onChanged: (value) => setState(() {
                                      _tab = value;
                                      _editing = false;
                                    })),
                            SizedBox(height: 20.sp),
                            _content(quote)
                          ]))));
            },
          ));

  Widget _header(CrmClientQuoteRecordModel quote) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        CustomStatusDropdownButton<String>(
            value: quote.status,
            useButtonSizing: true,
            items: _statusItems,
            isEnabled: false),
        Row(children: <Widget>[
          if (quote.status == 'adjustment') ...<Widget>[
            customButtonWithSvg(
                title: 'Create Version',
                image: AppAssets.crmVersion,
                widthImage: 18.sp,
                heightImage: 18.sp,
                colorBorder: AppColors.transparent,
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight500,
                function: () => _createVersion(quote)),
            SizedBox(width: 8.sp)
          ],
          if (quote.status == 'approved') ...<Widget>[
            customButtonWithSvg(
                title: 'Create Contract',
                image: AppAssets.crmTablerContract,
                widthImage: 18.sp,
                heightImage: 18.sp,
                colorBorder: AppColors.transparent,
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight500,
                function: () => _createContract(quote)),
            SizedBox(width: 8.sp)
          ],
          CustomDeleteIcon(
              title: 'Delete',
              color: AppColors.red,
              borderColor: AppColors.transparent,
              svgColor: AppColors.white,
              textStyle: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.white),
              onTap: _delete),
        ])
      ]);
  List<StatusDropdownItem<String>> get _statusItems =>
      <StatusDropdownItem<String>>[
        StatusDropdownItem(
            value: 'pending', label: 'Pending', color: AppColors.orange),
        StatusDropdownItem(
            value: 'adjustment', label: 'Adjustment', color: AppColors.blue),
        StatusDropdownItem(
            value: 'approved', label: 'Approved', color: AppColors.green),
        StatusDropdownItem(
            value: 'reject', label: 'Reject', color: AppColors.red),
        StatusDropdownItem(
            value: 'expired', label: 'Expired', color: AppColors.darkGrey),
        StatusDropdownItem(
            value: 'draft', label: 'Draft', color: AppColors.grey),
      ];
  Widget _content(CrmClientQuoteRecordModel quote) {
    switch (_tab) {
      case 0:
        return _overview(quote);
      case 1:
        return CrmQuoteProductsTab(
          items: quote.productLines
              .map((Map<String, dynamic> line) =>
                  QuoteProductLineItemModel.fromSnapshot(line, quote.currency))
              .toList(),
          subtotalValue: _money(quote.subtotal, quote.currency),
          taxesValue: _money(quote.taxTotal, quote.currency),
          discountValue: '-${_money(quote.discountTotal, quote.currency)}',
          totalValue: _money(quote.grandTotal, quote.currency),
        );
      case 2:
        return CrmQuoteServicesTab(
          items: quote.serviceLines
              .map((Map<String, dynamic> line) =>
                  QuoteServiceLineItemModel.fromSnapshot(line, quote.currency))
              .toList(),
          subtotalValue: _money(quote.subtotal, quote.currency),
          taxesValue: _money(quote.taxTotal, quote.currency),
          discountValue: '-${_money(quote.discountTotal, quote.currency)}',
          totalValue: _money(quote.grandTotal, quote.currency),
        );
      case 3:
        return CrmQuoteTermsTab(
          initialPaymentTerm: _termText(quote.paymentTerm),
          initialDeliveryTerm: _termText(quote.deliveryTerm),
          initialNoteEn: quote.noteEn,
          initialNoteAr: quote.noteAr,
          attachments: quote.attachments,
        );
      case 4:
        return const CrmQuoteDocumentsTab();
      default:
        return _overview(quote);
    }
  }

  Widget _overview(CrmClientQuoteRecordModel quote) => CrmSectionCard(
      title: 'Quote Details',
      showHideToggle: false,
      trailing: !_editing
          ? customButtonWithSvg(
              title: 'Edit',
              image: AppAssets.edit,
              widthImage: 14.sp,
              heightImage: 14.sp,
              colorBorder: AppColors.transparent,
              color: AppColors.primary,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.blackButton,
              ),
              function: () => setState(() => _editing = true))
          : null,
      child: Column(children: <Widget>[
        _field(
            'Quote Number', TextEditingController(text: quote.quoteNo), true),
        _field('Quote Date',
            TextEditingController(text: _date(quote.quoteDate)), true),
        _field('Valid Until', _validUntil, !_editing),
        _field('Note', _noteEn, !_editing, lines: 3),
        _field('ملاحظة', _noteAr, !_editing, lines: 3),
        if (_editing)
          Row(
              textDirection: TextDirection
                  .ltr, // X-73: Cancel left, action right in both languages

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                customButton(
                    title: 'Discard',
                    color: AppColors.grey,
                    textColor: AppColors.black,
                    function: () => setState(() {
                          _editing = false;
                          _sync(quote);
                        })),
                customButton(
                    title: 'Save',
                    color: AppColors.primary,
                    textColor: AppColors.black,
                    function: () => _save(quote))
              ])
      ]));
  Widget _field(String label, TextEditingController controller, bool readOnly,
          {int lines = 1}) =>
      Padding(
          padding: EdgeInsets.only(bottom: 12.sp),
          child: CustomTextField(
              label: label,
              controller: controller,
              readOnly: readOnly,
              maxLines: lines,
              minLines: lines,
              fillColor: AppColors.background));

  String _date(DateTime value) => '${value.day}/${value.month}/${value.year}';
  String _money(double value, String currency) => '$currency $value';
  String _termText(Map<String, dynamic> term) {
    for (final String key in <String>[
      'Text_En',
      'Name_En',
      'Text_Ar',
      'Name_Ar',
    ]) {
      final String value = '${term[key] ?? ''}'.trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('/');
    return parts.length == 3
        ? DateTime.tryParse(
            '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}')
        : null;
  }
}

// ****************** FILE INFO ******************
// File Name: crm_add_quote_page.dart
// Purpose: Multi-step Add Quote wizard container page hosting steps 1 to 4 with SideFrameMasterServices matching Figma screenshots
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_upload_document.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_quote_form_cubit.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_client_quote_form_state.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_quote_step1_details.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_quote_step2_preview_products.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_quote_step3_commercial_terms.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_quote_step4_review_pdf.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_add_quote_stepper_header.dart';

class CrmAddQuotePage extends StatefulWidget {
  final CrmClientDealModel? deal;
  final String clientId;
  final String dealId;
  final String? sourceQuoteId;

  const CrmAddQuotePage({
    super.key,
    this.deal,
    required this.clientId,
    required this.dealId,
    this.sourceQuoteId,
  });

  @override
  State<CrmAddQuotePage> createState() => _CrmAddQuotePageState();
}

class _CrmAddQuotePageState extends State<CrmAddQuotePage> {
  late final CrmClientQuoteFormCubit _quoteCubit;
  StreamSubscription<CrmClientQuoteFormState>? _quoteSubscription;
  bool _didPrefillSource = false;
  int _currentStep = 1;
  bool _showStep3Validation = false;

  // ── Step 1 Form Controllers ─────────────────────────────────────────────────
  final TextEditingController _quoteNumberController =
      TextEditingController(text: '78855A');
  late final TextEditingController _quoteDateController;
  final TextEditingController _quoteDateUntilController =
      TextEditingController();
  final TextEditingController _step1NoteEnController = TextEditingController();
  final TextEditingController _step1NoteArController = TextEditingController();

  // ── Step 3 Form State ───────────────────────────────────────────────────────
  String? _selectedPaymentTerm;
  String? _selectedDeliveryTerm;
  final TextEditingController _step3NoteEnController = TextEditingController();
  final TextEditingController _step3NoteArController = TextEditingController();
  final List<String> _uploadedFiles = <String>[];

  @override
  void initState() {
    super.initState();
    _quoteDateController =
        TextEditingController(text: _formatDate(DateTime.now()));
    _quoteCubit = CrmClientQuoteFormCubit()
      ..load(
        clientId: widget.clientId,
        dealId: widget.dealId,
        sourceQuoteId: widget.sourceQuoteId,
      );
    _quoteSubscription = _quoteCubit.stream.listen((state) {
      final source = state.sourceQuote;
      if (source != null && mounted && !_didPrefillSource) {
        _didPrefillSource = true;
        setState(() {
          _quoteNumberController.text =
              '${source.quoteNo} • V${source.version + 1}';
          _quoteDateController.text =
              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
          _quoteDateUntilController.text =
              '${source.validUntil.day}/${source.validUntil.month}/${source.validUntil.year}';
          _step1NoteEnController.text = source.noteEn;
          _step1NoteArController.text = source.noteAr;
          _step3NoteEnController.text = source.noteEn;
          _step3NoteArController.text = source.noteAr;
          _selectedPaymentTerm = source.paymentTerm['Clause_Id']?.toString();
          _selectedDeliveryTerm = source.deliveryTerm['Clause_Id']?.toString();
          _uploadedFiles
            ..clear()
            ..addAll(source.attachments.map((item) => '${item['Name'] ?? ''}'));
        });
      }
    });
  }

  @override
  void dispose() {
    _quoteNumberController.dispose();
    _quoteDateController.dispose();
    _quoteDateUntilController.dispose();
    _step1NoteEnController.dispose();
    _step1NoteArController.dispose();
    _step3NoteEnController.dispose();
    _step3NoteArController.dispose();
    _quoteSubscription?.cancel();
    _quoteCubit.close();
    super.dispose();
  }

  bool get _isStep1Valid =>
      _quoteDateUntilController.text.trim().isNotEmpty &&
      _quoteNumberController.text.trim().isNotEmpty;

  bool get _isStep3Valid =>
      _selectedPaymentTerm != null &&
      _selectedPaymentTerm!.isNotEmpty &&
      _selectedDeliveryTerm != null &&
      _selectedDeliveryTerm!.isNotEmpty;

  void _onNextStep() {
    if (_currentStep == 1) {
      if (!_isStep1Valid) return;
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      if (!_isStep3Valid) {
        setState(() => _showStep3Validation = true);
        return;
      }
      setState(() => _currentStep = 4);
    } else if (_currentStep == 4) {
      _confirmSubmitQuote();
    }
  }

  Future<void> _confirmSubmitQuote() async {
    if (_quoteCubit.state.isSaving) return;
    await CrmControlDialogs.showSaveDialog(
      context: context,
      title: 'Send Quote to Approve',
      subtitle: 'Are you sure you want to send this quote for approval?',
      onConfirm: _onSubmitQuote,
    );
  }

  Future<void> _onSubmitQuote() async {
    if (_quoteCubit.state.isSaving) return;
    _quoteCubit.setNotes(
      noteEn: _step1NoteEnController.text.trim().isNotEmpty
          ? _step1NoteEnController.text
          : _step3NoteEnController.text,
      noteAr: _step1NoteArController.text.trim().isNotEmpty
          ? _step1NoteArController.text
          : _step3NoteArController.text,
    );
    showLoadingIndicator();
    late final bool saved;
    try {
      saved = await _quoteCubit.save(submit: true, userId: '');
    } finally {
      hideLoadingIndicator();
    }
    if (!mounted) return;
    if (!saved) {
      CrmControlDialogs.showErrorDialog(
        context: context,
        title: 'Quote',
        subtitle: _quoteCubit.state.errorMessage ?? 'Quote could not be saved.',
      );
      return;
    }
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Quote Submitted',
        arabicName: 'تم إرسال عرض الأسعار',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'Quote has been sent to approval workflow successfully.',
        arabicName: 'تم إرسال عرض الأسعار إلى مسار الموافقة بنجاح.',
      ),
      onComplete: () => Navigator.pop(context),
    );
  }

  Future<void> _pickDateUntil() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (BuildContext ctx, Widget? child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.black,
              onSurface: AppColors.black,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      final List<String> months = <String>[
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final String formatted =
          '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      setState(() {
        _quoteDateUntilController.text = formatted;
      });
      _quoteCubit.setValidUntil(picked);
    }
  }

  Future<void> _pickFiles() async {
    await showUploadDialog(
      context: context,
      dialogTitle: FormatHelper.localizedString(
        englishName: 'Adding Attachment',
        arabicName: 'إضافة مرفق',
      ),
      titleFieldLabel: FormatHelper.localizedString(
        englishName: 'Title Name',
        arabicName: 'اسم العنوان',
      ),
      titleFieldHint: FormatHelper.localizedString(
        englishName: 'Text here',
        arabicName: 'اكتب هنا',
      ),
      submitLabel: FormatHelper.localizedString(
        englishName: 'Submit',
        arabicName: 'حفظ',
      ),
      discardLabel: FormatHelper.localizedString(
        englishName: 'Discard',
        arabicName: 'إلغاء',
      ),
      browseLabel: FormatHelper.localizedString(
        englishName: 'Browse Files',
        arabicName: 'تصفح الملفات',
      ),
      onSubmit: (PlatformFile file, String titleName) {
        setState(() {
          final String displayName =
              titleName.trim().isNotEmpty ? titleName.trim() : file.name;
          _uploadedFiles.add(displayName);
        });
        _quoteCubit.addAttachmentMetadata(<String, dynamic>{
          'Title': titleName,
          'Name': file.name,
          'Extension': file.extension ?? '',
          'Size_Bytes': file.size,
          'Picked_At': DateTime.now().toIso8601String(),
        });
      },
    );
  }

  void _onDownloadPdf() {
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Download PDF',
        arabicName: 'تحميل ملف PDF',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'PDF quote document is being prepared for download.',
        arabicName: 'جاري تجهيز ملف عرض الأسعار بصيغة PDF للتحميل.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String dealName = widget.deal?.dealNameEn ?? 'ERP System Deal';

    return SideFrameMasterServices(
      titleText: FormatHelper.localizedString(
        englishName: 'Deals',
        arabicName: 'الصفقات',
      ),
      secondTitle: dealName,
      thirdTitle: FormatHelper.localizedString(
        englishName: 'Add Quote',
        arabicName: 'إضافة عرض أسعار',
      ),
      onFirstTap: () => Navigator.pop(context),
      onSecondTap: () => Navigator.pop(context),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── 1. 4-Step Navigation Header ───────────────────────────────────
            CrmAddQuoteStepperHeader(
              currentStep: _currentStep,
              onStepTapped: (int step) {
                if (step < _currentStep || (step == 2 && _isStep1Valid)) {
                  setState(() => _currentStep = step);
                }
              },
            ),

            SizedBox(height: 20.sp),

            // ── 2. Active Step Content ────────────────────────────────────────
            _buildActiveStepContent(),

            SizedBox(height: 24.sp),

            // ── 3. Bottom Action Buttons Row ──────────────────────────────────
            _buildBottomActionsRow(context),

            SizedBox(height: 32.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveStepContent() {
    switch (_currentStep) {
      case 1:
        return CrmAddQuoteStep1Details(
          quoteNumberController: _quoteNumberController,
          quoteDateController: _quoteDateController,
          quoteDateUntilController: _quoteDateUntilController,
          noteEnController: _step1NoteEnController,
          noteArController: _step1NoteArController,
          onSelectQuoteDateUntil: _pickDateUntil,
          onChanged: (_) => setState(() {}),
        );
      case 2:
        return StreamBuilder<CrmClientQuoteFormState>(
          stream: _quoteCubit.stream,
          initialData: _quoteCubit.state,
          builder: (BuildContext context,
                  AsyncSnapshot<CrmClientQuoteFormState> snapshot) =>
              _buildSnapshotPreview(snapshot.data ?? _quoteCubit.state),
        );
      case 3:
        return StreamBuilder<CrmClientQuoteFormState>(
          stream: _quoteCubit.stream,
          initialData: _quoteCubit.state,
          builder: (BuildContext context,
              AsyncSnapshot<CrmClientQuoteFormState> snapshot) {
            final CrmClientQuoteFormState state =
                snapshot.data ?? _quoteCubit.state;
            return CrmAddQuoteStep3CommercialTerms(
              selectedPaymentTerm: _selectedPaymentTerm,
              selectedDeliveryTerm: _selectedDeliveryTerm,
              paymentTermOptions: state.paymentGroup?.clauses
                      .map((item) =>
                          QuoteTermOption(id: item.id, label: item.textEn))
                      .toList() ??
                  const <QuoteTermOption>[],
              deliveryTermOptions: state.deliveryGroup?.clauses
                      .map((item) =>
                          QuoteTermOption(id: item.id, label: item.textEn))
                      .toList() ??
                  const <QuoteTermOption>[],
              onPaymentTermChanged: (String? value) {
                setState(() => _selectedPaymentTerm = value);
                _quoteCubit.setPaymentClause(value);
              },
              onDeliveryTermChanged: (String? value) {
                setState(() => _selectedDeliveryTerm = value);
                _quoteCubit.setDeliveryClause(value);
              },
              noteEnController: _step3NoteEnController,
              noteArController: _step3NoteArController,
              uploadedFiles: _uploadedFiles,
              onUploadFile: _pickFiles,
              onAddFiles: _pickFiles,
              onRemoveFile: (String file) =>
                  setState(() => _uploadedFiles.remove(file)),
              showValidationErrors: _showStep3Validation,
              onChanged: (_) => setState(() {}),
            );
          },
        );
      case 4:
        return CrmAddQuoteStep4ReviewPdf(
          quoteNumber: _quoteNumberController.text,
          quoteDate: _quoteDateController.text,
          quoteDateUntil: _quoteDateUntilController.text.isNotEmpty
              ? _quoteDateUntilController.text
              : '14 Jun 2026',
          clientName: widget.deal?.assignedEmployee ?? 'John Doe Enterprises',
          onDownloadPdf: _onDownloadPdf,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomActionsRow(BuildContext context) {
    final bool isNextActive = (_currentStep == 1 && _isStep1Valid) ||
        _currentStep == 2 ||
        (_currentStep == 3 && _isStep3Valid) ||
        _currentStep == 4;

    final String nextButtonTitle = _currentStep == 4
        ? FormatHelper.localizedString(
            englishName: 'Sent to Approve',
            arabicName: 'إرسال للموافقة',
          )
        : FormatHelper.localizedString(
            englishName: 'Next',
            arabicName: 'التالي',
          );

    return Row(
      textDirection: TextDirection
          .ltr, // X-73: Cancel left, action right in both languages

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Left Column: Discard + Save For Later
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            customButton(
              title: FormatHelper.localizedString(
                englishName: 'Discard',
                arabicName: 'تراجع',
              ),
              color: const Color(0xFFE5E7EB),
              borderColor: Colors.transparent,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.blackButton,
              ),
              function: () => Navigator.pop(context),
            ),
            SizedBox(height: 10.sp),
            customButton(
              title: FormatHelper.localizedString(
                englishName: 'Save For Later',
                arabicName: 'حفظ لوقت لاحق',
              ),
              color: const Color(0xFF595959),
              borderColor: Colors.transparent,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
              function: _saveDraft,
            ),
          ],
        ),

        // Right Button: Next or Sent to Approve
        customButton(
          title: nextButtonTitle,
          color: isNextActive ? AppColors.primary : const Color(0xFFE5E7EB),
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
            color: isNextActive ? AppColors.black : const Color(0xFF9CA3AF),
          ),
          function:
              isNextActive && !_quoteCubit.state.isSaving ? _onNextStep : () {},
        ),
      ],
    );
  }

  Future<void> _saveDraft() async {
    _quoteCubit.setNotes(
      noteEn: _step1NoteEnController.text.trim().isNotEmpty
          ? _step1NoteEnController.text
          : _step3NoteEnController.text,
      noteAr: _step1NoteArController.text.trim().isNotEmpty
          ? _step1NoteArController.text
          : _step3NoteArController.text,
    );
    final bool saved = await _quoteCubit.save(submit: false, userId: '');
    if (!mounted) return;
    if (!saved) {
      CrmControlDialogs.showErrorDialog(
        context: context,
        title: 'Quote',
        subtitle: _quoteCubit.state.errorMessage ?? 'Quote could not be saved.',
      );
      return;
    }
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: 'Quote Draft Saved',
      subtitle: 'Draft saved successfully.',
      onComplete: () => Navigator.pop(context),
    );
  }

  Widget _buildSnapshotPreview(CrmClientQuoteFormState state) {
    final String currency = state.deal?.currency ?? 'EGP';
    String money(dynamic value) => '$currency ${value ?? 0}';
    final List<QuoteProductPreviewItem> products = state.deal?.productLines
            .map((line) => QuoteProductPreviewItem(
                category: '${line['Category_Name_En'] ?? ''}',
                product: '${line['Name_En'] ?? line['Product_Name_En'] ?? ''}',
                quantity: '${line['Quantity'] ?? 0}',
                unitPrice: money(line['Unit_Price']),
                discount:
                    '${line['Discount_Percentage'] ?? line['Discount'] ?? 0}%',
                tax: money(line['Tax_Amount'] ?? line['Tax']),
                total: money(line['Line_Total'] ?? line['Total'])))
            .toList() ??
        const <QuoteProductPreviewItem>[];
    final List<QuoteServicePreviewItem> services = state.deal?.serviceLines
            .map((line) => QuoteServicePreviewItem(
                category: '${line['Category_Name_En'] ?? ''}',
                service: '${line['Name_En'] ?? line['Service_Name_En'] ?? ''}',
                price: money(line['Unit_Price'] ?? line['Price']),
                discount:
                    '${line['Discount_Percentage'] ?? line['Discount'] ?? 0}%',
                tax: money(line['Tax_Amount'] ?? line['Tax']),
                total: money(line['Line_Total'] ?? line['Total'])))
            .toList() ??
        const <QuoteServicePreviewItem>[];
    return CrmAddQuoteStep2PreviewProducts(
      products: products,
      services: services,
      subtotalProducts: money(state.deal?.subtotal),
      subtotalServices: '',
      taxes: money(state.deal?.taxTotal),
      discount: '-${money(state.deal?.discountTotal)}',
      grandTotal: money(state.deal?.grandTotal),
    );
  }

  static String _formatDate(DateTime dt) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

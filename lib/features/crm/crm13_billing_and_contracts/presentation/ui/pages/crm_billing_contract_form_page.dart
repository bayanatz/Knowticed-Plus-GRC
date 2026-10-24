// ****************** FILE INFO ******************
// File Name: crm_billing_contract_form_page.dart
// Purpose: Edit form page for CRM Billing & Contract templates matching Figma design
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_upload_document.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_color_picker.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_control_dialogs.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/data/models/crm_billing_contract_model.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/presentation/controller/crm_billing_contracts_cubit.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/presentation/ui/widgets/crm_billing_files_section.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:file_picker/file_picker.dart';

class _NoteItemControllers {
  final TextEditingController enController;
  final TextEditingController arController;

  _NoteItemControllers({String en = '', String ar = ''})
      : enController = TextEditingController(text: en),
        arController = TextEditingController(text: ar);

  void dispose() {
    enController.dispose();
    arController.dispose();
  }
}

class CrmBillingContractFormPage extends StatefulWidget {
  final CrmBillingContractModel? item;
  final String mode;
  final String? initialUploadField;

  const CrmBillingContractFormPage({
    super.key,
    this.item,
    this.mode = 'edit',
    this.initialUploadField,
  });

  @override
  State<CrmBillingContractFormPage> createState() =>
      _CrmBillingContractFormPageState();
}

class _CrmBillingContractFormPageState
    extends State<CrmBillingContractFormPage> {
  late final CrmBillingContractsCubit _cubit;
  late final TextEditingController _messageEnController;
  late final TextEditingController _messageArController;
  late final TextEditingController _contractBodyEnController;
  late final TextEditingController _contractBodyArController;
  final List<_NoteItemControllers> _noteControllers = <_NoteItemControllers>[];
  final List<_NoteItemControllers> _sectionControllers =
      <_NoteItemControllers>[];

  late Color _textColor;
  late Color _highlightColor;
  late String _logoUrl;
  late String _digitalSealUrl;
  late String _watermarkUrl;
  late String _signatureUrl;

  @override
  void initState() {
    super.initState();
    final CrmBillingContractModel? initial = widget.item;
    _cubit = CrmBillingContractsCubit();

    _messageEnController = TextEditingController(
      text: initial?.messageEn ?? '',
    );
    _messageArController = TextEditingController(
      text: initial?.messageAr ?? '',
    );
    _contractBodyEnController = TextEditingController(
      text: initial?.contractTerms ?? '',
    );
    _contractBodyArController = TextEditingController(
      text: initial?.contractTermsAr ?? '',
    );

    _textColor = _parseHex(initial?.textColorHex ?? '', AppColors.black);
    _highlightColor =
        _parseHex(initial?.highlightColorHex ?? '', AppColors.grey);
    _logoUrl = initial?.logoUrl ?? '';
    _digitalSealUrl = initial?.digitalSealUrl ?? '';
    _watermarkUrl = initial?.watermarkUrl ?? '';
    _signatureUrl = initial?.signatureUrl ?? '';

    final List<CrmBilingualNoteModel> initialNotes =
        (initial != null && initial.notes.isNotEmpty)
            ? initial.notes
            : <CrmBilingualNoteModel>[
                const CrmBilingualNoteModel(),
                const CrmBilingualNoteModel(),
                const CrmBilingualNoteModel(),
              ];

    for (final CrmBilingualNoteModel note in initialNotes) {
      _noteControllers.add(
        _NoteItemControllers(en: note.textEn, ar: note.textAr),
      );
    }

    final List<CrmBilingualNoteModel> initialSections =
        (initial != null && initial.contractSections.isNotEmpty)
            ? initial.contractSections
            : <CrmBilingualNoteModel>[
                const CrmBilingualNoteModel(),
                const CrmBilingualNoteModel(),
                const CrmBilingualNoteModel(),
              ];
    for (final CrmBilingualNoteModel section in initialSections) {
      _sectionControllers.add(
        _NoteItemControllers(en: section.textEn, ar: section.textAr),
      );
    }

    final String? initialUploadField = widget.initialUploadField;
    if (initialUploadField != null && initialUploadField.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openFileUpload(initialUploadField);
      });
    }
  }

  @override
  void dispose() {
    _messageEnController.dispose();
    _messageArController.dispose();
    _contractBodyEnController.dispose();
    _contractBodyArController.dispose();
    for (final _NoteItemControllers c in _noteControllers) {
      c.dispose();
    }
    for (final _NoteItemControllers c in _sectionControllers) {
      c.dispose();
    }
    _cubit.close();
    super.dispose();
  }

  Color _parseHex(String hex, Color fallback) {
    try {
      final String cleanHex = hex.replaceAll('#', '').trim();
      if (cleanHex.length == 6) {
        return Color(int.parse('0xFF$cleanHex'));
      } else if (cleanHex.length == 8) {
        return Color(int.parse('0x$cleanHex'));
      }
    } catch (_) {
      return fallback;
    }
    return fallback;
  }

  String _hexOf(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  void _addNote() {
    setState(() {
      _noteControllers.add(_NoteItemControllers());
    });
  }

  void _removeNote(int index) {
    _removeBilingualItem(_noteControllers, index);
  }

  void _addSection() {
    setState(() => _sectionControllers.add(_NoteItemControllers()));
  }

  void _removeSection(int index) {
    _removeBilingualItem(_sectionControllers, index);
  }

  void _removeBilingualItem(
    List<_NoteItemControllers> items,
    int index,
  ) {
    if (index < 0 || index >= items.length) return;
    setState(() {
      final _NoteItemControllers removed = items.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _openFileUpload(String field) async {
    await showUploadDialog(
      context: context,
      dialogTitle: S.current.crmUpload,
      titleFieldLabel: S.current.crmFiles,
      titleFieldHint: 'Text here',
      submitLabel: S.current.save,
      discardLabel: S.current.crmDiscard,
      browseLabel: S.current.crmUpload,
      onSubmit: (PlatformFile file, String _) {
        _uploadFile(file: file, field: field);
      },
    );
  }

  Future<void> _uploadFile({
    required PlatformFile file,
    required String field,
  }) async {
    final List<int>? bytes = file.bytes;
    if (bytes == null) {
      CrmControlDialogs.showErrorDialog(
        context: context,
        title: S.current.errorOccurred,
        subtitle: 'The selected file could not be read.',
      );
      return;
    }

    showLoadingIndicator();
    final String? url = await _cubit.uploadContentFile(
      controlId: widget.item?.id ?? '',
      field: field,
      bytes: bytes,
      fileName: file.name,
    );
    hideLoadingIndicator();
    if (!mounted) return;

    if (url == null) {
      CrmControlDialogs.showErrorDialog(
        context: context,
        title: S.current.errorOccurred,
        subtitle: _cubit.state.errorMessage ?? 'File upload failed.',
      );
      return;
    }

    setState(() {
      switch (field) {
        case CrmBillingContractModel.LOGO_URL:
          _logoUrl = url;
        case CrmBillingContractModel.DIGITAL_SEAL_URL:
          _digitalSealUrl = url;
        case CrmBillingContractModel.WATERMARK_URL:
          _watermarkUrl = url;
        case CrmBillingContractModel.SIGNATURE_URL:
          _signatureUrl = url;
      }
    });
  }

  void _onSave() {
    Navigator.pop(context, <String, dynamic>{
      'action': 'save',
      'item': _buildDraft(),
    });
  }

  CrmBillingContractModel _buildDraft() {
    return (widget.item ?? CrmBillingContractModel.getEmptyModel()).copyWith(
      messageEn: _messageEnController.text.trim(),
      messageAr: _messageArController.text.trim(),
      notes: _itemsToModels(_noteControllers),
      contractTerms: _contractBodyEnController.text.trim(),
      contractTermsAr: _contractBodyArController.text.trim(),
      contractSections: _itemsToModels(_sectionControllers),
      logoUrl: _logoUrl,
      digitalSealUrl: _digitalSealUrl,
      watermarkUrl: _watermarkUrl,
      signatureUrl: _signatureUrl,
      textColorHex: _hexOf(_textColor),
      highlightColorHex: _hexOf(_highlightColor),
    );
  }

  List<CrmBilingualNoteModel> _itemsToModels(
    List<_NoteItemControllers> items,
  ) {
    return items
        .map(
          (item) => CrmBilingualNoteModel(
            textEn: item.enController.text.trim(),
            textAr: item.arController.text.trim(),
          ),
        )
        .toList();
  }

  Future<void> _onPreview() async {
    final CrmBillingContractModel draft = _buildDraft();
    final dynamic result =
        await CrmNavigationHelper.navigateToControlBillingContractPreview(
      context,
      arguments: <String, dynamic>{'item': draft},
    );
    if (!mounted || result != 'save') return;
    Navigator.pop(context, <String, dynamic>{
      'action': 'save',
      'item': draft,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isBilling =
        widget.item?.id != CrmBillingContractModel.contractControlId;
    final String pageTitle = FormatHelper.localizedString(
      englishName: isBilling ? 'Edit Billing' : 'Edit Contract',
      arabicName: isBilling ? 'تعديل الفوترة' : 'تعديل العقد',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmControlBillingAndContracts,
        fourthTitle: pageTitle,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        onThirdTap: () => CrmNavigationHelper.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Files
              CrmBillingFilesSection(
                logoUrl: _logoUrl,
                digitalSealUrl: _digitalSealUrl,
                watermarkUrl: _watermarkUrl,
                signatureUrl: _signatureUrl,
                onLogoUpload: () =>
                    _openFileUpload(CrmBillingContractModel.LOGO_URL),
                onDigitalSealUpload: () => _openFileUpload(
                  CrmBillingContractModel.DIGITAL_SEAL_URL,
                ),
                onWatermarkUpload: () =>
                    _openFileUpload(CrmBillingContractModel.WATERMARK_URL),
                onSignatureUpload: () =>
                    _openFileUpload(CrmBillingContractModel.SIGNATURE_URL),
                onLogoRemove: () => setState(() => _logoUrl = ''),
                onDigitalSealRemove: () => setState(() => _digitalSealUrl = ''),
                onWatermarkRemove: () => setState(() => _watermarkUrl = ''),
                onSignatureRemove: () => setState(() => _signatureUrl = ''),
              ),
              SizedBox(height: 16.sp),

              if (!isBilling) ...<Widget>[
                _buildContractBodySection(),
                SizedBox(height: 16.sp),
                _buildContractSectionsSection(),
                SizedBox(height: 16.sp),
              ],

              _buildMessageSection(),
              SizedBox(height: 16.sp),

              // Section 3: Notes (Collapsible with + Note and delete)
              _buildNotesSection(),
              SizedBox(height: 16.sp),

              // Section 4: Colors (Collapsible with color pickers)
              _buildColorsSection(),
              SizedBox(height: 24.sp),

              // Bottom Action Buttons
              _buildBottomActionButtons(),
              SizedBox(height: 32.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageSection() {
    return CrmSectionCard(
      title: S.current.crmMessage,
      showHideToggle: true,
      child: Column(
        children: <Widget>[
          CustomTextField(
            controller: _messageEnController,
            label: 'Message',
            hint: 'Description',
            maxLines: 4,
            height: 104.sp,
            maxLength: 500,
            showCharCount: true,
            textDirection: TextDirection.ltr,
            fillColor: AppColors.background,
          ),
          SizedBox(height: 16.sp),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustomTextField(
              controller: _messageArController,
              label: 'رساله',
              hint: 'اكتب هنا',
              textAlign: TextAlign.right,
              maxLines: 4,
              height: 104.sp,
              maxLength: 500,
              showCharCount: true,
              textDirection: TextDirection.rtl,
              fillColor: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractBodySection() {
    return CrmSectionCard(
      title: 'Contract body',
      showHideToggle: true,
      child: Column(
        children: <Widget>[
          CustomTextField(
            controller: _contractBodyEnController,
            label: 'Text',
            hint: 'Description',
            maxLines: 4,
            height: 104.sp,
            maxLength: 500,
            showCharCount: true,
            fillColor: AppColors.background,
          ),
          SizedBox(height: 16.sp),
          Directionality(
            textDirection: TextDirection.rtl,
            child: CustomTextField(
              controller: _contractBodyArController,
              label: 'نص',
              hint: 'اكتب هنا',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              maxLines: 4,
              height: 104.sp,
              maxLength: 500,
              showCharCount: true,
              fillColor: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractSectionsSection() {
    return _buildBilingualRepeaterSection(
      title: 'Sections',
      items: _sectionControllers,
      onAdd: _addSection,
      onRemove: _removeSection,
      addTitle: 'Section',
      itemPrefix: 'Section',
      itemPrefixAr: 'قسم',
    );
  }

  Widget _buildNotesSection() {
    return _buildBilingualRepeaterSection(
      title: S.current.crmNotes,
      items: _noteControllers,
      onAdd: _addNote,
      onRemove: _removeNote,
      addTitle: S.current.crmAddNote,
      itemPrefix: 'Note',
      itemPrefixAr: 'ملاحظة',
    );
  }

  Widget _buildBilingualRepeaterSection({
    required String title,
    required List<_NoteItemControllers> items,
    required VoidCallback onAdd,
    required ValueChanged<int> onRemove,
    required String addTitle,
    required String itemPrefix,
    required String itemPrefixAr,
  }) {
    return CrmSectionCard(
      title: title,
      showHideToggle: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(items.length, (int index) {
            final _NoteItemControllers c = items[index];
            final String itemLabel = FormatHelper.localizedString(
              englishName: '$itemPrefix ${index + 1}',
              arabicName: '$itemPrefixAr ${index + 1}',
            );
            return Padding(
              padding: EdgeInsets.only(bottom: 16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        itemLabel,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                      customButtonWithSvg(
                        title: '',
                        image: AppAssets.minusCircle,
                        color: AppColors.transparent,
                        colorBorder: AppColors.transparent,
                        widthImage: 20.sp,
                        heightImage: 20.sp,
                        fixedWidth: 24.sp,
                        fixedHeight: 24.sp,
                        svgColor: AppColors.red,
                        textStyle: StyleText.fontSize12Weight500,
                        function: () => onRemove(index),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.sp),
                  buildResponsiveFields(
                    context: context,
                    left: CustomTextField(
                      controller: c.enController,
                      hint: 'Text Here',
                      fillColor: AppColors.background,
                    ),
                    right: Directionality(
                      textDirection: TextDirection.rtl,
                      child: CustomTextField(
                        controller: c.arController,
                        hint: 'اكتب هنا',
                        textAlign: TextAlign.right,
                        fillColor: AppColors.background,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 4.sp),
          customButtonWithSvg(
            title: addTitle,
            image: AppAssets.add,
            color: AppColors.blackButton,
            colorBorder: AppColors.transparent,
            widthImage: 14.sp,
            heightImage: 14.sp,
            fixedWidth: 86.sp,
            fixedHeight: 32.sp,
            textStyle: StyleText.fontSize12Weight500.copyWith(
              color: AppTheme.readableOn(AppColors.blackButton),
            ),
            svgColor: AppTheme.readableOn(AppColors.blackButton),
            function: onAdd,
          ),
        ],
      ),
    );
  }

  Widget _buildColorsSection() {
    return CrmSectionCard(
      title: S.current.crmColors,
      showHideToggle: true,
      child: buildResponsiveFields(
        context: context,
        left: CustomColorPickerField(
          label: S.current.crmTextColor,
          color: _textColor,
          dialogTitle: S.current.crmTextColor,
          onColorSelected: (Color value) => setState(() => _textColor = value),
        ),
        right: CustomColorPickerField(
          label: S.current.crmHighlightingColor,
          color: _highlightColor,
          dialogTitle: S.current.crmHighlightingColor,
          onColorSelected: (Color value) =>
              setState(() => _highlightColor = value),
        ),
      ),
    );
  }

  /// Function Name: _buildBottomActionButtons
  ///
  /// Purpose: Builds the bottom action buttons layout with Discard and Preview
  /// stacked in a column on the left and Next on the right, eliminating mobile
  /// horizontal overflow while keeping Preview below Discard across screen sizes.
  ///
  /// Returns: Widget containing the responsive bottom action buttons.
  Widget _buildBottomActionButtons() {
    final bool isMobile = kpIsPhoneLayout(context);
    final double buttonWidth = isMobile ? 120.sp : 140.sp;

    return Row(
      textDirection: TextDirection
          .ltr, // X-73: Cancel left, action right in both languages

      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customButton(
              title: S.current.crmDiscard,
              color: AppColors.disabledGrey,
              width: buttonWidth,
              textStyle: StyleText.fontSize14Weight600.copyWith(
                color: AppColors.blackButton,
              ),
              function: () => Navigator.pop(context),
            ),
            SizedBox(height: 12.sp),
            customButton(
              title: S.current.crmPreview,
              color: AppColors.blackButton,
              width: buttonWidth,
              textStyle: StyleText.fontSize14Weight600.copyWith(
                color: AppTheme.readableOn(AppColors.blackButton),
              ),
              function: _onPreview,
            ),
          ],
        ),
        customButton(
          title: S.current.save,
          color: AppColors.primary,
          width: buttonWidth,
          textStyle: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.blackButton,
          ),
          function: _onSave,
        ),
      ],
    );
  }
}

/// Module: services / sv3_create_master_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: upload_details.dart
/// Purpose: Preview and edit service-requests data from bulk upload, then
///          upload BOTH Step 1 and Step 2 to Firebase together. Cell validation
///          and the Firestore upload itself now live in MasterUploadCubit —
///          this page owns per-row TextEditingControllers/FocusNodes/GlobalKeys
///          (widget lifecycle) and drives navigation/dialogs.
/// Author: Amr Mesbah
/// Date: 02/07/2026
/// Dependencies: MasterUploadCubit, UploadDetailsToolbar,
///              UploadDetailsPreviewTable, UploadDetailsDialogs
/// Revision History:
///   - Initial version. RequestServices Firestore path:
///     /Demo/{companyId}/Modules/services/RequestServices/.
///   - 02/07/2026 (Knowticed Team): Removed the per-row try/catch (moved
///     into MasterUploadCubit.uploadRequests, fix item 4). Extracted
///     toolbar, preview table and dialogs into ui/widgets/ (fix item 5).
///   - 02/07/2026 (Knowticed Team, fix item 10): AppControllers.employee
///     / AppControllers.department retained deliberately —
///     no Provider/BlocProvider registration exists for these singletons
///     anywhere in the app (verified via grep). Sole remaining GetX usage
///     in this file; no Get.to/Get.off/GetBuilder present.
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/services/sv3_create_master_services/presentation/ui/widgets/upload_row_controllers.dart';
import 'package:knowticed_plus/features/services/sv3_create_master_services/presentation/ui/widgets/step2_validation_texts.dart';
import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services/sv3_create_master_services/presentation/ui/widgets/upload_details_toolbar.dart';
import 'package:knowticed_plus/features/services/sv3_create_master_services/presentation/ui/widgets/upload_details_preview_table.dart';
import 'package:knowticed_plus/features/services/sv3_create_master_services/presentation/ui/widgets/upload_details_dialogs.dart';
import 'package:knowticed_plus/features/services/sv3_create_master_services/presentation/controller/master_upload_cubit.dart';

import 'package:knowticed_plus/features/services/helpers/guarded_action.dart';

class UploadRequestsDetailsScreen extends StatefulWidget {
  const UploadRequestsDetailsScreen({
    super.key,
    required this.formData,
    required this.validationErrors,
    this.selectedFileName,
    required this.uploadedServicesFormData,
    this.step1UploadFunction,
  });

  final List<Map<String, TextEditingController>> formData;
  final List<Map<String, String>> validationErrors;
  final String? selectedFileName;

  /// Services uploaded in Step 1 — used to validate Service Name.
  final List<Map<String, TextEditingController>> uploadedServicesFormData;

  /// Step 1's deferred uploadToFirebase function.
  /// Returns Map`<String, String>` (serviceName → firestoreDocId).
  /// Called BEFORE Step 2 uploads so Parent_Service_Id uses real doc IDs.
  final Future<Map<String, String>> Function()? step1UploadFunction;

  @override
  State<UploadRequestsDetailsScreen> createState() =>
      _UploadRequestsDetailsScreenState();
}

class _UploadRequestsDetailsScreenState
    extends State<UploadRequestsDetailsScreen> {
  late final MasterUploadCubit _cubit;

  List<Map<String, TextEditingController>> formData = [];
  List<Map<String, String>> validationErrors = [];
  Set<int> selectedRows = {};
  String? selectedFileName;

  Set<String> _validServiceNames = {};

  final List<String> expectedHeaders = const [
    'Service Name',
    'Email Requester',
    'Service Provider',
    'Approvers',
    'State',
    'Requested Date',
  ];

  List<Map<String, GlobalKey>> fieldKeys = [];
  List<Map<String, FocusNode>> focusNodes = [];
  List<MapEntry<int, String>> errorLocations = [];
  int currentErrorIndex = -1;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cubit = MasterUploadCubit(
      repository: ServicesManagerCubit.get(context).repository,
      employeeController: AppControllers.employee,
      departmentController: context.read<MainCoreDepartmentCubit>(),
      // Rule "Inject repositories": the module's picker, not a new one.
      mediaPicker: context.read<MediaPickerService>(),
    );

    formData = widget.formData;
    validationErrors = widget.validationErrors;
    selectedFileName = widget.selectedFileName;

    _validServiceNames = widget.uploadedServicesFormData
        .map((row) => row['Service Name']?.text.trim().toLowerCase() ?? '')
        .where((n) => n.isNotEmpty)
        .toSet();

    focusNodes = List.generate(formData.length, (i) {
      final map = <String, FocusNode>{};
      for (final key in expectedHeaders) {
        map[key] = FocusNode();
      }
      return map;
    });

    fieldKeys = List.generate(formData.length, (i) {
      final map = <String, GlobalKey>{};
      for (final key in expectedHeaders) {
        map[key] = GlobalKey();
      }
      return map;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revalidateAll();
      updateErrorLocations();
    });
  }

  @override
  void dispose() {
    for (final row in focusNodes) {
      for (final node in row.values) {
        node.dispose();
      }
    }
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  // ─── Validation ──────────────────────────────────────────────
  String? validateCell(String key, String? value) {
    if (key == 'Service Name') {
      if (value != null &&
          value.trim().isNotEmpty &&
          !_validServiceNames.contains(value.trim().toLowerCase())) {
        return S.of(context).svcServiceNotInUploadedList;
      }
    }
    final error = _cubit.validateStep2Cell(
      key,
      value,
      messages: step2ValidationTexts(context),
    );
    if (error != null) return error;

    // Approvers/duplicate-email checks specific to this preview screen.
    if (key == 'Service Provider' || key == 'Approvers') {
      final v = value?.trim() ?? '';
      if (v.isNotEmpty) {
        final emails = v.split(',').map((e) => e.trim()).toList();
        if (emails.toSet().length != emails.length) {
          return S.of(context).duplicateEmails;
        }
      }
    }
    return null;
  }

  void _revalidateAll() {
    for (int i = 0; i < formData.length; i++) {
      final rowErr = <String, String>{};
      for (final header in expectedHeaders) {
        final val = formData[i][header]?.text ?? '';
        final error = validateCell(header, val);
        if (error != null) rowErr[header] = error;
      }
      if (i < validationErrors.length) {
        validationErrors[i] = rowErr;
      } else {
        validationErrors.add(rowErr);
      }
    }
  }

  int getTotalErrorCount() {
    int total = 0;
    for (final row in validationErrors) {
      total += row.length;
    }
    return total;
  }

  void updateErrorLocations() {
    errorLocations.clear();
    for (int row = 0; row < validationErrors.length; row++) {
      validationErrors[row].forEach((header, _) {
        errorLocations.add(MapEntry(row, header));
      });
    }
    if (errorLocations.isEmpty) {
      currentErrorIndex = -1;
    } else if (currentErrorIndex >= errorLocations.length ||
        currentErrorIndex < 0) {
      currentErrorIndex = 0;
    }
  }

  void focusErrorField(bool forward) {
    if (errorLocations.isEmpty) return;
    setState(() {
      if (forward) {
        currentErrorIndex = (currentErrorIndex + 1) % errorLocations.length;
      } else {
        currentErrorIndex = (currentErrorIndex - 1 + errorLocations.length) %
            errorLocations.length;
      }
    });

    final entry = errorLocations[currentErrorIndex];
    final rowIndex = entry.key;
    final header = entry.value;
    final key = fieldKeys[rowIndex][header];
    final node = focusNodes[rowIndex][header];
    final controller = formData[rowIndex][header];

    // S2: the post-frame callback already runs after layout; the extra
    // fixed 100 ms wait was removed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = key?.currentContext;
      if (ctx != null) {
        if (!ctx.mounted) return;
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 500),
          alignment: 0.3,
          curve: Curves.easeInOut,
        ).then((_) {
          if (controller != null && node != null) {
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
            if (!mounted) return;
            FocusScope.of(context).requestFocus(node);
          }
        });
      }
    });
  }

  // ─── Firebase upload ─────────────────────────────────────────
  Future<void> uploadToFirebase() async {
    await _cubit.uploadRequests(
      formData: toRowValues(formData),
      step1UploadFunction: widget.step1UploadFunction,
    );
  }

  // ─── Row actions ─────────────────────────────────────────────
  void _onCellChanged(int rowIndex, String header) {
    final val = formData[rowIndex][header]?.text ?? '';
    final error = validateCell(header, val);
    setState(() {
      if (error != null) {
        validationErrors[rowIndex][header] = error;
      } else {
        validationErrors[rowIndex].remove(header);
      }
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => updateErrorLocations(),
      );
    });
  }

  void _toggleRowSelected(int rowIndex) {
    setState(() {
      if (selectedRows.contains(rowIndex)) {
        selectedRows.remove(rowIndex);
      } else {
        selectedRows.add(rowIndex);
      }
    });
  }

  void _removeSelectedRows() {
    if (selectedRows.isEmpty) return;
    setState(() {
      final sorted = selectedRows.toList()..sort((a, b) => b.compareTo(a));
      for (final i in sorted) {
        formData.removeAt(i);
        validationErrors.removeAt(i);
        focusNodes.removeAt(i);
        fieldKeys.removeAt(i);
      }
      selectedRows.clear();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => updateErrorLocations(),
      );
    });
  }

  void _addRow() {
    final newRow = <String, TextEditingController>{};
    final newFocus = <String, FocusNode>{};
    final newKeys = <String, GlobalKey>{};
    for (final h in expectedHeaders) {
      newRow[h] = TextEditingController();
      newFocus[h] = FocusNode();
      newKeys[h] = GlobalKey();
    }
    setState(() {
      formData.add(newRow);
      validationErrors.add({});
      focusNodes.add(newFocus);
      fieldKeys.add(newKeys);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => updateErrorLocations(),
      );
    });
  }

  Future<void> _handleReviewTap(bool lightMode) async {
    if (getTotalErrorCount() > 0) {
      UploadDetailsDialogs.showMustCorrectErrors(context);
      return;
    }

    await UploadDetailsDialogs.showConfirmActivate(
      context,
      lightMode: lightMode,
      onConfirm: () => _confirmActivate(),
    );
  }

  Future<void> _confirmActivate() async {
    if (!mounted) return;

    // C8: the failure comes back as a value (svcGuard) instead of a
    // try/catch in the page.
    final error = await svcGuard(uploadToFirebase);
    if (error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).uploadFailedTryAgain)),
      );
      return;
    }

    if (!mounted) return;

    final cubit = ServicesManagerCubit.get(context);
    await cubit.getAllServices();
    await cubit.getAllRequestServices();

    if (!mounted) return;
    UploadDetailsDialogs.showActivatedSuccess(
      context,
      onDismiss: () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
    );
  }

  // ─── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocProvider.value(
      value: _cubit,
      child: SlideInContent(
        from: SlideFrom.bottom,
        child: SideFrameMasterServices(
          titleText: S.of(context).service,
          onFirstTap: () => Navigator.pop(context),
          secondTitle: S.of(context).bulkUploadPreview,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      selectedFileName ?? S.of(context).noFileSelected,
                      style: StyleText.fontSize23Weight400.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 23.sp),
                UploadDetailsToolbar(
                  isArabic: isArabic,
                  lightMode: lightMode,
                  totalErrorCount: getTotalErrorCount(),
                  currentErrorIndex: currentErrorIndex,
                  onPrevError: () {
                    if (errorLocations.isEmpty) updateErrorLocations();
                    if (errorLocations.isNotEmpty) {
                      focusErrorField(false);
                      setState(() {});
                    }
                  },
                  onNextError: () {
                    if (errorLocations.isEmpty) updateErrorLocations();
                    if (errorLocations.isNotEmpty) {
                      focusErrorField(true);
                      setState(() {});
                    }
                  },
                  onRemoveSelection: _removeSelectedRows,
                  onAddRow: _addRow,
                ),
                SizedBox(height: 10.sp),
                UploadDetailsPreviewTable(
                  expectedHeaders: expectedHeaders,
                  formData: formData,
                  validationErrors: validationErrors,
                  fieldKeys: fieldKeys,
                  focusNodes: focusNodes,
                  selectedRows: selectedRows,
                  scrollController: _scrollController,
                  horizontalScrollController: _horizontalScrollController,
                  lightMode: lightMode,
                  onToggleRowSelected: _toggleRowSelected,
                  onCellChanged: _onCellChanged,
                ),
                SizedBox(height: 20.sp),
                Row(
                  textDirection: TextDirection
                      .ltr, // X-73: Cancel left, action right in both languages

                  children: [
                    customButton(
                      title: S.of(context).discard,
                      function: () => Navigator.pop(context),
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.onSecondaryAction,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: AppColors.secondaryAction,
                    ),
                    const Spacer(),
                    customButton(
                      title: S.of(context).review,
                      function: () => _handleReviewTap(lightMode),
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: getTotalErrorCount() > 0
                            ? AppColors.text
                            : AppColors.textButton,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: getTotalErrorCount() > 0
                          ? lightMode
                              ? AppColors.grey
                              : AppColors.mediumGrey
                          : AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

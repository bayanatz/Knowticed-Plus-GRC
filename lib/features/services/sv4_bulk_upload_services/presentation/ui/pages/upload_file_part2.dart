/// Module: services / sv4_bulk_upload_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: upload_file_part2.dart
/// Purpose: Declares _UploadFileTabletState.
/// Author: Amr Mesbah
/// Created At: 18/10/2026

part of 'upload_file.dart';

// Split from upload_file.dart to keep files <700 LOC.

class _UploadFileTabletState extends State<UploadFileTablet> {
  // Add drag and drop state variables
  bool _isDragging = false;
  final MainCoreEmployeeController employeeController = Get.find();
  // C4: the module's picker, injected by ServicesDependencies.
  late final MediaPickerService _mediaPicker =
      context.read<MediaPickerService>();

  List<Map<String, TextEditingController>> formData = [];
  List<Map<String, TextEditingController>> filteredData = [];
  List<Map<String, String>> validationErrors = [];
  int currentPage = 0;

  // ✅ UPDATED: Removed 'Service Availability' from expected headers
  final List<String> expectedHeaders = [
    MasterUploadHeaders.serviceNameEn,
    MasterUploadHeaders.serviceNameAr,
    MasterUploadHeaders.serviceDescriptionEn,
    MasterUploadHeaders.serviceDescriptionAr,
    'Duration of Service',
    'Time Unit',
    'Service Provider',
    'Limit Service Availability',
    'Departments',
    'Requires Approvals',
    'Approvers',
  ];

  String? selectedFileName;

  /// C7: the cell rules live in UploadFileRowValidator (shared with the
  /// details page) instead of a second copy in this page.
  late final UploadFileRowValidator _rowValidator = UploadFileRowValidator(
    employeeController: employeeController,
    departmentController: context.read<MainCoreDepartmentCubit>(),
  );

  String? validateCell(
    BuildContext context,
    String key,
    String? value, {
    Map<String, TextEditingController>? rowData,
  }) {
    return _rowValidator.validateCell(
      context,
      key,
      value,
      formData: formData,
      rowData: rowData,
    );
  }

  /// C1/C8: reading the workbook (and its error handling) lives in
  /// [ServiceExcelReader]; the page only validates the cells and reacts.
  Future<void> processFile(List<int> bytes, String fileName) async {
    setState(() {
      selectedFileName = fileName;
    });

    final result = const ServiceExcelReader().read(bytes, expectedHeaders);
    _hideLoadingDialog();

    switch (result) {
      case ServiceExcelInvalidFile():
        _showErrorDialog(S.of(context).svcExcelFileInvalid);
        return;
      case ServiceExcelNoWorksheets():
        _showErrorDialog(S.of(context).svcExcelNoWorksheets);
        return;
      case ServiceExcelNoValidData():
        _showErrorDialog(S.of(context).svcExcelNoValidData);
        return;
      case ServiceExcelTooManyMissingHeaders(:final missingHeaders):
        _showHeaderErrorDialog(missingHeaders);
        return;
      case ServiceExcelRows():
        break;
    }

    final parsedFormData = <Map<String, TextEditingController>>[];
    final parsedValidationErrors = <Map<String, String>>[];

    for (final row in result.rows) {
      if (row == null) {
        // SVC-CREATE-09: keep an unreadable row and mark it invalid.
        parsedFormData.add({
          for (final header in expectedHeaders) header: TextEditingController(),
        });
        parsedValidationErrors.add({
          for (final header in expectedHeaders)
            header: S.of(context).invalidData,
        });
        continue;
      }

      final rowControllers = <String, TextEditingController>{};
      final rowErrors = <String, String>{};
      for (final header in expectedHeaders) {
        final cellValue = row[header] ?? '';
        rowControllers[header] = TextEditingController(text: cellValue);

        final error = validateCell(
          context,
          header,
          cellValue.isEmpty ? null : cellValue,
          rowData: rowControllers,
        );
        if (error != null) rowErrors[header] = error;
        if (row[header] == null) {
          rowErrors[header] = S.of(context).missingColumns;
        }
      }
      parsedFormData.add(rowControllers);
      parsedValidationErrors.add(rowErrors);
    }

    if (parsedFormData.isEmpty) {
      _showErrorDialog(S.of(context).noDataRowsFoundInTheExcelFile);
      return;
    }

    setState(() {
      formData = parsedFormData;
      validationErrors = parsedValidationErrors;
    });

    // Optional columns were absent — tell the user before moving on. Shown
    // after the loading dialog is closed so closing it cannot dismiss this.
    if (result.missingHeaders.isNotEmpty) {
      await _showMissingHeadersWarning(result.missingHeaders);
    }

    if (!mounted) return;

    navigateTo(
      context,
      ToggleUploadFileDetails(
        formData: parsedFormData,
        validationErrors: parsedValidationErrors,
        selectedFileName: fileName,
      ),
    );
  }

  // File picker method
  // S4-003/007/008: no try/catch, no FilePicker/PlatformFile in the page — the
  // MediaPickerService owns picking and IO.
  Future<void> pickAndParseExcel() async {
    final hasPermission = await ServicesStoragePermission.request();
    if (!hasPermission) {
      _showErrorDialog(S.of(context).svcStoragePermissionDenied);
      return;
    }

    final picked = await _mediaPicker.pickExcelFile();
    if (picked == null) return;

    await processFile(picked.bytes, picked.name);
  }

  // Drag and drop handlers
  void _onDragEntered() {
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragExited() {
    setState(() {
      _isDragging = false;
    });
  }

  void _onDragUpdate(DropEventDetails details) {}

  Future<void> _onDragDone(DropDoneDetails details) async {
    setState(() {
      _isDragging = false;
    });

    if (details.files.isEmpty) {
      _showErrorDialog(S.of(context).employeeBulkNoDroppedFiles);
      return;
    }

    final file = details.files.first;
    final fileName = file.name.toLowerCase();

    // Check file extension
    if (!fileName.endsWith('.xlsx') && !fileName.endsWith('.xls')) {
      _showErrorDialog(S.of(context).pleaseDropAnExcelFileXlsxOrXls);
      return;
    }

    final bytes = await file.readAsBytes().then<List<int>?>(
      (b) => b,
      onError: (Object e) {
        svcLog('dropped file could not be read', error: e);
        return null;
      },
    );
    if (!mounted) return;
    if (bytes == null) {
      _showErrorDialog(S.of(context).unableToReadTheSelectedFile);
      return;
    }
    await processFile(bytes, file.name);
  }

  // ───────────────────────── Dialog helpers ─────────────────────────
  //
  // ✅ CHANGED: every dialog on this screen now
  //   • is bilingual (AR/EN) — the strings below came from hardcoded English
  //     literals, which showed English text to Arabic users,
  //   • uses AppColors.card as its background, and
  //   • closes itself after [_dialogAutoDismiss]; there are no OK buttons and
  //     nothing to tap. The SnackBar that reported non-fatal missing columns is
  //     gone too, so all feedback on this page arrives the same way.

  /// How long a message dialog stays on screen before closing itself.
  static const Duration _dialogAutoDismiss = Duration(seconds: 3);

  /// Shows a message dialog that dismisses itself after [_dialogAutoDismiss].
  ///
  /// The close is driven off the dialog's OWN context, and is a no-op once the
  /// route is gone — the user can still tap the barrier, and the page may be
  /// popped, before the timer fires. Popping the enclosing navigator by the
  /// page's context instead would tear down whatever route happened to be on
  /// top by then, or throw "Looking up a deactivated widget's ancestor".
  Future<void> _showAutoDismissDialog({
    required String lottieAsset,
    required String title,
    required String message,
  }) async {
    BuildContext? dialogContext;
    var isClosed = false;

    void closeDialog() {
      if (isClosed) return;
      isClosed = true;
      final ctx = dialogContext;
      if (ctx != null && ctx.mounted) {
        Navigator.of(ctx, rootNavigator: true).maybePop();
      }
    }

    Future.delayed(_dialogAutoDismiss, closeDialog);

    await showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        dialogContext = ctx;

        return AlertDialog(
          backgroundColor: AppColors.card,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                lottieAsset,
                width: 90.sp,
                height: 90.sp,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16.sp),
              Text(
                title,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.sp),
              Text(
                message,
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    // The dialog is already gone (barrier tap, or the timer above) — make sure
    // the pending timer can never pop the route that replaced it.
    isClosed = true;
  }

  /// True only while the progress dialog below is actually on screen.
  /// [_hideLoadingDialog] reads it — see the fix note there.
  bool _isLoadingDialogVisible = false;

  void _hideLoadingDialog() {
    // ✅ FIX: guard on the flag. This used to pop unconditionally whenever the
    // navigator could pop — but _showLoadingDialog has no call site on this
    // screen, so no progress dialog is ever open, and every error path here
    // calls this first. The pop therefore removed THIS PAGE from the stack,
    // bouncing the user off the upload screen on any parse failure and leaving
    // the message dialog floating over whatever was underneath.
    if (!_isLoadingDialogVisible) return;
    _isLoadingDialogVisible = false;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showErrorDialog(String message) {
    _showAutoDismissDialog(
      lottieAsset: ServicesLottie.rejected,
      title: S.of(context).error,
      message: message,
    );
  }

  void _showHeaderErrorDialog(List<String> missingHeaders) {
    _showAutoDismissDialog(
      lottieAsset: ServicesLottie.rejected,
      title: S.of(context).headerMismatch,
      message:
          '${S.of(context).missingRequiredColumns}: ${missingHeaders.join(', ')}',
    );
  }

  /// Non-fatal: the file is still parsed, a few optional columns were absent.
  ///
  /// ✅ CHANGED: was a SnackBar. It reads as a warning, not an error, so it
  /// keeps the warning lottie — but it now uses the same auto-dismissing
  /// dialog as everything else here.
  Future<void> _showMissingHeadersWarning(List<String> missingHeaders) {
    return _showAutoDismissDialog(
      lottieAsset: ServicesLottie.warning,
      title: S.of(context).warning,
      message: '${S.of(context).missingColumns}: ${missingHeaders.join(', ')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return SlideInContent(
      from: SlideFrom.bottom,
      child: SideFrameMasterServices(
        titleText: S.of(context).service,
        onFirstTap: () {
          navigateTo(context, LayoutScreenServices());
        },
        secondTitle: S.of(context).bulkUpload,
        child: Padding(
          padding: EdgeInsets.only(right: 7.sp),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Enhanced Upload box with drag and drop
                  DropTarget(
                    onDragEntered: (_) => _onDragEntered(),
                    onDragExited: (_) => _onDragExited(),
                    onDragUpdated: _onDragUpdate,
                    onDragDone: _onDragDone,
                    child: GestureDetector(
                      onTapDown: hapticDown(
                        pickAndParseExcel,
                        HapticLevel.medium,
                      ),
                      onTap: pickAndParseExcel,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _isDragging
                              ? (lightMode
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.primary.withValues(alpha: 0.2))
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 60.sp),

                            // Animated icon based on drag state
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: _isDragging
                                  ? Icon(
                                      Icons.cloud_upload_outlined,
                                      key: ValueKey('dragging'),
                                      size: 100.sp,
                                      color: AppColors.primary,
                                    )
                                  : CustomSvgImage.natural(
                                      assetPath:
                                          "assets/icons_assets/main_icons_assets/ic_action_cloud_download.svg",
                                      key: ValueKey('normal'),
                                      width: 150.sp,
                                      height: 150.sp,
                                      color: AppColors.secondaryText,
                                      semanticsLabel: 'Upload Icon',
                                    ),
                            ),

                            SizedBox(height: 27.sp),

                            // Dynamic text based on drag state
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              child: Text(
                                _isDragging
                                    ? S.of(context).svcDropExcelHere
                                    : S.of(context).dragDropFilesHere,
                                key: ValueKey(_isDragging ? 'drop' : 'drag'),
                                style: StyleText.fontSize20Weight500.copyWith(
                                  color: _isDragging
                                      ? AppColors.primary
                                      : AppColors.blackButton,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: 25.sp),

                            SizedBox(height: 60.sp),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 26.sp),

              // Discard And Browse buttons
              Row(
                textDirection: TextDirection
                    .ltr, // X-73: Cancel left, action right in both languages

                children: [
                  customButton(
                    title: S.of(context).discard,
                    function: () {
                      setState(() {
                        selectedFileName = null;
                        formData.clear();
                        validationErrors.clear();
                      });
                    },
                    textStyle: StyleText.fontSize16Weight600.copyWith(
                      color: AppColors.onSecondaryAction,
                    ),
                    width: 150.sp,
                    height: 38.sp,
                    radius: 8.r,
                    color: AppColors.secondaryAction,
                  ),
                  Spacer(),
                  customButton(
                    title: S.of(context).browseFiles,
                    function: pickAndParseExcel,
                    textStyle: StyleText.fontSize16Weight600.copyWith(
                      color: AppColors.textButton,
                    ),
                    width: 150.sp,
                    height: 38.sp,
                    radius: 8.r,
                    color: AppColors.primary,
                  ),
                ],
              ),

              // Show selected file name if any
              if (selectedFileName != null) ...[
                SizedBox(height: 16.sp),
                Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: Text(
                          selectedFileName!,
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          HapticController.high();
                          setState(() {
                            selectedFileName = null;
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          color: AppColors.primary,
                          size: 18.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

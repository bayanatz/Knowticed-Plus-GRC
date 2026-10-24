/// Module: knowledge_hub/kh1_create_new_knowledge/presentation/ui/pages
///
///*************************** FILE INFO ****************************///
/// File Name: creating_knowledge_hub.actions.dart
/// Description: `_CreatingKnowledgeHubActions` — split out of `creating_knowledge_hub.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'creating_knowledge_hub.dart';

/// Module: knowledge_hub / presentation / s1_create_new_knowledge/master_page/creating_knowledge_hub.actions.dart

/// Pickers, validation, submit + dialog/build helpers for
/// [CreatingKnowledgeHub]. Depends on _CreatingKnowledgeHubData for fields.
mixin _CreatingKnowledgeHubActions
    on State<CreatingKnowledgeHub>, _CreatingKnowledgeHubData {
  /// Saves the form (see _CreatingKnowledgeHubActionsLogic).
  Future<bool> _submitToFirebase({required bool isEditing});

  /// Fills the form from [knowledge] when editing.
  void _preFillFormData(CreateKnowledgeModel knowledge);

  // Image Picker
  Future<void> _pickImage() async {
    khLog('Picking image from gallery');
    final picked = await _mediaPicker.pickImage(fromCamera: false);

    if (picked?.path != null) {
      setState(() {
        _selectedImage = File(picked!.path!);
        khLog(picked.name, name: 'Image name');
      });
    }
  }

  // Document Picker
  Future<void> _pickDocument() async {
    khLog('Picking document file');
    final picked = await _mediaPicker.pickDocument(
      extensions: const [
        'jpg',
        'jpeg',
        'png',
        'mp4',
        'mov',
        'pdf',
        'doc',
        'docx',
        'txt',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
      ],
    );

    if (picked?.path != null) {
      setState(() {
        _selectedDocument = File(picked!.path!);
        _documentFileName = picked.name;
        _documentExtension = path
            .extension(picked.name)
            .replaceAll('.', '')
            .toUpperCase();
        _documentSize = picked.bytes.length;
        _documentUploadedDate = DateTime.now();
      });
    }
  }

  /// Combines a picked date and time.
  ///
  /// KH-CREATE-09. Start vs end was decided by comparing
  /// [date] with `_startDate`/`_endDate`; when both were the SAME day the end
  /// matched the start branch and became 00:00, so the document was expired
  /// the moment it was published (and if neither matched, `time!` crashed).
  /// The caller now says which one it is: an end date with no time means the
  /// END of that day (23:59), a start date with no time means its start.
  DateTime? _combineDateTime(
    DateTime? date,
    TimeOfDay? time, {
    required bool isEnd,
  }) {
    if (date == null) return null;
    if (time == null) {
      return isEnd
          ? DateTime(date.year, date.month, date.day, 23, 59)
          : DateTime(date.year, date.month, date.day, 0, 0);
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // Validation
  bool _validateForm() {
    if (!_documentNameFormKey.currentState!.validate() ||
        !_documentDescriptionKey.currentState!.validate()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessageDialog(S.of(context).pleaseFillAllRequiredFieldsCorrectly);
      });
      return false;
    }

    if (_dropDownMenuText == 'Choose Type') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessageDialog(S.of(context).please_select_doc_type);
      });
      return false;
    }

    if (_selectedDocument == null &&
        submittedDocument?.currentDocumentFileName == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessageDialog(S.of(context).pleaseAttachDocument);
      });
      return false;
    }

    if (_limitDepartmentAvailability && _selectedDepartments.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessageDialog(
          S.of(context).addDepartmentsOrSwitchOffLimitAvailability,
        );
      });
      return false;
    }

    if (_schedulePublishing && _startDate == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessageDialog(
          S.of(context).addStartDateOrSwitchOffSchedulePublishing,
        );
      });
      return false;
    }

    return true;
  }

  void _showMessageDialog(
    String message, {
    Color? backgroundColor,
    String? title,
    String? lottiePath =
        'assets/lottie_assets/main_lottie_assets/lot_status_attention.json',
    Duration autoCloseDuration = const Duration(seconds: 3),
  }) {
    BuildContext? dialogCtx;

    showAppDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (ctx) {
        dialogCtx = ctx;
        return Dialog(
          backgroundColor: backgroundColor ?? AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: SizedBox(
              width: 411.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lottiePath != null) ...[
                    Lottie.asset(
                      lottiePath,
                      width: 70.sp,
                      height: 70.sp,
                      fit: BoxFit.scaleDown,
                      repeat: false,
                    ),
                    SizedBox(height: 15.sp),
                  ],
                  if (title != null) ...[
                    Text(
                      title,
                      style: StyleText.fontSize20Weight500.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 15.sp),
                  ],
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).timeout(const Duration(milliseconds: 1), onTimeout: () {});

    Future.delayed(autoCloseDuration).then((_) {
      final BuildContext? openDialogCtx = dialogCtx;
      if (openDialogCtx != null && openDialogCtx.mounted) {
        final nav = Navigator.of(openDialogCtx, rootNavigator: true);
        if (nav.canPop()) {
          nav.pop();
        }
      }
    });
  }

  /// The status a submission is saved with: `approved` (skips the queue) or
  /// `pending_approval` (goes to a supervisor).
  ///
  /// "when make request must wait until approved from
  /// supervisor but he approved automatic".
  ///
  /// This method asked ONE question — `editDocumentWithoutApproval` — and used
  /// the answer for both branches of the caller: creating a brand-new document
  /// AND editing an existing one. There was no permission for creation, so it
  /// borrowed the edit one. The effect was that a role given the right to
  /// re-publish its own edits without review ALSO had every new document it
  /// created saved as `approved`; `createKnowledgeHubFromParams` then
  /// normalises `approved` + no scheduling to `published`, so the document went
  /// live, appeared in the supervisor's Approvals list already approved, and
  /// the supervisor was never notified (see the notification block below,
  /// which was gated on the same permission).
  ///
  /// The two cases are now separate rights:
  ///   • creating  -> `Create_Without_Need_Approval`
  ///   • editing   -> `Edit_Document_Without_Approval` (unchanged)
  ///
  /// A role holding neither gets `pending_approval`, which is the default for
  /// everyone until an administrator turns the matching switch on.
  String _getKnowledgeStatus({required bool isEditing}) {
    final bool skipsApproval = isEditing
        ? KnowledgeHubAccess.editAccess.publishesDirectly
        : KnowledgeHubAccess.createsWithoutApproval;

    if (skipsApproval) {
      khLog(
        isEditing
            ? '✅ Role may edit without approval - Status: approved'
            : '✅ Role may create without approval - Status: approved',
      );
      return 'approved';
    }

    khLog(
      isEditing
          ? '⏳ Edit requires approval - Status: pending_approval'
          : '⏳ New document requires approval - Status: pending_approval',
    );
    return 'pending_approval';
  }

  /// The owning department's name for saving, or null when it is not known.
  ///
  /// KH-CREATE-10: this used to return "Unknown Department", which was then
  /// saved as if it were real. Null now blocks the submit instead.
  String? _getOwningDepartmentForSubmission() {
    if (_selectedOwningDepartmentId != null) {
      for (var dept in _availableDepartments) {
        if (dept.departmentID == _selectedOwningDepartmentId) {
          final name = dept.departmentName;
          return (name == null || name.isEmpty) ? null : name;
        }
      }
    }
    final own = _employeeDepartmentEn;
    return (own == null || own.isEmpty) ? null : own;
  }

  /// Parse limited departments from JSON string
  /// KH-CREATE-02: same single decoder as everywhere else, so an edited
  /// document's restriction is read back correctly into the form.
  List<String> _parseLimitedDepartments(List<dynamic> limitedDepartments) {
    return CreateKnowledgeModel.decodeDepartments(
          limitedDepartments.map((e) => e.toString()).toList(),
        ) ??
        const <String>[];
  }

  void _showSuccessAndNavigate() {
    if (!mounted) return;

    khLog('=== Knowledge Hub Data Submitted Successfully ===');

    // Show success dialog
    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(child: _buildSuccessDialog(context)),
    );

    // Wait 3 seconds, then close dialog and navigate
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (!mounted) return;

      // Close success dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Wait a bit then navigate back
      Future.delayed(const Duration(milliseconds: 200)).then((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  Widget _buildSuccessDialog(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Material(
      color: AppColors.transparent,
      child: Container(
        width: isMobile ? double.infinity : 411.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: lightMode ? AppColors.white : AppColors.background,
        ),
        padding: EdgeInsets.all(20.w),
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
              height: 80.h,
              width: 80.w,
            ),
            SizedBox(height: 33.h),
            Text(
              S.of(context).successful,
              style: StyleText.fontSize20Weight500.copyWith(
                color: AppColors.blackButton,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              S.of(context).submit_success_message,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeDocument() {
    setState(() {
      _selectedDocument = null;
      _documentFileName = null;
      _documentExtension = null;
      _documentSize = 0;
      _documentUploadedDate = null;
      if (submittedDocument != null) {
        submittedDocument = null;
      }
    });
  }

  Widget _buildEmployeeDataWrapper({required Widget child}) {
    return BlocListener<CreateKnowledgeCubit, CreateKnowledgeState>(
      listener: (context, state) {
        // Handle department data loading
        if (state is FetchingDepartmentSuccessState) {
          _availableDepartments = state.departmentList;
          _isDepartmentDataLoaded = true;
          _updateDepartmentNames();
        }

        // Handle knowledge data loading for EDIT MODE
        if (state is FetchingKnowledgeByIdSuccessState) {
          khLog('✅ Knowledge data fetched for editing');
          _preFillFormData(state.knowledge);
        }

        // Handle errors
        if (state is FetchingKnowledgeByIdErrorState) {
          khLog('❌ Error fetching knowledge: ${state.error}');
          Fluttertoast.showToast(
            msg: S.of(context).khDocumentNotFound,
            toastLength: Toast.LENGTH_LONG,
          );
        }
      },
      child: GetBuilder<MainCoreEmployeeController>(
        id: 'employee_data',
        builder: (employeeController) {
          if (_employeeDepartmentId != null &&
              _availableDepartments.isNotEmpty) {
            _updateDepartmentNames();
          }
          return child;
        },
      ),
    );
  }

  void _handleSubmitForApproval() {
    if (!_validateForm()) return;

    // EDITING NOW ASKS WHY.
    //
    // Reported as "add dialog of reason of editing then confirmation message"
    // against the Requesting Resubmit dialog. That dialog only ever asked
    // yes/no, so an edit that went to a supervisor arrived with no account of
    // what changed or why.
    //
    // The edit path runs through `CustomDialogManager.showDialogFlow`, which
    // is the app's existing confirm -> reason -> confirmation sequence (the
    // same one the Services approvals use), instead of a second hand-rolled
    // copy of it. Creating is unchanged: there is nothing to explain about a
    // document that did not exist a moment ago.
    if (widget.knowledgeId != null) {
      _handleResubmitWithReason();
      return;
    }

    showAppDialog(
      context: context,
      barrierDismissible: false,
      builder: (confirmationDialogContext) {
        bool localIsUploading = false;
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return Center(
              child: creatingKnowledgeConfirmation(
                context,
                isUploading: localIsUploading,
                submitForApproval: () async {
                  // The dialog closes
                  // FIRST and the upload runs under the page's full-page
                  // loading overlay (`_isUploading`, see build), instead of a
                  // small "Uploading..." spinner inside this dialog.
                  Navigator.of(confirmationDialogContext).pop();

                  final bool saved = await _submitToFirebase(isEditing: false);

                  await Future.delayed(Duration(milliseconds: 100));

                  // KH-CREATE-04: success ONLY when the save really worked.
                  // On failure the error toast is shown and the user stays
                  // on the form with everything they entered.
                  if (mounted && saved) {
                    _showSuccessAndNavigate();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Resubmit: confirm -> reason for editing -> confirmation message.
  ///
  /// The reason is REQUIRED (`commentRequired: true`): an edit queued for a
  /// supervisor with a blank justification tells them nothing, which is the
  /// state this dialog was added to end.
  ///
  /// Ordering note — `showDialogFlow` runs the reason dialog BEFORE
  /// `onConfirm`, so the text is in hand by the time the edit is written. The
  /// reason is attached after the write, because it is pinned to the status
  /// entry that write appends.
  Future<void> _handleResubmitWithReason() async {
    final TextEditingController reasonController = TextEditingController();
    bool submitted = false;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: 'assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json',
      confirmTitle: S.of(context).requestingResubmit,
      confirmSubtitle: S.of(context).areYouSureYouWantToResubmit,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,

      // Reason step
      comment: true,
      commentRequired: true,
      commentController: reasonController,
      customReasonTitle: S.of(context).reasonOfEditing,
      // Without this the shared dialog falls back to its red rejection icon,
      // which is the wrong signal on an edit.
      customReasonIconAsset:
          'assets/icons_assets/main_icons_assets/ic_action_edit.svg',
      commentSubmitText: S.of(context).submit,
      commentDiscardText: S.of(context).discard,
      onCommentSubmit: () async => true,

      // The edit itself. Returning false here stops the flow before the
      // success dialog, so a failed save cannot report success.
      onConfirm: () async {
        final String reason = reasonController.text.trim();

        // KH-CREATE-04: a failed save stops the flow before the success
        // dialog (returning false), instead of reporting success.
        // The flow shows its own loading overlay; the page's stays off.
        _suppressPageOverlay = true;
        final bool saved = await _submitToFirebase(isEditing: true);
        _suppressPageOverlay = false;
        if (!mounted || !saved) return false;

        // KH-CREATE-23: the reason is required history. If it could not be
        // saved, say so and stop before the success dialog.
        final bool reasonSaved = await context
            .read<CreateKnowledgeCubit>()
            .attachEditReason(documentId: widget.knowledgeId!, reason: reason);
        if (!mounted) return false;
        if (!reasonSaved) {
          Fluttertoast.showToast(
            msg: S.of(context).khEditReasonNotSaved,
            toastLength: Toast.LENGTH_LONG,
          );
          return false;
        }

        submitted = true;
        return true;
      },

      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
      // The same wording the create path's success dialog uses, so the two
      // outcomes read alike.
      successTitle: S.of(context).successful,
      successSubtitle: S.of(context).submit_success_message,
      onSuccessComplete: () {
        if (mounted && submitted) {
          Navigator.of(context).pop();
        }
      },
    );

    reasonController.dispose();
  }
}

/// Module: services / sv2_create_single_services / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: sla_screen_page_part2.dart
/// Purpose: Declares _SlaScreenPageTabletState.
/// Author: Amr Mesbah
/// Created At: 18/10/2026

part of 'sla_screen_page.dart';

// Split from sla_screen_page.dart to keep files <700 LOC.

class _SlaScreenPageTabletState extends State<SlaScreenPageTablet> {
  late SlaNotificationCubit cubit;
  Timer? _debounceTimer;

  // The page owns the text fields (rule: no text controllers in models or
  // cubits). The cubit keeps plain values; [_syncControllers] copies them in
  // after a load or an add/remove, and the fields report edits back.
  final TextEditingController _slaOne = TextEditingController();
  final TextEditingController _slaTwo = TextEditingController();
  final List<TextEditingController> _extraSla = [];
  final List<TextEditingController> _extraSlaTwo = [];

  @override
  void initState() {
    super.initState();

    final rawJson = ServicesManagerCubit.get(context).docServiceRawJson;
    if (rawJson != null) {
      SharedPrefsHelper.setBool('sla_switch', rawJson['branchSLA'] ?? false);
      SharedPrefsHelper.setBool(
        'inquiry_switch',
        rawJson['allowInquiries'] ?? false,
      );
      SharedPrefsHelper.setBool(
        'comments_switch',
        rawJson['allowComments'] ?? false,
      );
      SharedPrefsHelper.setString('percentage', rawJson['percentage'] ?? '');
      SharedPrefsHelper.setStringList(
        'notifications',
        (rawJson['notifications'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
    }

    final servicesManager = ServicesManagerCubit.get(context);

    cubit = SlaNotificationCubit(
      submitSlaData: servicesManager.submitSlaData,
      repository: servicesManager.repository,
      // ✅ FIX 26/8/2026 — this used to be ONLY
      //
      //     await SharedPrefsServiceMaster.saveDraft(model);
      //
      // with the comment "Implement save draft logic or call your existing
      // method" still above it. A placeholder that shipped.
      //
      // SharedPrefs is device-local, so a draft saved from this screen never
      // existed in Firestore. The home page reads its drafts from Firestore, so
      // it could not list one, and the draft did not survive a reinstall or
      // follow the user to another device. It all looked fine because the cubit
      // reported success either way.
      //
      // Firebase first — that is the storage the rest of the app reads — with
      // the prefs write kept underneath as a local cache, matching what
      // `CreateServiceCubit.saveDraftFromPage1` does on page 1.
      //
      // `pageSlaNotification` is this screen, so resuming the draft knows how
      // far the user got. Failures are deliberately NOT swallowed here:
      // `_saveDraftData` catches them and reports the save as failed, instead
      // of a success dialog over a draft that is not there.
      saveDraft: (model) async {
        // ⚠️ 26/8/2026 — do NOT seed the draft session with `model.currentId`
        // here. That was tried and it is wrong twice over:
        //
        //   • `model.currentId` is a `services/` document id
        //     (`User<random><MMMdd_yyyy>`), and the draft repository looks its
        //     "existing draft" up in a DIFFERENT collection
        //     (`FirestoreCollections.createServicesRoot`). The lookup misses,
        //     so it mints a fresh `draft_…` id anyway.
        //   • Worse, it overwrites the real draft id that
        //     `saveDraftToFirebase` records after a successful save — so the
        //     NEXT Save For Later would miss again and mint yet another
        //     document. Repeated saves would pile up duplicate drafts.
        //
        // Left to itself, `ServiceDraftManager` reuses the id it stored last
        // time, and a resumed draft is tracked by `getDraftWithPage`. Both
        // give the update-in-place behaviour this was reaching for.
        final draftId = await servicesManager.saveDraftToFirebase(
          model: model,
          currentPage: FirebaseDraftRepository.pageSlaNotification,
        );

        await SharedPrefsServiceMaster.saveDraft(model);
      },
    );

    cubit.initialize(widget.editingModel);
    _setupControllerListeners();
  }

  /// The validation message in the reader's language (C6/C11: the cubit
  /// only reports which check failed).
  String _validationText(
    BuildContext context,
    SlaNotificationValidationError state,
  ) {
    final s = S.of(context);
    switch (state.issue) {
      case SlaValidationIssue.wholeNumbersOnly:
        return s.svcSlaWholeNumbersOnly;
      case SlaValidationIssue.numbersOnly:
        return s.Onlynumbersareallowed;
      case SlaValidationIssue.enableSection:
        return s.svcSlaEnableSection(state.section);
      case SlaValidationIssue.enableSectionWithSla:
        return s.svcSlaEnableSectionWithSla(state.section);
      case SlaValidationIssue.draftNotSaved:
        return s.svcDraftNotSaved;
      case SlaValidationIssue.saveFailed:
        return s.svcServiceSaveFailed;
    }
  }

  /// Function Name: [_confirmThenSaveForLater]
  ///
  /// Purpose: Ask before saving a draft, then save it.
  ///
  /// ADDED 26/8/2026. This screen's Save For Later called
  /// `cubit.handleSaveForLater(...)` straight from the button's `function:`,
  /// with no confirmation at all — press it by accident and the draft was
  /// written and the success dialog was already on screen.
  ///
  /// The confirmation existed, but only on the OTHER save-for-later entry
  /// point: `SaveForLaterButton` (the provider-selection screen) wraps the same
  /// action in a [ConfirmationDialog] with the Edit Document lottie, and a note
  /// there says both paths were meant to "render identically". This one was
  /// never brought across. Same component, same lottie, same wording — so the
  /// two now match, which is what that note intended.
  ///
  /// The "Discard change" case is deliberately NOT wrapped: it saves nothing,
  /// it just navigates back to the details screen, so there is nothing to
  /// confirm. `handleSaveForLater` still makes that decision itself from the
  /// model's state; this only decides whether to ask first.
  ///
  /// Parameters:
  /// - [isEditingSubmittedService]: true when the button is acting as
  ///   "Discard change" rather than "Save for later".
  void _confirmThenSaveForLater({required bool isEditingSubmittedService}) {
    void run() {
      cubit.handleSaveForLater(widget.editingModel, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsToggleScreen(
              editingModel: widget.editingModel!,
              docId: widget.editingModel!.currentId,
            ),
          ),
        );
      });
    }

    if (isEditingSubmittedService) {
      run();
      return;
    }

    showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => ConfirmationDialog(
        lottiePath: ServicesLottie.editDocument,
        title: S.of(dialogContext).saveForLater,
        message: S.of(dialogContext).areYouSureYouWantToSaveAsDraft,
        noText: S.of(dialogContext).no,
        yesText: S.of(dialogContext).yes,
        onConfirm: run,
      ),
    );
  }

  /// Makes the text fields match the cubit's values (same number of extra
  /// fields, same text). Runs outside build: after a state change and after
  /// an add or remove.
  void _syncControllers() {
    void sync(TextEditingController c, String value) {
      if (c.text != value) c.text = value;
    }

    void syncList(List<TextEditingController> list, List<String> values) {
      while (list.length > values.length) {
        list.removeLast().dispose();
      }
      while (list.length < values.length) {
        list.add(TextEditingController());
      }
      for (var i = 0; i < values.length; i++) {
        sync(list[i], values[i]);
      }
    }

    sync(_slaOne, cubit.model.slaOne);
    sync(_slaTwo, cubit.model.slaTwo);
    syncList(_extraSla, cubit.model.extraSla);
    syncList(_extraSlaTwo, cubit.model.extraSlaTwo);
  }

  /// Removes the extra field at [index] (list 2 when [two]) and its value.
  void _removeExtra(int index, {bool two = false}) {
    final list = two ? _extraSlaTwo : _extraSla;
    setState(() {
      if (index < list.length) list.removeAt(index).dispose();
      two
          ? cubit.removeExtraSlaTwoController(index)
          : cubit.removeExtraSlaController(index);
      _syncControllers();
    });
    cubit.updateAndSaveModel();
  }

  void _setupControllerListeners() {
    _slaOne.addListener(() {
      cubit.setSlaOneText(_slaOne.text);
      final v = _slaOne.text.trim();

      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 500), () {
        cubit.updateAndSaveModel();
        SharedPrefsHelper.setString('sla_one', v);
        setState(() {});
      });
    });

    _slaTwo.addListener(() {
      cubit.setSlaTwoText(_slaTwo.text);
      final v = _slaTwo.text.trim();

      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 500), () {
        cubit.updateAndSaveModel();
        SharedPrefsHelper.setString('sla_two', v);
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    final isDraft = widget.editingModel != null &&
        (widget.editingModel!.currentState == "draft" ||
            widget.editingModel!.currentDurationOfServices.isEmpty ||
            widget.editingModel!.currentDurationOfServices == "-");

    final isEditingSubmittedService = widget.editingModel != null &&
        widget.editingModel!.currentState != "submitted";
    final shouldShowSaveForLaterButton = !isEditingSubmittedService || isDraft;

    return SlideInContent(
      from: SlideFrom.bottom,
      child: BlocProvider.value(
        value: cubit,
        child: BlocListener<SlaNotificationCubit, SlaNotificationState>(
          listener: (context, state) {
            if (state is SlaNotificationLoaded) {
              setState(_syncControllers);
            }
            if (state is SlaNotificationValidationError) {
              SlaNotificationWidgets.showValidationError(
                context,
                _validationText(context, state),
              );
            } else if (state is SlaNotificationDraftSaved) {
              // ✅ Only shows for Save For Later
              showDraftSavedSuccessDialog(context);
            } else if (state is SlaNotificationSaved) {
              // ✅ Only shows for Submit
              showCreateServiceDialog(
                context,
                cubit.currentModel,
                cubit.model.notificationSwitches,
              );
            }
          },
          child: BlocBuilder<SlaNotificationCubit, SlaNotificationState>(
            builder: (context, state) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: SafeArea(
                  child: SideFrameMasterServices(
                    titleText: S.of(context).service,
                    onFirstTap: () {
                      navigateTo(context, LayoutScreenServices());
                    },
                    secondTitle: widget.editingModel != null
                        ? isDraft
                            ? "${S.of(context).draft} ${context.svcPick(widget.editingModel!.currentServiceNameEnglish, widget.editingModel!.currentServiceNameArabic)}"
                            : "${S.of(context).Editing} ${context.svcPick(widget.editingModel!.currentServiceNameEnglish, widget.editingModel!.currentServiceNameArabic)}"
                        : S.of(context).creatingNewService,
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                S.of(context).ServiceFulfillment,
                                style: StyleText.fontSize18Weight500.copyWith(
                                  color: AppColors.blackButton,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.sp),
                          SingleChildScrollView(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15.sp,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10.sp),
                                    Text(
                                      S.of(context).SendNotifications,
                                      style: StyleText.fontSize14Weight500
                                          .copyWith(
                                        color: AppColors.blackButton,
                                      ),
                                    ),
                                    SizedBox(height: 28.sp),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        NotificationTile(
                                          audience:
                                              NotificationAudience.requester,
                                          title: S
                                              .of(context)
                                              .notifyServiceRequester,
                                          isChecked: cubit
                                              .model.notifyRequesterChecked,
                                          onCheckboxChanged: (value) {
                                            setState(() {
                                              cubit.updateCheckbox(
                                                'requester',
                                                value,
                                              );
                                            });
                                            cubit.updateAndSaveModel();
                                            SharedPrefsHelper.setBool(
                                              'Notify Service Requester_checked',
                                              value,
                                            );
                                          },
                                          children: [
                                            S
                                                .of(context)
                                                .whenManagerApprovesServiceIfRequired,
                                            S
                                                .of(context)
                                                .whenServiceStattusChanges,
                                            S
                                                .of(context)
                                                .whenTheyReceiveCommentFromServiceProvider,
                                            S.of(context).whenSlaIsBreached,
                                          ],
                                          onSwitchChanged: (map) {
                                            setState(() {
                                              cubit.updateNotificationSwitches(
                                                S
                                                    .of(context)
                                                    .notifyServiceRequester,
                                                map,
                                              );
                                            });
                                          },
                                          onSingleSwitchChanged: ({
                                            required index,
                                            required value,
                                            required title,
                                          }) {
                                            cubit.updateAndSaveModel();
                                          },
                                        ),

                                        SizedBox(height: 15.h),
                                        NotificationTile(
                                          audience:
                                              NotificationAudience.provider,
                                          title: S
                                              .of(context)
                                              .notifyServiceProvider,
                                          isChecked:
                                              cubit.model.notifyProviderChecked,
                                          onCheckboxChanged: (value) {
                                            setState(() {
                                              cubit.updateCheckbox(
                                                'provider',
                                                value,
                                              );
                                            });
                                            cubit.updateAndSaveModel();
                                            SharedPrefsHelper.setBool(
                                              'Notify Service Provider_checked',
                                              value,
                                            );
                                          },
                                          onCheckSlaData: () {
                                            if (cubit.hasProviderSlaData()) {
                                              SlaNotificationWidgets
                                                  .showSlaValidationError(
                                                context,
                                                S
                                                    .of(context)
                                                    .notifyServiceProvider,
                                              );
                                            } else {
                                              setState(() {
                                                cubit.updateCheckbox(
                                                  'provider',
                                                  false,
                                                );
                                              });
                                              cubit.updateAndSaveModel();
                                              SharedPrefsHelper.setBool(
                                                'Notify Service Provider_checked',
                                                false,
                                              );
                                            }
                                          },
                                          children: [
                                            S
                                                .of(context)
                                                .whenServicesRequestedAndApprovedIfRequired,
                                            S
                                                .of(context)
                                                .whenTheyReceiveCommentFromRequester,
                                            S
                                                .of(context)
                                                .whenServiceSlaIsBreached,
                                          ],
                                          onSwitchChanged: (map) {
                                            setState(() {
                                              cubit.updateNotificationSwitches(
                                                S
                                                    .of(context)
                                                    .notifyServiceProvider,
                                                map,
                                              );
                                            });
                                          },
                                          onSingleSwitchChanged: ({
                                            required index,
                                            required value,
                                            required title,
                                          }) {
                                            cubit.updateAndSaveModel();
                                          },
                                        ),

                                        SizedBox(height: 15.sp),
                                        // ✅ One shared row builder for the label,
                                        // the CustomTextField, the "%" and the
                                        // remove icon — all centred on the field.
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: isArabic ? 0 : 30.w,
                                            right: isArabic ? 30.w : 0,
                                          ),
                                          child: SlaNotificationWidgets.slaRow(
                                            context: context,
                                            label: S
                                                .of(context)
                                                .whenServiceSlaIsAboutToBeBreached,
                                            labelStyle: _slaLabelStyle(
                                              lightMode,
                                            ),
                                            controller: _slaOne,
                                            isInvalid:
                                                cubit.model.isInvalidNumber,
                                            onChanged: (val) {
                                              setState(() {
                                                cubit.updateSlaOne(val);
                                              });
                                            },
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ..._extraSla.asMap().entries.map((
                                              entry,
                                            ) {
                                              final index = entry.key;
                                              final controller = entry.value;

                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  left: isArabic ? 0 : 30.w,
                                                  right: isArabic ? 30.w : 0,
                                                ),
                                                child: SlaNotificationWidgets
                                                    .slaRow(
                                                  context: context,
                                                  label: S
                                                      .of(context)
                                                      .whenServiceSlaIsAboutToBeBreached,
                                                  labelStyle: _slaLabelStyle(
                                                    lightMode,
                                                  ),
                                                  controller: controller,
                                                  isInvalid:
                                                      _isInvalidPercentage(
                                                    controller.text,
                                                  ),
                                                  onChanged: (val) {
                                                    setState(() {});
                                                    cubit.setExtraSlaText(
                                                      index,
                                                      val,
                                                    );
                                                  },
                                                  onRemove: () =>
                                                      _removeExtra(index),
                                                ),
                                              );
                                            }),
                                            SlaNotificationWidgets.addSlaButton(
                                              context: context,
                                              onTap: () {
                                                setState(() {
                                                  cubit.addExtraSlaController();
                                                  _syncControllers();
                                                });
                                              },
                                              onSave: () {
                                                cubit.updateAndSaveModel();
                                              },
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 20.sp),
                                      ],
                                    ),
                                    NotificationTile(
                                      audience: NotificationAudience.manager,
                                      title:
                                          S.of(context).notifyProviderManager,
                                      isChecked:
                                          cubit.model.notifyManagerChecked,
                                      onCheckboxChanged: (value) {
                                        setState(() {
                                          cubit.updateCheckbox(
                                            'manager',
                                            value,
                                          );
                                        });
                                        cubit.updateAndSaveModel();
                                        SharedPrefsHelper.setBool(
                                          'Notify Provider Manager_checked',
                                          value,
                                        );
                                      },
                                      onCheckSlaData: () {
                                        if (cubit.hasManagerSlaData()) {
                                          SlaNotificationWidgets
                                              .showSlaValidationError(
                                            context,
                                            S.of(context).notifyProviderManager,
                                          );
                                        } else {
                                          setState(() {
                                            cubit.updateCheckbox(
                                              'manager',
                                              false,
                                            );
                                          });
                                          cubit.updateAndSaveModel();
                                          SharedPrefsHelper.setBool(
                                            'Notify Provider Manager_checked',
                                            false,
                                          );
                                        }
                                      },
                                      children: [
                                        S.of(context).whenProviderBreachedSla,
                                        S
                                            .of(context)
                                            .whenServiceRequestedAndApprovedIfRequired,
                                        S.of(context).whenServiceStatusChanges,
                                      ],
                                      onSwitchChanged: (map) {
                                        setState(() {
                                          cubit.updateNotificationSwitches(
                                            S.of(context).notifyProviderManager,
                                            map,
                                          );
                                        });
                                      },
                                      onSingleSwitchChanged: ({
                                        required index,
                                        required value,
                                        required title,
                                      }) {
                                        cubit.updateAndSaveModel();
                                        _saveNotificationSwitchesToSharedPrefs();
                                      },
                                    ),
                                    SizedBox(height: 15.sp),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: isArabic ? 0 : 30.w,
                                            right: isArabic ? 30.w : 0,
                                          ),
                                          child: SlaNotificationWidgets.slaRow(
                                            context: context,
                                            label: S
                                                .of(context)
                                                .whenServiceSlaIsAboutToBeBreached,
                                            labelStyle: _slaLabelStyle(
                                              lightMode,
                                            ),
                                            controller: _slaTwo,
                                            isInvalid:
                                                cubit.model.isInvalidNumberTwo,
                                            onChanged: (val) {
                                              setState(() {
                                                cubit.updateSlaTwo(val);
                                              });
                                            },
                                          ),
                                        ),
                                        ..._extraSlaTwo.asMap().entries.map((
                                          entry,
                                        ) {
                                          final index = entry.key;
                                          final controller = entry.value;

                                          return Padding(
                                            padding: EdgeInsets.only(
                                              left: isArabic ? 0 : 30.w,
                                              right: isArabic ? 30.w : 0,
                                            ),
                                            child:
                                                SlaNotificationWidgets.slaRow(
                                              context: context,
                                              label: S
                                                  .of(context)
                                                  .whenServiceSlaIsAboutToBeBreached,
                                              labelStyle: _slaLabelStyle(
                                                lightMode,
                                              ),
                                              controller: controller,
                                              isInvalid: _isInvalidPercentage(
                                                controller.text,
                                              ),
                                              onChanged: (val) {
                                                setState(() {});
                                                cubit.setExtraSlaText(
                                                  index,
                                                  val,
                                                  two: true,
                                                );
                                              },
                                              onRemove: () => _removeExtra(
                                                index,
                                                two: true,
                                              ),
                                            ),
                                          );
                                        }),
                                        SlaNotificationWidgets.addSlaButtonAlt(
                                          context: context,
                                          onTap: () {
                                            setState(() {
                                              cubit.addExtraSlaTwoController();
                                              _syncControllers();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15.sp),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.sp),
                          SlaActionButtons(
                            isNewService: widget.editingModel == null,
                            showSaveForLater: shouldShowSaveForLaterButton,
                            isEditingSubmittedService:
                                isEditingSubmittedService,
                            onBack: () => Navigator.pop(context),
                            onSubmit: () => cubit.handleSubmit(
                              S.of(context).notifyServiceRequester,
                              S.of(context).notifyServiceProvider,
                              S.of(context).notifyProviderManager,
                            ),
                            onSaveForLater: () => _confirmThenSaveForLater(
                              isEditingSubmittedService:
                                  isEditingSubmittedService,
                            ),
                          ),
                          SizedBox(height: 20.sp),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Shared style for the "When service SLA is about to be breached" label so
  /// the first row and every added row render identically.
  TextStyle _slaLabelStyle(bool lightMode) => StyleText.fontSize12Weight500
      .copyWith(color: AppColors.blackButton, letterSpacing: .34);

  /// A percentage is invalid when it is non-empty and not a whole number.
  bool _isInvalidPercentage(String value) {
    final text = value.trim();
    if (text.isEmpty) return false;
    return text.contains('.') ||
        text.contains(',') ||
        !RegExp(r'^\d+$').hasMatch(text);
  }

  Future<void> _saveNotificationSwitchesToSharedPrefs() async {
    final reqMap = cubit
            .model.notificationSwitches[S.of(context).notifyServiceRequester] ??
        {};
    final mgrMap =
        cubit.model.notificationSwitches[S.of(context).notifyProviderManager] ??
            {};
    cubit.model.notifyRequesterSwitch0 = reqMap[0] ?? false;
    cubit.model.notifyManagerSwitch1 = mgrMap[0] ?? false;

    await SharedPrefsHelper.setBool(
      'notifyRequesterSwitch0',
      cubit.model.notifyRequesterSwitch0,
    );
    await SharedPrefsHelper.setBool(
      'notifyManagerSwitch1',
      cubit.model.notifyManagerSwitch1,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _slaOne.dispose();
    _slaTwo.dispose();
    for (final c in [..._extraSla, ..._extraSlaTwo]) {
      c.dispose();
    }
    cubit.close();
    super.dispose();
  }
}

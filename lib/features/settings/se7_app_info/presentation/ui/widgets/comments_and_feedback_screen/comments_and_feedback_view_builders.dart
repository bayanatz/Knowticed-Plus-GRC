/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: comments_and_feedback_view_builders.dart
/// Description: UI builder methods of `_CommentsAndFeedbackViewState` — split out of `comments_and_feedback_screen.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/comments_and_feedback_screen.dart';

// Split from comments_and_feedback_screen.dart to keep every file under 700 lines.

extension _CommentsAndFeedbackViewStateBuilders
    on _CommentsAndFeedbackViewState {
  Widget _buildRequestDetailsBody(
    BuildContext context, {
    required CommentsFeedbackCubit cubit,
    required CommentsFeedbackState state,
    required bool isMobile,
  }) {
    if (state is CommentsFeedbackLoading || state is CommentsFeedbackInitial) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: const Center(child: CircleProgressMaster()),
      );
    }

    // An error state is transient — the cubit re-emits the previous loaded
    // state straight after it — so anything that is not Loaded by now is a
    // frame in between and renders as nothing rather than as an error page.
    if (state is! CommentsFeedbackLoaded) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StatusChipFilter(
          selectedKey: _CommentsAndFeedbackViewState._chipKey(
            state.selectedStatus,
          ),
          onSelected: (String key) => cubit.updateStatus(
            _CommentsAndFeedbackViewState._filterFromKey(key),
          ),
          items: <StatusChipItem>[
            StatusChipItem(
              key: _kChipAll,
              label: S.of(context).all,
              count: state.totalCount,
            ),
            for (final FeedbackStatus status in FeedbackStatus.values)
              StatusChipItem(
                key: status.wireValue,
                label: FeedbackDisplay.statusLabel(context, status),
                count: state.counts[status] ?? 0,
                labelColor: FeedbackDisplay.statusColor(status),
              ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: <Widget>[
            // AppSearchTextField returns an Expanded of its own, so it must sit
            // directly in this Row and must not be wrapped again.
            AppSearchTextField(
              controller: cubit.searchController,
              onChanged: (_) {},
            ),
            SizedBox(width: ButtonSizing.toolbarGap(context)),
            // CustomSortButton, the app's shared sort control, in place of
            // the local FeedbackSortMenu popup — same options, same two
            // labels, but the toolbar button now matches Requests and every
            // other sort in the app (it paints itself primary while a sort is
            // active and highlights the live row in its menu).
            CustomSortButton<FeedbackSortOption>(
              value: state.sortOption,
              items: FeedbackSortOption.values,
              labelBuilder: (FeedbackSortOption option) =>
                  option == FeedbackSortOption.ascending
                      ? S.of(context).ascending
                      : S.of(context).descending,
              title: S.of(context).sort,
              // Glyph only on phone, glyph + label above — what `compact` did.
              showTitle: !isMobile,
              onChanged: (FeedbackSortOption? option) {
                // Tapping the active option again deselects the sort.
                cubit.updateSort(option);
              },
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (state.displayedItems.isEmpty)
          _buildEmptyState(context)
        else
          // Owner 21/10/2026: 3 columns on the large view (2 iPad portrait, 1 phone); rows size to the card's content instead of a fixed 104.h, which overflowed by 3.9px.
          Builder(
            builder: (BuildContext context) {
              final List<FeedbackRequest> items = state.displayedItems;
              // Moataz 23/10/2026: one card per row on every device.
              const int columns = 1;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (int start = 0;
                      start < items.length;
                      start += columns) ...<Widget>[
                    if (start > 0) SizedBox(height: 12.h),
                    // IntrinsicHeight + stretch: every card in a row is as
                    // tall as the tallest one, and never shorter than its
                    // own content.
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          for (int i = start;
                              i < start + columns;
                              i++) ...<Widget>[
                            if (i > start) SizedBox(width: 12.w),
                            Expanded(
                              child: i < items.length
                                  ? FeedbackRequestCard(
                                      request: items[i],
                                      // 21/9/2026 — cards open the Request
                                      // Details page (in the pane on tablet /
                                      // desktop, pushed on a phone).
                                      onTap: () =>
                                          _openRequest(context, items[i]),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
      ],
    );
  }

  /// One of the three boxes: the tick with its Expand / Hide link, and — while
  /// expanded — the text area, its attachments, its priority and the collapsed
  /// "More Options" panel.
  ///
  /// Note the two different flags. [isSelected] decides whether the box is
  /// SENT; [isExpanded] decides only whether it is DRAWN. A box that is ticked
  /// but folded away still submits, which is the point of the Hide link.
  Widget _buildKindBox(
    BuildContext context, {
    required CommentsFeedbackCubit cubit,
    required FeedbackKind kind,
    required bool isMobile,
  }) {
    final bool isSelected = _selectedKinds.contains(kind);
    final bool isExpanded = isSelected && _expandedKinds.contains(kind);
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final List<FeedbackAttachment> files =
        _attachments[kind] ?? const <FeedbackAttachment>[];
    final bool isUploading = _uploadingKind == kind;
    final bool isBlocked = _uploadingKind != null && _uploadingKind != kind;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildCheckboxRow(
          context,
          title: FeedbackDisplay.kindLabel(context, kind),
          isSelected: isSelected,
          // The Expand / Hide link only appears once the box is ticked —
          // there is nothing to expand before that, and the design does not
          // draw it on an unticked row.
          isExpanded: isExpanded,
          onToggleExpanded:
              isSelected ? () => _setExpanded(kind, !isExpanded) : null,
          onChanged: (bool value) {
            rebuild(() {
              if (value) {
                _selectedKinds.add(kind);
                // Ticking opens the box: the user ticked it in order to fill
                // it in, and making them press "Expand" as a second step to
                // reach a field they just asked for is a step for nothing.
                _expandedKinds.add(kind);
                _details.putIfAbsent(kind, () => const FeedbackDetails());
              } else {
                // Unticking discards the box entirely — text, files,
                // priority and the whole More Options panel. Leaving them
                // behind would let an invisible attachment or a stale module
                // ride along on the next submit.
                _selectedKinds.remove(kind);
                _expandedKinds.remove(kind);
                _moreOptionsKinds.remove(kind);
                _controllers[kind]?.clear();
                _stepsControllers[kind]?.clear();
                _attachments.remove(kind);
                _priorities.remove(kind);
                _details.remove(kind);
              }
            });
          },
        ),
        if (isExpanded) ...<Widget>[
          // CHANGED 8/9/2026: was 8.h. The row above already carries 8.h of
          // its own bottom padding, so the tick and the box it belongs to were
          // 16.h apart and read as two unrelated controls.
          SizedBox(height: 2.h),
          CustomTextField(
            hint: S.of(context).textHere,
            controller: _controllers[kind],
            maxLines: 3,
            // Figma draws a "0/500" counter under the box.
            maxLength: 500,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
          SizedBox(height: 12.h),
          _buildAttachmentsAndPriority(
            context,
            cubit: cubit,
            kind: kind,
            files: files,
            isMobile: isMobile,
          ),
          SizedBox(height: 12.h),
          FeedbackMoreOptionsPanel(
            // Non-null because ticking the box seeds the map above, but
            // defaulted anyway: a box restored from some future draft state
            // must not crash the form on a missing entry.
            details: _details[kind] ?? const FeedbackDetails(),
            isExpanded: _moreOptionsKinds.contains(kind),
            enabled: !isUploading && !isBlocked,
            isMobile: isMobile,
            stepsController: _stepsControllers[kind]!,
            onToggle: () {
              rebuild(() {
                if (!_moreOptionsKinds.remove(kind)) {
                  _moreOptionsKinds.add(kind);
                }
              });
            },
            onChanged: (FeedbackDetails updated) {
              rebuild(() => _details[kind] = updated);
            },
          ),
        ],
        // CHANGED 28/9/2026 (Settings bug report p.2): the LAST box no longer
        // adds this gap. It sat on top of the card's own 16.sp padding, so the
        // space under "Request New Feature" was far larger than the space
        // beside it; now the card's padding is equal on every side.
        if (kind != FeedbackKind.values.last) SizedBox(height: 16.h),
      ],
    );
  }

  /// Figma draws two variants of this block, and both are here:
  ///
  ///  • nothing uploaded yet → the "Attach Document" button and the Priority
  ///    field share one row, one column each;
  ///  • one or more files → the attachments take the full two-column width and
  ///    Priority drops to its own row underneath.
  ///
  /// On a phone everything is one column, so the row never applies.
  Widget _buildAttachmentsAndPriority(
    BuildContext context, {
    required CommentsFeedbackCubit cubit,
    required FeedbackKind kind,
    required List<FeedbackAttachment> files,
    required bool isMobile,
  }) {
    final bool isUploading = _uploadingKind == kind;
    final bool isBlocked = _uploadingKind != null && _uploadingKind != kind;
    // D-107 / D-205 (21/10/2026): on iPad portrait the two do not fit side by
    // side ("Attach Docum…" was cut), so they stack full width like the phone.
    final bool stack =
        isMobile || MediaQuery.of(context).orientation == Orientation.portrait;

    final Widget grid = FeedbackAttachmentsGrid(
      attachments: files,
      isUploading: isUploading,
      isBlocked: isBlocked,
      columns: stack ? 1 : 2,
      onAdd: () => _pickAndUpload(cubit, kind),
      onRemove: (int index) => _removeAttachment(kind, index),
    );

    final Widget priority = FeedbackPriorityDropdown(
      value: _priorities[kind],
      // Changing priority mid-upload is harmless, but keeping the whole block
      // inert while a file is in flight matches the attach button beside it.
      enabled: !isUploading && !isBlocked,
      // TAP-TO-CLEAR, added 8/9/2026. Choosing the priority that is already
      // selected clears it, matching the seven dropdowns in the More Options
      // panel below.
      //
      // FeedbackPriorityDropdown's own note explains why the comparison lives
      // here: CustomDropdown.onChanged is `ValueChanged<T>` and can only ever
      // report a CHOSEN item, so it cannot express "none" on its own.
      // Removing the key rather than storing null keeps `_priorities` meaning
      // exactly "boxes that have a priority", which is what _detailsForSubmit
      // reads. Unticking the box still drops it too, via _buildKindBox.
      onChanged: (FeedbackPriority value) {
        rebuild(() {
          if (_priorities[kind] == value) {
            _priorities.remove(kind);
          } else {
            _priorities[kind] = value;
          }
        });
      },
    );

    if (!stack && files.isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: FeedbackAttachmentsGrid(
              attachments: files,
              isUploading: isUploading,
              isBlocked: isBlocked,
              // One column: this grid is already sharing the row with Priority.
              columns: 1,
              onAdd: () => _pickAndUpload(cubit, kind),
              onRemove: (int index) => _removeAttachment(kind, index),
            ),
          ),
          // Owner 21/10/2026 (R-1): equal halves, 16 between.
          SizedBox(width: 16.sp),
          Expanded(child: priority),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        grid,
        SizedBox(height: 12.h),
        // Half width on tablet so it lines up with the grid's first column
        // instead of stretching across both.
        if (stack)
          priority
        else
          FractionallySizedBox(
            widthFactor: 0.5,
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              // Owner 21/10/2026: half of the grid's 16 gap.
              padding: EdgeInsetsDirectional.only(end: 8.sp),
              child: priority,
            ),
          ),
      ],
    );
  }

  /// The tick, its label, and — once ticked — the Expand / Hide link.
  ///
  /// The link is a SEPARATE tap target inside the row rather than part of it:
  /// the row's own tap toggles the tick, and pressing "Hide" must not also
  /// untick the box it is hiding. That is why the label is wrapped in its own
  /// [GestureDetector] with the row's [InkWell] stopping short of it.
  Widget _buildCheckboxRow(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required bool isExpanded,
    required ValueChanged<bool> onChanged,
    VoidCallback? onToggleExpanded,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTapDown: (_) => HapticController.low(),
              onTap: () => onChanged(!isSelected),
              child: Row(
                children: <Widget>[
                  CustomCheckBox(
                    borderColor: Colors.grey,
                    isSelected: isSelected,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      title,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onToggleExpanded != null)
            GestureDetector(
              onTapDown: hapticDown(onToggleExpanded, HapticLevel.low),
              onTap: onToggleExpanded,
              // Opaque so the padding around the short word is tappable too —
              // "Hide" is four characters and would otherwise be a 24pt
              // target.
              behavior: HitTestBehavior.opaque,
              // CHANGED 8/9/2026 — blue, with a rule under it, so the link
              // reads as a link. It was grey body text, indistinguishable
              // from the label on the other side of the row.
              //
              // The rule is a Container, not TextDecoration.underline: the
              // decoration sits hard against the glyphs with no way to offset
              // it, and the ask was a 3 gap. IntrinsicWidth is what keeps the
              // rule the width of the WORD — inside a Row the Column would
              // otherwise be handed unbounded width and `stretch` would have
              // nothing to measure against.
              child: Padding(
                // D-146 (Moataz 20/10/2026): "Hide" ends on the section's own
                // right inset like everything else — no extra end padding.
                padding: EdgeInsetsDirectional.only(
                    start: 6.w, top: 4.h, bottom: 4.h),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        isExpanded ? S.of(context).hide : S.of(context).expand,
                        style: StyleText.fontSize13Weight500.copyWith(
                          color: AppColors.blue,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      // Raw 1, not 1.h: a hairline rule that scales below one
                      // logical pixel can drop out entirely on some densities.
                      Container(height: 1, color: AppColors.blue),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

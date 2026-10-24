/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: preview_helper_sections.dart
/// Description: UI sections of `_PreviewAllCustomPageState` — split out of `preview.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../preview.dart';

// Split from preview_all_custom_page_builders.dart to keep every file under 700 lines.

extension _PreviewAllCustomPageHelperSections on _PreviewAllCustomPageState {
  List<Widget> _helperAndMiscSections(BuildContext context) {
    return [
      _section(
        '35 · DatePicker (single) + AppSearchTextField',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customButton(
              title: 'Open calendar picker',
              width: 220,
              height: 40,
              function: () => DatePicker().showDatePicker(
                context,
                [],
                DateTime.now(),
                CalendarDatePicker2Type.single,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                AppSearchTextField(
                  controller: _searchController,
                  onChanged: (_) {},
                ),
              ],
            ),
          ],
        ),
      ),
      _section(
        '36 · UniversalCommentSection',
        // The section sizes itself (header + collapsedHeight); boxing it in
        // a 260-high SizedBox overflowed by the header row (31 px on phone).
        UniversalCommentSection(
          collectionPath: 'preview_comments',
          filterFields: const {},
          currentUserId: 'preview_user',
          collapsedHeight: 260,
        ),
      ),
      _section(
        '37 · navigateTo / navigateAndFinish',
        customButton(
          title: 'navigateTo demo page',
          width: 220,
          height: 40,
          function: () => navigateTo(
            context,
            Scaffold(
              appBar: AppBar(title: const Text('Pushed via navigateTo')),
              body: const Center(child: Text('Hello from navigateTo()')),
            ),
          ),
        ),
      ),
      _section(
        '38 · ResponsiveHelper',
        SizedBox(
          height: 60.h,
          child: ResponsiveHelper(
            mobileWidget: Container(
              color: AppColors.primary.withValues(alpha: 0.15),
              alignment: Alignment.center,
              child: const Text('Mobile layout'),
            ),
            tabletWidget: Container(
              color: AppColors.green.withValues(alpha: 0.15),
              alignment: Alignment.center,
              child: const Text('Tablet layout'),
            ),
          ),
        ),
      ),
      _section(
        '42 · CustomApprovalCycle',
        const CustomApprovalCycle(
          steps: [
            ApprovalStep(name: 'Ahmed Mohammed', title: 'Marketing Manager'),
            ApprovalStep(name: 'Sara Ali', title: 'HR Specialist'),
            ApprovalStep(name: 'Omar Khaled', title: 'Backend Engineer'),
            ApprovalStep(name: 'Mona Hassan', title: 'HR Manager'),
            ApprovalStep(name: 'Youssef Ashraf', title: 'CTO'),
          ],
        ),
      ),
      _section(
        '43 · ModuleInfoCard',
        ModuleInfoCard(
          title: 'Data Management',
          infoRows: const [
            CardInfo(label: 'Owner :', value: 'Amro Handousa'),
            CardInfo(label: 'Creation Date:', value: '28 May 2020'),
          ],
          complianceScore: '-',
          footerLabel: 'Last Update:',
          footerValue: '28 May 2020',
          onMenuTap: () {},
        ),
      ),
      _section(
        '43 · CustomSegmentedToggle (AR | EN) + CustomPersonChip + CustomRemovableChip — from Time Tracker',
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CustomSegmentedToggle(
              tabs: const ['AR', 'EN'],
              selectedIndex: 1,
              onChanged: (_) {},
            ),
            CustomPersonChip(name: 'Sara Ali', photo: '', onRemove: () {}),
            CustomRemovableChip(label: 'Cairo Office', onRemove: () {}),
          ],
        ),
      ),
      _section(
        'circle_progress · CircleProgressMaster',
        const SizedBox(height: 60, child: CircleProgressMaster()),
      ),
      // _section(
      //   'loading · showLoadingIndicator / hideLoadingIndicator',
      //   customButton(
      //     title: 'Show loading overlay (2s)',
      //     width: 240,
      //     height: 40,
      //     function: () async {
      //       showLoadingIndicator();
      //       await Future.delayed(const Duration(seconds: 2));
      //       hideLoadingIndicator();
      //     },
      //   ),
      // ),
      _section(
        '39 · customViewModeButton (List | Grid — one button, two icons)',
        Row(
          children: [
            customViewModeButton(
                mode: ViewMode.list, function: () {}, isSelected: false),
            SizedBox(width: 8.w),
            customViewModeButton(
                mode: ViewMode.grid, function: () {}, isSelected: true),
          ],
        ),
      ),
      _section(
        '41 · ButtonSizing (helper)',
        Text(
          'isMobile: ${ButtonSizing.isMobile(context)} · '
          'width("Save"): ${ButtonSizing.width(context, title: 'Save')}',
        ),
      ),
      _section(
        '44 · CustomValidatedTextFieldMaster',
        CustomValidatedTextFieldMaster(
          label: 'Email',
          hint: 'name@company.com',
          controller: _validatedCtrl,
        ),
      ),
      _section(
        '45 · AppDropdown',
        AppDropdown(
          textButton: 'Choose',
          items: const [
            DropdownMenuItem(value: 'a', child: Text('Option A')),
            DropdownMenuItem(value: 'b', child: Text('Option B')),
          ],
          onChanged: (v) {},
        ),
      ),
      _section(
        '46 · CustomImagePicker',
        CustomImagePicker(onImagePicked: (file) {}),
      ),
      _section(
        '47 · CustomSortButton',
        CustomSortButton<String>(
          value: _sortValue,
          items: const ['name', 'date', 'status'],
          labelBuilder: (v) => v,
          onChanged: (v) => rebuild(() => _sortValue = v),
        ),
      ),
      _section(
        '48 · CurvedArrowPainter',
        SizedBox(
          height: 60,
          child: CustomPaint(
            painter: CurvedArrowPainter(
              color: AppColors.primary,
              isArabic: false,
            ),
            child: const SizedBox(width: double.infinity),
          ),
        ),
      ),
      _section(
        '49 · CustomMultiSelectField',
        CustomMultiSelectField(
          textButton: 'Select many',
          items: const ['Alpha', 'Beta', 'Gamma'],
          selectedItems: _multiSelMaster,
          onChanged: (_) {},
          onSelectionChanged: (v) => rebuild(() => _multiSelMaster = v),
        ),
      ),
      _section(
        '50 · SideFrameMasterServices',
        SizedBox(
          height: 180,
          child: SideFrameMasterServices(
            titleText: 'Services',
            secondTitle: 'Details',
            child: const Center(child: Text('Framed content')),
          ),
        ),
      ),
      _section(
        '51 · CustomPopupMenuButton',
        CustomPopupMenuButton(
          title: 'Actions',
          iconPath:
              'assets/icons_assets/main_icons_assets/ic_nav_more_vertical.svg',
          options: [
            PopupOption(value: 'edit', label: 'Edit'),
            PopupOption(value: 'delete', label: 'Delete'),
          ],
          onSelected: (v) {},
          backgroundColor: AppColors.card,
          iconColor: AppColors.text,
        ),
      ),
      _section(
        '54 · CrossAxisCountHelperResponsive (helper)',
        Text(
          'columns: '
          '${CrossAxisCountHelperResponsive.getCrossAxisCountForDefaultTabletResponsive(context)}',
        ),
      ),
      _section(
        '55 · buildResponsiveFields',
        buildResponsiveFields(
          context: context,
          left: const Text('Left field'),
          right: const Text('Right field'),
        ),
      ),
      _section(
        '57 · CustomDialogManager',
        customButton(
          title: 'Show message dialog',
          function: () => CustomDialogManager.showMessage(
            context: context,
            lottiePath:
                'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
            title: 'Saved',
            subtitle: 'Your changes were stored.',
          ),
        ),
      ),
      _section(
        '58 · DefaultSwitchButton',
        DefaultSwitchButton(
          value: _switchOn,
          onChanged: (v) => rebuild(() => _switchOn = v),
        ),
      ),
      _section('59 · IntlPhoneField', const IntlPhoneField()),
      _section(
        '60 · showCountryPickerDialog',
        customButton(
          title: 'Pick a country',
          function: () => showCountryPickerDialog(context),
        ),
      ),
      _section(
        '61 · CustomColorPickerField',
        CustomColorPickerField(
          label: 'Brand colour',
          color: _pickedColor,
          onColorSelected: (c) => rebuild(() => _pickedColor = c),
        ),
      ),
      _section(
        '62 · FormDateTimeHelper (helper)',
        Text(
          'formatDate: ${FormDateTimeHelper.formatDate(DateTime.now())}\n'
          'formatTime: ${FormDateTimeHelper.formatTime(DateTime.now())}\n'
          'getMonthName(3): ${FormDateTimeHelper.getMonthName(3)}',
        ),
      ),
      _section(
        '64 · ResponseDialog',
        customButton(
          title: 'Show response dialog',
          function: () => showAppDialog(
            context: context,
            builder: (_) => const ResponseDialog(
              title: 'Done',
              subtitle: 'The request was submitted.',
              lottieAsset:
                  'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
            ),
          ),
        ),
      ),
      _section(
        '65 · CustomDropdownButton2',
        CustomDropdownButton2(
          hint: 'Pick one',
          value: _dd2Value,
          dropdownItems: const ['First', 'Second', 'Third'],
          onChanged: (v) => rebuild(() => _dd2Value = v),
        ),
      ),
      _section(
        '67 · ColumnRequestData',
        ColumnRequestData(
          title: 'Reason',
          isTextField: true,
          hint: 'Why do you need this?',
          isOptional: false,
          isExpanded: false,
        ),
      ),
      _section(
        '68 · ConfirmDialog',
        customButton(
          title: 'Show confirm dialog',
          function: () => ConfirmDialog().show(
            context,
            title: 'Delete item?',
            subtitle: 'This cannot be undone.',
            icon:
                'assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg',
            onConfirm: () {},
            onCancel: () {},
          ),
        ),
      ),
      _section(
        '69 · CrossAxisCountHelper (helper)',
        Text(
          'columns: '
          '${CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context)}',
        ),
      ),
      _section(
        '70 · CustomAppBar',
        const Text(
          'CustomAppBar — live Firebase-backed app bar; '
          'not instantiated here to keep the gallery offline.',
        ),
      ),
      _section(
        '71 · CustomAppBarMobile',
        SizedBox(
          height: 70,
          child: CustomAppBarMobile(title: 'Profile', showIcon: true),
        ),
      ),
      _section(
        '72 · CustomCalendarPicker',
        CustomCalendarPicker(
          calendarType: local_cal.CalendarDatePicker2Type.single,
          selectedDate: _calendarDates,
          selectedDateState: (v) => rebuild(() => _calendarDates = v),
        ),
      ),
      _section(
        '74 · CustomStackedAvatars',
        const CustomStackedAvatars(
          avatars: ['Amr Mesbah', 'Sara Ali', 'Omar Hany'],
        ),
      ),
      _section(
        '75 · CustomTitleValueWidget',
        const CustomTitleValueWidget(title: 'Department', value: 'Engineering'),
      ),
      _section(
        '76 · date_time_in_arabic (helpers)',
        Text(
          'convertToArabicDate: ${convertToArabicDate('Aug 12, 2026')}\n'
          'formatTimeToArabic: ${formatTimeToArabic('09:30 AM')}\n'
          'convertNumberToEnglish: ${convertNumberToEnglish('١٢٣')}',
        ),
      ),
      _section(
        '77 · DefaultDialog',
        const DefaultDialog(
          title: 'Heads up',
          subTitle: 'A default dialog body.',
        ),
      ),
      _section(
        '78 · ExpandedContent',
        ExpandedContent(
          title: 'More details',
          content: const Text('Hidden content revealed on expand.'),
        ),
      ),
      _section(
        '79 · FilterBarItem',
        FilterBarItem(
          isSelected: _filterBarSelected,
          title: 'Pending',
          numberOfItems: 12,
          onTap: () => rebuild(() => _filterBarSelected = !_filterBarSelected),
        ),
      ),
      _section(
        '80 · FiltersAppBar',
        const FiltersAppBar(imageUrl: '', title: 'Filters'),
      ),
      _section(
        '81 · HoverExample',
        const HoverExample(subtitle: 'Hover to reveal a tooltip'),
      ),
      _section(
        '82 · ImageGridCard',
        const SizedBox(
          height: 120,
          child: ImageGridCard(
            image:
                'assets/icons_assets/main_icons_assets/img_image_placeholder_large.png',
          ),
        ),
      ),
      _section(
        '85 · module page stubs',
        Text(
          'Stub pages: ${stubs.GrcResponsivePage}, '
          '${stubs.FormResponsivePage}, ${stubs.TasksResponsivePage}, '
          '${stubs.TrackerPageResponsivePageRefactor}, ${stubs.Settings}',
        ),
      ),
      _section(
        '86 · RemovedModulePage',
        const SizedBox(
          height: 200,
          child: RemovedModulePage(moduleName: 'Tasks'),
        ),
      ),
      _section(
        '87 · ResponsiveCardContent',
        SizedBox(
          height: 80,
          child: ResponsiveCardContent(
            child: Text(
              'Scales with text size · '
              'forListCard: ${ResponsiveCardHeight.forListCard(context).toStringAsFixed(1)}',
            ),
          ),
        ),
      ),
      _section(
        '88 · StackedAvatars',
        const StackedAvatars(images: ['Amr Mesbah', 'Sara Ali', 'Omar Hany']),
      ),
      SizedBox(height: 24.h),
    ];
  }
}

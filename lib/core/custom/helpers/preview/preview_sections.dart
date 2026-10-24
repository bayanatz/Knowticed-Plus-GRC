/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: preview_sections.dart
/// Description: UI sections of `_PreviewAllCustomPageState` — split out of `preview.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../preview.dart';

// Split from preview_all_custom_page_builders.dart to keep every file under 700 lines.

extension _PreviewAllCustomPageSections on _PreviewAllCustomPageState {
  List<Widget> _inputAndDialogSections(BuildContext context) {
    return [
      _section(
        '1 · CustomDropdown',
        CustomDropdown<String>(
          label: 'Department',
          hint: 'Select a department',
          value: _dropdownValue,
          items: const [
            DropdownItem(value: 'eng', label: 'Engineering'),
            DropdownItem(value: 'sales', label: 'Sales'),
            DropdownItem(value: 'hr', label: 'Human Resources'),
          ],
          onChanged: (v) => rebuild(() => _dropdownValue = v),
        ),
      ),
      _section(
        '2 · CustomTextField',
        Column(
          children: [
            CustomTextField(
              label: 'Name',
              hint: 'Enter your name',
              controller: _textFieldController,
            ),
            SizedBox(height: 12.h),
            const CustomTextField(
              label: 'Read-only',
              hint: 'Cannot edit this',
              readOnly: true,
              initialValue: 'Fixed value',
            ),
          ],
        ),
      ),
      _section(
        '3 · CustomDateField',
        CustomDateField(
          label: 'Date of birth',
          hint: 'Select a date',
          value: _dobValue,
          onChanged: (v) => rebuild(() => _dobValue = v),
        ),
      ),
      _section(
        '4 · CustomRangeCalendar (one-slot toolbar filter)',
        CustomRangeCalendar(
          label: 'Date range',
          startDate: _rangeStart,
          endDate: _rangeEnd,
          onChanged: (start, end) => rebuild(() {
            _rangeStart = start;
            _rangeEnd = end;
          }),
        ),
      ),
      _section(
        '4b · CustomDateRangeFields (From / To — from Time Tracker; forms & filter dialogs)',
        StatefulBuilder(
          builder: (context, setLocal) => CustomDateRangeFields(
            from: null,
            to: null,
            onFrom: (_) {},
            onTo: (_) {},
          ),
        ),
      ),
      _section(
        '5 · customButton',
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          children: [
            customButton(
              title: 'Save',
              function: () {},
              width: 140,
              height: 40,
              color: AppColors.primary,
              textColor: AppColors.textButton,
            ),
            customButton(
              title: 'Cancel',
              function: () {},
              width: 140,
              height: 40,
              color: AppColors.darkGrey,
              textColor: AppColors.text,
            ),
          ],
        ),
      ),
      _section(
        '6 · customButtonWithSvg',
        customButtonWithSvg(
          title: 'Add',
          function: () {},
          textStyle: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.textButton,
          ),
          height: 44,
          space: 8,
          radius: 8,
          color: AppColors.primary,
          image: 'assets/icons_assets/main_icons_assets/ic_action_plus.svg',
          widthImage: 20,
          heightImage: 20,
          colorBorder: Colors.transparent,
        ),
      ),
      _section(
        '8 · StatusChipFilter',
        StatusChipFilter(
          selectedKey: _filterSelectedKey,
          onSelected: (key) => rebuild(() => _filterSelectedKey = key),
          items: const [
            StatusChipItem(key: 'all', label: 'All', count: 12),
            StatusChipItem(key: 'pending', label: 'Pending', count: 5),
            StatusChipItem(key: 'approved', label: 'Approved', count: 7),
          ],
        ),
      ),
      _section(
        '9 · CustomSegmentedTabs',
        SizedBox(
          width: 130.sp,
          child: CustomSegmentedTabs(
            tabs: const ['Chart', 'Table'],
            selectedIndex: _segmentedIndex,
            onTabSelected: (i) => rebuild(() => _segmentedIndex = i),
          ),
        ),
      ),
      _section(
        '10 · CustomTabs (underlined page tabs)',
        CustomTabs(
          tabs: const [
            'Role Management',
            'User Management',
            'User Access',
            'Active Directory',
            'System Logs',
          ],
          selectedValue: _pageTabIndex,
          onChanged: (v) => rebuild(() => _pageTabIndex = v),
        ),
      ),
      _section(
        '10 · showUploadDialog',
        customButton(
          textStyle: StyleText.fontSize16Weight600.copyWith(
            color: AppColors.textButton,
          ),
          title: 'Open upload dialog',
          width: 220,
          height: 40,
          function: () => showUploadDialog(
            context: context,
            onSubmit: (file, title) {},
            headerIconAsset:
                "assets/icons_assets/main_icons_assets/ic_cloud_upload.svg",
          ),
        ),
      ),
      _section(
        '11 · showConfirmDialog / showSuccessDialog / showCommentDialog',
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          children: [
            customButton(
              title: 'Confirm dialog',
              width: 150,
              height: 36,
              function: () => showConfirmDialog(context: context),
            ),
            customButton(
              title: 'Success dialog',
              width: 150,
              height: 36,
              function: () => showSuccessDialog(context: context),
            ),
            customButton(
              title: 'Comment dialog',
              width: 150,
              height: 36,
              function: () =>
                  showCommentDialog(context: context, onSubmit: (comment) {}),
            ),
          ],
        ),
      ),
      _section(
        '12-15 · Delete / Edit / Filter / Sort (icon-only upright · icon + text sideways)',
        // On the page colour, like a real toolbar (Filter / Sort are card-filled).
        Container(
          padding: EdgeInsets.all(8.sp),
          color: AppColors.background,
          child: Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            children: [
              CustomDeleteIcon(onTap: () {}),
              CustomEditIcon(onTap: () {}),
              CustomFilterIcon(onTap: () {}),
            ],
          ),
        ),
      ),
      _section(
        '16 · CardInfoRow (CardStyles/CardSvg tokens)',
        const CardInfoRow(
          info: CardInfo(label: 'Job Title:', value: 'Marketing Manager'),
        ),
      ),
      _section(
        '17 · CustomServiceCard',
        const CustomServiceCard(
          title: 'Laptop Repair',
          infoRows: [
            CardInfo(label: 'Service Provider:', value: 'Ahmed Mohammed'),
            CardInfo(label: 'Duration:', value: '2 days'),
          ],
          footerLabel: 'Status:',
          footerValue: 'In progress',
        ),
      ),
    ];
  }

  List<Widget> _cardAndChartSections() {
    return [
      _section(
        '18 · ServiceRequestCard',
        ServiceRequestCard(
          title: 'Market Research Service',
          icon: CardSvg.icon(CardSvg.services),
          infoRows: [
            CardInfo(
              label: 'Service Provider:',
              value: 'Ahmed Mohammed',
              icon: CardSvg.icon(CardSvg.serviceProvider),
            ),
            CardInfo(
              label: 'Job Title:',
              value: 'Marketing Manager',
              icon: CardSvg.icon(CardSvg.jobTitle),
            ),
            CardInfo(
              label: 'Duration of Service:',
              value: '1 Week',
              icon: CardSvg.icon(CardSvg.duration),
            ),
            CardInfo(
              label: 'Approval:',
              value: 'Needs Approval',
              icon: CardSvg.icon(CardSvg.approval),
            ),
          ],
          buttonText: 'Request',
          onPressed: () {},
        ),
      ),
      _section(
        '19 · PersonChipCard',
        PersonChipCard(
          // Full width and the page colour, so the card's own edge — and
          // its 10 / 10 corner — shows inside the white preview panel.
          width: double.infinity,
          backgroundColor: AppColors.background,
          name: 'Sara Ali',
          subtitle1: 'Product Designer',
          subtitle2: 'sara.ali@company.com',
        ),
      ),
      _section(
        '20 · CustomApprovalCard',
        const CustomApprovalCard(
          title: 'Change Request',
          requestedByName: 'Mona Hassan',
          jobTitle: 'HR Specialist',
          department: 'Human Resources',
        ),
      ),
      _section(
        '21 · ContactCard',
        const ContactCard(
          name: 'Omar Khaled',
          jobTitle: 'Backend Engineer',
          department: 'Engineering',
          email: 'omar.khaled@company.com',
          phone: '+20 100 000 0000',
        ),
      ),
      _section(
        '22 · ProductWarrantyCard',
        const ProductWarrantyCard(
          title: 'Warranty Document',
          fileName: 'warranty.pdf',
          fileSize: '1.2 MB',
          date: '01 Jul 2026',
        ),
      ),
      _section(
        '23 · CustomCheckBox',
        Wrap(
          spacing: 16.w,
          children: [
            GestureDetector(
              onTapDown: (_) => HapticController.low(),
              onTap: () =>
                  rebuild(() => _checkboxSelected = !_checkboxSelected),
              child: CustomCheckBox(isSelected: _checkboxSelected),
            ),
            GestureDetector(
              onTapDown: (_) => HapticController.low(),
              onTap: () =>
                  rebuild(() => _checkboxSelected2 = !_checkboxSelected2),
              child: CustomCheckBox(isSelected: _checkboxSelected2),
            ),
          ],
        ),
      ),
      _section(
        '24 · ChartCard + legend helpers',
        ChartCard(
          title: 'Requests overview',
          child: Column(
            children: [
              ChartLegendRow(
                name: 'Approved',
                amount: '24',
                color: AppColors.green,
              ),
              ChartLegendRow(
                name: 'Pending',
                amount: '6',
                color: AppColors.secondaryPrimary,
              ),
            ],
          ),
        ),
      ),
      _section(
        '25 · OverallStatsCard',
        OverallStatsCard(
          items: [
            StatItem(
              label: 'Products',
              value: '11',
              icon: CardSvg.icon(ChartSvg.products),
            ),
            StatItem(
              label: 'Orders',
              value: '11',
              icon: CardSvg.icon(ChartSvg.orders),
            ),
            StatItem(
              label: 'Warehouses',
              value: '11',
              icon: CardSvg.icon(ChartSvg.warehouse),
            ),
            StatItem(
              label: 'Low Stocks',
              value: '11',
              icon: CardSvg.icon(ChartSvg.lowStock),
            ),
            StatItem(
              label: 'Suppliers',
              value: '11',
              icon: CardSvg.icon(ChartSvg.supplier),
            ),
            StatItem(
              label: 'Requests',
              value: '11',
              icon: CardSvg.icon(ChartSvg.request),
            ),
          ],
        ),
      ),
      _section(
        '26 · BarChartCard',
        BarChartCard(
          title: 'Monthly requests',
          bars: [
            ChartData(label: 'Jan', value: 12, color: AppColors.primary),
            ChartData(label: 'Feb', value: 20, color: AppColors.green),
            ChartData(label: 'Mar', value: 8, color: AppColors.orange),
          ],
        ),
      ),
      _section(
        '27 · DonutChartCard',
        DonutChartCard(
          title: 'Demands',
          centerValue: '9K',
          centerLabel: 'Total Product',
          sections: [
            ChartData(label: 'Assets', value: 513, color: AppColors.primary),
            ChartData(
              label: 'Consumables',
              value: 320,
              color: AppColors.colorDarkGrey,
            ),
          ],
        ),
      ),
      _section(
        '28 · HorizontalBarChartCard',
        HorizontalBarChartCard(
          title: 'Requests by department',
          bars: [
            ChartData(
              label: 'Engineering',
              value: 14,
              color: AppColors.primary,
            ),
            ChartData(label: 'Sales', value: 9, color: AppColors.green),
          ],
        ),
      ),
      _section(
        '29 · GroupedBarChartCard',
        GroupedBarChartCard(
          title: 'Asset condition',
          series: [
            ChartData(label: 'New', value: 0, color: AppColors.green),
            ChartData(label: 'Used', value: 0, color: AppColors.orange),
          ],
          groups: const [
            GroupedBarData(label: 'Laptops', values: [12, 4]),
            GroupedBarData(label: 'Phones', values: [8, 2]),
          ],
        ),
      ),
      _section(
        '30 · AttendanceTilesCard',
        AttendanceTilesCard(
          itemsPerCard: 2,
          items: [
            AttendanceItem(
              label: 'Present',
              count: '03',
              color: AppColors.green,
            ),
            AttendanceItem(label: 'Absent', count: '05', color: AppColors.red),
            AttendanceItem(
                label: 'Late', count: '02', color: AppColors.secondaryPrimary),
          ],
        ),
      ),
      _section(
        '31 · CustomMultiSelectFilter',
        CustomMultiSelectFilter<int>(
          label: 'Skills',
          hint: 'Select skills',
          values: _multiSelectValues,
          items: const [
            MultiSelectDropdownItem(value: 1, label: 'Flutter'),
            MultiSelectDropdownItem(value: 2, label: 'Dart'),
            MultiSelectDropdownItem(value: 3, label: 'Firebase'),
          ],
          onChanged: (values) => rebuild(() => _multiSelectValues = values),
        ),
      ),
      _section(
        '32 · CustomSvgImage',
        const CustomSvgImage(
          assetPath:
              'assets/icons_assets/main_icons_assets/ic_delete_trash_red.svg',
          width: 28,
          height: 28,
        ),
      ),
      _section(
        '33 · hapticController',
        customButton(
          title: 'Trigger haptic feedback',
          width: 220,
          height: 40,
          function: () => hapticController.triggerHapticFeedback(),
        ),
      ),
      _section(
        '34 · AnimatedCustomGridView',
        AnimatedCustomGridView(
          itemCount: 6,
          crossAxisCount: 3,
          mainAxisExtent: 70,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Text('${index + 1}'),
          ),
        ),
      ),
    ];
  }
}

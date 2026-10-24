/// Module: core/custom
/// Description: DEBUG — "Keep or remove": every unused custom (U1…U7) and
///              every duplicate group side by side (D1…D5, options A/B/C),
///              drawn live, so Moataz decides what stays (17/10/2026).

part of '../preview.dart';

extension _PreviewKeepOrRemove on _PreviewAllCustomPageState {
  Widget _korHeader(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: StyleText.fontSize16Weight600
                    .copyWith(color: AppTheme.readableOn(AppColors.primary))),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppTheme.readableOn(AppColors.primary))),
          ],
        ),
      ),
    );
  }

  List<Widget> _keepOrRemoveSections(BuildContext context) {
    return [
      _korHeader('U · Not used by any screen', 'Remove or keep each one.'),
      _section(
        'U2 · ContactCard — 0 screens',
        const ContactCard(
          name: 'Omar Khaled',
          jobTitle: 'Backend Engineer',
          department: 'Engineering',
          email: 'omar.khaled@company.com',
          phone: '+20 100 000 0000',
        ),
      ),
      _section(
        'U3 · CustomApprovalCard — 0 screens',
        const CustomApprovalCard(
          title: 'Change Request',
          requestedByName: 'Mona Hassan',
          jobTitle: 'HR Specialist',
          department: 'Human Resources',
        ),
      ),
      _section(
        'U4 · ServiceRequestCard — 0 screens',
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
        'U5 · CustomServiceCard — 0 screens',
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
      _korHeader('D1 · Single dropdown — pick ONE',
          'Numbers = how many screens use it.'),
      _section(
        'D1-A · CustomDropdown — 168 screens',
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
        'D1-B · AppDropdown — 10 screens',
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
        'D1-C · CustomDropdownButton2 — 0 screens',
        CustomDropdownButton2(
          hint: 'Pick one',
          value: _dd2Value,
          dropdownItems: const ['First', 'Second', 'Third'],
          onChanged: (v) => rebuild(() => _dd2Value = v),
        ),
      ),
      _korHeader('D2 · Multi-select dropdown — pick ONE',
          'Your rule: the picked values show below the field.'),
      _section(
        'D2-A · CustomMultiSelectFilter — 35 screens',
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
        'D2-B · CustomMultiSelectField — 7 screens',
        CustomMultiSelectField(
          textButton: 'Select many',
          items: const ['Alpha', 'Beta', 'Gamma'],
          selectedItems: _multiSelMaster,
          onChanged: (v) =>
              rebuild(() => _multiSelMaster = List<String>.from(v as List)),
        ),
      ),
      _korHeader('D3 · Sort — pick ONE',
          'Services now uses CustomSortButton too (17 Oct).'),
      _section(
        'D3-A · CustomSortButton (opens a menu) — 15 screens',
        CustomSortButton<String>(
          value: _sortValue,
          items: const ['name', 'date', 'status'],
          labelBuilder: (v) => v,
          onChanged: (v) => rebuild(() => _sortValue = v),
        ),
      ),
      _korHeader('D4 · Stacked avatars — pick ONE', ''),
      _section(
        'D4-A · StackedAvatars — 5 screens',
        const StackedAvatars(images: ['Amr Mesbah', 'Sara Ali', 'Omar Hany']),
      ),
      _section(
        'D4-B · CustomStackedAvatars — 1 screen',
        const CustomStackedAvatars(
          avatars: ['Amr Mesbah', 'Sara Ali', 'Omar Hany'],
        ),
      ),
      _korHeader('D5 · Comment section — pick ONE',
          'B and C need a real request, so they are shown on their screens.'),
      _section(
        'D5-A · UniversalCommentSection — 11 screens',
        SizedBox(
          height: 260.h,
          child: UniversalCommentSection(
            collectionPath: 'preview_comments',
            filterFields: const {},
            currentUserId: 'preview_user',
            collapsedHeight: 260,
          ),
        ),
      ),
      _section(
        'D5-B · Inventory ChatCommentSection (private copy)',
        Text(
          'Seen in Inventory › Assets › Service history › a service.',
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
      ),
      _section(
        'D5-C · Time Tracker comments (RequestCommentsSection)',
        Text(
          'Seen in Time Tracker › Requests › open a request (the one you fixed).',
          style: StyleText.fontSize12Weight400
              .copyWith(color: AppColors.secondaryText),
        ),
      ),
    ];
  }
}

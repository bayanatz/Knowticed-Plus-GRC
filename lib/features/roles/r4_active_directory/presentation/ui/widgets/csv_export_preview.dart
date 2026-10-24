/// Module: roles / r4_active_directory / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: csv_export_preview.dart
/// Description: Declares `_ExportDialogPreview`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/custom_csv_table_page.dart';

extension _ExportDialogPreview on _ExportDialogState {
  Widget _buildPreviewPanel() {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
            child: Row(
              children: [
                AppSearchTextField(
                  controller: _searchController,
                  hintText: S.current.searchEmployee,
                  onChanged: (v) => rebuild(() => _searchQuery = v),
                ),
              ],
            ),
          ),

          // Employee list from real data
          Expanded(
            child: _previewRows.isEmpty
                ? Center(
                    child: Text(
                      S.current.noMatchesFound,
                      style: StyleText.fontSize16Weight400.copyWith(
                        fontSize: 10.sp,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _previewRows.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: AppColors.border, height: 1),
                    itemBuilder: (context, index) {
                      final row = _previewRows[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: AppColors.greyDark,
                              child: Text(
                                _rowName(row).isNotEmpty
                                    ? _rowName(row)[0].toUpperCase()
                                    : '?',
                                style: StyleText.fontSize16Weight400.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _rowName(row),
                                    style:
                                        StyleText.fontSize16Weight400.copyWith(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  Text(
                                    _rowDepartment(row),
                                    style:
                                        StyleText.fontSize16Weight400.copyWith(
                                      fontSize: 10.sp,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  Text(
                                    _rowTitle(row),
                                    style:
                                        StyleText.fontSize16Weight400.copyWith(
                                      fontSize: 10.sp,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Bottom actions
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTapDown: (_) => HapticController.medium(),
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: AppColors.darkGrey,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          S.current.discard,
                          style: StyleText.fontSize16Weight400.copyWith(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: InkWell(
                    onTapDown: _previewRows.isEmpty
                        ? null
                        : (_) => HapticController.medium(),
                    onTap: _previewRows.isEmpty
                        ? null
                        : () async {
                            Navigator.pop(context);
                            // Trigger the real export through the controller
                            final ctrl = AppControllers.activeDirectory;
                            // FIXED 25/8/2026 — this compared against the English
                            // LABEL 'Excel (.xlsx)'. Since the export dialog started
                            // storing a locale-independent CODE ('csv'/'xlsx'/'pdf')
                            // it could never match, so picking Excel still wrote a
                            // .csv — and under Arabic the label had changed anyway.
                            final fileName = _fileFormat == 'xlsx'
                                ? 'export.xlsx'
                                : 'export.csv';
                            await ctrl.exportToCSV(fileName);
                          },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: _previewRows.isEmpty
                            ? AppColors.greyDark
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_rounded,
                              size: 16.r,
                              color: _previewRows.isEmpty
                                  ? AppColors.white
                                  : AppColors.black,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              S.current.export,
                              style: StyleText.fontSize16Weight400.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: _previewRows.isEmpty
                                    ? AppColors.white
                                    : AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

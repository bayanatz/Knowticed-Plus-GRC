/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_action_buttons.viewers.dart
/// Description: `_ApprovalsFileViewers` — split out of `approvals_action_buttons.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'approvals_action_buttons.dart';

/// File-type viewer builders (pdf/image/video/office/excel/csv/placeholder),
/// split out of approvals_action_buttons.dart to stay under 800 LOC (§7).
/// Param-only helpers — no widget-field access.
mixin _ApprovalsFileViewers {
  Widget _buildPdfViewer(String fileUrl, bool lightMode) {
    return Container(
      color: AppColors.background.withValues(alpha: 0.87),
      child: SfPdfViewer.network(
        key: ValueKey<String>(fileUrl),
        fileUrl,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
      ),
    );
  }

  /// ✅ Image Viewer
  Widget _buildImageViewer(BuildContext context, String fileUrl) {
    return Container(
      color: AppColors.background.withValues(alpha: 0.87),
      child: PhotoView(
        // Keyed for the same reason as the pdf viewer above.
        key: ValueKey<String>(fileUrl),
        imageProvider: NetworkImage(fileUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        initialScale: PhotoViewComputedScale.contained,
        backgroundDecoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.87),
        ),
        loadingBuilder: (context, event) => Center(
          child: CircleProgressMaster.inline(
            color: AppColors.primary,
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
          ),
        ),
        errorBuilder: (context, error, stackTrace) =>
            _buildViewerError(S.of(context).khFailedToLoadImage),
      ),
    );
  }

  /// ✅ Video Player Widget
  Widget _buildVideoPlayer(String fileUrl, bool lightMode) {
    return _VideoPlayerWidget(videoUrl: fileUrl, lightMode: lightMode);
  }

  /// ✅ Office Files Viewer (Excel/CSV). The bytes are loaded first; the
  /// table is built afterwards with the widget's own context, so its texts
  /// are translated.
  Widget _buildOfficeFileViewer(
    BuildContext context,
    String fileUrl,
    String extension,
    bool lightMode,
  ) {
    return FutureBuilder<List<int>>(
      future: FilePreviewLoader.fetchBytes(fileUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildViewerLoading(
            S.of(context).khLoadingFileType(extension.toUpperCase()),
          );
        }
        final List<int>? bytes = snapshot.data;
        if (snapshot.hasError || bytes == null) {
          // The technical error goes to the log, not to the screen.
          khLog(
            'Loading $extension preview failed: ${snapshot.error}',
            name: 'ApprovalsFileViewers',
          );
          return _buildViewerError(S.of(context).khFileLoadFailed);
        }
        if (['xls', 'xlsx', 'xlsm'].contains(extension)) {
          return _buildExcelViewer(context, bytes, lightMode);
        }
        if (extension == 'csv') {
          return _buildCsvViewer(context, bytes, lightMode);
        }
        return _buildUnsupportedFileView(context, extension);
      },
    );
  }

  /// Spinner with a caption, while a preview loads.
  Widget _buildViewerLoading(String caption) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleProgressMaster.inline(color: AppColors.primary),
          SizedBox(height: 16.h),
          Text(
            caption,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.blackButton,
            ),
          ),
        ],
      ),
    );
  }

  /// Error icon with a translated message.
  Widget _buildViewerError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
          SizedBox(height: 16.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.blackButton,
            ),
          ),
        ],
      ),
    );
  }

  /// A centred grey message ("the file is empty").
  Widget _buildViewerNotice(String message) {
    return Center(
      child: Text(
        message,
        style: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
    );
  }

  /// ✅ Excel Viewer
  Widget _buildExcelViewer(
    BuildContext context,
    List<int> bytes,
    bool lightMode,
  ) {
    final S s = S.of(context);
    final SheetPreview? parsed = FilePreviewLoader.parseExcel(bytes);
    if (parsed == null) return _buildViewerError(s.khExcelParseFailed);
    if (parsed.sheetNames.isEmpty) return _buildViewerNotice(s.khExcelEmpty);
    if (parsed.rows.isEmpty) return _buildViewerNotice(s.khSheetEmpty);

    return Container(
      color: AppColors.background.withValues(alpha: 0.87),
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          if (parsed.sheetNames.length > 1)
            _buildSheetTabs(parsed.sheetNames, parsed.sheetName),
          Expanded(
            child: _buildPreviewTable(
              header: parsed.rows[0],
              body: parsed.rows.skip(1).toList(),
              maxColumns: parsed.maxColumns,
              lightMode: lightMode,
            ),
          ),
        ],
      ),
    );
  }

  /// One chip per sheet of the workbook; [selected] is the sheet shown.
  Widget _buildSheetTabs(List<String> sheetNames, String selected) {
    return Container(
      height: 48.h,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sheetNames.length,
        itemBuilder: (context, index) {
          final name = sheetNames[index];
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(name),
              selected: name == selected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.card,
              labelStyle: StyleText.fontSize12Weight500.copyWith(
                color: name == selected
                    ? AppColors.colorWhite
                    : AppColors.blackButton,
              ),
            ),
          );
        },
      ),
    );
  }

  /// ✅ CSV Viewer
  Widget _buildCsvViewer(
    BuildContext context,
    List<int> bytes,
    bool lightMode,
  ) {
    final S s = S.of(context);
    final rows = FilePreviewLoader.parseCsv(bytes);
    if (rows == null) return _buildViewerError(s.khCsvParseFailed);
    if (rows.isEmpty) return _buildViewerNotice(s.khCsvEmpty);

    final List<List<String>> cells = rows
        .map((row) => row.map((cell) => cell?.toString() ?? '').toList())
        .toList();
    final int maxColumns = cells.fold<int>(
      0,
      (max, row) => row.length > max ? row.length : max,
    );

    return Container(
      color: AppColors.background.withValues(alpha: 0.87),
      padding: EdgeInsets.all(8.w),
      child: _buildPreviewTable(
        header: cells[0],
        body: cells.skip(1).toList(),
        maxColumns: maxColumns,
        lightMode: lightMode,
      ),
    );
  }

  /// The scrollable table shared by the Excel and CSV previews. Short rows
  /// are padded with empty cells.
  Widget _buildPreviewTable({
    required List<String> header,
    required List<List<String>> body,
    required int maxColumns,
    required bool lightMode,
  }) {
    String cellAt(List<String> row, int index) =>
        index < row.length ? row[index] : '';
    Widget cellText(String text, TextStyle style) => Container(
      constraints: BoxConstraints(maxWidth: 150.w),
      child: Text(text, style: style, overflow: TextOverflow.ellipsis),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: AnimatedSizeWrap(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              AppColors.primary.withValues(alpha: 0.1),
            ),
            dataRowColor: WidgetStateProperty.all(AppColors.card),
            border: TableBorder.all(
              color: lightMode ? AppColors.colorGrey : AppColors.colorGreyDark,
              width: 1,
            ),
            columnSpacing: 20.w,
            columns: List.generate(
              maxColumns,
              (index) => DataColumn(
                label: cellText(
                  cellAt(header, index),
                  StyleText.fontSize14Weight600.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ),
            ),
            rows: body
                .map(
                  (row) => DataRow(
                    cells: List.generate(
                      maxColumns,
                      (colIndex) => DataCell(
                        cellText(
                          cellAt(row, colIndex),
                          StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.blackButton,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  /// ✅ Document Placeholder (Word/PowerPoint)
  Widget _buildDocumentPlaceholder(BuildContext context, String extension) {
    final S s = S.of(context);
    final String type = extension.toUpperCase();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForExtension(extension),
            size: 80.sp,
            color: AppColors.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            s.khFileTypePreview(type),
            style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.blackButton,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              s.khPreviewNotAvailableForType(type),
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Unsupported File Type View
  Widget _buildUnsupportedFileView(BuildContext context, String extension) {
    final S s = S.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file, size: 80.sp, color: AppColors.darkGrey),
          SizedBox(height: 16.h),
          Text(
            s.khUnsupportedFileType,
            style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.blackButton,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '.${extension.toUpperCase()}',
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            s.khPreviewNotAvailable,
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            s.khDownloadToView,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Helper: Get icon for file extension
  IconData _getIconForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
      case 'xlsm':
      case 'csv':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }
}

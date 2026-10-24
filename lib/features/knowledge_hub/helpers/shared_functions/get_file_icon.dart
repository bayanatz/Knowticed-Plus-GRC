/// Module: knowledge_hub/data/utils/shared_functions
/// ************************* FILE INFO *************************** ///
/// File Name: get_file_icon.dart
/// Description: Get file icon — knowledge_hub core/widgets.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
///
/// 14/10/2026 — KH large-screen report p.2: "why the icon of excel files not
/// appear in submission page". The Submissions grid and list each kept their
/// own copy of this switch, and neither copy had Excel/CSV or video, so those
/// files fell through to the generic image placeholder. This is now the one
/// mapping both use; it matches the hub's FileCard so a document shows the same
/// icon on every screen.
library;

String getFileIcon(String extension) {
  return switch (extension.toLowerCase()) {
    'pdf' => 'assets/icons_assets/main_icons_assets/ic_file_pdf.svg',
    'ppt' ||
    'pptx' => 'assets/icons_assets/main_icons_assets/ic_file_powerpoint.svg',
    'doc' || 'docx' => 'assets/icons_assets/main_icons_assets/ic_file_doc.svg',
    'xls' ||
    'xlsx' ||
    'xlsm' ||
    'csv' => 'assets/icons_assets/main_icons_assets/ic_file_excel_grid.svg',
    'mp4' ||
    'avi' ||
    'mov' ||
    'wmv' ||
    'flv' ||
    'mkv' ||
    'webm' => 'assets/icons_assets/main_icons_assets/ic_file_video.svg',
    _ => 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg',
  };
}

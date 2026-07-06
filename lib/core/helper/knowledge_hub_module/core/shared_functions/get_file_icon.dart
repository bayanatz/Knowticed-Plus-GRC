String getFileIcon(String extension) {
  return switch (extension.toLowerCase()) {
    'pdf' => 'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg',
    'ppt' || 'pptx' => 'assets/icons_assets/main_icons_assets/ppt_attachment_icon.svg',
    'doc' || 'docx' => 'assets/icons_assets/main_icons_assets/doc_icon.svg',
    'xls' || 'xlsx' => 'assets/icons_assets/knowledge_hub_assets/xls_icon.svg',
    _ => 'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg',
  };
}
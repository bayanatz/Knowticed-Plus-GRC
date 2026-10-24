/// Module: messaging / chat / domain/enum/file_types.dart
///
/// FIXED (bug report #18): the icons pointed at assets/png_assets/images_pdf.png
/// and images_xls.png, which are not in the project, so the doc bubble drew an
/// empty square. They now use the svgs that ship in main_icons_assets.
enum FileTypes {
  pdf,
  word,
  excel,
  powerpoint;

  static String getFileIcon(String filePath) {
    switch (getFileType(filePath)) {
      case FileTypes.pdf:
        return 'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
      case FileTypes.word:
        return 'assets/icons_assets/main_icons_assets/ic_file_doc.svg';
      case FileTypes.excel:
        return 'assets/icons_assets/main_icons_assets/ic_file_excel_grid.svg';
      case FileTypes.powerpoint:
        return 'assets/icons_assets/main_icons_assets/ic_file_powerpoint.svg';
    }
  }

  static FileTypes getFileType(String filePath) {
    // Storage download URLs end in "?alt=media&token=…", so strip the query
    // before looking at the extension, and ignore case (".PDF").
    final String path = filePath.split('?').first.toLowerCase();
    if (path.endsWith('.pdf')) {
      return FileTypes.pdf;
    } else if (path.endsWith('.doc') || path.endsWith('.docx')) {
      return FileTypes.word;
    } else if (path.endsWith('.xls') || path.endsWith('.xlsx')) {
      return FileTypes.excel;
    } else if (path.endsWith('.ppt') || path.endsWith('.pptx')) {
      return FileTypes.powerpoint;
    }
    return FileTypes.pdf;
  }
}

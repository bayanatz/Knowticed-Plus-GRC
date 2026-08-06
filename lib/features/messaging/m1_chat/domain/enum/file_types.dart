/// Module: messaging / chat / domain/enum/file_types.dart
enum FileTypes {
  pdf,
  word,
  excel,
  powerpoint;

  static String getFileIcon(String filePath) {
    switch (getFileType(filePath)) {
      case FileTypes.pdf:
        return 'assets/png_assets/images_pdf.png';
      case FileTypes.word:
        return 'assets/png_assets/images_pdf.png';
      case FileTypes.excel:
        return 'assets/png_assets/images_xls.png';
      case FileTypes.powerpoint:
        return 'assets/png_assets/images_pdf.png';
      // Default icon for unknown types
    }
  }

  static FileTypes getFileType(String filePath) {
    if (filePath.endsWith('.pdf')) {
      return FileTypes.pdf;
    } else if (filePath.endsWith('.doc') || filePath.endsWith('.docx')) {
      return FileTypes.word;
    } else if (filePath.endsWith('.xls') || filePath.endsWith('.xlsx')) {
      return FileTypes.excel;
    } else if (filePath.endsWith('.ppt') || filePath.endsWith('.pptx')) {
      return FileTypes.powerpoint;
    }
    return FileTypes.pdf;
  }
}
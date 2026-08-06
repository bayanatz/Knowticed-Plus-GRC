/// Module: messaging / chat / data/models/message/doc_message_model.dart
import 'dart:io';
import 'dart:typed_data';

//Youssef Ashraf
class DocMessageModel {
  String extension;
  String? fileName;
  double totalSize;
  int totalPages;
  String docPath;
  Uint8List? firstPage;

  DocMessageModel(
      {this.totalSize = 0,
      this.totalPages = 0,
      this.extension = '',
      required this.docPath,
      this.fileName,
      this.firstPage}) {
    if (!docPath.contains("http")) {
      fileName = docPath.split('/').last.split('\\').last;

      extension = fileName!.split('.').last;

      totalSize = File(docPath).lengthSync() / (1024 * 1024);
    }
  }

  DocMessageModel copyWith({
    double? totalSize,
    int? totalPages,
    String? extension,
    String? fileName,
    required String docPath,
  }) {
    return DocMessageModel(
      totalSize: totalSize ?? this.totalSize,
      docPath: docPath,
      totalPages: totalPages ?? this.totalPages,
      extension: extension ?? this.extension,
      fileName: fileName ?? this.fileName,
    );
  }

  static const String totalSizeKey = 'Total_Size';
  static const String totalPagesKey = 'Total_Pages';
  static const String extensionKey = 'Extension';
  static const String docPathKey = 'Media_Link';
  static const String fileNameKey = 'File_Name';
  static const String firstPageBytesKey = 'First_Page_Bytes';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      totalSizeKey: totalSize,
      totalPagesKey: totalPages,
      extensionKey: extension,
      fileNameKey: fileName,
      docPathKey: docPath,
      firstPageBytesKey: firstPage,
    };
  }

  factory DocMessageModel.fromMap(Map<String, dynamic> map) {
    // get the first page bytes from the map
    final List<dynamic> firstPageBytes =
        map[firstPageBytesKey] as List<dynamic>;
    // convert the list of dynamic to list of int
    final List<int> firstPageBytesInt =
        firstPageBytes.map((e) => e as int).toList();

    return DocMessageModel(
        totalSize: map[totalSizeKey] as double,
        totalPages: map[totalPagesKey] as int,
        docPath: map[docPathKey] as String,
        extension: map[extensionKey] as String,
        fileName: map[fileNameKey] as String,
        firstPage: Uint8List.fromList(firstPageBytesInt));
  }
}
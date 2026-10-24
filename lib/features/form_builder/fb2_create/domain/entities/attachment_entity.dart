/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: attachment_entity.dart
/// Description: `AttachmentEntity` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

/// A file attached to an answer (path, name, size in KB, date).
class AttachmentEntity {
  String path;
  String name;
  int size;
  String createdAt;

  AttachmentEntity(
      {required this.path,
      required this.name,
      required this.size,
      required this.createdAt});
  static final String _codingKey = "^*^*^*^";
  String get encodedAttachmentData {
    String encodedData = path;
    encodedData += _codingKey;
    encodedData += name;
    encodedData += _codingKey;
    encodedData += size.toString();
    encodedData += _codingKey;
    encodedData += createdAt;
    return encodedData;
  }

  static AttachmentEntity fromDecodedData(String encodedData) {
    List<String> decodedData = encodedData.split(_codingKey);
    String path = decodedData[0];
    String name = decodedData[1];
    int size = int.parse(decodedData[2]);
    String createdAt = decodedData[3];
    return AttachmentEntity(
        path: path, name: name, size: size, createdAt: createdAt);
  }
}



class AccessData {
  AccessData(
      {required this.accessIcon,
        required this.grantedBy,
        required this.text,
        required this.grantedDate,
        required this.isRemoved});
  final String accessIcon;
  final String text;
  final String grantedBy;
  final String grantedDate;
  bool isRemoved;
}

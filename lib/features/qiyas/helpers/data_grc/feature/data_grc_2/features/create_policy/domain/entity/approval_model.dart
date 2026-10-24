// This class definition defines a data model for an approval,
//which represents an approval request or decision in a business process.
// name: the name of the person or entity requesting approval
// startTime: the date and time when the approval request was made
// imagPath: the path to an image associated with the approval request
// file: the file associated with the approval request
// fileSize: the size of the file
// jobTitle: the job title of the person requesting approval
// status: the status of the approval request (note: this is not actually required in the constructor, despite being listed as required)
// submissionNote: a note or comment submitted with the approval request (note: this is not actually required in the constructor, despite being listed as required)

class ApprovalModel {
  final String name;
  final DateTime startTime;
  final String imagPath;
  final String file;
  final String fileSize;
  final String jobTitle;
  final String? submissionNote;
  String? status;

  ApprovalModel({
    required this.file,
    required this.fileSize,
    required this.imagPath,
    required this.jobTitle,
    required this.name,
    required this.startTime,
    required this.status,
    required this.submissionNote,
  });
}

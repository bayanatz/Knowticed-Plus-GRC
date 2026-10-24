// This class definition defines a data model for a comment, with the following properties:

// name: the name of the person making the comment
// description: the text of the comment
// startTime: the date and time when the comment was made
// imagPath: the path to an image associated with the comment
// isPdf: a boolean indicating whether the image is a PDF
// jobTitle: the job title of the person making the comment
// date: the date of the comment
class CommentsModel {
  final String name;
  String description;
  final DateTime startTime;
  final String imagPath;
  final bool isPdf;
  final String jobTitle;
  final String date;

  CommentsModel(
      {required this.name,
      required this.description,
      required this.startTime,
      required this.imagPath,
      required this.isPdf,
      required this.jobTitle,
      required this.date});
}

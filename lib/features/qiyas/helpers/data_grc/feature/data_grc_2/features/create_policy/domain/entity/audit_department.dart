// This class definition defines a data model for an audit department, with two properties: name and score.

// Here's a list explaining what each part of the class does:

// final String name;: Declares a required string property to store the name of the audit department.
// int score;: Declares an integer property to store the score of the audit department.
class AuditDepartment {
  final String name;
  int score;

  AuditDepartment({required this.name, required this.score});
}

/// Module: GRC Request Management
/// Description: Discriminates what kind of GRC approval request a
///              GrcRequestEntity represents. Only [reassignChampion] has a
///              working creation flow / business logic in this feature —
///              [controlChanges] is reserved for a future feature and must
///              not be given speculative fields or logic.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: None
library;

enum GrcRequestType {
  reassignChampion,
  controlChanges;

  String get value {
    switch (this) {
      case GrcRequestType.reassignChampion:
        return 'Reassign Control Champion';
      case GrcRequestType.controlChanges:
        return 'Control Changes';
    }
  }

  static GrcRequestType fromString(String value) {
    switch (value) {
      case 'Control Changes':
        return GrcRequestType.controlChanges;
      case 'Reassign Control Champion':
      default:
        return GrcRequestType.reassignChampion;
    }
  }
}

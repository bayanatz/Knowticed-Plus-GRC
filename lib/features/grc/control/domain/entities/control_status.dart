/// Module: Policy Management
/// Description: Defines the ControlStatus enum representing all possible
///              lifecycle states a Control record can be in. Separate from
///              [PolicyStatus] because Controls do not have a "Removed"
///              state but instead have "Unassigned".
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-14
/// Dependencies: None
/// Revision History: 2026-07-14 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_status.dart
/// Purpose: Contains the ControlStatus enum and its serialization helpers
///          used across the Control model and entity.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 14/7/2026

/// class name: [ControlStatus]
///
/// purpose: represent the lifecycle state of a Control record.
///          - [draft]      → created but not yet published
///          - [scheduled]  → published but the Start Date hasn't arrived yet
///          - [active]     → published and currently in effect
///          - [inactive]   → manually deactivated
///          - [expired]    → past the End Date
///          - [unassigned] → not yet assigned to a responsible owner
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 14/7/2026
enum ControlStatus {
  draft,
  scheduled,
  active,
  inactive,
  expired,
  unassigned;

  /// function name: [value]
  ///
  /// purpose: return the exact string stored in Firestore for this status.
  ///
  /// parameters: none
  ///
  /// return type: [String] - the Firestore-ready string representation
  String get value {
    switch (this) {
      case ControlStatus.draft:
        return 'Draft';
      case ControlStatus.scheduled:
        return 'Scheduled';
      case ControlStatus.active:
        return 'Active';
      case ControlStatus.inactive:
        return 'Inactive';
      case ControlStatus.expired:
        return 'Expired';
      case ControlStatus.unassigned:
        return 'Unassigned';
    }
  }

  /// function name: [fromString]
  ///
  /// purpose: parse a [ControlStatus] from a raw Firestore string, defaulting
  ///          to [ControlStatus.unassigned] for any unrecognised value.
  ///
  /// parameters:
  ///            [String] value: the raw string read from Firestore
  ///
  /// return type: [ControlStatus] - the matching enum value, or [ControlStatus.unassigned] if unknown
  static ControlStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'draft':
        return ControlStatus.draft;
      case 'scheduled':
        return ControlStatus.scheduled;
      case 'active':
        return ControlStatus.active;
      case 'inactive':
        return ControlStatus.inactive;
      case 'expired':
        return ControlStatus.expired;
      case 'unassigned':
      default:
        return ControlStatus.unassigned;
    }
  }
}

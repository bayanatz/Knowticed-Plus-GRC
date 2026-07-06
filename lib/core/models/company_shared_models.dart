/// Module: Core · Models · Company Shared Models
/// Description: Single barrel that re-exports the sub-models shared between the
///              settings, employee and organization-chart features. Features
///              import these through core/ instead of reaching directly into
///              another feature's internal data layer (decouples cross-feature
///              data dependencies — see CR-KP-SET-DATA-M06 / DS03 / REP04).
/// Author: Amr Mesbah
/// Date: 26/06/2026
/// Dependencies: shared employee / org-chart sub-models
/// Revision History:
///   - 26/06/2026 (Amr Mesbah): Initial creation (barrel for shared models).
library;


export 'package:demo_app/features/employee/data/models/emplyees_model/mobile_phone_model.dart';

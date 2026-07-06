/// Module: Settings · Company Controller State
/// Description: State for [CompanyController]. Like SettingsControllerState,
///              this is intentionally a thin marker — CompanyController still
///              exposes company/branding data as plain fields (and a GetX
///              `Rx<CompanyModel>` for the sign-up form, which is unaffected
///              by the GetxController→Cubit change) for backward
///              compatibility with call sites across the app.
/// Author: Knowticed Team
/// Date: 01/07/2026
/// Dependencies: none
/// Revision History:
///   - 01/07/2026: Introduced as part of the GetX→Cubit migration
///       (CompanyController extends GetxController → extends Cubit).

part of 'add_company_controller.dart';

///*************************** FILE INFO ****************************///
/// File Name: company_state.dart
/// Purpose: Marker state for CompanyController's Cubit.

@immutable
class CompanyState {
  const CompanyState();
}

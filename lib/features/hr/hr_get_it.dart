/// Module: hr
///
///*************************** FILE INFO ****************************///
/// File Name: hr_get_it.dart
/// Purpose: Declares `setupHrDependencies` — the get_it registrations
///          for the HR module (K-04, K-26). Empty until the module's
///          repositories and cubits move to get_it: data sources and
///          repositories as lazy singletons, cubits as factories.
/// Author: Knowticed Plus team
/// Created at: 16/10/2026
library;

import 'package:get_it/get_it.dart';

/// Function Name: [setupHrDependencies]
///
/// Purpose: Registers the HR module's dependencies. Called once from
/// `main()`, like `setupTodoDependencies`.
///
/// Parameters:
/// - [getIt]: the app's service locator.
void setupHrDependencies(GetIt getIt) {}

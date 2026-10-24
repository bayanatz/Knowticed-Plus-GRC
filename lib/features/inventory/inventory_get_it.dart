/// Module: inventory
///
///*************************** FILE INFO ****************************///
/// File Name: inventory_get_it.dart
/// Purpose: Declares `setupInventoryDependencies` — the get_it registrations
///          for the Inventory module (K-04, K-26). Empty until the module's
///          repositories and cubits move to get_it: data sources and
///          repositories as lazy singletons, cubits as factories.
/// Author: Knowticed Plus team
/// Created at: 16/10/2026
library;

import 'package:get_it/get_it.dart';

/// Function Name: [setupInventoryDependencies]
///
/// Purpose: Registers the Inventory module's dependencies. Called once from
/// `main()`, like `setupTodoDependencies`.
///
/// Parameters:
/// - [getIt]: the app's service locator.
void setupInventoryDependencies(GetIt getIt) {}

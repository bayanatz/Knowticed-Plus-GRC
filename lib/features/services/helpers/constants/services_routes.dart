/// Module: services / helpers / constants
///
///*************************** FILE INFO ****************************///
/// File Name: services_routes.dart
/// Purpose: Route names of the services module's own Navigator (rule "Use
///          named routes from the router"; it built an anonymous
///          MaterialPageRoute for every route).
/// Author: Amr Mesbah
/// Created At: 22/10/2026
library;

/// Class Name: [ServicesRoutes]
///
/// Purpose: Named routes inside the services module.
class ServicesRoutes {
  const ServicesRoutes._();

  /// The services home page (the module's first route).
  static const String home = '/';

  /// The provider picker of a request (argument: the request,
  /// ServicesHistoryModel). Lets other sub-modules open it without
  /// importing its page (Provider rule 3).
  static const String editProvider = '/edit-provider';
}

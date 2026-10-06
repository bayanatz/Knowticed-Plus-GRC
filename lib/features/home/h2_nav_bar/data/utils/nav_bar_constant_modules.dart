/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: nav_bar_constant_modules.dart
/// Purpose: Declares `NavBarConstantModules`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:grc_module/core/helper/role/modules_enum.dart';

abstract class NavBarConstantModules {
  /// default modules to appear at admin nav bar
  static List<Modules> defaultAdminNavBarModules = [
    Modules.home,
    Modules.employees,
    Modules.tracking,
    Modules.messages,
    Modules.more
  ];

  /// default modules to appear at HR nav bar
  static List<Modules> defaultHRNavBarModules = [
    Modules.home,
    Modules.roles,
    Modules.tracking,
    Modules.messages,
    Modules.more
  ];

  /// default modules to appear at default user
  static List<Modules> defaultUserNavBarModules = [
    Modules.home,
    Modules.tracking,
    Modules.messages,
    Modules.tasks,
    Modules.more
  ];



 static List<Modules> secondaryNavBarItems =[
   Modules.tasks,
   Modules.todo,
   Modules.events,
   Modules.formBuilder,
   Modules.database,
   Modules.inventory,
   Modules.qiyas,
   Modules.services,
   // Was missing entirely while AppDrawerConstantModules.drawerModules has
   // carried it since the module shipped. Without an entry here GRC could only
   // reach the More page through the catch-all sweep at the end of
   // _getMoreListModules, which appends in enum order — so it landed after
   // everything else instead of next to Services, where the drawer puts it.
   Modules.grc,
   Modules.knowledgeHub,
   Modules.notes,
   Modules.requests,
   Modules.roles,
   Modules.crm
 ];




}

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
   Modules.knowledgeHub,
   Modules.notes,
   Modules.requests,
   Modules.roles,
   Modules.crm
 ];




}

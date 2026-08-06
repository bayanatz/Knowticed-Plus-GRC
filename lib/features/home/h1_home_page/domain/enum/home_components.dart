///********************** FILE INFO ****************************///
/// Purpose: Enum for home components determine which component to show and its assigned values
/// Created by: Mohamed Elrashidy
/// Create at: 21/9/2025
library;

import 'package:flutter/material.dart';
import 'package:grc_module/features/home/h1_home_page/data_source/models/home_component_model.dart';

import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/forms/forms_actions.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/inventory/inventory_actions.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/inventory/inventory_new_request.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/inventory/inventory_overview.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/inventory/my_request_inventory.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/inventory/stocks.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/knowledgehub/approval_knowledge.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/knowledgehub/knowledge_hub_actions.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/knowledgehub/knowledge_hub_overview.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/messages/schedule_message.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/qiyas/qiyas_assign_overview.dart';

import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/todo/my_todo.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/todo/to_check_box.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/ui/widgets/module_widget/todo/todo_status.dart';


enum HomeComponents {
  /// Fallback for component names found in a stored layout that this
  /// build no longer knows (e.g. the removed messaging cards).
  /// widget() returns null for it, so such cards render as empty and are
  /// never offered in the add-widget picker.
  unknown,
  formActions,
  scheduleMessages,
  requestedService,
  serviceActions,
  serviceStatus,
  serviceOverview,
  myServices,
  myRequestServices,
  nearBreachedSLA,
  qiyasAssignOverview,
  inventoryActions,
  inventoryNewRequest,
  inventoryOverview,
  stocks,
  myRequestInventory,
  knowledgeHubActions,
  knowledgeHubOverview,
  approvalDashboard,  // ✅ NEW COMPONENT
  myTodoList,
  myTodoStatus,
  MyTodoBox,
  none;

  String get databaseName {
    switch (this) {
      case HomeComponents.unknown:
        return 'Unknown';
      case HomeComponents.formActions:
        return 'Form_Actions';
      case HomeComponents.scheduleMessages:
        return 'Schedule_Messages';
      case HomeComponents.requestedService:
        return 'Requested_Service';
      case HomeComponents.serviceActions:
        return 'Service_Actions';
      case HomeComponents.serviceStatus:
        return 'Service_Status';
      case HomeComponents.myServices:
        return 'My_Services';
      case HomeComponents.nearBreachedSLA:
        return 'Near_Breached_SLA';
      case HomeComponents.inventoryActions:
        return 'Inventory_Actions';
      case HomeComponents.inventoryNewRequest:
        return 'Inventory_New_Request';
      case HomeComponents.inventoryOverview:
        return 'Inventory_Overview';
      case HomeComponents.stocks:
        return 'Stocks';
      case HomeComponents.knowledgeHubActions:
        return 'Knowledge_Hub_Actions';
      case HomeComponents.knowledgeHubOverview:
        return 'Knowledge_Hub_Overview';
      case HomeComponents.approvalDashboard:  // ✅ NEW CASE
        return 'Approval_Dashboard';
      case HomeComponents.serviceOverview:
        return 'Service_Overview';
      case HomeComponents.myRequestServices:
        return 'My_Request_Services';
      case HomeComponents.myRequestInventory:
        return 'My_Request_Inventory';
      case HomeComponents.qiyasAssignOverview:
        return 'Qiyas_Assign_Overview';
      case HomeComponents.myTodoList:
        return 'My_Todo_List';
      case HomeComponents.myTodoStatus:
        return 'My_Todo_Status';
      case HomeComponents.MyTodoBox:
        return 'My_Todo_Check_Box';
      case HomeComponents.none:
        return 'None';
    }
  }

  bool get isEditable {
    switch (this) {
      case HomeComponents.nearBreachedSLA:
        return true;
      default:
        return false;
    }
  }

  Widget? widget(HomeComponentModel model) {
    switch (this) {
      case HomeComponents.scheduleMessages:
        return ScheduleMessage(model: model);
      case HomeComponents.formActions:
        return FormActions(model: model);
      // case HomeComponents.serviceActions:
      //   return ServicesActions(model: model);
      // case HomeComponents.requestedService:
      //   return RequestService(model: model);
      case HomeComponents.inventoryActions:
        return InventoryActions(model: model);
      case HomeComponents.inventoryNewRequest:
        return InventoryNewRequests(model: model);
      case HomeComponents.knowledgeHubActions:
        return KnowledgeHubActions(model: model);
      // case HomeComponents.serviceStatus:
      //   return ServicesStatus(model: model);
      // case HomeComponents.myServices:
      //   return MyServices(model: model);
      // case HomeComponents.nearBreachedSLA:
      //   return NearBreachedSLA(model: model);
      case HomeComponents.inventoryOverview:
        return InventoryOverview(model: model);
      case HomeComponents.knowledgeHubOverview:
        return KnowledgeHubOverview(model: model);
      case HomeComponents.approvalDashboard:  // ✅ NEW CASE
        return ApprovalDashBoardWidget(model: model);
      // case HomeComponents.serviceOverview:
      //   return ServiceOverview(model: model);
      // case HomeComponents.myRequestServices:
      //   return MyRequestServices(model: model);
      case HomeComponents.myRequestInventory:
        return MyRequestInventory(model: model);
      case HomeComponents.myTodoList:
        return MyTodo(model: model);
      case HomeComponents.myTodoStatus:
        return MyTodoStatus(model: model);
      case HomeComponents.MyTodoBox:
        return MyTodoCheckBox(model: model);
      case HomeComponents.stocks:
        return Stocks(model: model);
      case HomeComponents.qiyasAssignOverview:
        return QiyasAssignOverview(model: model);
      default:
        return null;
    }
  }

  HomeComponentModel getModel(
      {required int rowNumber, required int columnNumber}) {
    switch (this) {
      case HomeComponents.nearBreachedSLA:
        return HomeComponentModel(
            component: this, rowNumber: rowNumber, columnNumber: columnNumber);

      default:
        return HomeComponentModel(
            component: this, rowNumber: rowNumber, columnNumber: columnNumber);
    }
  }
}
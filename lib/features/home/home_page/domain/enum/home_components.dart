///********************** FILE INFO ****************************///
/// Purpose: Enum for home components determine which component to show and its assigned values
/// Created by: Mohamed Elrashidy
/// Create at: 21/9/2025
library;

import 'package:flutter/material.dart';
import 'package:demo_app/features/home/home_page/data_source/models/direct_message_model.dart';
import 'package:demo_app/features/home/home_page/data_source/models/group_message_model.dart';
import 'package:demo_app/features/home/home_page/data_source/models/home_component_model.dart';

import 'package:demo_app/features/home/home_page/data_source/models/form_submissions_model.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/forms/form_submission.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/forms/forms_actions.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/inventory/inventory_actions.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/inventory/inventory_new_request.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/inventory/inventory_overview.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/inventory/my_request_inventory.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/inventory/stocks.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/knowledgehub/approval_knowledge.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/knowledgehub/knowledge_hub_actions.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/knowledgehub/knowledge_hub_overview.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/messages/direct_messages.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/messages/group_messages.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/messages/schedule_message.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/qiyas/qiyas_assign_overview.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/services/approval.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/services/my_request_services.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/services/near_breach_sla.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/services/request_service.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/services/service_overview.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/services/services_actions.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/services/services_status.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/todo/my_todo.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/todo/to_check_box.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/widgets/todo/todo_status.dart';


enum HomeComponents {
  directMessage,
  groupMessage,
  formSubmissions,
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
      case HomeComponents.directMessage:
        return 'Direct_Message';
      case HomeComponents.groupMessage:
        return 'Group_Message';
      case HomeComponents.formSubmissions:
        return 'Form_Submissions';
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
      case HomeComponents.directMessage:
        return true;
      case HomeComponents.groupMessage:
        return true;
      case HomeComponents.formSubmissions:
        return true;
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
      case HomeComponents.directMessage:
        return DirectMessages(model: model as DirectMessageModel);
      case HomeComponents.groupMessage:
        return GroupMessages(model: model as GroupMessageModel);
      case HomeComponents.formActions:
        return FormActions(model: model);
      case HomeComponents.formSubmissions:
        return FormSubmission(model: model as FormSubmissionsModel);
      case HomeComponents.serviceActions:
        return ServicesActions(model: model);
      case HomeComponents.requestedService:
        return RequestService(model: model);
      case HomeComponents.inventoryActions:
        return InventoryActions(model: model);
      case HomeComponents.inventoryNewRequest:
        return InventoryNewRequests(model: model);
      case HomeComponents.knowledgeHubActions:
        return KnowledgeHubActions(model: model);
      case HomeComponents.serviceStatus:
        return ServicesStatus(model: model);
      case HomeComponents.myServices:
        return MyServices(model: model);
      case HomeComponents.nearBreachedSLA:
        return NearBreachedSLA(model: model);
      case HomeComponents.inventoryOverview:
        return InventoryOverview(model: model);
      case HomeComponents.knowledgeHubOverview:
        return KnowledgeHubOverview(model: model);
      case HomeComponents.approvalDashboard:  // ✅ NEW CASE
        return ApprovalDashBoardWidget(model: model);
      case HomeComponents.serviceOverview:
        return ServiceOverview(model: model);
      case HomeComponents.myRequestServices:
        return MyRequestServices(model: model);
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
      case HomeComponents.directMessage:
        return DirectMessageModel(
            component: this,
            rowNumber: rowNumber,
            columnNumber: columnNumber,
            usersEmails: []);
      case HomeComponents.groupMessage:
        return GroupMessageModel(
            component: this,
            rowNumber: rowNumber,
            columnNumber: columnNumber,
            groupIds: []);
      case HomeComponents.formSubmissions:
        return FormSubmissionsModel(
            component: this,
            rowNumber: rowNumber,
            columnNumber: columnNumber,
            formId: 'formId1');
      case HomeComponents.nearBreachedSLA:
        return HomeComponentModel(
            component: this, rowNumber: rowNumber, columnNumber: columnNumber);

      default:
        return HomeComponentModel(
            component: this, rowNumber: rowNumber, columnNumber: columnNumber);
    }
  }
}
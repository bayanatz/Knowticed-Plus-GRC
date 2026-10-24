// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:knowticed_plus/features/qiyas/core/widgets/pagination_app_bar.dart';
// import 'package:knowticed_plus/features/qiyas/features/owner/owner_tasks/presentation/controller/qiyas_owner_core_cubit.dart';
//
// import '../../../../../../../../core/helpers/cross_axis_count_helper.dart';
// import 'package:knowticed_plus/features/qiyas/helper/qiyas/helper/service_locator.dart';
// import '../../../../../../core/widgets/filter_bar_item.dart';
// import '../../../../../common/users_tasks/domain/enums/evidence_submission_status.dart';
// import '../../../../../common/users_tasks/presentation/ui/widgets/task_overview_widget.dart';
// import 'owner_task_details_page.dart';
//
// class OwnerTasksPage extends StatelessWidget {
//   OwnerTasksPage({super.key});
//   QiyasOwnerTasksCubit controller =
//       sl.registerSingletonIfAbsent(() => QiyasOwnerTasksCubit());
//   @override
//   Widget build(BuildContext context) {
//     controller.initCubit();
//     bool isTablet =
//         !kpIsPhoneLayout(context); // Check if pages
//     return BlocProvider<QiyasOwnerTasksCubit>.value(
//       value: controller,
//       child: Scaffold(
//         body: SafeArea(
//             child: Container(
//           padding: EdgeInsetsDirectional.only(
//               start: isTablet ? 30.sp : 15.sp, end: 15.sp),
//           child: Directionality(
//             textDirection: TextDirection.rtl,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 PaginationAppBar(
//                     screensTitles: ['قياس التحول الرقمي', 'المعايير المكلفه']),
//                 Column(
//                   children: [
//                     BlocBuilder<QiyasOwnerTasksCubit, QiyasTasksState>(
//                       buildWhen: (_, currentState) {
//                         print("curentState: $currentState");
//                         return currentState is QiyasTasksStatusUpdated;
//                       },
//                       builder: (context, state) {
//                         // Define custom order for statuses
//                         final List<EvidenceSubmissionStatus> orderedStatuses = [
//                           EvidenceSubmissionStatus.all,
//                           EvidenceSubmissionStatus.unCompleted,
//                           EvidenceSubmissionStatus.submitted,
//                           EvidenceSubmissionStatus.pending,
//                           EvidenceSubmissionStatus.approved,
//                           EvidenceSubmissionStatus.rejected,
//                           EvidenceSubmissionStatus.late,
//                         ];
//
//                         return SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: Row(
//                             spacing: 30.sp,
//                             children: [
//                               for (EvidenceSubmissionStatus status in orderedStatuses)
//                                 FilterBarItem(
//                                   isSelected: status == controller.selectedStatus,
//                                   title: status.value,
//                                   numberOfItems: controller.taskStatusMap[status]?.length ?? 0,
//                                   onTap: () {
//                                     controller.updateSelectedStatus(status);
//                                   },
//                                   color: status.color,
//                                 ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 15.sp),
//                 BlocBuilder<QiyasOwnerTasksCubit, QiyasTasksState>(
//                   buildWhen: (_, currentState) {
//                     print("curentState: $currentState");
//                     return currentState is QiyasTasksStatusUpdated;
//                   },
//                   builder: (context, state) {
//                     return Expanded(
//                         child: GridView.builder(
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: CrossAxisCountHelper
//                             .getCrossAxisCountForDefaultTablet2(context),
//                         mainAxisExtent: 175.sp,
//                         mainAxisSpacing: 10.sp,
//                         crossAxisSpacing: 10.sp,
//                       ),
//                       itemCount: controller
//                               .taskStatusMap[controller.selectedStatus]
//                               ?.length ??
//                           0,
//                       itemBuilder: (BuildContext context, int index) {
//                         return InkWell(
//                           splashColor: Colors.transparent,
//                           hoverColor: Colors.transparent,
//                           onTap: () {
//                             controller.selectTask(controller.taskStatusMap[
//                                 controller.selectedStatus]![index]);
//
//                             Navigator.push(context,
//                                 MaterialPageRoute(builder: (_) {
//                               return OwnerTaskDetailsPage();
//                             }));
//                           },
//                           child: TaskOverviewWidget(
//                             taskOverview: controller.taskStatusMap[
//                                 controller.selectedStatus]![index],
//                           ),
//                         );
//                       },
//                     ));
//                   },
//                 )
//               ],
//             ),
//           ),
//         )),
//       ),
//     );
//   }
// }

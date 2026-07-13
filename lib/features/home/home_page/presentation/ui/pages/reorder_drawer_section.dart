// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:demo_app/core/theme/app_colors.dart';
// import 'package:demo_app/features/skeleton/app_drawer/presentation/controller/drawer_controller.dart';
// import 'package:demo_app/features/skeleton/roles_module/domain/enums/modules_enum.dart';
//
// import 'package:demo_app/core/theme/app_text_styles.dart';
//
// /// Widget that displays a reorderable list of drawer modules
// /// allowing users to customize the order of drawer items
// class ReorderableDrawerSection extends StatefulWidget {
//   const ReorderableDrawerSection({super.key});
//
//   @override
//   State<ReorderableDrawerSection> createState() => _ReorderableDrawerSectionState();
// }
//
// class _ReorderableDrawerSectionState extends State<ReorderableDrawerSection> {
//   late AppDrawerController drawerController;
//   late List<Modules> localModules;
//   bool hasChanges = false;
//
//   @override
//   void initState() {
//     super.initState();
//     drawerController = Get.find<AppDrawerController>();
//     // Create a copy of the modules to work with
//     localModules = List<Modules>.from(drawerController.allowedDrawerModules);
//   }
//
//   void _onReorder(int oldIndex, int newIndex) {
//     setState(() {
//       // Adjust newIndex if moving down the list
//       if (newIndex > oldIndex) {
//         newIndex -= 1;
//       }
//
//       // Move the item
//       final item = localModules.removeAt(oldIndex);
//       localModules.insert(newIndex, item);
//       hasChanges = true;
//     });
//   }
//
//   void _saveOrder() {
//     drawerController.saveCustomOrder(localModules);
//     setState(() {
//       hasChanges = false;
//     });
//
//     Get.snackbar(
//       'Success'.tr,
//       'Drawer order saved successfully'.tr,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: AppColors.primary,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 2),
//     );
//   }
//
//   void _resetOrder() {
//     setState(() {
//       drawerController.resetToDefaultOrder();
//       localModules = List<Modules>.from(drawerController.allowedDrawerModules);
//       hasChanges = false;
//     });
//
//     Get.snackbar(
//       'Reset'.tr,
//       'Drawer order reset to default'.tr,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: AppColors.primary,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 2),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
//
//     return Container(
//       padding: EdgeInsets.all(isTablet ? 20.sp : 15.sp),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.inversePrimary,
//         borderRadius: BorderRadius.circular(12.sp),
//         border: Border.all(color: AppColors.primary.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Drawer Layout'.tr,
//                 style: AppTextStyles.font16BlackRegularCairo.copyWith(
//                   fontWeight: FontWeight.bold,
//                   fontSize: isTablet ? 18.sp : 16.sp,
//                 ),
//               ),
//               Row(
//                 spacing: 10.sp,
//                 children: [
//                   // Reset button
//                   InkWell(
//                     onTap: _resetOrder,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12.sp,
//                         vertical: 8.sp,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(6.sp),
//                       ),
//                       child: Row(
//                         spacing: 5.sp,
//                         children: [
//                           Icon(
//                             Icons.refresh,
//                             size: 16.sp,
//                             color: Colors.black87,
//                           ),
//                           Text(
//                             'Reset'.tr,
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // Save button
//                   if (hasChanges)
//                     InkWell(
//                       onTap: _saveOrder,
//                       child: Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 12.sp,
//                           vertical: 8.sp,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary,
//                           borderRadius: BorderRadius.circular(6.sp),
//                         ),
//                         child: Row(
//                           spacing: 5.sp,
//                           children: [
//                             Icon(
//                               Icons.save,
//                               size: 16.sp,
//                               color: Colors.white,
//                             ),
//                             Text(
//                               'Save Order'.tr,
//                               style: TextStyle(
//                                 fontSize: 12.sp,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//
//           SizedBox(height: 15.sp),
//
//           // Instructions
//           Container(
//             padding: EdgeInsets.all(10.sp),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8.sp),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.info_outline,
//                   size: 16.sp,
//                   color: AppColors.primary,
//                 ),
//                 SizedBox(width: 8.sp),
//                 Expanded(
//                   child: Text(
//                     'Long press and drag to reorder drawer items'.tr,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: 15.sp),
//
//           // Reorderable List
//           Container(
//             constraints: BoxConstraints(
//               maxHeight: 400.sp,
//             ),
//             child: ReorderableListView.builder(
//               shrinkWrap: true,
//               itemCount: localModules.length,
//               onReorder: _onReorder,
//               proxyDecorator: (child, index, animation) {
//                 return AnimatedBuilder(
//                   animation: animation,
//                   builder: (context, child) {
//                     return Material(
//                       elevation: 8,
//                       color: Colors.transparent,
//                       borderRadius: BorderRadius.circular(8.sp),
//                       child: child,
//                     );
//                   },
//                   child: child,
//                 );
//               },
//               itemBuilder: (context, index) {
//                 final module = localModules[index];
//                 return _buildModuleItem(
//                   module: module,
//                   index: index,
//                   isTablet: isTablet,
//                   key: ValueKey(module),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildModuleItem({
//     required Modules module,
//     required int index,
//     required bool isTablet,
//     required Key key,
//   }) {
//     return Container(
//       key: key,
//       margin: EdgeInsets.only(bottom: 8.sp),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.background,
//         borderRadius: BorderRadius.circular(8.sp),
//         border: Border.all(
//           color: AppColors.primary.withOpacity(0.2),
//         ),
//       ),
//       child: ListTile(
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: 12.sp,
//           vertical: 8.sp,
//         ),
//         leading: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Drag handle
//             Icon(
//               Icons.drag_indicator,
//               color: AppColors.primary,
//               size: 20.sp,
//             ),
//             SizedBox(width: 8.sp),
//             // Module icon
//             SvgPicture.asset(
//               module.iconPath,
//               width: isTablet ? 24.sp : 20.sp,
//               height: isTablet ? 24.sp : 20.sp,
//               color: AppColors.primary,
//             ),
//           ],
//         ),
//         title: Text(
//           module.getModuleName.tr,
//           style: AppTextStyles.font14BlackRegularCairo,
//         ),
//         trailing: Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: 8.sp,
//             vertical: 4.sp,
//           ),
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(4.sp),
//           ),
//           child: Text(
//             '${index + 1}',
//             style: TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.bold,
//               color: AppColors.primary,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
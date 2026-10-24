import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/layout/custom_responsive.dart';

import 'package:knowticed_plus/core/theme/toggle_control.dart';
import 'package:knowticed_plus/features/inventory/data/repository/product_repository_impl.dart';
import 'package:knowticed_plus/features/inventory/presentation/controller/product_cubit.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/master_page_toggle.dart';

GlobalKey<NavigatorState> inventoryNavKey = GlobalKey<NavigatorState>();

class InventoryResponsivePage extends StatelessWidget {
  InventoryResponsivePage({super.key});
  final ThemeAndLocalizationsCubit themeCubit = Get.put(ThemeAndLocalizationsCubit());

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => ProductCubit(
                ProductRepositoryImpl(FirebaseFirestore.instance))),
        BlocProvider.value(value: themeCubit), // share
      ],
      child: ResponsiveHelper(
          mobileWidget: Navigator(
            key: inventoryNavKey,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) {
                  return InventoryManagement();
                },
              );
            },
          ),
          tabletWidget: Navigator(
            key: inventoryNavKey,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) {
                  return InventoryManagement();
                },
              );
            },
          )),
    );
  }
}

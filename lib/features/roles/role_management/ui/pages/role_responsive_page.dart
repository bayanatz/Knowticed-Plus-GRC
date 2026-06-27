import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_app/features/roles/role_management/ui/pages/role_screen.dart';

import 'package:demo_app/features/roles/core_widgets/main_widget/responsive_helper.dart';
import 'package:demo_app/features/roles/account_status/controller/account_status_cubit.dart';
import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';
import 'package:demo_app/features/roles/user_management/controller/user_management_cubit.dart';


RoleCubit roleCubit = RoleCubit();
AccountStatusCubit _accountStatusCubit = AccountStatusCubit();
UserManagementAccessCubit _userManagementCubit = UserManagementAccessCubit();

class RoleResponsivePage extends StatelessWidget {
  const RoleResponsivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountStatusCubit>.value(
      value: _accountStatusCubit,
      child: BlocProvider<UserManagementAccessCubit>.value(
        value: _userManagementCubit,
        child: BlocProvider<RoleCubit>.value(
          value: roleCubit,
          child: ResponsiveHelper(
              mobileWidget: RoleScreen(),
              tabletWidget: Navigator(
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (context) {
                      return RoleScreen();
                    },
                  );
                },
              )),
        ),
      ),
    );
  }
}

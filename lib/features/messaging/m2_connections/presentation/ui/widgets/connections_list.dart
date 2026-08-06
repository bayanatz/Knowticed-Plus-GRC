/// Module: messaging / connections / presentation/ui/widgets/connections_list.dart
/// ************************* FILE INFO *************************** ///
/// File Name: connections_list.dart
/// Purpose: Connections list — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 1/9/2024
// By: Youssef Ashraf, Nada Mohammed
// Last update: 18/9/2024
// Objectives: This file is responsible for providing the community chats list used in the community feature.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/features/messaging/m2_connections/presentation/controller/connections_controller.dart';

import 'package:grc_module/core/enums/message_module/message_types.dart';
import '../../../domain/entities/single_connection_entity.dart';
import './connection_tile.dart';
import './connectionless_tile.dart';

class ConnectionsList extends StatelessWidget {
  final bool seeAll;

  const ConnectionsList({
    this.seeAll = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionsCubit, ConnectionsState>(
      builder: (context, state) {
        final controller = context.read<ConnectionsCubit>();
        List<SingleConnectionEntity> filteredList = controller.filteredConnections;

        // ✅ When seeAll=false (in "All" tab), show only 3
        // When seeAll=true (in "Direct Messages" tab OR after clicking See More), show all
        final itemCount = seeAll
            ? filteredList.length
            : filteredList.length.clamp(0, 3);

        return ListView.separated(
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
          shrinkWrap: true,
          itemCount: itemCount,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            SingleConnectionEntity connection = filteredList[index];
            return connection.messageType != MessageTypes.none
                ? ConnectionTile(connection: connection)
                : ConnectionlessTile(chatModel: connection);
          },
        );
      },
    );
  }
}
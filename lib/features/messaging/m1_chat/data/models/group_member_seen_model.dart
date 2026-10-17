/// Module: messaging / chat / data/models/group_member_seen_model.dart
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMemberSeenModel {
  String memberId;
  Timestamp seenTime;

  GroupMemberSeenModel({
    required this.memberId,
    required this.seenTime,
  });

  static const String kMemberId = "Member_Id";
  static const String kSeenTime = "Seen_Time";

  Map<String, Object> toMap() {
    return {
      kMemberId: memberId,
      kSeenTime: seenTime,
    };
  }

  static GroupMemberSeenModel fromMap(Map<String, dynamic> map) {
    return GroupMemberSeenModel(
      memberId: map[kMemberId],
      seenTime: map[kSeenTime],
    );
  }
}

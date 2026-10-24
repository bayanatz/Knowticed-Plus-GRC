/// Module: knowledge_hub/data/data_source/remote_data_source
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_firebase_services.dart
/// Description: Firebase services for Approvals screen - consolidated service
/// Author: Amr Mesbah
/// Created at: 26/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/data/models/kh_firestore_keys.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data_json.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_system_log.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/approval_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';

part 'approvals_firebase_services.part.1.dart';
part 'approvals_firebase_services.part.2.dart';
part 'approvals_firebase_services.part.1/approvals_services_part1_methods.dart';
part 'approvals_firebase_services.part.2/approvals_services_part2_methods.dart';

/// The documents that could be read, plus how many could not
/// (KH-APPROVE-10 — "show a count of documents that could not be read").
class KnowledgeFetchResult {
  const KnowledgeFetchResult(this.documents, this.unreadable);
  final List<CreateKnowledgeModel> documents;
  final int unreadable;
}

class ApprovalsFirebaseServices extends ApprovalsFirebaseServicesBase
    with
        ApprovalsServicesPart1,
        ApprovalsServicesPart1Methods2,
        ApprovalsServicesPart2,
        ApprovalsServicesPart2Methods2 {}

/// The Firebase handles shared by the approvals service mixins.
abstract class ApprovalsFirebaseServicesBase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;
}

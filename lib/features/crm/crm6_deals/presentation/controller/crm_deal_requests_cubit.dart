// ****************** FILE INFO ******************
// File Name: crm_deal_requests_cubit.dart
// Purpose: Watches persisted quote approval requests for one client deal.
// Author: Mohand Adel
// Created At: 31/08/2026

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_quote_record_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/domain/interfaces/crm_client_quotes_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_deal_requests_state.dart';

class CrmDealRequestsCubit extends Cubit<CrmDealRequestsState> {
  final CrmClientQuotesBaseRepository _repository;
  StreamSubscription<Either<Failure, List<CrmClientQuoteRecordModel>>>?
      _subscription;

  CrmDealRequestsCubit({CrmClientQuotesBaseRepository? repository})
      : _repository = repository ?? Get.find<CrmClientQuotesBaseRepository>(),
        super(const CrmDealRequestsState());

  void load({required String clientId, required String dealId}) {
    emit(state.copyWith(operation: CrmDealRequestsOperation.loading));
    _subscription?.cancel();
    _subscription = _repository
        .watchDealQuoteRequests(clientId: clientId, dealId: dealId)
        .listen((Either<Failure, List<CrmClientQuoteRecordModel>> result) {
      result.fold(
        (Failure failure) {
          if (!isClosed) {
            emit(state.copyWith(
              operation: CrmDealRequestsOperation.error,
              errorMessage: failure.errMessage,
            ));
          }
        },
        (List<CrmClientQuoteRecordModel> quotes) {
          final List<CrmClientQuoteRecordModel> requests = quotes
              .where((CrmClientQuoteRecordModel quote) =>
                  quote.status == 'pending' ||
                  quote.status == 'approved' ||
                  quote.status == 'reject')
              .toList();
          if (!isClosed) {
            emit(state.copyWith(
              operation: CrmDealRequestsOperation.idle,
              requests: requests,
              errorMessage: '',
            ));
          }
        },
      );
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

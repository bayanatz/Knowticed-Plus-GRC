/// Module: services / sv3_create_master_services / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: master_upload_state.dart
/// Purpose: State classes for MasterUploadCubit (bulk service + service-request
///          Excel upload flow).
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: equatable
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Initial version — extracted from
///     master_upload.dart / upload_details.dart (fix items 4/5).
library;

import 'package:equatable/equatable.dart';

abstract class MasterUploadState extends Equatable {
  const MasterUploadState();

  @override
  List<Object?> get props => [];
}

class MasterUploadInitial extends MasterUploadState {}

/// Emitted while a file is being picked/parsed or while permissions are
/// being requested.
class MasterUploadLoading extends MasterUploadState {}

/// Emitted after a step's Excel file has been parsed successfully. The
/// parsed rows/errors are handed back via the Future returned by the
/// cubit's parse method — this state just signals "done, no error".
class MasterUploadParsed extends MasterUploadState {}

/// Emitted when picking/parsing/uploading fails.
class MasterUploadError extends MasterUploadState {
  final String message;

  const MasterUploadError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted once the Firebase upload (services + requests) completes.
class MasterUploadSubmitted extends MasterUploadState {
  final int success;
  final int failed;

  const MasterUploadSubmitted({required this.success, required this.failed});

  @override
  List<Object?> get props => [success, failed];
}

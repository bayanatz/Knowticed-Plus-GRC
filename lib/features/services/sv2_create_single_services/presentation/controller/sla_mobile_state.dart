/// Module: services / sv2_create_single_services / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: sla_mobile_state.dart
/// Purpose: State of the phone SLA step: idle, busy, published, draft saved
///          or failed. The page listens and shows the matching dialog.
/// Author: Knowticed Team
/// Created At: 02/07/2026
/// Revision History:
///   - 22/10/2026 (Amr Mesbah): moved here from
///     sv12_create_notification_mobile (Provider rule 18); published /
///     draft-saved / failed states.
library;

import 'package:equatable/equatable.dart';

abstract class SlaMobileState extends Equatable {
  const SlaMobileState();

  @override
  List<Object?> get props => [];
}

class SlaMobileIdle extends SlaMobileState {
  const SlaMobileIdle();
}

class SlaMobileBusy extends SlaMobileState {
  const SlaMobileBusy();
}

/// The service was created or updated.
class SlaMobilePublished extends SlaMobileState {
  /// True when an existing service was edited.
  final bool wasEdit;

  const SlaMobilePublished({required this.wasEdit});

  @override
  List<Object?> get props => [wasEdit];
}

/// "Save for later" stored the draft.
class SlaMobileDraftSaved extends SlaMobileState {
  const SlaMobileDraftSaved();
}

/// The save failed; nothing was lost (drafts and staged values are kept).
class SlaMobileFailed extends SlaMobileState {
  /// English detail for logs only — never shown to the user.
  final String message;

  const SlaMobileFailed(this.message);

  @override
  List<Object?> get props => [message];
}

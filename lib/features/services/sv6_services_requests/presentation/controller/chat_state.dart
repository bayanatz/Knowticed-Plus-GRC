/// Module: services / sv6_services_requests / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: chat_state.dart
/// Purpose: State for ChatCubit — the comment thread of one service request
///          (loading / loaded / error) plus a busy flag for a send, edit,
///          delete or upload in flight.
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:equatable/equatable.dart';
import 'package:knowticed_plus/features/services/data/repository/chat_repository_impl.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatMessageData> messages;
  final bool isBusy;

  const ChatLoaded({required this.messages, this.isBusy = false});

  ChatLoaded copyWith({List<ChatMessageData>? messages, bool? isBusy}) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isBusy: isBusy ?? this.isBusy,
    );
  }

  @override
  List<Object?> get props => [messages, isBusy];
}

/// What went wrong; the widget turns it into translated text.
enum ChatErrorType { load, send, upload, edit, delete, notAuthor }

class ChatError extends ChatState {
  final ChatErrorType type;

  const ChatError(this.type);

  @override
  List<Object?> get props => [type];
}

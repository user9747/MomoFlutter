part of 'message_bloc.dart';

abstract class MessageState extends Equatable {
  const MessageState();
}

class MessageInitial extends MessageState {
  @override
  List<Object> get props => [];
}

class BotMessage extends MessageState{

  final String messageText;

  BotMessage({this.messageText});

  @override
  List<Object> get props => [messageText];

}

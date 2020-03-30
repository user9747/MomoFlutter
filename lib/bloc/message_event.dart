part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();
}

class BotUttered extends MessageEvent{
  final String messageText;

  BotUttered({@required this.messageText}) : assert(messageText != null);

  @override
  List<Object> get props => [messageText];

}

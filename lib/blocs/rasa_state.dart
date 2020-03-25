import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class RasaState extends Equatable {
  const RasaState();

  @override
  List<Object> get props => [];
}

class RasaEmpty extends RasaState {
  final String bot_message = 'Lets start';
  @override
  List<Object> get props => [bot_message];
}


class BotMessage extends RasaState {
  final String bot_message;

  const BotMessage({@required this.bot_message}) : assert(bot_message != null);

  @override
  List<Object> get props => [bot_message];
}

class RasaError extends RasaState {}
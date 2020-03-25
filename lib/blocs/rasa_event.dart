import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class RasaEvent extends Equatable {
  const RasaEvent();
}

class UserUttered extends RasaEvent {
  final String message;

  const UserUttered({@required this.message}) : assert(message != null);

  @override
  List<Object> get props => [message];
}

class BotUttered extends RasaEvent {
  final String message;

  const BotUttered({@required this.message}) : assert(message != null);

  @override
  List<Object> get props => [message];
}
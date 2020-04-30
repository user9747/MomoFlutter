part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();
}

class RecievedMessage extends GameEvent{
  final String message;

  RecievedMessage({@required this.message}) : assert(message != null);
  @override
  List<Object> get props => null;

}

class StartISpyRules extends GameEvent{
  @override
  List<Object> get props => [];
}

class StartWordchainRules extends GameEvent{
  @override
  List<Object> get props => [];
}

class StartISpy extends GameEvent{
  @override
  List<Object> get props => [];
}

class StartWordchain extends GameEvent{
  @override
  List<Object> get props => [];
}

class GetSpeechGameEvent extends GameEvent{
  @override
  List<Object> get props => [];
}

class ResetGame extends GameEvent{
  @override
  List<Object> get props => [];
}

class TestEvent extends GameEvent{
  @override
  List<Object> get props => [];
}

class CorrectAnswer extends GameEvent{
  @override
  List<Object> get props => [];
}

class WrongAnswer extends GameEvent{
  @override
  List<Object> get props => [];
}

class MomoTalk extends GameEvent{
  @override
  List<Object> get props => [];
}

class MomoStopTalk extends GameEvent{
  @override
  List<Object> get props => [];
}

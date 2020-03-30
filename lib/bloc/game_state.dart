part of 'game_bloc.dart';

abstract class GameState extends Equatable {
  const GameState();
}

class GameInitial extends GameState {
  @override
  List<Object> get props => [];
}

class GameIdleChat extends GameState {
  @override
  List<Object> get props => [];
}

class ISpyRules extends GameState{
  @override
  List<Object> get props => [];
}

class WordchainRules extends GameState{
  @override
  List<Object> get props => [];
}

class ISpy extends GameState{
  @override
  List<Object> get props => [];
}

class WordChain extends GameState{
  @override
  List<Object> get props => [];
}

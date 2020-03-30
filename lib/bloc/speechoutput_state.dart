part of 'speechoutput_bloc.dart';

abstract class SpeechoutputState extends Equatable {
  const SpeechoutputState();
}

class SpeechReadyState extends SpeechoutputState{
  @override
  List<Object> get props => [];
}

class SpeakingState extends SpeechoutputState{
  @override
  List<Object> get props => [];
}

class SpeechCompletedState extends SpeechoutputState{
  @override
  List<Object> get props => [];
}

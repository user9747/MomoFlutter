part of 'speechoutput_bloc.dart';

abstract class SpeechoutputEvent extends Equatable {
  const SpeechoutputEvent();
}

class GenerateSpeechEvent extends SpeechoutputEvent{
  final String message;
  GenerateSpeechEvent({@required this.message}) : assert(message != null);
  @override
  List<Object> get props => [message];
}

class SpeechGenerationCompletedEvent extends SpeechoutputEvent{
  @override
  List<Object> get props => null;
}

class ResetSpeechEvent extends SpeechoutputEvent{
  @override
  List<Object> get props => [];
}

part of 'speechinput_bloc.dart';

abstract class SpeechinputEvent extends Equatable {
  const SpeechinputEvent();
}

class GetSpeechInput extends SpeechinputEvent {
  @override
  List<Object> get props => null;

}

class ResetSpeechInput extends SpeechinputEvent {
  @override
  List<Object> get props => null;

}

class TranslationCompleted extends SpeechinputEvent {
  final String result;

  TranslationCompleted({@required this.result}) : assert(result != null);

  @override
  List<Object> get props => null;
}

class ErrorEncountered extends SpeechinputEvent {
  final String errorMessage;

  ErrorEncountered({@required this.errorMessage}):assert(errorMessage != null);

  @override
  List<Object> get props => null;
}
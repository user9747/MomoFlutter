part of 'speechinput_bloc.dart';

abstract class SpeechinputState extends Equatable {
  const SpeechinputState();
}

class SpeechinputInitial extends SpeechinputState {
  @override
  List<Object> get props => [];
}

class SpeechProcessing extends SpeechinputState {
  @override
  List<Object> get props => [];
}

class TextGenerated extends SpeechinputState {
  final String transcript;

  TextGenerated({@required this.transcript}) : assert(transcript != null);

  @override
  List<Object> get props => [transcript];
}

class SpeechInputError extends SpeechinputState {
  final String errorMessage;

  SpeechInputError({@required this.errorMessage}): assert(errorMessage != null);

  @override
  List<Object> get props => null;
}

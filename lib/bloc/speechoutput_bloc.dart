import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';

part 'speechoutput_event.dart';
part 'speechoutput_state.dart';

class SpeechoutputBloc extends Bloc<SpeechoutputEvent, SpeechoutputState> {
  FlutterTts flutterTts;
  String language;

  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;

  @override
  SpeechoutputState get initialState => SpeechReadyState();

  SpeechoutputBloc(){
    flutterTts = FlutterTts();
    initLang();
    flutterTts.setStartHandler((){
      print("Playing");
    });
    flutterTts.setCompletionHandler((){
      print("Stopped");
    });
    flutterTts.setErrorHandler((msg){
      print("Error Encountered");
    });
    print("Speech output bloc setup complete");
  }

  void initLang() async {
    dynamic languages = await flutterTts.getLanguages;
    dynamic voices = await flutterTts.getVoices;
    if(languages != null){
      print("Following languages were found");
      print(languages);
      print("Following voices were found");
      print(voices);
      flutterTts.setLanguage("en-US");
    }
    else
      print("No lamguages found");
  }

  Future _speak(String message) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if(message != null && message.isNotEmpty){
      var result = await flutterTts.speak(message);
      return result;
    }
  }

  @override
  Stream<SpeechoutputState> mapEventToState(
    SpeechoutputEvent event,
  ) async* {
    if(event is GenerateSpeechEvent){
      yield SpeakingState();
      await _speak(event.message);
    }
    else if(event is SpeechGenerationCompletedEvent){
      yield SpeechCompletedState();
    }
    else if(event is ResetSpeechEvent){
      yield SpeechReadyState();
    }
  }
}

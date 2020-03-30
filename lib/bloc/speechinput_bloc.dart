import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

part 'speechinput_event.dart';
part 'speechinput_state.dart';

class SpeechinputBloc extends Bloc<SpeechinputEvent, SpeechinputState> {
  bool _hasSpeech = false;
  String prevWords = "";
  String prevError = "";
  String prevStatus = "";

  String currentLocale = "";

  final SpeechToText _speechToText = SpeechToText();
  @override
  SpeechinputState get initialState => SpeechinputInitial();

  SpeechinputBloc(){
    initSpeech();
  }

  Future<void> initSpeech() async {
    _hasSpeech = await _speechToText.initialize(
      onError: errorListener,
      onStatus: statusListener,
    );
    if(_hasSpeech){
      var sysLocale = await _speechToText.systemLocale();
      this.currentLocale = sysLocale.localeId;
    }
  }

  void startListening(){
    prevError = "";
    prevWords = "";

    _speechToText.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 10),
      localeId: currentLocale,
      cancelOnError: true,
      partialResults: false
    );
  }

  void resultListener(SpeechRecognitionResult result){
    if(result.finalResult){
      prevWords = result.recognizedWords;
      add(TranslationCompleted(result: prevWords));
    }
  }

  void errorListener(SpeechRecognitionError error){
    this.prevError = "${error.errorMsg} - ${error.permanent}";
    add(ErrorEncountered(errorMessage: prevError));
  }

  void statusListener(String status){
    this.prevStatus = status;
    print("New Status: $status");
    if(status == "notListening")
      add(ResetSpeechInput());
  }

  @override
  Stream<SpeechinputState> mapEventToState(
    SpeechinputEvent event,
  ) async* {
    if(event is TranslationCompleted){
      yield TextGenerated(transcript: event.result);
    }
    else if(event is GetSpeechInput){
      yield SpeechProcessing();
      startListening();
    }
    else if(event is ErrorEncountered){
      yield SpeechInputError(errorMessage: event.errorMessage);
    }
    else if(event is ResetSpeechInput){
      prevWords = "";
      prevError = "";
      yield SpeechinputInitial();
    }
  }
}

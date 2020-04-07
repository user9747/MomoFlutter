import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:momo/bloc/message_bloc.dart';
import 'package:momo/bloc/speechinput_bloc.dart';
import 'speechoutput_bloc.dart';
import 'detectimage_bloc_exports.dart';
import 'package:socket_io_flutter/socket_io_flutter.dart';

import '../conf.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  SpeechinputBloc speechinputBloc;
  MessageBloc messageBloc;
  SpeechoutputBloc speechoutputBloc;
  DetectImageBloc detectimageBloc;

  String uri = Conf.uri;
  SocketIOManager manager;
  SocketIO socket;

  List<String> botMessages = [];

  @override
  GameState get initialState => GameIdleChat();

  GameBloc({this.messageBloc,this.speechinputBloc}){
    speechoutputBloc = SpeechoutputBloc();
    detectimageBloc = DetectImageBloc();
    speechoutputBloc.listen(onSpeechGeneration);
    speechinputBloc.listen(onSpeechRecognition);
    detectimageBloc.listen(onImageDetection);
    manager = SocketIOManager();
    initSocket();
  }
    
  initSocket() async {
    socket = await manager.createInstance(SocketOptions(
        //Socket IO server URI
        uri,
        //Enable or disable platform channel logging
        enableLogging: false,
        transports: [
          Transports.WEB_SOCKET /*, Transports.POLLING*/
        ] //Enable required transport
    ));
    socket.onConnect((data) {
      print("connected...");
      print(data);
    });
    socket.onConnectError(print);
    socket.onConnectTimeout(print);
    socket.onError(print);
    socket.onDisconnect(print);
    socket.on("bot_uttered", (data) {
      print(data);
      recieveMessage(data["text"]);
    });
    socket.connect();

  }

  void recieveMessage(String text){
    this.add(RecievedMessage(message: text));
  }

  @override
  Stream<GameState> mapEventToState(
    GameEvent event,
  ) async* {
    //Event for testing purposes.
    if(event is TestEvent){
      add(RecievedMessage(message: '/takephoto'));
    }
    if(state is GameIdleChat){
      if (event is RecievedMessage){
        print('Game Bloc Recieved reply');
        if(event.message.startsWith('/')){
          handleServerCommand(event.message);
        }
        else if(speechoutputBloc.state is SpeechReadyState){
          print("First Message");
          speechoutputBloc.add(GenerateSpeechEvent(message: event.message));
          messageBloc.add(BotUttered(messageText: event.message));
        }
        else{
          botMessages.add(event.message);
        }
      }
      if(event is StartWordchain){
        yield WordChain();
      }
    }
    if(state is WordChain){
      if(event is RecievedMessage){
        if(event.message.startsWith('/')){
          handleServerCommand(event.message);
        }
        else if(speechoutputBloc.state is SpeechReadyState){
          print("First Message");
          speechoutputBloc.add(GenerateSpeechEvent(message: event.message));
          messageBloc.add(BotUttered(messageText: event.message));
        }
        else{
          botMessages.add(event.message);
        }
      }
    }
  }

  void sendMessage(String msg) {
    print("sending message ...");
    socket.emit("user_uttered", [
      {'message': msg}
    ]);
    print("Message emitted ...");
  }

  void handleServerCommand(String message){
    switch (message) {
      case '/setgame[Word chain]':
        add(StartWordchain());
        break;
      case '/takephoto':
        detectimageBloc.add(CaptureImage());
        break;
      default:
    }
  }

  void onSpeechRecognition(SpeechinputState speechinputState ) {
    if(speechinputState is TextGenerated){
      if(state is GameIdleChat)
        sendMessage(speechinputState.transcript);
      else if(state is WordChain){
        if(speechinputState.transcript.contains("play"))
          sendMessage(speechinputState.transcript);
        else{
          var word = speechinputState.transcript.toLowerCase();
          sendMessage("/inform_word{\"userword\":\"$word\"}");
        }
      }
    }
  }

  void onSpeechGeneration(SpeechoutputState speechoutputState){
    if(speechoutputState is SpeechCompletedState){
      if(botMessages.isNotEmpty){
        speechoutputBloc.add(GenerateSpeechEvent(message: botMessages.first));
        messageBloc.add(BotUttered(messageText: botMessages.first));
        botMessages.removeAt(0);
      }
      else{
        speechoutputBloc.add(ResetSpeechEvent());
        speechinputBloc.add(ResetSpeechInput());
      }
    }
  }
  void onImageDetection(DetectImageState detectimageState){
    if(detectimageState is ImageDetected){
      print(detectimageState.image);
      sendMessage(detectimageState.image);
    }
  }
  void dispose(){
    speechoutputBloc.close();
    manager.clearInstance(socket);
  }
}

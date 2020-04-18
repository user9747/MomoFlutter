import 'dart:async';
import 'dart:convert';

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

  String word;
  List<String> answers;

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
    else if (event is RecievedMessage){
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
    else if(state is GameIdleChat){
      if(event is StartWordchain){
        yield WordChain();
      }
      if(event is StartISpy){
        yield ISpy();
      }
    }
    else if(state is WordChain){
      if(event is CorrectAnswer){
        if(speechoutputBloc.state is SpeechReadyState){
          print("First Message");
          speechoutputBloc.add(GenerateSpeechEvent(message: 'Wow that\'s correct. My next word is'));
          messageBloc.add(BotUttered(messageText: 'Wow that\'s correct. My next word is'));
        }
        else{
          botMessages.add('Wow that\'s correct. My next word is');
        }
        sendMessage("/inform_word{\"userword\":\"$word\"}");
      }
      if(event is WrongAnswer){
        if(speechoutputBloc.state is SpeechReadyState){
          print("First Message");
          speechoutputBloc.add(GenerateSpeechEvent(message: 'I am sorry but that is not a correct answer'));
          messageBloc.add(BotUttered(messageText: 'I am sorry but that is not a correct answer'));
        }
        else{
          botMessages.add('I am sorry but that is not a correct answer');
        }
        botMessages.add('Try again, my word was ${this.word}');
      }
    }
    else if (state is ISpy){

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
      case '/setgame[word chain]':
        add(StartWordchain());
        break;
      case '/setgame[I spy]':
        add(StartISpy());
        break;
      case '/takephoto':
        detectimageBloc.add(CaptureImage());
        break;
      default:
    }
    if(message.startsWith('/word')){
      this.word = message.substring(6);
      this.word = this.word.replaceAll("}", " ").trimRight();
      print(this.word);
      this.add(RecievedMessage(message: this.word));
    }
    if(message.startsWith('/answer')){
      message = message.substring(8);
      this.answers = message.split(',');
      answers.removeLast();
      print(this.answers);
    }
  }

  void onSpeechRecognition(SpeechinputState speechinputState ) {
    if(speechinputState is TextGenerated){
      if(state is WordChain){
        if(speechinputState.transcript.contains(" ")){
          sendMessage(speechinputState.transcript);
        }
        else if(this.answers.contains(speechinputState.transcript.toLowerCase())){
          this.add(CorrectAnswer());
        }
        else{
          this.add(WrongAnswer());
        }
      }
      else
        sendMessage(speechinputState.transcript);
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
      print("detected image\n");
      print(detectimageState.image);
      var image = jsonDecode(detectimageState.image);
      if(image["data"].isEmpty){
        print("No objects detected");
        add(RecievedMessage(message: "I'm Sorry but I could not find anything, could you try again pwees"));
      }
      else{
        var imgText = detectimageState.image.replaceAll("\"", "'");
        imgText = imgText.replaceAll(new RegExp("\n|\t| "), '');
        print("/inform_object_details{\"object_list\":\"$imgText\"}");
        sendMessage("/inform_object_details{\"object_list\":\"$imgText\"}");
      }
      //sendMessage(detectimageState.image);
    }
  }
  void dispose(){
    speechoutputBloc.close();
    manager.clearInstance(socket);
  }
}
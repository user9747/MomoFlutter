import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:momo/bloc/message_bloc.dart';
import 'package:momo/bloc/speechinput_bloc.dart';
import 'package:socket_io_flutter/socket_io_flutter.dart';

import '../conf.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  SpeechinputBloc speechinputBloc;
  MessageBloc messageBloc;

  String uri = Conf.uri;
  SocketIOManager manager;
  SocketIO socket;

  @override
  GameState get initialState => GameInitial();

  GameBloc({this.messageBloc,this.speechinputBloc}){
    speechinputBloc.listen(onSpeechRecognition);
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
    print('Inside mapEventtostate of GameBloc');
    if (event is RecievedMessage){
      print('Game Bloc Recieved reply');
      messageBloc.add(BotUttered(messageText: event.message));
      speechinputBloc.add(ResetSpeechInput());
    }
  }

  void sendMessage(String msg) {
    print("sending message ...");
    socket.emit("user_uttered", [
      {'message': msg}
    ]);
    print("Message emitted ...");
  }

  void onSpeechRecognition(SpeechinputState speechinputState ) {
    if(speechinputState is TextGenerated){
      sendMessage(speechinputState.transcript);
    }
  }
  void dispose(){
    manager.clearInstance(socket);
  }
}

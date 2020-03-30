import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './bloc/bloc_exports.dart';
// import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TestApp(),
    );
  }
}

class TestApp extends StatefulWidget {
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  final speechInputBloc = SpeechinputBloc();
  final messageBloc = MessageBloc();
  GameBloc gameBloc;

  @override
  void initState() {
    super.initState();
    gameBloc = GameBloc(messageBloc: messageBloc,speechinputBloc: speechInputBloc);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: Text('Momo'),
          ),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  BlocBuilder(
                    bloc: messageBloc,
                    builder: (context, state) {
                      if (state is BotMessage) {
                        return Center(child: Text(state.messageText));
                      } else if (state is MessageInitial) {
                        return Center(child: Text("Ready for action"));
                      }
                      return Text('sss');
                    },
                  ),
                  BlocBuilder(
                    bloc: speechInputBloc,
                    builder: (context,state){
                      if(state is SpeechinputInitial){
                        return RaisedButton(
                          onPressed: (){
                            speechInputBloc.add(GetSpeechInput());
                          },
                          child: Text('Start Speaking'),
                        );
                      }
                      else if(state is SpeechProcessing){
                        return RaisedButton(
                          onPressed: null,
                          child: Text('Processing...'),
                        );
                      }
                      else if(state is SpeechInputError){
                        return Column(
                          children: <Widget>[
                            Text(state.errorMessage),
                            RaisedButton(
                              onPressed: (){
                                speechInputBloc.add(GetSpeechInput());
                              },
                              child: Text('Start Speaking'),
                            ),
                          ],
                        );
                      }
                      else if (state is TextGenerated){
                        return Column(
                          children: <Widget>[
                            Text('Waiting for Server Response'),
                            Text('Your input was'),
                            Text(state.transcript)
                          ],
                        );
                      }
                      return Text('unhandled state ${state.runtimeType}');
                    }
                  )
                ],
              ),
            ),
          ),
        );
  }

  @override
  void dispose(){
    super.dispose();
    gameBloc.dispose();
    gameBloc.close();
    speechInputBloc.close();
    messageBloc.close();
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './bloc/bloc_exports.dart';
import './bloc/detectimage_bloc_exports.dart';
import 'custom_ui.dart';
// import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TestApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TestApp extends StatefulWidget {
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> with SingleTickerProviderStateMixin {
  final speechInputBloc = SpeechinputBloc();
  final messageBloc = MessageBloc();
  final detectImageBloc = DetectImageBloc();
  AnimationController _animationController;
  var spinkit;
  GameBloc gameBloc;
  bool isp = false;

  @override
  void initState() {
    super.initState();
    gameBloc =
        GameBloc(messageBloc: messageBloc, speechinputBloc: speechInputBloc);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    spinkit = SpinKitRipple(
      color: Colors.deepPurpleAccent,
      size: 150.0,
      controller: _animationController,
    );
    // _animationController.forward();
    // _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.5,
        brightness: Brightness.light,
        title: Text(
          'Hello!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              return helpDialog(context);
            },
            icon: Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 30,
            ),
            color: Colors.grey.shade100,
          ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(246, 246, 246, 1),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // spinkit,
              BlocBuilder(
                  bloc: gameBloc,
                  builder: (context, state) {
                    if (state is MomoTalking) {
                      _animationController.repeat();
                    } else if (state is MomoSilent) {
                      _animationController.forward();
                    }
                    return spinkit;
                  }),
              FlatButton(
                  child: Text('Take Photo'),
                  onPressed: () {
                    gameBloc.add(TestEvent());
                  },
                  textColor: Colors.white,
                  color: Colors.deepPurpleAccent),

              BlocBuilder(
                bloc: messageBloc,
                builder: (context, state) {
                  if (state is BotMessage) {
                    return Center(child: Text(state.messageText));
                  } else if (state is MessageInitial) {
                    return Center(
                        child: Text("Say Hello Momo to Start a conversation"));
                  }
                  return Text('Say Hello Momo to Start a conversation');
                },
              ),
              BlocBuilder(
                  bloc: speechInputBloc,
                  builder: (context, state) {
                    if (state is SpeechinputInitial) {
                      return (InkWell(
                        child: MyCard(child: Text('Tap to Talk')),
                        onTap: () {
                          speechInputBloc.add(GetSpeechInput());
                        },
                      ));
                    } else if (state is SpeechProcessing) {
                      return MyCard(child: Text('Listening!'));
                    } else if (state is SpeechInputError) {
                      return Column(
                        children: <Widget>[
                          Text(state.errorMessage),
                          InkWell(
                            child: MyCard(child: Text('Tap to Talk')),
                            onTap: () {
                              speechInputBloc.add(GetSpeechInput());
                            },
                          ),
                        ],
                      );
                    } else if (state is TextGenerated) {
                      return Column(
                        children: <Widget>[
                          Text('Waiting for Server Response'),
                          Text('Your input was'),
                          Text(state.transcript)
                        ],
                      );
                    }
                    return Text('unhandled state ${state.runtimeType}');
                  })
            ],
          ),
        ),
      ),
    );
  }

  helpDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            child: Text('''Help                        



                data ivdey
            
             ezhuthanam 
             
             
             
                  poda gopala
             
             
             ''',style: TextStyle(color: Colors.deepPurpleAccent),),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
    gameBloc.dispose();
    gameBloc.close();
    speechInputBloc.close();
    messageBloc.close();
    detectImageBloc.close();
    _animationController.dispose();
  }
}

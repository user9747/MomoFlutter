import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './blocs/blocs.dart';
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
  final _controller = TextEditingController();
  RasaBloc bloc = RasaBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: Text('Momo'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                BlocBuilder(
                  bloc: bloc,
                  builder: (context, state) {
                    if (state is BotMessage) {
                      return Center(child: Text(state.bot_message));
                    } else if (state is RasaEmpty) {
                      return Center(child: Text(state.bot_message));
                    }
                    return Text('sss');
                  },
                ),
                TextFormField(
                  controller: _controller,
                ),
                RaisedButton(
                  onPressed: () {
                    print(_controller.text);
                    bloc.add(UserUttered(message: _controller.text));
                    setState(() {
                      _controller.text = '';
                    });
                  },
                  child: Text('send'),
                ),
                RaisedButton(
                  onPressed: () => print('diconnect but not'),
                  child: Text('reconnect'),
                ),
              ],
            ),
          ),
        );
  }
}


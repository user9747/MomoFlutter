import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import './counter_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CounterBloc bloc = CounterBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(     
        title: Text(widget.title),
      ),
      body: Center(      
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            BlocBuilder(
              bloc: bloc,
              builder: (context, _counter) {
                return Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.display1,
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              bloc.add(CounterEvent.increment);
            },
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () {
              bloc.add(CounterEvent.decrement);
            },
            tooltip: 'Increment',
            child: Icon(Icons.remove),
          )
        ],
      ),
      
    );
  }
}

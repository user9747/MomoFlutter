import 'package:bloc/bloc.dart';
import 'package:socket_io_flutter/socket_io_flutter.dart';
import './blocs.dart';
import '../conf.dart';

class RasaBloc extends Bloc<RasaEvent, RasaState> {
  static String URI = Conf.URI;
  SocketIOManager manager;
  SocketIO socket;

  @override
  RasaState get initialState => RasaEmpty();

  RasaBloc() {
    manager = SocketIOManager();
    initSocket();
  }

  initSocket() async {
    socket = await manager.createInstance(SocketOptions(
        //Socket IO server URI
        URI,
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
      add(BotUttered(message: data['text'] as String));
    });
    socket.connect();
  }

  sendMessage(String msg) {
    print("sending message ...");
    socket.emit("user_uttered", [
      {'message': msg}
    ]);
    print("Message emitted ...");
  }

  @override
  Stream<RasaState> mapEventToState(RasaEvent event) async* {
    if (event is UserUttered) {
      sendMessage(event.message);
    }
    if (event is BotUttered) {
      yield BotMessage(bot_message: event.message);
    }
  }
}

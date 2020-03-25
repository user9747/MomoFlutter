import 'package:socket_io_flutter/socket_io_flutter.dart';
import './rasa_bloc.dart';

class RasaSocket {
  static String URI = "http://192.168.43.7:5005/";
  SocketIOManager manager;
  bool _isProbablyConnected = false;
  SocketIO socket;
  String bot_response = 'empty';

  static final RasaSocket rasa_socket_repo = RasaSocket();

  RasaSocket() {
    manager = SocketIOManager();
    initSocket();
  }

  static RasaSocket get() {
    return rasa_socket_repo;
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
      pprint(data);
      
    });
    socket.connect();
  }

  pprint(data) {
    print(data['text']);
    bot_response = data['text'] as String;
  }

  sendMessage(String msg) {
    print("sending message ...");
    socket.emit("user_uttered", [
      {'message': msg}
    ]);
    print("Message emitted ...");
  }

  disconnect() async {
    await manager.clearInstance(socket);
    initSocket();
  }
}

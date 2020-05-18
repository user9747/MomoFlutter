import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import './detectimage_bloc_exports.dart';
import '../conf.dart';

class DetectImageBloc extends Bloc<DetectImageEvent, DetectImageState> {
  String url;
  @override
  DetectImageState get initialState => Ready();

  DetectImageBloc() {
    // url = 'https://postman-echo.com/post';
    url = Conf.flask_uri;
    wakeUpHeroku(url);
  }
  wakeUpHeroku(String url) async{
    var response = await http.get(url);
    print(response);
  }

  @override
  Stream<DetectImageState> mapEventToState(DetectImageEvent event) async* {
    if (event is CaptureImage) {
      yield CapturingImage();
      print('Capturing image...');

      String image64 = await takePhoto();
      yield ImageCaptured();
      print('Image Captured');

      add(SendImage(image: image64));
    }

    if (event is SendImage) {
      print('Sending image..');
      var response =
          await http.post(url, body: {'img': event.image});
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      yield ImageDetected(image: response.body);
      yield Ready();
    }
  }

  Future<String> takePhoto() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    Future<void> _initializeControllerFuture;

    CameraController _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    try {
      await _initializeControllerFuture;
      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );
      print(path);
      await _controller.takePicture(path);
      List bytes = File(path).readAsBytesSync();
      String img64 = base64.encode(bytes);
      log(img64);
      return img64;
    } catch (e) {
      print(e);
      return 'err';
    }
    // return 'err2';
  }

}

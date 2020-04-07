import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class DetectImageState extends Equatable {
  const DetectImageState();

  @override
  List<Object> get props => [];
}

class Ready extends DetectImageState {
  @override
  List<Object> get props => [];
}

class CapturingImage extends DetectImageState {
  @override
  List<Object> get props => [];
}

class ImageCaptured extends DetectImageState {
  @override
  List<Object> get props => [];
}

class ImageSend extends DetectImageState {
  final String image;

  const ImageSend({@required this.image}) : assert(image != null);

  @override
  List<Object> get props => [image];
}

class WaitingForServer extends DetectImageState {
  final String image;

  const WaitingForServer({@required this.image}) : assert(image != null);

  @override
  List<Object> get props => [image];
}

class ImageDetected extends DetectImageState {
  final String image;

  const ImageDetected({@required this.image}) : assert(image != null);

  @override
  List<Object> get props => [image];
}

class DetectImageError extends DetectImageState {}

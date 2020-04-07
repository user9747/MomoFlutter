import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class DetectImageEvent extends Equatable {
  const DetectImageEvent();
}

class CaptureImage extends DetectImageEvent {
  
  @override
  List<Object> get props => [];
}

class SendImage extends DetectImageEvent {
  final String image;

  const SendImage({@required this.image}) : assert(image != null);

  @override
  List<Object> get props => [image];
}

import 'package:camera/camera.dart';

abstract class PhoneCameraState {}

class InitializingCameraState implements PhoneCameraState {}

class CameraReadyState implements PhoneCameraState {

  final CameraController controller;

  CameraReadyState(this.controller);
}
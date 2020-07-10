import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todointernship/data/image_manager.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/widgets/phone_camera/phone_camera_event.dart';
import 'package:todointernship/widgets/phone_camera/phone_camera_state.dart';

class PhoneCameraBloc extends Bloc<PhoneCameraEvent, PhoneCameraState> {

  final ImageManager _imageManager;
  final TaskRepository _taskRepository;
  final int _taskId;
  CameraController _cameraController;

  PhoneCameraBloc(this._taskRepository, this._imageManager, this._taskId) : super(InitializingCameraState()) {
   _initializeCamera().then((value) => this.add(InitializeCameraEvent()));
  }

  @override
  Stream<PhoneCameraState> mapEventToState(PhoneCameraEvent event) async* {
    if(event is InitializeCameraEvent) {
      yield CameraReadyState(_cameraController);
    } else if (event is TakePictureEvent) {
      _taskPhoto();
    }
  }

  @override
  Future<void> close() {
    _cameraController.dispose();
    return super.close();
  }

  Future<void> _initializeCamera() async {
    var cameras = await availableCameras();
    _cameraController = CameraController(cameras.first, ResolutionPreset.ultraHigh);
    await _cameraController.initialize();
  }

  Future<void> _taskPhoto() async {
    var name = DateTime.now().toString() + '.jpg';
    var path = await _imageManager.getPathForSaveCameraImage(name);
    _taskRepository.saveCameraImage(name, _taskId);
    _cameraController.takePicture(path);
  }

}
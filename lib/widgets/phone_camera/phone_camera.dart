import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injector/injector.dart';
import 'package:todointernship/data/image_manager.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/widgets/phone_camera/phone_camera_bloc.dart';
import 'package:todointernship/widgets/phone_camera/phone_camera_event.dart';
import 'package:todointernship/widgets/phone_camera/phone_camera_state.dart';

class PhoneCamera extends StatefulWidget {

  final int taskId;
  PhoneCamera(this.taskId);

  @override
  _PhoneCameraState createState() => _PhoneCameraState();
}

class _PhoneCameraState extends State<PhoneCamera> {

  PhoneCameraBloc _phoneCameraBloc;

  @override
  void initState() {
    var injector = Injector.appInstance;
    _phoneCameraBloc = PhoneCameraBloc(
        injector.getDependency<TaskRepository>(),
        injector.getDependency<ImageManager>(),
        widget.taskId);
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: _phoneCameraBloc,
        builder: (context, state) {
          if(state is CameraReadyState) {
            return Scaffold(
                body: Stack(
                  children: <Widget>[
                    Positioned.fill(
                        child: CameraPreview(state.controller)
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: IconButton(
                        padding: const EdgeInsets.only(bottom: 50),
                        icon: Icon(Icons.camera),
                        color: Colors.grey,
                        iconSize: 50,
                        onPressed: () => _phoneCameraBloc.add(TakePictureEvent()),
                      ),
                    )
                  ],
                )
            );
          }
          return Container();
        }
    );
  }

  @override
  void dispose() {
    _phoneCameraBloc.close();
    super.dispose();
  }

}

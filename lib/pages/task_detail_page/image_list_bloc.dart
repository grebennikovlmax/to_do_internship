import 'dart:async';

import 'package:todointernship/data/image_manager.dart';
import 'package:todointernship/model/task_image.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/pages/task_detail_page/image_event.dart';

class ImageListBloc {

  final int taskId;
  final _taskRepository = TaskDatabaseRepository.shared;
  final _imageListStreamController = StreamController<List<TaskImage>>();
  final _eventImageStreamController = StreamController<ImageEvent>();

  List<TaskImage> _imageList;

  Stream get imageListStream => _imageListStreamController.stream;

  Sink get imageEvent => _eventImageStreamController.sink;

  ImageListBloc(this.taskId) {
    _loadImagesPath();
    _eventImageStreamController.stream.listen((event) {
      switch(event.runtimeType) {
        case NewImageEvent:
          _saveImage(event);
          break;
        case DeleteImageEvent:
          _deleteImage(event);
          break;
      }
    });
  }

  Future<void> _loadImagesPath() async{
    _imageList = await _taskRepository.fetchImagesForTask(taskId);
    var path = await ImageManager.shared.path;
    _imageList.map((e) => e.pathToFile = path + e.path).toList();
    _imageListStreamController.add(_imageList);
  }

  Future<void> _saveImage(NewImageEvent event) async {
    await _taskRepository.saveImage(url: event.url, taskId: taskId);
    _loadImagesPath();
  }

  void _deleteImage(DeleteImageEvent event) {
    _imageList.removeWhere((element) => element.path == event.path);
    _imageListStreamController.add(_imageList);
    _taskRepository.removeImage(event.path);
  }

  void dispose() {
    _imageListStreamController.close();
    _eventImageStreamController.close();
  }

}
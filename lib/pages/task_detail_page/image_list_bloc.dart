import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todointernship/data/image_manager.dart';
import 'package:todointernship/model/task_image.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'package:todointernship/pages/task_detail_page/image_event.dart';

class ImageListBloc extends Bloc<ImageEvent, List<TaskImage>> {

  final int taskId;
  final TaskRepository _taskRepository;
  List<TaskImage> _imageList = [];

  ImageListBloc(this.taskId, this._taskRepository) : super(null) {
    _loadImagesPath().then((value) => this.add(UpdateImageEvent()));
  }

  @override
  List<TaskImage> get state => List.from(_imageList);

  @override
  Stream<List<TaskImage>> mapEventToState(ImageEvent event) async* {
    if (event is NewImageEvent) {
      yield* _saveImage(event);
    } else if ( event is DeleteImageEvent) {
      yield* _deleteImage(event);
    } else if ( event is UpdateImageEvent) {
      yield List.from(_imageList);
    }
  }

  Future<void> _loadImagesPath() async {
    _imageList = await _taskRepository.fetchImagesForTask(taskId);
    var path = await ImageManager.shared.path;
    _imageList.map((e) => e.pathToFile = path + e.path).toList();
  }

  Stream<List<TaskImage>> _saveImage(NewImageEvent event) async* {
    await _taskRepository.saveImage(url: event.url, taskId: taskId);
    await _loadImagesPath();
    yield List.from(_imageList);
  }

  Stream<List<TaskImage>> _deleteImage(DeleteImageEvent event) async* {
    _imageList.removeWhere((element) => element.path == event.path);
    _taskRepository.removeImage(event.path);
    yield List.from(_imageList);
  }

}
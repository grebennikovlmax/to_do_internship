class TaskImage {
  
  final int taskID;
  final String path;
  
  TaskImage({this.taskID, this.path});

  TaskImage.fromMap(Map<String, dynamic> map)
      : taskID = map['task_id'],
        path = map['path'];

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'task_id': taskID
    };
  }
  
}
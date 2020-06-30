class Task {
  bool isCompleted;
  int id;
  int categoryId;
  String name;
  DateTime createdDate;
  DateTime finalDate;
  DateTime notificationDate;
  List<TaskStep> steps;

  Task({this.id, this.name, this.finalDate, this.createdDate, this.isCompleted = false, this.steps = const [], this.notificationDate, this.categoryId}) {
    createdDate ??= DateTime.now();
  }

  Task.fromMap(Map<String, dynamic> map)
      : name = map['title'],
        categoryId = map['category_id'],
        id = map['id'],
        finalDate = DateTime.fromMillisecondsSinceEpoch(map['final_date']),
        createdDate = DateTime.fromMillisecondsSinceEpoch(map['created_date']),
        isCompleted = map['is_completed'] == 0 ? false : true,
        notificationDate = map['notification_date'] == null ? null : DateTime.fromMillisecondsSinceEpoch(map['notification_date']),
        steps = map['steps'];

  Map<String, dynamic> toMap() {
    var map = {
      'title' : name,
      'is_completed': isCompleted ? 1 : 0,
      'created_date': createdDate.millisecondsSinceEpoch,
      'final_date': finalDate.millisecondsSinceEpoch,
      'id': id,
      'category_id': categoryId
    };
    if(notificationDate != null) {
      map['notification_date'] = notificationDate.millisecondsSinceEpoch;
    }
    return map;
  }
}

class TaskStep {
  String description;
  bool isCompleted;
  int id;
  int taskID;

  TaskStep({this.description, this.isCompleted = false, this.id, this.taskID});

  TaskStep.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        taskID = map['task_id'],
        description = map['description'],
        isCompleted = map['is_completed'] == 1 ? true : false;

  Map<String, dynamic> toMap() {
    var map = {
      'description' : description,
      'is_completed' : isCompleted ? 1 : 0,
      'task_id' : taskID
    };
    if(id != null) {
      map['id'] = id;
    }
    return map;
  }
}
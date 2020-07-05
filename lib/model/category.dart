class Category {
  String name;
  int id;
  int completedTask = 0;
  int incompletedTask = 0;
  int amountTask = 0;
  double completionRate = 0;

  Category({this.name, this.id});

  Category.fromMap(Map<String, dynamic> map)
      : name = map['title'],
        id = map['id'];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map  = {'title': name};
    if(id != null) {
      map['id'] = id;
    }
    return map;
  }
}
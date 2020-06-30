abstract class CategoryListPageEvent {

}

class CreateNewCategoryEvent implements CategoryListPageEvent {

  final String name;
  final int color;

  CreateNewCategoryEvent(this.name, this.color);

}


abstract class CategoryListPageEvent {}

class CreateNewCategoryEvent implements CategoryListPageEvent {

  final String name;
  final int color;

  CreateNewCategoryEvent(this.name, this.color);

}

class UpdatePageEvent implements CategoryListPageEvent {}

class DeleteCategoryEvent implements CategoryListPageEvent {
  final int categoryId;

  DeleteCategoryEvent(this.categoryId);
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injector/injector.dart';
import 'package:todointernship/data/task_data/task_repository.dart';
import 'dart:io';
import 'dart:math';
import 'package:todointernship/model/task_image.dart';
import 'package:todointernship/pages/task_detail_page/image_event.dart';
import 'package:todointernship/pages/task_detail_page/image_list_bloc.dart';

class ImageList extends StatefulWidget {

  final int categoryId;
  final int taskId;

  ImageList({this.categoryId, this.taskId});

  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {

  final double height = 150;
  ImageListBloc _imageListBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _imageListBloc = ImageListBloc(
      widget.taskId,
      Injector.appInstance.getDependency<TaskRepository>()
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _imageListBloc,
      builder: (context, snapshot) {
        return Container(
          color: Colors.white,
          height: height,
          child: Container(
            padding: EdgeInsets.all(16),
            child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.length + 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  crossAxisCount: 1,
                ),
                itemBuilder: (context, index) {
                  if(!snapshot.asMap().containsKey(index)) {
                    return FractionallySizedBox(
                      widthFactor: 0.5,
                      alignment: Alignment.centerLeft,
                      child: _AddImageButton(
                        onTap: _onAddImage
                      ),
                    );
                  }
                  return _ImageItem(
                    onDelete: () => _onDelete(snapshot[index].path),
                    image: snapshot[index],
                  );
                }
            )
        ),
          );
      }
    );
  }

  @override
  void dispose() {
    _imageListBloc.close();
    super.dispose();
  }

  Future<void> _onAddImage() async{
    var url = await Navigator.of(context).pushNamed('/photo_picker', arguments: widget.categoryId);
    if(url != null) {
      _imageListBloc.add(NewImageEvent(url));
    }
  }

  void _onDelete(String path) {
    _imageListBloc.add(DeleteImageEvent(path));
  }

}

class _ImageItem extends StatelessWidget {

  final VoidCallback onDelete;
  final TaskImage image;

  _ImageItem({this.onDelete, this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          Positioned.fill(
              child: Image.file(File(image.pathToFile),
                fit: BoxFit.cover
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                margin: EdgeInsets.only(top: 5,right: 5),
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff01A39D),
                ),
                child: FittedBox(
                    fit: BoxFit.fill,
                    child: Icon(Icons.close,
                      color: Colors.white,
                    )
                ),
              ),
            ),
          ),
        ],
    );
  }

}

class _AddImageButton extends StatelessWidget {

  final VoidCallback onTap;

  _AddImageButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: Color(0xff01A39D),
            borderRadius: BorderRadius.circular(16)
        ),
        child: Transform.rotate(
          angle: 3 * pi / 4,
          child: Icon(Icons.attach_file,
              color: Colors.white,
          ),
        ),
      ),
    );
  }
}

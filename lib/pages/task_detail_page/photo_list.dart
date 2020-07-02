import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:math';

import 'package:todointernship/model/task_image.dart';

class PhotoList extends StatelessWidget {

  final VoidCallback onPickPhoto;
  final void Function(String) onDelete;
  final List<TaskImage> imageList;
  final double height = 150;

  PhotoList({this.onPickPhoto, this.imageList, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: height,
      child: Container(
        padding: EdgeInsets.all(16),
        child: GridView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageList.length + 1,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              crossAxisCount: 1,
            ),
            itemBuilder: (context, index) {
              if(!imageList.asMap().containsKey(index)) {
                return _AddImageButton(
                  padding: height / 2.5,
                  onTap: onPickPhoto
                );
              }
              return _ImageItem(
                onDelete: () => {},
                image: imageList[index],
              );
            }
        )
    ),
      );
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
              child: Image.file(File(image.path),
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
  final double padding;

  _AddImageButton({this.onTap, this.padding});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(right: padding),
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
      ),
    );
  }
}

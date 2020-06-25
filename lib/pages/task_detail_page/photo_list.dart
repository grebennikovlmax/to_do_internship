import 'package:flutter/material.dart';

class PhotoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 150,
      child: Container(
        padding: EdgeInsets.all(10),
        child: GridView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              crossAxisCount: 1,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/photo_picker'),
                  child: Container(color: Colors.black)
              );
            }),
      )
    );
  }
}

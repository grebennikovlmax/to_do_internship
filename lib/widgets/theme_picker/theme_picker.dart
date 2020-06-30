import 'package:flutter/material.dart';

import 'package:todointernship/widgets/theme_picker/theme_picker_bloc.dart';

class ThemePicker extends StatelessWidget {

  final Stream<ThemePickerState> stateStream;
  final Sink<ThemePickerEvent> eventSink;
  final double height;
  final void Function(int) onPick;

  ThemePicker({this.eventSink,this.stateStream,this.height, this.onPick});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 30,
      width: double.maxFinite,
      child: StreamBuilder<ThemePickerState>(
        stream: stateStream,
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Container();
          }
          return GridView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.colorList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 5,
                crossAxisCount: 1,
              ),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _CustomThemPickerButton(
                  color: snapshot.data.colorList[index],
                  value: snapshot.data.pickedColor == snapshot.data.colorList[index],
                  onTap: () => _onTap(snapshot.data.colorList[index]),
                );
              }
          );
        },
      ),
    );
  }

  void _onTap(int color) {
    onPick(color);
    eventSink.add(ThemePickerEvent(color));
  }
}


class _CustomThemPickerButton extends StatelessWidget {

  final int color;
  final VoidCallback onTap;
  final bool value;

  _CustomThemPickerButton({this.color, this.onTap, this.value});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(color)
          ),
          child: value
              ? Center(child:
          FractionallySizedBox(
            widthFactor: 0.4,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffffffff)
              ),
            ),
          ),
          )
              : Container()
      ),
    );
  }


}
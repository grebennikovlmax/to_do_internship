import 'package:flutter/material.dart';

class CustomCheckBox extends StatelessWidget {

  final bool value;
  final VoidCallback onChange;

  CustomCheckBox({this.value,this.onChange});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChange,
      child: Icon(value ? Icons.check_circle : Icons.radio_button_unchecked,
        color: Theme.of(context).primaryColor,),
    );
  }

}
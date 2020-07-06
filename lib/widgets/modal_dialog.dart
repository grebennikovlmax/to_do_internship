import 'package:flutter/material.dart';

class ModalDialog extends StatelessWidget {

  final String title;

  ModalDialog({@required this.title});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        contentPadding: EdgeInsets.all(16),
        children: <Widget>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(title,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 16),
                ),
                Divider(
                  color: Colors.transparent,
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      onTap: () => _onDecline(context),
                      child: Text('ОТМЕНА',
                          style: Theme.of(context).textTheme.headline5
                      ),
                    ),
                    VerticalDivider(),
                    InkWell(
                      onTap: () => _onAccept(context),
                      child: Text('ВЫБРАТЬ',
                          style: Theme.of(context).textTheme.headline5
                      ),
                    ),
                  ],
                )
              ]
          )
        ]
    );
  }

  void _onAccept(BuildContext context) {
    Navigator.of(context).pop(true);
  }

  void _onDecline(BuildContext context) {
    Navigator.of(context).pop(false);
  }

}
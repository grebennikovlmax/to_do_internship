import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/pages/image_picker_page/custom_search_app_bar.dart';
import 'package:todointernship/pages/image_picker_page/image_page_event.dart';
import 'package:todointernship/pages/image_picker_page/image_picker_bloc.dart';
import 'package:todointernship/pages/image_picker_page/image_picker_page_state.dart';
import 'package:todointernship/theme_bloc_provider.dart';
import 'package:todointernship/theme_event.dart';

class ImagePickerBlockProvider extends InheritedWidget {
  
  final ImagePickerBloc block;
  
  const ImagePickerBlockProvider({Widget child, this.block})  : super(child: child);

  static ImagePickerBlockProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ImagePickerBlockProvider>();
  }

  @override
  bool updateShouldNotify(ImagePickerBlockProvider old) {
    return false;
  }
}

class  ImagePickerPage extends StatefulWidget {

  final int categoryId;

  ImagePickerPage(this.categoryId);

  @override
  _ImagePickerPageState createState() => _ImagePickerPageState();

}


class _ImagePickerPageState extends State<ImagePickerPage> {

  final _imagePickerBloc = ImagePickerBloc();


  @override
  void dispose() {
    _imagePickerBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ImagePickerBlockProvider(
      block: _imagePickerBloc,
      child: StreamBuilder<Map<int, CategoryTheme>>(
          stream: ThemeBlocProvider.of(context).themeBloc.themeStream,
          builder: (context, themeSnapshot) {
            if(!themeSnapshot.hasData) {
              ThemeBlocProvider.of(context).themeBloc.themeEventSink.add(RefreshThemeEvent());
              return Container();
            }
            var theme = themeSnapshot.data[widget.categoryId];
            return Scaffold(
                backgroundColor: Color(theme.backgroundColor),
                appBar: SearchAppBar(
                  color: Color(theme.primaryColor),
                ),
                body: StreamBuilder<ImagePickerPageState>(
                  stream: _imagePickerBloc.pageStateStream,
                  initialData: LoadingState(),
                  builder: (context, snapshot) {
                    if (snapshot.data is LoadingState) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if(snapshot.data is LoadedImageListState) {
                      return _ImagesGridView(
                        imageDataList: (snapshot.data as LoadedImageListState).urlList,
                        onPick: _saveImage,
                      );
                    }
                    if(snapshot.data is EmptyImageListState) {
                      var text = (snapshot.data as EmptyImageListState).description;
                      return Center(
                          child: Text(text)
                      );
                    }
                    return Container();
                  }
                )
            );
          }
      ),
    );

  }

  Future<void> _saveImage(String url) async {
    final choice = await showDialog<bool>(
        context: context,
        builder: (context) {
          return _SaveImageDialog();
        }
    );
    if(choice != null && choice) {
      Navigator.of(context).pop(url);
    }
  }

}

class _ImagesGridView extends StatefulWidget {

  final List<String> imageDataList;
  final void Function(String) onPick;

  _ImagesGridView({this.imageDataList, this.onPick});

  @override
  _ImagesGridViewState createState() => _ImagesGridViewState();
}

class _ImagesGridViewState extends State<_ImagesGridView> {

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _setGridViewListeners();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              delegate: SliverChildBuilderDelegate((context, index){
                return GestureDetector(
                  key: ValueKey(widget.imageDataList[index]),
                  onTap: () => widget.onPick(widget.imageDataList[index]),
                  child: FadeInImage.assetNetwork (
                      fit: BoxFit.cover,
                      fadeInDuration: Duration(milliseconds: 500),
                      placeholder: 'assets/png/placeholder.png',
                      image: widget.imageDataList[index],
                      imageErrorBuilder: (context, error, trace ) {
                        return Image.asset('assets/png/placeholder.png');
                      },
                    ),
                  );
                },
                childCount: widget.imageDataList.length
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: CircularProgressIndicator()),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ImagePickerBlockProvider.of(context).block.imagePageEventSink.add(RefreshPageEvent());
  }

  void _setGridViewListeners() {
    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        ImagePickerBlockProvider.of(context).block.imagePageEventSink.add(NextImagePage());
      }
    });
  }

}

class _SaveImageDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(16),
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('Выбрать данное изображение?',
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

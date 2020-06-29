import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:todointernship/model/category_theme.dart';
import 'package:todointernship/pages/image_picker_page/image_page_event.dart';
import 'package:todointernship/pages/image_picker_page/image_picker_bloc.dart';
import 'package:todointernship/pages/image_picker_page/image_picker_page_state.dart';
import 'package:todointernship/pages/image_picker_page/search_state.dart';

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
      child: StreamBuilder(
          stream: _imagePickerBloc.pageThemeStream,
          builder: (context, themeSnapshot) {
            if(!themeSnapshot.hasData) return Container();
            final theme = _setTheme(themeSnapshot.data);
            return Scaffold(
                backgroundColor: theme.backgroundColor,
                appBar: _SearchAppBar(
                  color: theme.primaryColor,
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
                    return Center(
                        child: Text("Ничего не найдено")
                    );
                  }
                )
            );
          }
      ),
    );

  }

  ThemeData _setTheme(CategoryTheme categoryTheme) {
    if(categoryTheme.backgroundColor == null || categoryTheme.primaryColor == null) {
      return Theme.of(context);
    }
    return ThemeData(
        backgroundColor: Color(categoryTheme.backgroundColor),
        primaryColor: Color(categoryTheme.primaryColor)
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

class _SearchAppBar extends StatelessWidget implements PreferredSizeWidget{

  final Color color;
  final Size preferredSize = Size.fromHeight(56);

  _SearchAppBar({this.color});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SearchState>(
      stream: ImagePickerBlockProvider.of(context).block.searchStateStream,
      initialData: ClosedSearchState(),
      builder: (context, snapshot) {
        return AppBar(
          titleSpacing: 5,
          automaticallyImplyLeading: !snapshot.data.isSearching,
          backgroundColor: color,
          title: snapshot.data.isSearching ? CustomSearchBar(text: (snapshot.data as OpenSearchState).text) : Text('Flickr'),
          actions: <Widget>[
            !snapshot.data.isSearching
                ? IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => _onSearch(context)
                  )
                : Container()
          ],
        );
      }
    );
  }

  void _onSearch(BuildContext context) {
    ImagePickerBlockProvider.of(context).block.imagePageEventSink.add(OpenSearchEvent());
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

class CustomSearchBar extends StatelessWidget {

  final String text;

  CustomSearchBar({this.text});

  @override
  Widget build(BuildContext context) {
      return Container(
        height: 32,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16)
        ),
        child: TextFormField(
          autofocus: true,
          textAlign: TextAlign.start,
          initialValue: text,
          onFieldSubmitted: (val) => _onSubmitted(context, val),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: "Поиск...",
            icon: IconButton(
              icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
              padding: EdgeInsets.zero,
              onPressed: () => _onPressReturn(context),
              color: Colors.black
            ),
            suffixIcon: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.close),
              color: Colors.black,
              onPressed: () => _onClosed(context),
            )
          ),
        ),
      );
  }

  void _onSubmitted(BuildContext context, String text) {
    ImagePickerBlockProvider.of(context).block.imagePageEventSink.add(SearchEvent(text: text));
  }

  void _onClosed(BuildContext context) {
    ImagePickerBlockProvider.of(context).block.imagePageEventSink.add(CloseSearchEvent());
  }

  void _onPressReturn(BuildContext context) {
    Navigator.pop(context);
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

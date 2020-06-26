import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/service/flickr_api_service.dart';

class  PhotoPickerPage extends StatefulWidget {

  @override
  _PhotoPickerPageState createState() => _PhotoPickerPageState();

}


class _PhotoPickerPageState extends State<PhotoPickerPage> {

  bool isSearching = false;

  StreamController<bool> _searchStreamController;
  StreamController<Future<List<String>>> _imagesStreamController;

  @override
  void initState() {
    super.initState();
    _searchStreamController = StreamController();
    _imagesStreamController = StreamController();
  }

  @override
  void dispose() {
    _searchStreamController.close();
    _imagesStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeData>(
        future: _getTheme(context),
        builder: (context, future) {
          if(!future.hasData) {
            return Container();
          }
          return Scaffold(
              backgroundColor: future.data.backgroundColor,
              appBar: _SearchAppBar(
                color: future.data.primaryColor,
                onSearch: _onSearch,
                onSubmitted: _searchImage,
                searchStream: _searchStreamController.stream,
              ),
              body: StreamBuilder<Future<List<String>>>(
                stream: _imagesStreamController.stream,
                initialData: FlickrApiService.shared.getRecentImages(),
                builder: (context, snapshot) {
                  return FutureBuilder<List<String>>(
                      future: snapshot.data,
                      builder: (context, futureImages) {
                        if (futureImages.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if(futureImages.hasError) {
                          return Container();
                        }
                        if(futureImages.data.isEmpty) {
                          return Center(
                            child: Text("Ничего не найдено"),
                          );
                        }
                        return _ImagesGridView(
                          imageDataList: futureImages.data,
                          onPick: _saveImage,
                          onRefresh: _refreshImageList,
                        );
                      }
                  );
                })
          );
        }
    );

  }

  Future<void> _refreshImageList() async {
    final imageList = FlickrApiService.shared.getRecentImages();
    _imagesStreamController.add(imageList);
  }

  void _onSearch() {
    isSearching = !isSearching;
    if(!isSearching) {
      _refreshImageList();
    }
    _searchStreamController.add(isSearching);
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

  Future<ThemeData> _getTheme(BuildContext context) async {
    final pref = SharedPrefManager();
    final categoryTheme = await pref.loadTheme(0);
    if(categoryTheme.backgroundColor == null || categoryTheme.primaryColor == null) {
      return Theme.of(context);
    }
    final theme = ThemeData(
        backgroundColor: Color(categoryTheme.backgroundColor),
        primaryColor: Color(categoryTheme.primaryColor)
    );
    return theme;
  }

  Future<void> _searchImage(String searchText) async {
    final findedImages = FlickrApiService.shared.searchPhotos(searchText: searchText);
    _imagesStreamController.add(findedImages);
  }

}

class _SearchAppBar extends StatelessWidget implements PreferredSizeWidget{

  final Color color;
  final Stream searchStream;
  final VoidCallback onSearch;
  final ValueChanged<String> onSubmitted;
  final Size preferredSize = Size.fromHeight(56);

  _SearchAppBar({this.color, this.searchStream, this.onSearch, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: searchStream,
      initialData: false,
      builder: (context, snapshot) {
        return AppBar(
          titleSpacing: 5,
          automaticallyImplyLeading: !snapshot.data,
          backgroundColor: color,
          title: snapshot.data ? CustomSearchBar(onClosed: onSearch, onSubmitted: onSubmitted) : Text('Flickr'),
          actions: <Widget>[ !snapshot.data ?
          IconButton(
              icon: Icon(Icons.search),
              onPressed: onSearch
          ) : Container()
          ],
        );
      }
    );
  }
}

class _ImagesGridView extends StatelessWidget {

  final RefreshCallback onRefresh;
  final List<String> imageDataList;
  final void Function(String) onPick;

  _ImagesGridView({this.onRefresh, this.imageDataList, this.onPick});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
          padding: EdgeInsets.all(16),
          itemCount: imageDataList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onPick(imageDataList[index]),
              child: FadeInImage.assetNetwork (
                  fit: BoxFit.cover,
                  fadeInDuration: Duration(milliseconds: 500),
                  placeholder: 'assets/png/placeholder.png',
                  image: imageDataList[index],
                  imageErrorBuilder: (context, error, trace ) {
                    return Image.asset('assets/png/placeholder.png');
                  },
              ),
            );
          }
      ),
    );
  }
}


class CustomSearchBar extends StatelessWidget {

  final VoidCallback onClosed;
  final ValueChanged<String> onSubmitted;

  CustomSearchBar({this.onClosed, this.onSubmitted});

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
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: "Поиск...",
            icon: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              padding: EdgeInsets.zero,
              onPressed: () => _onPressReturn(context),
              color: Colors.black
            ),
            suffixIcon: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.close),
              color: Colors.black,
              onPressed: onClosed,
            )
          ),
        ),
      );
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
          crossAxisAlignment: CrossAxisAlignment.end,
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
                Padding(
                  padding: EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () => _onDecline(context),
                    child: Text('ОТМЕНА',
                        style: Theme.of(context).textTheme.headline5
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                  child: InkWell(
                    onTap: () => _onAccept(context),
                    child: Text('ВЫБРАТЬ',
                        style: Theme.of(context).textTheme.headline5
                    ),
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


import 'dart:async';

import 'package:flutter/material.dart';

import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/service/flickr_api_service.dart';

class  PhotoPickerPage extends StatefulWidget {

  final apiService = FlickrApiService();

  @override
  _PhotoPickerPageState createState() => _PhotoPickerPageState();

}


class _PhotoPickerPageState extends State<PhotoPickerPage> {

  bool isSearching = false;

  StreamController<bool> _searchStreamController;
  StreamController<List<String>> _imagesStreamController;

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
          body: FutureBuilder<List<String>>(
            future: widget.apiService.getRecentPhotos(),
            builder: (context, futureImages) {
              if (futureImages.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (futureImages.hasError) {
                return Container();
              }
              return StreamBuilder<List<String>>(
                stream: _imagesStreamController.stream,
                initialData: futureImages.data,
                builder: (context, snapshot) {
                  return GridView.builder(
                      padding: EdgeInsets.all(15),
                      itemCount: snapshot.data.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20
                      ),
                      itemBuilder: (context, index) {
                        return FadeInImage.assetNetwork (
                            fit: BoxFit.cover,
                            fadeInDuration: Duration(milliseconds: 500),
                            placeholder: 'assets/png/placeholder.png',
                            image: snapshot.data[index]
                        );
                      }
                  );
                }
              );
            })
        );
      }
    );
  }

  void _onSearch() {
    isSearching = !isSearching;
    _searchStreamController.add(isSearching);
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
    final findedImages = await widget.apiService.searchPhotos(searchText: searchText);
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


class CustomSearchBar extends StatelessWidget {

  final VoidCallback onClosed;
  final ValueChanged<String> onSubmitted;

  CustomSearchBar({this.onClosed, this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16)
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.black,
            onPressed: () => _onPressReturn(context),
          ),
          Expanded(
            child: TextFormField(
              onFieldSubmitted: onSubmitted,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close),
            color: Colors.black,
            onPressed: onClosed,
          )
        ],
      ),
    );
  }

  void _onPressReturn(BuildContext context) {
    Navigator.pop(context);
  }

}


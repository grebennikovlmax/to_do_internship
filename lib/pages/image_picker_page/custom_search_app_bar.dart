import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injector/injector.dart';
import 'package:todointernship/data/shared_prefs_manager.dart';
import 'package:todointernship/pages/image_picker_page/seach_bar_bloc.dart';
import 'package:todointernship/pages/image_picker_page/search_event.dart';
import 'package:todointernship/pages/image_picker_page/image_page_event.dart';
import 'image_picker_bloc.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {

  final Color color;
  final Size preferredSize = Size.fromHeight(56);

  SearchAppBar({this.color});

  @override
  _SearchAppBarState createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {

  SearchBarBloc _searchBarBloc;

  @override
  void initState() {
    super.initState();
    var injector = Injector.appInstance;
    _searchBarBloc = SearchBarBloc(injector.getDependency<SharedPrefManager>());
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
        bloc: _searchBarBloc,
        builder: (context, state) {
          return AppBar(
            titleSpacing: 5,
            automaticallyImplyLeading: !state.isSearching,
            backgroundColor: widget.color,
            title: state.isSearching ? _CustomSearchBar(
                text: state.text,
                searchEventSink: _searchBarBloc,
            ) : Text('Flickr'),
            actions: <Widget>[
              !state.isSearching
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

  @override
  void dispose() {
    _searchBarBloc.close();
    super.dispose();
  }

  void _onSearch(BuildContext context) {
    _searchBarBloc.add(OpenSearchEvent());
  }
}

class _CustomSearchBar extends StatelessWidget {

  final String text;
  final Sink searchEventSink;

  _CustomSearchBar({this.text, this.searchEventSink});

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
    BlocProvider.of<ImagePickerBloc>(context).add(SearchImageEvent(text: text));
    searchEventSink.add(OnSearchEvent(text));
  }

  void _onClosed(BuildContext context) {
    searchEventSink.add(CloseSearchEvent());
    BlocProvider.of<ImagePickerBloc>(context).add(RefreshPageEvent());
  }

  void _onPressReturn(BuildContext context) {
    Navigator.pop(context);
  }

}
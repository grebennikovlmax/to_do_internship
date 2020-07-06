import 'package:flutter/material.dart';

import 'dart:io';

import 'package:todointernship/pages/image_picker_page/seach_bar_bloc.dart';
import 'package:todointernship/pages/image_picker_page/search_state.dart';
import 'package:todointernship/pages/image_picker_page/search_event.dart';
import 'package:todointernship/pages/image_picker_page/image_page_event.dart';
import 'package:todointernship/pages/image_picker_page/image_picker_page.dart';

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
    _searchBarBloc = SearchBarBloc();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SearchState>(
        stream: _searchBarBloc.searchStateStream,
        initialData: ClosedSearchState(),
        builder: (context, snapshot) {
          return AppBar(
            titleSpacing: 5,
            automaticallyImplyLeading: !snapshot.data.isSearching,
            backgroundColor: widget.color,
            title: snapshot.data.isSearching ? _CustomSearchBar(
                text: (snapshot.data as OpenSearchState).text,
                searchEventSink: _searchBarBloc.searchEventSink,
            ) : Text('Flickr'),
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

  @override
  void dispose() {
    _searchBarBloc.dispose();
    super.dispose();
  }

  void _onSearch(BuildContext context) {
    _searchBarBloc.searchEventSink.add(OpenSearchEvent());
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
    ImagePickerBlockProvider.of(context).block.imagePageEventSink.add(SearchImageEvent(text: text));
    searchEventSink.add(OnSearchEvent(text));
  }

  void _onClosed(BuildContext context) {
    searchEventSink.add(CloseSearchEvent());
    ImagePickerBlockProvider.of(context).block.imagePageEventSink.add(RefreshPageEvent());
  }

  void _onPressReturn(BuildContext context) {
    Navigator.pop(context);
  }

}
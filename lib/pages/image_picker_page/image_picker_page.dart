import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injector/injector.dart';
import 'package:todointernship/data/flickr_api_service.dart';
import 'package:todointernship/pages/image_picker_page/custom_search_app_bar.dart';
import 'package:todointernship/pages/image_picker_page/image_page_event.dart';
import 'package:todointernship/pages/image_picker_page/image_picker_bloc.dart';
import 'package:todointernship/pages/image_picker_page/image_picker_page_state.dart';
import 'package:todointernship/theme_bloc.dart';
import 'package:todointernship/widgets/modal_dialog.dart';

class  ImagePickerPage extends StatefulWidget {

  final int categoryId;

  ImagePickerPage(this.categoryId);

  @override
  _ImagePickerPageState createState() => _ImagePickerPageState();

}

class _ImagePickerPageState extends State<ImagePickerPage> {

  ImagePickerBloc _imagePickerBloc;

  @override
  void initState() {
    super.initState();
    var injector = Injector.appInstance;
    _imagePickerBloc = ImagePickerBloc(injector.getDependency<FlickrApiService>());
  }

  @override
  Widget build(BuildContext context) {
    var theme = BlocProvider.of<ThemeBloc>(context).state[widget.categoryId];
    return BlocProvider<ImagePickerBloc>(
      create: (context) => _imagePickerBloc,
      child: Scaffold(
          backgroundColor: Color(theme.backgroundColor),
          appBar: SearchAppBar(
            color: Color(theme.primaryColor),
          ),
          body: BlocBuilder(
              bloc: _imagePickerBloc,
              builder: (context, state) {
                if (state is LoadingState) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if(state is LoadedImageListState) {
                  return _ImagesGridView(
                    imageDataList: state.urlList,
                    onPick: _saveImage,
                  );
                }
                if(state is EmptyImageListState) {
                  return _EmptyPage(state.description);
                }
                return Container();
              }
          )
      ),
    );
  }

  @override
  void dispose() {
    _imagePickerBloc.close();
    super.dispose();
  }

  Future<void> _saveImage(String url) async {
    final choice = await showDialog<bool>(
        context: context,
        builder: (context) {
          return ModalDialog(
            title: 'Выбрать данное изображение?',
          );
        }
    );
    if(choice != null && choice) {
      Navigator.of(context).pop(url);
    }
  }

}

class _EmptyPage extends StatelessWidget {

  final String title;

  _EmptyPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title,
            style: Theme.of(context).textTheme.headline5
          ),
          SizedBox(height: 20),
          IconButton(
            onPressed: () => BlocProvider.of<ImagePickerBloc>(context).add(RefreshPageEvent()),
            icon: Icon(Icons.refresh),
          )
        ],
      )
    );
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
                  child: FadeInImage(
                      fit: BoxFit.cover,
                      placeholder: AssetImage('assets/png/placeholder.png'),
                      image: NetworkImage(widget.imageDataList[index]),
                      imageErrorBuilder: (___, __, _) {
                       return Image.asset('assets/png/placeholder.png');
                      }
                    )
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
    BlocProvider.of<ImagePickerBloc>(context).add(RefreshPageEvent());
  }

  void _setGridViewListeners() {
    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        BlocProvider.of<ImagePickerBloc>(context).add(NextImagePage());
      }
    });
  }

}
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:todointernship/data/flickr_api_service.dart';

class ImageManager {

  static final shared = ImageManager._privateConstructor();

  ImageManager._privateConstructor();

  Future<String> get path async {
    final docDir = await getApplicationDocumentsDirectory();
    return docDir.path + '/images/';
  }

  Future<String> saveImage(String url) async {
    final data = await FlickrApiService.shared.loadImage(url: url);
    final name = _clipUrl(url);
    final file = await _getFileFor(name);
    file.writeAsBytes(data);
    return name;
  }

  Future<void> removeImage(String path) async {
    final docDir = await getApplicationDocumentsDirectory();
    final file = File('${docDir.path}/images/$path');
    file.delete();
  }

  Future<File> _getFileFor(String name) async {
    final docDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(docDir.path +'/images');
    final newDir = await imageDir.create();
    return File('${newDir.path}/$name');
  }

  String _clipUrl(String url) {
    final reg = RegExp(r'[^A-Za-z0-9]');
    final res = url.replaceAll(reg, '');
    return res +'.jpg';
  }

}
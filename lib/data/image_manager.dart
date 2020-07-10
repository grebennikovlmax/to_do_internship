import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:todointernship/data/flickr_api_service.dart';

class ImageManager {

  static final shared = ImageManager._privateConstructor();

  ImageManager._privateConstructor();

  Future<String> get path async {
    return await _getImageDir();
  }

  Future<String> saveImage(String url) async {
    final data = await FlickrApiService.shared.loadImage(url: url);
    final name = _clipUrl(url);
    final file = await _getFileFor(name);
    file.writeAsBytes(data);
    return name;
  }

  Future<void> removeImage(String path) async {
    final docDir = await _getImageDir();
    final file = File(docDir + path);
    file.delete();
  }

  Future<File> _getFileFor(String name) async {
    var dir = await _getImageDir();
    return File(dir + name);
  }

  String _clipUrl(String url) {
    final reg = RegExp(r'[^A-Za-z0-9]');
    final res = url.replaceAll(reg, '');
    return res +'.jpg';
  }

  Future<String> getPathForSaveCameraImage(String path) async{
    var docDir = await _getImageDir();
    return docDir + path;
  }

  Future<String> _getImageDir() async {
    var docDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(docDir.path +'/images/');
    final newDir = await imageDir.create();
    return newDir.path;
  }

}
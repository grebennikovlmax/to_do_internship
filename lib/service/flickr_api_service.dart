import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FlickrApiService {

  final String _url = 'https://www.flickr.com/services/rest/';
  final String _jsonFormat = '&format=json&nojsoncallback=?';
  final String _apiKey = '&api_key=d328bb24cdf0fb1358182bd72884f361';
  final String _getRecentMethod = '?method=flickr.photos.getRecent&extras=url_m';
  final String _photoSearchMethod = '?method=flickr.photos.search&extras=url_m';

  Future<List<String>> getRecentPhotos() async {
    final url = _url + _getRecentMethod + _apiKey + _jsonFormat;
    final response = await http.get(url);
    return compute(_getPhotosURLfromJson, response.body);
  }

  Future<List<String>> searchPhotos({String searchText}) async {
    final url = _url + _photoSearchMethod + _apiKey + '&text=$searchText' + _jsonFormat;
    final response = await http.get(url);
    return compute(_getPhotosURLfromJson, response.body);
  }

}

List<String> _getPhotosURLfromJson(String response) {
  List<String> photoUrlList = [];
  final json = jsonDecode(response);
  final photos = json['photos'] as Map<String, dynamic>;
  final photoList = photos['photo'] as List<dynamic>;
  for(var photo in photoList) {
    final id = photo['id'] as String;
    final farm = photo['farm'] as int;
    final server = photo['server'] as String;
    final secret = photo['secret'] as String;
    final url = 'https://farm$farm.staticflickr.com/$server/$id' + '_$secret.jpg';
    photoUrlList.add(url);
  }
  return photoUrlList;
}


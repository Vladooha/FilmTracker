import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:random_film_app/model/dto/film/film_filter.dart';
import 'package:random_film_app/model/film/film.dart';

import 'package:random_film_app/service/mapper/film/film_mapper.dart';

class FilmApi {
  static const host = "https://www.kinopoisk.ru/chance/";
  static const jsonArg = "item=true";
  static const timeoutMs = 10000;

  static final FilmApi instance = FilmApi._();

  final FilmJsonMapper _filmJsonMapper = FilmJsonMapper.instance;

  FilmApi._();

  Future<List<Film>> getFilmsJson(FilmFilter filmFilter) async {
    String url = host + "?" + jsonArg + filmFilter.toUrl(isBegin: false);

    var request = http.Request("get", Uri.parse(url));
    request.followRedirects = true;

    return http.get(url)
        .timeout(Duration(milliseconds: timeoutMs))
        .then(_mapJsonToHtml)
        .then(_filmJsonMapper.mapHtmlJsonToFilmList);
  }

  Future<List<String>> _mapJsonToHtml(http.Response response) async {
    final json = jsonDecode(response.body);

    return json
        .cast<String>()
        .toList();
  }
}
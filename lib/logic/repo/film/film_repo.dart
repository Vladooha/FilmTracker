import 'package:random_film_app/model/dto/film/film_query.dart';
import 'package:random_film_app/model/dto/film/storage_film_filter.dart';
import 'package:random_film_app/model/film/film.dart';
import 'package:random_film_app/service/db/film/film_db.dart';
import 'package:random_film_app/util/db/db_query_utils.dart';

class FilmRepository {
  static final FilmRepository instance = FilmRepository._();

  final FilmDb _filmDb = FilmDb.instance;

  FilmRepository._();

  Future<List<Film>> getFilms({FilmQuery query}) async {
    return _filmDb.getFilms(query: query);
  }

  Future<void> saveFilms(List<Film> films) async {
    return _filmDb.saveFilms(films);
  }

  Future<void> deleteFilms(List<Film> films) async {
    return _filmDb.removeFilms(films);
  }

  Future<List<Film>> updateFilms(
      List<Film> films,
      {bool onlyApiData = false}) async {
    List<String> fields;
    if (onlyApiData) {
      fields = ['genres', 'countries', 'rating', 'name', 'description',
        'director', 'year', 'duration'];
    }

    return _filmDb.updateFilms(films, fieldNames: fields);
  }
}
import 'package:random_film_app/model/dto/film/film_query.dart';
import 'package:random_film_app/model/film/film.dart';
import 'package:random_film_app/model/film/film_country.dart';
import 'package:random_film_app/model/film/film_genre.dart';
import 'package:random_film_app/service/mapper/film/film_mapper.dart';
import 'package:sqflite/sqflite.dart';

import '../db_provider.dart';

class FilmDb {
  static final FilmDb instance = FilmDb._();

  final asyncDb = DatabaseProvider.instance.database;
  final filmMapper = FilmJsonMapper.instance;

  FilmDb._();

  Future<List<Film>> getFilmsByRawSql(String sql) async {
    final db = await asyncDb;

    return (await db.rawQuery(sql))
      .map(filmMapper.mapFromJson)
      .toList();
  }

  Future<List<Film>> getFilms({FilmQuery query}) async {
    final db = await asyncDb;

    List<Map<String, dynamic>> filmJsonList =
      await db.query(
          'FILM',
          where: _mapQueryToSql(query),
          offset: query.offset,
          limit: query.limit,
          orderBy: query.orderByQuery ?? 'create_time DESC',
      );

    if (null == filmJsonList || filmJsonList.isEmpty) {
      return <Film>[];
    }

    Map<int, Film> filmById = <int, Film>{};

    List<Film> films = filmJsonList
        .map((json) {
          Film film = filmMapper.mapFromJson(json);
          filmById[film.id] = film;

          return film;
        })
        .toList();

    List<Map<String, dynamic>> filmToGenreJsons =
      await db.query('FILM_TO_GENRE', where: 'film_id IN (${filmById.keys.join(',')})');

    List<Map<String, dynamic>> filmToCountryJsons =
      await db.query('FILM_TO_COUNTRY', where: 'film_id IN (${filmById.keys.join(',')})');

    filmToGenreJsons
      .forEach((json) {
        int filmId = json["film_id"] as int;
        int genreId = json["genre_id"] as int;
        FilmGenre genre = FilmGenre.values
          .firstWhere((genre) => genreId == genre.index);
        filmById[filmId].genres.add(genre);
      });

    filmToCountryJsons
      .forEach((json) {
        int filmId = json["film_id"] as int;
        int countryId = json["country_id"] as int;
        FilmCountry country = FilmCountry.values
            .firstWhere((country) => countryId == country.index);
        filmById[filmId].countries.add(country);
      });

    return films;
  }

  Future<void> saveFilms(List<Film> films) async {
    if (null == films || films.isEmpty) {
      return;
    }

    final db = await asyncDb;

    Batch batch = db.batch();
    for (Film film in films) {
      film.setSaved = true;
      var filmJson = filmMapper.mapToJson(film);
      batch.insert(
        'FILM',
        filmJson,
        conflictAlgorithm: ConflictAlgorithm.replace
      );

      batch.delete('FILM_TO_GENRE', where: 'film_id = ${film.id}');
      for (FilmGenre genre in film.genres) {
        var filmToGenreJson = {
          "film_id": film.id,
          "genre_id": genre.index,
        };
        batch.insert('FILM_TO_GENRE', filmToGenreJson);
      }

      batch.delete('FILM_TO_COUNTRY', where: 'film_id = ${film.id}');
      for (FilmCountry country in film.countries) {
        var filmToCountryJson = {
          "film_id": film.id,
          "country_id": country.index,
        };
        batch.insert('FILM_TO_COUNTRY', filmToCountryJson);
      }
    }
    batch.commit(noResult: true, continueOnError: false);
  }

  Future<void> removeFilms(List<Film> films) async {
    if (null == films || films.isEmpty) {
      return;
    }

    final db = await asyncDb;

    films.forEach((film) => film.setSaved = false);

    List<int> filmIds = films
      .map((film) => film.id)
      .toList();

    Batch batch = db.batch();

    batch.delete('FILM_TO_GENRE', where: 'film_id in (${filmIds.join(',')})');
    batch.delete('FILM_TO_COUNTRY', where: 'film_id in (${filmIds.join(',')})');
    batch.delete('FILM', where: 'id in (${filmIds.join(',')})');

    batch.commit(noResult: true, continueOnError: false);
  }

  Future<List<Film>> updateFilms(
      List<Film> films,
      {List<String> fieldNames}) async {
    final db = await asyncDb;

    List<Film> newFilms = [];
    Batch batch = db.batch();
    for (Film film in films) {
      if (film.isSaved) {
        Map<String, dynamic> filmJson = filmMapper.mapToJson(film);
        if (fieldNames != null) {
          filmJson.removeWhere((key, value) => !fieldNames.contains(key));
        }
        batch.update('FILM', filmJson, where: 'id = ${film.id}');

        if (null == fieldNames || fieldNames.contains('genres')) {
          batch.delete('FILM_TO_GENRE', where: 'film_id = ${film.id}');
          for (FilmGenre genre in film.genres) {
            var filmToGenreJson = {
              'film_id': film.id,
              'genre_id': genre.index,
            };
            batch.insert('FILM_TO_GENRE', filmToGenreJson);
          }
        }

        if (null == fieldNames || fieldNames.contains('countries')) {
          batch.delete('FILM_TO_COUNTRY', where: 'film_id = ${film.id}');
          for (FilmCountry country in film.countries) {
            var filmToCountryJson = {
              'film_id': film.id,
              'country_id': country.index,
            };
            batch.insert('FILM_TO_COUNTRY', filmToCountryJson);
          }
        }
      } else {
        newFilms.add(film);
      }
    }
    batch.commit(noResult: true, continueOnError: false);

    if (newFilms.isNotEmpty) {
      saveFilms(newFilms);
    }

    List<int> filmIds = films
      .map((film) => film.id)
      .toList();

    FilmQuery filmQuery = FilmQuery();
    filmQuery.ids = List.from(filmIds);
    return getFilms(query: filmQuery);
  }

  String _mapQueryToSql(FilmQuery filmQuery) {
    if (filmQuery != null) {
      List<String> whereClauses = [];
      if (filmQuery.ids != null && filmQuery.ids.isNotEmpty) {
        whereClauses.add("id IN (${filmQuery.ids.join(',')})");
      }
      if (filmQuery.nameQuery != null && filmQuery.nameQuery.isNotEmpty) {
        whereClauses.add("upper(name) LIKE '%${filmQuery.nameQuery.toUpperCase()}%'");
      }
      if (filmQuery.countries != null && filmQuery.countries.isNotEmpty) {
        whereClauses.add("EXISTS( "
            "SELECT 1 FROM FILM_TO_COUNTRY "
            "WHERE id = film_id "
            "AND country_id IN ("
            "${filmQuery.countries
              .map((country) => country.index)
              .join(',')})"
            ")");
      }
      if (filmQuery.countriesExcluded != null
          && filmQuery.countriesExcluded.isNotEmpty) {
        whereClauses.add("NOT EXISTS( "
            "SELECT 1 FROM FILM_TO_COUNTRY "
            "WHERE id = film_id "
            "AND country_id IN ("
            "${filmQuery.countriesExcluded
              .map((country) => country.index)
              .join(',')})"
            ")");
      }
      if (filmQuery.genres != null && filmQuery.genres.isNotEmpty) {
        whereClauses.add("EXISTS( "
            "SELECT 1 FROM FILM_TO_GENRE "
            "WHERE id = film_id "
            "AND genre_id IN ("
            "${filmQuery.genres
              .map((genre) => genre.index)
              .join(',')})"
            ")");
      }
      if (filmQuery.genresExcluded != null
          && filmQuery.genresExcluded.isNotEmpty) {
        whereClauses.add("NOT EXISTS( "
            "SELECT 1 FROM FILM_TO_GENRE "
            "WHERE id = film_id "
            "AND genre_id IN ("
            "${filmQuery.genresExcluded
              .map((genre) => genre.index)
              .join(',')})"
            ")");
      }
      if (filmQuery.dateFrom != null) {
        whereClauses.add(
          "create_time > ${filmQuery.dateFrom.millisecondsSinceEpoch}"
        );
      }

      if (whereClauses.isEmpty) {
        return null;
      }

      return "(${whereClauses.join(" AND ")}) ";
    }

    return null;
  }
}
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_film_app/logic/bloc/film/random/random_film_bloc_events.dart';
import 'package:random_film_app/logic/bloc/film/random/random_film_bloc_states.dart';
import 'package:random_film_app/logic/bloc/status/bloc_http_status.dart';
import 'package:random_film_app/logic/repo/film/film_repo.dart';
import 'package:random_film_app/model/dto/film/film_filter.dart';
import 'package:random_film_app/model/dto/film/film_query.dart';
import 'package:random_film_app/model/dto/film/storage_film_filter.dart';
import 'package:random_film_app/model/film/film.dart';
import 'package:random_film_app/model/film/film_country.dart';
import 'package:random_film_app/model/film/film_genre.dart';
import 'package:random_film_app/service/api/film/film_api.dart';

class RandomFilmBloc extends Bloc<RandomFilmEvent, RandomFilmState> {
  static const MAX_PARSE_RETRIES = 5;

  final FilmApi _filmApi = FilmApi.instance;
  final FilmRepository _filmRepository = FilmRepository.instance;

  FilmFilter lastFilter = FilmFilter.custom(
    count: 5,
    genresExcluded: {FilmGenre.Anime},
    countries: {FilmCountry.USSR, FilmCountry.USA},
  );

  RandomFilmBloc() : super(RandomFilmState.empty());

  getSameFilms() async {
    getFilms(lastFilter);
  }

  getFilms(FilmFilter filter, {bool cleanHistory: false}) {
    add(GetRandomFilms(filmFilter: filter, cleanHistory: cleanHistory));
  }

  @override
  Stream<RandomFilmState> mapEventToState(RandomFilmEvent event) async* {
    yield RandomFilmState.loading(state, event);

    if (event is GetRandomFilms) {
      yield await _getFilms(event);
    }

    yield state;
  }

  Future<RandomFilmState> _getFilms(GetRandomFilms event) async {
    lastFilter = event.filmFilter;

    List<Film> filmHistory = List.from(event.cleanHistory ? [] : state.films);

    return _getMoreFilms(event, filmHistory, 0, 0);
  }

  Future<RandomFilmState> _getMoreFilms(
      GetRandomFilms event,
      List<Film> filmHistory,
      int newFilmsCount,
      int parseTry) async {

    RandomFilmState errorResponse;
    List<Film> films = await _filmApi
        .getFilmsJson(event.filmFilter)
        .catchError((error) {
            errorResponse = RandomFilmState.timeout(state, event);

            return [];
          },
          test: (error) => error is TimeoutException)
        .catchError((error) {
            errorResponse = RandomFilmState.error(state, event, error.toString());

            return [];
          });

    if (errorResponse != null) {
      return errorResponse;
    }

    films = await _filterFilms(films, filmHistory, event.filmFilter);
    List<Film> allFilms = filmHistory + films;

    newFilmsCount += films.length;
    if (newFilmsCount < event.filmFilter.count && parseTry < MAX_PARSE_RETRIES) {
      return _getMoreFilms(event, allFilms, newFilmsCount, ++parseTry);
    }

    return RandomFilmState.successful(allFilms, event);
  }

  Future<List<Film>> _filterFilms(
      List<Film> films,
      List<Film> downloadedFilms,
      FilmFilter filter) async {
    int beginTime = DateTime.now().millisecondsSinceEpoch;
    List<int> filmIds = downloadedFilms
        .map((film) => film.id)
        .toList();

    var filmQuery = FilmQuery();
    filmQuery.ids = List.from(filmIds);
    List<Film> filmsFromDb =
      await _filmRepository.getFilms(query: filmQuery);

    List<Film> duplicatedFilms = films.where((film) {
      for (Film filmFromDb in filmsFromDb) {
        if (film.id == filmFromDb.id) {
          return true;
        }
      }

      return false;
    })
    .toList();

    for (Film duplicateFilm in duplicatedFilms) {
      films.remove(duplicateFilm);
    }

    if (!filter.excludeSaved) {
      List<Film> syncedDuplicateFilms =
        await _filmRepository.updateFilms(duplicatedFilms, onlyApiData: true);

      films.addAll(syncedDuplicateFilms);
    }

    List<int> downloadedFilmIds = downloadedFilms
        .map((film) => film.id)
        .toList();

    films = films
        .where((film) {
          if (downloadedFilmIds.contains(film.id)) {
            return false;
          }

          if (filter.countriesExcluded.intersection(film.countries.toSet()).isNotEmpty) {
            return false;
          }

          if (filter.genresExcluded.intersection(film.genres.toSet()).isNotEmpty) {
            return false;
          }

          if (!(film?.name?.toUpperCase()?.contains(filter?.nameQuery?.toUpperCase()) ?? false)) {
            return false;
          }

          if (film.rating < filter.minRating) {
            return false;
          }

          return true;
        }).toList();

    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Filter time is ${endTime - beginTime} ms. "
        "Returned ${films.length} films");

    return films;
  }
}
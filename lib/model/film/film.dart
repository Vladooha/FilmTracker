import 'package:equatable/equatable.dart';
import 'film_genre.dart';
import 'film_country.dart';

enum FilmGrade {
  LIKE, DISLIKE, NO_GRADE
}

class Film extends Equatable {
  int id;
  String name;
  String description;
  String director;
  int duration;
  int year;
  List<FilmGenre> genres;
  List<FilmCountry> countries;
  double rating;
  int saveTimeMs;
  FilmGrade userGrade;

  String get picUrl => "https://www.kinopoisk.ru/images/film_big/$id.jpg";
  String get sourceUrl => "https://www.kinopoisk.ru/film/$id";
  bool get isLoaded => id != -1;
  bool get isSaved => saveTimeMs != null;

  set setSaved(bool value) {
    if (value ?? false) {
      saveTimeMs = DateTime.now().millisecondsSinceEpoch;
    } else {
      saveTimeMs = null;
    }
  }

  Film({id, name, description, director, duration, year, genres,
    countries, rating, saveTimeMs, userGrade}) :
      id = id ?? -1,
      name = name ?? "",
      description = description ?? "",
      director = director ?? "",
      duration = duration ?? "",
      year = year ?? -1,
      genres = genres ?? [],
      countries = countries ?? [],
      rating = rating ?? -1,
      saveTimeMs = saveTimeMs,
      userGrade = userGrade ?? FilmGrade.NO_GRADE;

  factory Film.empty() {
    return Film();
  }

  @override
  String toString() {
    return 'Film {id: $id, name: $name}';
  }

  @override
  List<Object> get props => [id, name, description, year, genres, countries];
}
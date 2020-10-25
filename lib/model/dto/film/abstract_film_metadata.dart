import 'package:equatable/equatable.dart';
import 'package:random_film_app/model/film/film_country.dart';
import 'package:random_film_app/model/film/film_genre.dart';

abstract class FilmMetadata extends Equatable {
  FilmMetadata({
    this.nameQuery,
    Set<FilmGenre> genres,
    Set<FilmGenre> genresExcluded,
    Set<FilmCountry> countries,
    Set<FilmCountry> countriesExcluded,
  }) {
    this.genres = genres ?? <FilmGenre>{};
    this.genresExcluded = genresExcluded ?? <FilmGenre>{};
    this.countries = countries ?? <FilmCountry>{};
    this.countriesExcluded = countriesExcluded ?? <FilmCountry>{};
  }

  String nameQuery;
  Set<FilmGenre> genres;
  Set<FilmGenre> genresExcluded;
  Set<FilmCountry> countries;
  Set<FilmCountry> countriesExcluded;

  @override
  List<Object> get props => [
    nameQuery, genres, genresExcluded, countries, countriesExcluded
  ];

  @override
  bool get stringify => true;
}
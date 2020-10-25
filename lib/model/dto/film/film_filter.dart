import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import '../../film/film_genre.dart';
import '../../film/film_country.dart';
import 'package:random_film_app/util/http/mixin/url_encodable.dart';

import 'abstract_film_metadata.dart';

class FilmFilter extends FilmMetadata with UrlEncoded  {
  static const MIN_YEAR_LIMIT = 1900;

  int count;
  int minYear;
  int maxYear;
  int minRating;
  bool excludeSaved;

  FilmFilter({
    @required this.count,
    @required String nameQuery,
    @required Set<FilmGenre> genres,
    @required Set<FilmGenre> genresExcluded,
    @required Set<FilmCountry> countries,
    @required Set<FilmCountry> countriesExcluded,
    @required this.minYear,
    @required this.maxYear,
    @required this.minRating,
    @required this.excludeSaved})
    : super(
      nameQuery: nameQuery,
      genres: genres,
      genresExcluded: genresExcluded,
      countries: countries,
      countriesExcluded: countriesExcluded
    );

  factory FilmFilter.custom({
    int count,
    String nameQuery,
    Set<FilmGenre> genres,
    Set<FilmGenre> genresExcluded,
    Set<FilmCountry> countries,
    Set<FilmCountry> countriesExcluded,
    int minYear,
    int maxYear,
    int minRating,
    bool excludeSaved,
  }) {
    return FilmFilter(
        count: count ?? 1,
        nameQuery: nameQuery ?? "",
        genres: genres ?? <FilmGenre>{},
        genresExcluded: genresExcluded ?? <FilmGenre>{},
        countries: countries ?? <FilmCountry>{},
        countriesExcluded: countriesExcluded ?? <FilmCountry>{},
        minYear: minYear ?? 1900,
        maxYear: maxYear ?? DateTime.now().year,
        minRating: minRating ?? 0,
        excludeSaved: excludeSaved ?? true,
    );
  }

  factory FilmFilter.empty() {
    return FilmFilter.custom();
  }

  factory FilmFilter.copy(FilmFilter filter) {
    return FilmFilter(
        count: filter.count,
        nameQuery: filter.nameQuery,
        genres: filter.genres,
        genresExcluded: filter.genresExcluded,
        countries: filter.countries,
        countriesExcluded: filter.countriesExcluded,
        minYear: filter.minYear,
        maxYear: filter.maxYear,
        minRating: filter.minRating,
        excludeSaved: filter.excludeSaved);
  }

  @override
  Map<String, Object> get urlParams => {
    "count": count,
    "genre[]": genres.map((genre) => genre.index),
    "country[]": countries.map((country) => country.index),
    "max_years": maxYear,
    "min_years": minYear,
  };

  @override
  List<Object> get props => [
    nameQuery, genres, genresExcluded, countries,
    countriesExcluded, minYear, maxYear
  ];

  @override
  bool get stringify => true;
}
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts_cyrillic_ext_lite/google_fonts_cyrillic_ext_lite.dart';
import 'package:random_film_app/logic/bloc/film/random/random_film_bloc.dart';
import 'package:random_film_app/model/dto/film/abstract_film_metadata.dart';
import 'package:random_film_app/model/dto/film/film_filter.dart';
import 'package:random_film_app/model/dto/film/film_query.dart';
import 'package:random_film_app/model/film/film_country.dart';
import 'package:random_film_app/model/film/film_genre.dart';
import 'package:random_film_app/ui/layout/film_search.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';


enum ExcludedStatus {
  INCLUDED, EXCLUDED, DISABLED
}

class FilmSearchFilter extends StatefulWidget {
  FilmMetadata metadata;
  Function(void Function()) onStateUpdate;

  bool isFilter;
  bool isQuery;
  FilmFilter get filter => metadata as FilmFilter;
  FilmQuery get query => metadata as FilmQuery;

  FilmSearchFilter({this.metadata, this.onStateUpdate}) {
    if (null == metadata) {
      metadata = FilmFilter.custom(
        count: 5,
        genresExcluded: {FilmGenre.Anime},
        countries: {FilmCountry.USSR, FilmCountry.USA},
      );
    }

    if (metadata is FilmFilter) {
      isFilter = true;
      isQuery = false;
    } else {
      isFilter = false;
      isQuery = true;
    }
  }

  @override
  State createState() => _FilmSearchFilterState();
}

class _FilmSearchFilterState extends State<FilmSearchFilter> {
  static const FILTER_CHIP_LIMIT = 6;
  static const QUERY_CHIP_LIMIT = 4;

  int get chipLimit => widget.isFilter
    ? FILTER_CHIP_LIMIT
    : QUERY_CHIP_LIMIT;

  static int minYear = FilmFilter.MIN_YEAR_LIMIT;
  static int maxYear = DateTime.now().year;

  final List<FilmGenre> allGenres = List.of(FilmGenre.values);
  final List<FilmCountry> allCountries = List.of(FilmCountry.values);

  RangeValues yearsRange;

  Function(void Function()) get onStateUpdate =>
      widget.onStateUpdate ?? setState;

  @override
  void initState() {
    super.initState();

    if (widget.isFilter) {
      double minYearRange = (widget.filter?.minYear ?? minYear).toDouble();
      double maxYearRange = (widget.filter?.maxYear ?? maxYear).toDouble();

      yearsRange = RangeValues(minYearRange, maxYearRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> searchFilters = [];

    searchFilters.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 32.0),
                child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: "Введите часть названия",
                  ),
                  onChanged: _updateFilterNameQuery,
                ),
              ),
            ]
        ),
      ),
    );

    searchFilters.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Жанры",
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: CyrillicExtendedFonts.Comfortaa,
                      package: 'google_fonts_cyrillic_ext_lite'
                  ),
                ),
                Spacer(),
                RawMaterialButton(
                  child: Text(
                    "Все жанры",
                    style: TextStyle(
                        decoration: TextDecoration.underline
                    ),
                  ),
                  onPressed: _showAllGenresDialog,
                ),
              ],
            ),
            Divider(),
            SizedBox(
              height: 64.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    children: allGenres
                        .map((genre) => _getGenreChip(genre, onStateUpdate))
                        .toList(),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        height: double.maxFinite,
                        child: Icon(Icons.chevron_left),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Theme.of(context).canvasColor,
                                Theme.of(context).canvasColor.withOpacity(0.05),
                              ]
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: double.maxFinite,
                        child: Icon(Icons.chevron_right),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                Theme.of(context).canvasColor,
                                Theme.of(context).canvasColor.withOpacity(0.05),
                              ]
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );

    searchFilters.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Страны",
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: CyrillicExtendedFonts.Comfortaa,
                      package: 'google_fonts_cyrillic_ext_lite'
                  ),
                ),
                Spacer(),
                RawMaterialButton(
                  child: Text(
                    "Все страны",
                    style: TextStyle(
                        decoration: TextDecoration.underline
                    ),
                  ),
                  onPressed: _showAllCountriesDialog,
                ),
              ],
            ),
            Divider(),
            SizedBox(
              height: 64.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    children: allCountries
                        .map((country) => _getCountryChip(country, onStateUpdate))
                        .toList(),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        height: double.maxFinite,
                        child: Icon(Icons.chevron_left),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Theme.of(context).canvasColor,
                                Theme.of(context).canvasColor.withOpacity(0.05),
                              ]
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: double.maxFinite,
                        child: Icon(Icons.chevron_right),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                Theme.of(context).canvasColor,
                                Theme.of(context).canvasColor.withOpacity(0.05),
                              ]
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );

    if (widget.isFilter) {
      searchFilters.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Года выхода",
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: CyrillicExtendedFonts.Comfortaa,
                    package: 'google_fonts_cyrillic_ext_lite'
                ),
              ),
              Divider(),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("${widget.filter.minYear}"),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                          showValueIndicator: ShowValueIndicator.never,
                          valueIndicatorColor: Theme.of(context).buttonColor
                      ),
                      child: RangeSlider(
                          values: yearsRange,
                          min: minYear.toDouble(),
                          max: maxYear.toDouble(),
                          divisions: maxYear - minYear + 1,
                          labels: RangeLabels(
                              "${yearsRange.start.round()}", "${yearsRange.end.round()}"
                          ),
                          onChanged: (values) {
                            widget.filter.minYear = values.start.round();
                            widget.filter.maxYear = values.end.round();
                            yearsRange = RangeValues(values.start, values.end);

                            onStateUpdate(() {});
                          }
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("${widget.filter.maxYear}"),
                  ),
                ],
              ),
              Divider(),
            ],
          ),
        ),
      );

      searchFilters.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Минимальный рейтинг",
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: CyrillicExtendedFonts.Comfortaa,
                    package: 'google_fonts_cyrillic_ext_lite'
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("0"),
                  ),
                  SmoothStarRating(
                    // size: 16.0,
                    starCount: 10,
                    rating: widget.filter.minRating.toDouble(),
                    onRated: (rating) {
                      widget.filter.minRating = rating.round();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("10"),
                  ),
                ],
              ),
              Divider(),
            ],
          ),
        ),
      );

      searchFilters.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Checkbox(
                    value: true,
                    onChanged: (status) => onStateUpdate(() {
                      widget.filter.excludeSaved = status;
                    }),
                  ),
                ),
                Text("Скрыть сохранённые фильмы"),
              ],
            ),
            Divider(),
          ],
        ),
      );

      searchFilters.add(
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 96.0),
            child: Container(
              width: double.maxFinite,
              child: RaisedButton(
                  color: Theme.of(context).accentColor,
                  child: Text("Найти"),
                  onPressed: () {
                    BlocProvider.of<RandomFilmBloc>(context)
                        .getFilms(widget.filter, cleanHistory: true);
                    SearchFilmsLayoutSubtype.goToFilmsLayout(context);
                  }
              ),
            ),
          ),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: widget.isQuery ? NeverScrollableScrollPhysics() : null,
      children: searchFilters,
    );
  }

  _sortGenres() {
    allGenres.sort((genre1, genre2) {
      var status1 = _getGenreStatus(genre1);
      var status2 = _getGenreStatus(genre2);

      return status1.index - status2.index;
    });
  }

  _sortCountries() {
    allCountries.sort((country1, country2) {
      var status1 = _getCountryStatus(country1);
      var status2 = _getCountryStatus(country2);

      return status1.index - status2.index;
    });
  }

  ExcludedStatus _getGenreStatus(FilmGenre genre) {
    var status = ExcludedStatus.DISABLED;
    if (widget.metadata.genres.contains(genre)) {
      status = ExcludedStatus.INCLUDED;
    } else if (widget.metadata.genresExcluded.contains(genre)) {
      status = ExcludedStatus.EXCLUDED;
    }

    return status;
  }

  ExcludedStatus _getCountryStatus(FilmCountry country) {
    var status = ExcludedStatus.DISABLED;
    if (widget.metadata.countries.contains(country)) {
      status = ExcludedStatus.INCLUDED;
    } else if (widget.metadata.countriesExcluded.contains(country)) {
      status = ExcludedStatus.EXCLUDED;
    }

    return status;
  }

  Widget _getGenreChip(FilmGenre genre, Function stateUpdater) {
    var status = _getGenreStatus(genre);

    Color backgroundColor;
    void Function() onTap;
    Widget avatar;
    switch (status) {
      case ExcludedStatus.INCLUDED:
        avatar = Icon(Icons.check);
        backgroundColor = Theme.of(context).accentColor;
        onTap = () {
          widget.metadata.genres.remove(genre);
          widget.metadata.genresExcluded.add(genre);
          stateUpdater(() {});
        };
        break;
      case ExcludedStatus.EXCLUDED:
        avatar = Icon(Icons.cancel);
        backgroundColor = Theme.of(context).errorColor;
        onTap = () {
          widget.metadata.genresExcluded.remove(genre);
          stateUpdater(() {});
        };
        break;
      case ExcludedStatus.DISABLED:
        onTap = () {
          widget.metadata.genres.add(genre);
          stateUpdater(() {});
        };
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ActionChip(
        avatar: avatar,
        label: Text(genre.name),
        backgroundColor: backgroundColor,
        onPressed: onTap,
      ),
    );
  }

  Widget _getCountryChip(FilmCountry country, Function stateUpdater) {
    var status = _getCountryStatus(country);

    Color backgroundColor;
    void Function() onTap;
    Widget avatar;
    switch (status) {
      case ExcludedStatus.INCLUDED:
        avatar = Icon(Icons.check);
        backgroundColor = Theme.of(context).accentColor;
        onTap = () {
          widget.metadata.countries.remove(country);
          widget.metadata.countriesExcluded.add(country);
          stateUpdater(() {});
        };
        break;
      case ExcludedStatus.EXCLUDED:
        avatar = Icon(Icons.cancel);
        backgroundColor = Theme.of(context).errorColor;
        onTap = () {
          widget.metadata.countriesExcluded.remove(country);
          stateUpdater(() {});
        };
        break;
      case ExcludedStatus.DISABLED:
        onTap = () {
          widget.metadata.countries.add(country);
          stateUpdater(() {});
        };
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ActionChip(
        avatar: avatar,
        label: Text(country.name),
        backgroundColor: backgroundColor,
        onPressed: onTap,
      ),
    );
  }

  _showAllGenresDialog() => showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (context, stateUpdater) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Жанры",
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: CyrillicExtendedFonts.Comfortaa,
                        package: 'google_fonts_cyrillic_ext_lite'
                    ),
                  ),
                  Divider(),
                  Wrap(
                    children: FilmGenre.values
                        .map((genre) => _getGenreChip(genre, stateUpdater))
                        .toList(),
                  ),
                ]
            ),
          ),
        ),
      )
    )
    .then((_) => onStateUpdate(_sortGenres));

  _showAllCountriesDialog() => showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: StatefulBuilder(
          builder: (context, stateUpdater) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Страны",
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: CyrillicExtendedFonts.Comfortaa,
                    package: 'google_fonts_cyrillic_ext_lite'
                ),
              ),
              Divider(),
              Wrap(
                children: FilmCountry.values
                    .map((country) => _getCountryChip(country, stateUpdater))
                    .toList(),
              ),
            ]
          ),
        ),
      ),
    )
  )
  .then((_) => onStateUpdate(_sortCountries));

  _updateFilterNameQuery(String value) {
    widget.metadata.nameQuery = value;
    if (widget.isQuery) {
      onStateUpdate(() {});
    }
  }
}
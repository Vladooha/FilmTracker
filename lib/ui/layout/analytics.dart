import 'dart:io';

import 'package:charts_common/src/chart/cartesian/axis/spec/date_time_axis_spec.dart' as dateTimeFormatterHolder show BasicDateTimeTickFormatterSpec;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts_cyrillic_ext_lite/google_fonts_cyrillic_ext_lite.dart';
import 'package:intl/intl.dart';
import 'package:random_film_app/logic/bloc/film/analytics/film_analytics_bloc.dart';
import 'package:random_film_app/logic/bloc/film/analytics/film_analytics_bloc_events.dart';
import 'package:random_film_app/logic/bloc/film/analytics/film_analytics_bloc_state.dart';
import 'package:random_film_app/logic/bloc/status/bloc_sql_status.dart';
import 'package:random_film_app/model/film/film.dart';
import 'package:random_film_app/model/film/film_country.dart';
import 'package:random_film_app/model/film/film_genre.dart';
import 'package:random_film_app/ui/screen/home_screen.dart';

final analyticsScrollController = ScrollController();

class Analytics extends StatefulWidget implements AbstractLayout {
  static GlobalKey _analyticsKey = GlobalKey();

  final int currentLayoutIndex;

  Analytics({this.currentLayoutIndex}) : super(key: _analyticsKey);

  @override
  int get layoutIndex => 2;

  @override
  bool get isLayoutChosen => layoutIndex == currentLayoutIndex;

  @override
  GlobalKey<State<StatefulWidget>> get stateKey => _analyticsKey;

  @override
  State<StatefulWidget> createState() => _AnalyticsState();

  @override
  onLayoutDraw(BuildContext context) {
    AnalyticsLayoutSubtype.goToAnalyticsLayout(context, analyticsScrollController);
  }

  @override
  updateStateKey(BuildContext context) {
    _analyticsKey = GlobalKey();
  }
}

class _AnalyticsState extends State<Analytics> {
  static const GRAPH_HEIGHT = 256.0;
  static const BAR_WIDTH = 128.0;
  static const POINT_WIDTH = 64.0;

  final _genreScrollController = ScrollController();
  final _countriesScrollController = ScrollController();
  final _saveScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _sendAnalyticsRequest(AnalyticsType.TotalShort);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FilmAnalyticsState>(
      stream: _getAnalyticsStream(AnalyticsType.TotalShort),
      builder: (context, snapshot) {
        if (null == snapshot.data || snapshot.data.status is SqlLoading) {
          return _loading;
        }

        if (snapshot.data.status is SqlError) {
          return _error;
        }

        var analyticsState = snapshot.data as FilmAnalyticsData;
        var analyticsData = analyticsState.data as FilmAnalyticsTotalShort;

        if (analyticsData.saveAnalytics.saveDates.isEmpty) {
          return _emptyFilmList;
        }

        return ListView(
          controller: analyticsScrollController,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Количество оценок",
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: CyrillicExtendedFonts.Comfortaa,
                        package: 'google_fonts_cyrillic_ext_lite'
                    ),
                  ),
                  Divider(),
                  Row(
                      children: [
                        _getGradeChart(analyticsData.gradeAnalytics),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _getColorDescription(Colors.green, "нравится"),
                            _getColorDescription(Colors.red, "не нравится"),
                            _getColorDescription(Colors.grey, "без оценки")
                          ],
                        )
                      ]
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Оценки по жанрам",
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: CyrillicExtendedFonts.Comfortaa,
                        package: 'google_fonts_cyrillic_ext_lite'
                    ),
                  ),
                  Divider(),
                  Scrollbar(
                    isAlwaysShown: true,
                    radius: Radius.circular(8.0),
                    controller: _genreScrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _genreScrollController,
                        child: _getGenreChart(analyticsData.genreAnalytics),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Оценки по странам",
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: CyrillicExtendedFonts.Comfortaa,
                        package: 'google_fonts_cyrillic_ext_lite'
                    ),
                  ),
                  Divider(),
                  Scrollbar(
                    isAlwaysShown: true,
                    radius: Radius.circular(8.0),
                    controller: _countriesScrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _countriesScrollController,
                        child: _getCountriesChart(analyticsData.countryAnalytics),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "История сохранений",
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: CyrillicExtendedFonts.Comfortaa,
                        package: 'google_fonts_cyrillic_ext_lite'
                    ),
                  ),
                  Divider(),
                  Scrollbar(
                    isAlwaysShown: true,
                    radius: Radius.circular(8.0),
                    controller: _saveScrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _saveScrollController,
                        child: _getSaveChart(analyticsData.saveAnalytics),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        );
      }
    );
  }

  // UI parts

  Widget get _loading => Center(
    child: SizedBox(
      width: 64.0,
      height: 64.0,
      child: CircularProgressIndicator(),
    ),
  );

  Widget get _error => Center(
    child: Column(
      children: [
        Icon(Icons.error),
        Text(
          "Возникла непредвиденная ошибка",
          style: TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
              fontFamily: CyrillicExtendedFonts.Comfortaa,
              package: 'google_fonts_cyrillic_ext_lite'
          ),
        ),
      ],
    ),
  );

  Widget get _emptyFilmList => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          FontAwesomeIcons.folderOpen,
          size: 128.0,
          color: Theme.of(context).disabledColor,
        ),
        Text(
          "Нет сохранённых фильмов",
          style: TextStyle(
              color: Theme.of(context).disabledColor,
              fontSize: 16.0,
              fontFamily: CyrillicExtendedFonts.Comfortaa,
              package: 'google_fonts_cyrillic_ext_lite'
          ),
        ),
      ],
    ),
  );

  Widget _getColorDescription(Color color, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            height: 12.0,
            width: 12.0,
            color: color,
          ),
          Text(
            " - ",
            style: TextStyle(
                fontSize: 12.0
            ),
          ),
          Text(
            description,
            style: TextStyle(
                fontSize: 12.0
            ),
          ),
        ],
      ),
    );
  }

  // Charts UI

  Widget _getGradeChart(FilmAnalyticsGradeTotal gradeAnalytics) {
    var gradeSeries = charts.Series<MapEntry<FilmGrade, int>, String>(
      data: gradeAnalytics.gradesCount.entries.toList(),
      domainFn: (gradeCount, _) => gradeCount.key.toString(),
      measureFn: (gradeCount, _) => gradeCount.value,
      labelAccessorFn: (gradeCount, _) {
        if (gradeCount.value != 0) {
          return gradeCount.value.toString();
        } else {
          return null;
        }
      },
      colorFn: (gradeCount, _) {
        if (FilmGrade.LIKE == gradeCount.key) {
          return charts.ColorUtil.fromDartColor(Colors.green);
        } else if (FilmGrade.DISLIKE == gradeCount.key) {
          return charts.ColorUtil.fromDartColor(Colors.red);
        } else {
          return charts.ColorUtil.fromDartColor(Colors.grey);
        }
      },
    );

    return SizedBox(
      height: GRAPH_HEIGHT,
      width: GRAPH_HEIGHT,
      child: charts.PieChart(
        [gradeSeries],
        animate: true,
        defaultRenderer: new charts.ArcRendererConfig(
          arcWidth: 32,
          arcRendererDecorators: [new charts.ArcLabelDecorator()]
        ),
      ),
    );
  }

  Widget _getSaveChart(FilmAnalyticsCountBySaveDate saveAnalytics) {
    var saveDateSeries = charts.Series<MapEntry<DateTime, int>, DateTime>(
      data: saveAnalytics.saveDates.entries.toList(),
      domainFn: (saveData, _) => saveData.key,
      measureFn: (saveData, _) => saveData.value,
      colorFn: (_, __) =>
          charts.ColorUtil.fromDartColor(Theme.of(context).accentColor),
    );
    double screenWidth = MediaQuery.of(context).size.width;
    double chartWidth = POINT_WIDTH * saveAnalytics.saveDates.length;

    return SizedBox(
      height: GRAPH_HEIGHT,
      width: chartWidth > screenWidth
        ? chartWidth
        : screenWidth,
      child: charts.TimeSeriesChart(
        [saveDateSeries],
        animate: true,
        defaultRenderer: charts.LineRendererConfig(
          includeArea: true,
          stacked: true
        ),
        domainAxis: charts.DateTimeAxisSpec(
          tickFormatterSpec:
            dateTimeFormatterHolder.BasicDateTimeTickFormatterSpec.fromDateFormat(
              DateFormat.yMMM(Platform.localeName)
            )
        )
      ),
    );
  }

  Widget _getCountriesChart(FilmAnalyticsGradeByCountry countryAnalytics) {
    var likedSeries = charts.Series<MapEntry<FilmCountry, Map<FilmGrade, int>>, String>(
      data: countryAnalytics.countriesGrades.entries.toList(),
      domainFn: (countryGrade, _) => countryGrade.key.toString(),
      measureFn: (countryGrade, _) => countryGrade.value[FilmGrade.LIKE],
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.green),
    );

    var dislikedSeries = charts.Series<MapEntry<FilmCountry, Map<FilmGrade, int>>, String>(
      data: countryAnalytics.countriesGrades.entries.toList(),
      domainFn: (countryGrade, _) => countryGrade.key.toString(),
      measureFn: (countryGrade, _) => countryGrade.value[FilmGrade.DISLIKE],
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.red),
    );

    var noGradeSeries = charts.Series<MapEntry<FilmCountry, Map<FilmGrade, int>>, String>(
      data: countryAnalytics.countriesGrades.entries.toList(),
      domainFn: (countryGrade, _) => countryGrade.key.toString(),
      measureFn: (countryGrade, _) => countryGrade.value[FilmGrade.NO_GRADE],
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.grey),
    );

    double screenWidth = MediaQuery.of(context).size.width;
    double chartWidth = BAR_WIDTH * countryAnalytics.countriesGrades.length;

    return SizedBox(
      height: GRAPH_HEIGHT,
      width: chartWidth > screenWidth
          ? chartWidth
          : screenWidth,
      child: charts.BarChart(
        [likedSeries, dislikedSeries, noGradeSeries],
        animate: true,
        barGroupingType: charts.BarGroupingType.grouped,
        defaultRenderer: charts.BarRendererConfig(
          strokeWidthPx: 16.0,
        ),
      ),
    );
  }

  Widget _getGenreChart(FilmAnalyticsGradeByGenre genreAnalytics) {
    var likedSeries = charts.Series<MapEntry<FilmGenre, Map<FilmGrade, int>>, String>(
      data: genreAnalytics.genresGrades.entries.toList(),
      domainFn: (genreGrade, _) => genreGrade.key.toString(),
      measureFn: (genreGrade, _) => genreGrade.value[FilmGrade.LIKE],
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.green),
    );

    var dislikedSeries = charts.Series<MapEntry<FilmGenre, Map<FilmGrade, int>>, String>(
      data: genreAnalytics.genresGrades.entries.toList(),
      domainFn: (genreGrade, _) => genreGrade.key.toString(),
      measureFn: (genreGrade, _) => genreGrade.value[FilmGrade.DISLIKE],
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.red),
    );

    var noGradeSeries = charts.Series<MapEntry<FilmGenre, Map<FilmGrade, int>>, String>(
      data: genreAnalytics.genresGrades.entries.toList(),
      domainFn: (genreGrade, _) => genreGrade.key.toString(),
      measureFn: (genreGrade, _) => genreGrade.value[FilmGrade.NO_GRADE],
      colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.grey),
    );

    double screenWidth = MediaQuery.of(context).size.width;
    double chartWidth = BAR_WIDTH * genreAnalytics.genresGrades.length;

    return SizedBox(
      height: GRAPH_HEIGHT,
      width: chartWidth > screenWidth
          ? chartWidth
          : screenWidth,
      child: charts.BarChart(
        [likedSeries, dislikedSeries, noGradeSeries],
        animate: true,
        barGroupingType: charts.BarGroupingType.grouped,
      ),
    );
  }

  // UI logic

  _sendAnalyticsRequest(AnalyticsType type) {
    BlocProvider.of<FilmAnalyticsBloc>(context).getFilmAnalytics(type);
  }

  _getAnalyticsStream(AnalyticsType type) {
    return BlocProvider.of<FilmAnalyticsBloc>(context)
        .where((state) {
            if (state is FilmAnalyticsData && state.event is GetFilmAnalytics) {
              return (state.event as GetFilmAnalytics).analyticsType == type;
            }

          return false;
        });
  }
}

class AnalyticsLayoutSubtype extends LayoutSubtype {
  static void goToAnalyticsLayout(
      BuildContext context,
      ScrollController analyticsScrollController) {
    var layoutTypeContainer = LayoutSubtypeContainer.of(context);
    layoutTypeContainer.layoutSubtype =
        AnalyticsLayoutSubtype();
  }

  @override
  Widget buildFloatButton(BuildContext context) {
    return FloatingActionButton(
        child: Icon(Icons.keyboard_arrow_up),
        onPressed: () => analyticsScrollController.animateTo(
            0.0,
            duration: Duration(milliseconds: 500),
            curve: Curves.linear
        )
    );
  }
}
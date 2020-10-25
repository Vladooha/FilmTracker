import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_film_app/logic/bloc/film/analytics/film_analytics_bloc_events.dart';
import 'package:random_film_app/logic/bloc/film/analytics/film_analytics_bloc_state.dart';
import 'package:random_film_app/model/film/film.dart';
import 'package:random_film_app/model/film/film_country.dart';
import 'package:random_film_app/model/film/film_genre.dart';
import 'package:random_film_app/service/db/db_provider.dart';

enum AnalyticsType {
  TotalShort, GradeTotal, GradeByGenre, GradeByCountry, CountBySaveDate
}

abstract class FilmAnalyticsChartData {
  AnalyticsType get type;
}

class FilmAnalyticsTotalShort extends FilmAnalyticsChartData {
  @override
  AnalyticsType get type => AnalyticsType.TotalShort;

  FilmAnalyticsGradeTotal gradeAnalytics;
  FilmAnalyticsGradeByGenre genreAnalytics;
  FilmAnalyticsGradeByCountry countryAnalytics;
  FilmAnalyticsCountBySaveDate saveAnalytics;
}

class FilmAnalyticsGradeTotal extends FilmAnalyticsChartData {
  @override
  AnalyticsType get type => AnalyticsType.GradeTotal;

  Map<FilmGrade, int> gradesCount = {};
}

class FilmAnalyticsGradeByGenre extends FilmAnalyticsChartData {
  @override
  AnalyticsType get type => AnalyticsType.GradeByGenre;

  Map<FilmGenre, Map<FilmGrade, int>> genresGrades = {};
}

class FilmAnalyticsGradeByCountry extends FilmAnalyticsChartData {
  @override
  AnalyticsType get type => AnalyticsType.GradeByCountry;

  Map<FilmCountry, Map<FilmGrade, int>> countriesGrades = {};
}

class FilmAnalyticsCountBySaveDate extends FilmAnalyticsChartData {
  @override
  AnalyticsType get type => AnalyticsType.CountBySaveDate;

  Map<DateTime, int> saveDates = {};
}



class FilmAnalyticsBloc extends Bloc<FilmAnalyticsEvent, FilmAnalyticsState> {
  static const int SHORT_LIMIT = 3;

  final DatabaseProvider _dbProvider = DatabaseProvider.instance;

  FilmAnalyticsBloc() : super(FilmAnalyticsData.loading(null));

  getFilmAnalytics(AnalyticsType analyticsType) {
    add(GetFilmAnalytics(analyticsType));
  }

  @override
  Stream<FilmAnalyticsState> mapEventToState(FilmAnalyticsEvent event) async* {
    if (event is GetFilmAnalytics) {
      yield* _getFilmAnalytics(event);
    }
  }

  Stream<FilmAnalyticsState> _getFilmAnalytics(
      GetFilmAnalytics event) async* {
    yield FilmAnalyticsData.loading(event);

    try {
      FilmAnalyticsChartData analytics;
      if (AnalyticsType.GradeByGenre == event.analyticsType) {
        analytics = await _createGradeByGenreAnalytics(false);
      } else if (AnalyticsType.GradeByCountry == event.analyticsType) {
        analytics = await _createGradeByCountryAnalytics(false);
      } else if (AnalyticsType.CountBySaveDate == event.analyticsType) {
        analytics = await _createCountBySaveDateAnalytics(false);
      } else if (AnalyticsType.GradeTotal == event.analyticsType) {
        analytics = await _createGradeTotalAnalytics();
      } else {
        var gradeAnalytics = await _createGradeTotalAnalytics();
        var genreAnalytics = await _createGradeByGenreAnalytics(false);
        var countryAnalytics = await _createGradeByCountryAnalytics(false);
        var saveAnalytics = await _createCountBySaveDateAnalytics(false);
        analytics = FilmAnalyticsTotalShort()
          ..gradeAnalytics = gradeAnalytics
          ..genreAnalytics = genreAnalytics
          ..countryAnalytics = countryAnalytics
          ..saveAnalytics = saveAnalytics;
      }

      yield FilmAnalyticsData.success(event, analytics);
    } catch (error) {
      yield FilmAnalyticsData.error(event, error.toString());
    }
  }

  Future<FilmAnalyticsGradeTotal> _createGradeTotalAnalytics() async {
    String sql =
        "SELECT "
        "   COUNT("
        "       CASE FILM.user_grade "
        "       WHEN '${FilmGrade.LIKE.toString()}' "
        "       THEN id "
        "       ELSE null "
        "       END "
        "   ) AS likes, "
        "   COUNT("
        "       CASE FILM.user_grade "
        "       WHEN '${FilmGrade.DISLIKE.toString()}' "
        "       THEN id "
        "       ELSE null "
        "       END "
        "   ) AS dislikes, "
        "   COUNT("
        "       CASE FILM.user_grade "
        "       WHEN '${FilmGrade.NO_GRADE.toString()}' "
        "       THEN id "
        "       ELSE null "
        "       END "
        "   ) AS no_grade "
        "FROM FILM ";

    List<Map<String, dynamic>> analyticsJson =
    await _dbProvider.passRawQuery(sql);

    var analytics = FilmAnalyticsGradeTotal();
    for (Map<String, dynamic> row in analyticsJson) {
      analytics.gradesCount = {
        FilmGrade.LIKE: row["likes"],
        FilmGrade.DISLIKE: row["dislikes"],
        FilmGrade.NO_GRADE: row["no_grade"],
      };
    }

    return analytics;
  }

  Future<FilmAnalyticsGradeByCountry> _createGradeByCountryAnalytics(
      bool isShort) async {
    String sql =
        "SELECT "
        "   FILM.id AS id, "
        "   FILM_TO_COUNTRY.country_id AS country_id, "
        "   COUNT("
        "       CASE FILM.user_grade "
        "       WHEN '${FilmGrade.LIKE.toString()}' "
        "       THEN id "
        "       ELSE null "
        "       END "
        "   ) AS likes, "
        "   COUNT("
        "       CASE FILM.user_grade "
        "       WHEN '${FilmGrade.DISLIKE.toString()}' "
        "       THEN id "
        "       ELSE null "
        "       END "
        "   ) AS dislikes, "
        "   COUNT("
        "       CASE FILM.user_grade "
        "       WHEN '${FilmGrade.NO_GRADE.toString()}' "
        "       THEN id "
        "       ELSE null "
        "       END "
        "   ) AS no_grade "
        "FROM FILM "
        "JOIN FILM_TO_COUNTRY ON FILM.id = FILM_TO_COUNTRY.film_id "
        "GROUP BY FILM_TO_COUNTRY.country_id "
        "ORDER BY 3 DESC ";
    if (isShort) {
      sql += "LIMIT $SHORT_LIMIT ";
    }

    List<Map<String, dynamic>> analyticsJson =
    await _dbProvider.passRawQuery(sql);

    var analytics = FilmAnalyticsGradeByCountry();
    for (Map<String, dynamic> row in analyticsJson) {
      FilmCountry country = FilmCountry.findByIndex(row["country_id"]);
      if (country != null) {
        Map<FilmGrade, int> grades = {
          FilmGrade.LIKE: row["likes"],
          FilmGrade.DISLIKE: row["dislikes"],
          FilmGrade.NO_GRADE: row["no_grade"],
        };
        analytics.countriesGrades[country] = grades;
      }
    }

    return analytics;
  }

  Future<FilmAnalyticsCountBySaveDate> _createCountBySaveDateAnalytics(
      bool isShort) async {
    String sql =
        "SELECT "
        "   COUNT(id) AS film_count, "
        "   strftime('%Y-%m', create_time/1000, 'unixepoch') AS year_month_str "
        "FROM FILM "
        "GROUP BY 2 "
        "ORDER BY 2 ";
    if (isShort) {
      sql += "LIMIT $SHORT_LIMIT ";
    }

    List<Map<String, dynamic>> analyticsJson =
    await _dbProvider.passRawQuery(sql);

    var analytics = FilmAnalyticsCountBySaveDate();
    for (Map<String, dynamic> row in analyticsJson) {
      List<int> yearAndMonth = row["year_month_str"]
          .toString()
          .split("-")
          .map(int.parse)
          .toList();

      var date = DateTime(
        yearAndMonth[0],
        yearAndMonth[1],
      );
      analytics.saveDates[date] = row["film_count"];
    }

    return analytics;
  }

  Future<FilmAnalyticsGradeByGenre> _createGradeByGenreAnalytics(
      bool isShort) async {
    String sql =
        "SELECT "
        "   FILM.id AS id, "
        "   FILM_TO_GENRE.genre_id AS genre_id, "
        "   COUNT("
        "       CASE FILM.user_grade "
        "       WHEN '${FilmGrade.LIKE.toString()}' "
        "       THEN id "
        "       ELSE null "
        "       END "
        "   ) AS likes, "
        "   COUNT("
        "       CASE FILM.user_grade "
        "       WHEN '${FilmGrade.DISLIKE.toString()}' "
        "       THEN id "
        "       ELSE null "
        "       END "
        "   ) AS dislikes, "
        "   COUNT("
        "       CASE FILM.user_grade "
        "       WHEN '${FilmGrade.NO_GRADE.toString()}' "
        "       THEN id "
        "       ELSE null "
        "       END "
        "   ) AS no_grade "
        "FROM FILM "
        "JOIN FILM_TO_GENRE ON FILM.id = FILM_TO_GENRE.film_id "
        "GROUP BY FILM_TO_GENRE.genre_id "
        "ORDER BY 3 DESC ";
    if (isShort) {
      sql += "LIMIT $SHORT_LIMIT ";
    }

    List<Map<String, dynamic>> analyticsJson =
    await _dbProvider.passRawQuery(sql);

    var analytics = FilmAnalyticsGradeByGenre();
    for (Map<String, dynamic> row in analyticsJson) {
      FilmGenre genre = FilmGenre.findByIndex(row["genre_id"]);
      if (genre != null) {
        Map<FilmGrade, int> grades = {
          FilmGrade.LIKE: row["likes"],
          FilmGrade.DISLIKE: row["dislikes"],
          FilmGrade.NO_GRADE: row["no_grade"],
        };
        analytics.genresGrades[genre] = grades;
      }
    }

    return analytics;
  }
}
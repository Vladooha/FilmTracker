import 'package:random_film_app/logic/bloc/bloc_event.dart';
import 'package:random_film_app/logic/bloc/bloc_state.dart';
import 'package:random_film_app/logic/bloc/film/analytics/film_analytics_bloc.dart';
import 'package:random_film_app/logic/bloc/film/analytics/film_analytics_bloc_events.dart';
import 'package:random_film_app/logic/bloc/status/abstract_bloc_status.dart';
import 'package:random_film_app/logic/bloc/status/bloc_sql_status.dart';

abstract class FilmAnalyticsState extends BlocState<FilmAnalyticsEvent> {
  FilmAnalyticsState(BlocStatus status, FilmAnalyticsEvent event) : super(status, event);
}

class FilmAnalyticsData extends FilmAnalyticsState {
  final FilmAnalyticsChartData data;

  FilmAnalyticsData(SqlStatus status, FilmAnalyticsEvent event, {this.data})
      : super(status, event);

  factory FilmAnalyticsData.loading(FilmAnalyticsEvent event) =>
      FilmAnalyticsData(SqlLoading(), event);

  factory FilmAnalyticsData.error(FilmAnalyticsEvent event, String error) =>
      FilmAnalyticsData(SqlError(error), event);

  factory FilmAnalyticsData.success(
          FilmAnalyticsEvent event,
          FilmAnalyticsChartData data) =>
      FilmAnalyticsData(SqlOk(), event, data: data);
}
import 'package:random_film_app/logic/bloc/bloc_event.dart';
import 'package:random_film_app/logic/bloc/film/analytics/film_analytics_bloc.dart';

abstract class FilmAnalyticsEvent extends BlocEvent {}

class GetFilmAnalytics extends FilmAnalyticsEvent {
  final AnalyticsType analyticsType;

  GetFilmAnalytics(this.analyticsType);
}
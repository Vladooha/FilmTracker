import 'package:flutter/foundation.dart';
import 'package:random_film_app/model/dto/film/film_filter.dart';

import '../../bloc_event.dart';

abstract class RandomFilmEvent extends BlocEvent {}

class GetRandomFilms extends RandomFilmEvent {
  final FilmFilter filmFilter;
  final bool cleanHistory;

  GetRandomFilms({@required this.filmFilter, this.cleanHistory = false});
}
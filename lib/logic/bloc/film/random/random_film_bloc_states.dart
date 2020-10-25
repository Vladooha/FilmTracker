
import 'package:flutter/foundation.dart';
import 'package:random_film_app/logic/bloc/bloc_event.dart';
import 'package:random_film_app/logic/bloc/film/random/random_film_bloc_events.dart';
import 'package:random_film_app/logic/bloc/status/bloc_http_status.dart';
import 'package:random_film_app/logic/bloc/status/abstract_bloc_status.dart';
import 'package:random_film_app/model/film/film.dart';

import '../../bloc_state.dart';

class RandomFilmState extends BlocState<RandomFilmEvent> {
  final List<Film> films;

  RandomFilmState({
    @required HttpStatus httpStatus,
    @required RandomFilmEvent event,
    @required this.films})
      : super(httpStatus, event);

  factory RandomFilmState.empty() {
    return RandomFilmState(
        httpStatus: HttpOk(),
        event: null,
        films: []
    );
  }

  factory RandomFilmState.successful(
      final List<Film> films,
      final RandomFilmEvent event) {
    return RandomFilmState(
        httpStatus: HttpOk(),
        event: event,
        films: films
    );
  }

  factory RandomFilmState.timeout(
      final RandomFilmState oldState,
      final RandomFilmEvent event) {
    return RandomFilmState(
        httpStatus: HttpTimeout(),
        event: event,
        films: oldState.films
    );
  }

  factory RandomFilmState.error(
      final RandomFilmState oldState,
      final RandomFilmEvent event,
      final String error) {
    return RandomFilmState(
        httpStatus: HttpError(error),
        event: event,
        films: oldState.films
    );
  }

  factory RandomFilmState.loading(
      final RandomFilmState oldState,
      final RandomFilmEvent event) {
    bool ignoreHistory = event is GetRandomFilms && event.cleanHistory;

    return RandomFilmState(
        httpStatus: WaitForResponse(),
        event: event,
        films: ignoreHistory ? [] : oldState.films,
    );
  }
}
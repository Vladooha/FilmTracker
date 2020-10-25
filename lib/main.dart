import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:random_film_app/logic/bloc/film/analytics/film_analytics_bloc.dart';
import 'package:random_film_app/ui/screen/home_screen.dart';

import 'logic/bloc/bloc_obsevable.dart';
import 'logic/bloc/film/random/random_film_bloc.dart';

void main() {
  FlutterError.onError = null;

  Bloc.observer = MainBlocObserver();

  initializeDateFormatting(Platform.localeName)
    .then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<RandomFilmBloc>(
            create: (context) => RandomFilmBloc()
          ),
          BlocProvider<FilmAnalyticsBloc>(
            create: (context) => FilmAnalyticsBloc()
          )
        ],
        child: HomeScreen()
      ),
    );
  }
}

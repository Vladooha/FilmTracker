import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:random_film_app/logic/repo/film/film_repo.dart';
import 'package:random_film_app/model/dto/film/film_query.dart';
import 'package:random_film_app/model/film/film.dart';
import 'package:random_film_app/ui/block/film_list.dart';
import 'package:random_film_app/ui/block/film_preview.dart';
import 'package:random_film_app/ui/block/film_search_filter.dart';
import 'package:random_film_app/ui/screen/home_screen.dart';

final GlobalKey filmListKey = GlobalKey();

class FilmStorage extends StatefulWidget implements AbstractLayout {
  static GlobalKey _filmStorageKey = GlobalKey();

  final int chosenLayoutIndex;
  final FilmRepository filmRepository = FilmRepository.instance;

  @override
  int get layoutIndex => 1;

  @override
  bool get isLayoutChosen => layoutIndex == chosenLayoutIndex;

  @override
  GlobalKey get stateKey => _filmStorageKey;

  FilmStorage({@required this.chosenLayoutIndex}) : super(key: _filmStorageKey);

  @override
  State<StatefulWidget> createState() => _FilmStorageState();

  @override
  onLayoutDraw(BuildContext context) {
    StorageListLayoutSubtype.goToListLayout(context);
  }

  @override
  updateStateKey(BuildContext context) {
    _filmStorageKey = GlobalKey();
  }
}

class _FilmStorageState extends State<FilmStorage> {
  static const FILM_LIMIT = 10;
  static const QUERY_DEBOUNCE = const Duration(milliseconds: 500);

  List<Film> films;
  FilmQuery filmQuery;
  bool filmLimitReached;
  Timer _queryDebouncer;
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();

    filmQuery = FilmQuery()
      ..limit = FILM_LIMIT
      ..offset = 0;
    filmLimitReached = false;
  }

  @override
  Widget build(BuildContext context) {
    var layoutSubtypeContainer = LayoutSubtypeContainer.of(context);
    if (widget.isLayoutChosen
        && !(layoutSubtypeContainer.layoutSubtype is StorageLayoutSubtype)) {
      Future.delayed(
        Duration.zero,
        () => layoutSubtypeContainer.layoutSubtype = StorageListLayoutSubtype(),
      );
    }

    var layoutSubtype = layoutSubtypeContainer.layoutSubtype;
    int layoutSubtypeIndex = 0;
    bool withFilter = false;
    Film currentFilm;

    if (layoutSubtype is StorageSearchLayoutSubtype) {
      withFilter = true;
    } else if (layoutSubtype is StoragePreviewLayoutSubtype) {
      layoutSubtypeIndex = 1;
      currentFilm = layoutSubtype.film;
    }

    return IndexedStack(
      index: layoutSubtypeIndex,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            FilmList(
              key: filmListKey,
              films: films,
              onFilmTap: openFilm,
              onFilmDelete: removeFilm,
              onListScrolled: filmLimitReached ? null : loadMoreFilms,
            ),
            Offstage(
              offstage: !withFilter,
              child: Container(
                child: FilmSearchFilter(
                  metadata: filmQuery,
                  onStateUpdate: updateQuery
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).dividerColor,
                      blurRadius: 4,
                      offset: Offset(0.0, -4),
                    ),
                  ]
                ),
              ),
            )
          ],
        ),
        currentFilm != null ? FilmPreview(film: currentFilm) : Container(),
      ],
    );
  }

  Function openFilm = StoragePreviewLayoutSubtype.goToPreviewLayout;

  removeFilm(BuildContext context, Film film) => setState(() {
    films.remove(film);
    widget.filmRepository.deleteFilms([film]);
  });

  updateQuery(Function callback) {
    if (isDisposed || (_queryDebouncer?.isActive ?? false)) {
      _queryDebouncer.cancel();
    }
    _queryDebouncer = Timer(QUERY_DEBOUNCE, () {
      clearSearchResults();
      callback.call();
      loadMoreFilms(context);
    });
  }

  loadMoreFilms(BuildContext context) async {
    List<Film> loadedFilms =
      await widget.filmRepository.getFilms(query: filmQuery);

    filmQuery.limit = FILM_LIMIT;
    filmQuery.offset += FILM_LIMIT;

    if (!isDisposed) {
      setState(() {
        if (null == films) {
          films = List.of(loadedFilms);
        } else {
          films.addAll(loadedFilms);
        }

        if (films != null && films.length < filmQuery.offset) {
          filmLimitReached = true;
        }
      });
    }
  }

  clearSearchResults() {
    films = null;
    filmLimitReached = false;
    filmQuery.offset = 0;
  }

  @override
  void dispose() {
    isDisposed = true;

    super.dispose();
  }
}

abstract class StorageLayoutSubtype extends LayoutSubtype {
  static const DEFAULT_INDEX = 0;

  int get index;
}

class StorageListLayoutSubtype extends StorageLayoutSubtype {
  static void goToListLayout(BuildContext context) {
    var layoutTypeContainer = LayoutSubtypeContainer.of(context);
    layoutTypeContainer.layoutSubtype = StorageListLayoutSubtype();
  }

  int get index => StorageLayoutSubtype.DEFAULT_INDEX;

  @override
  Widget buildFloatButton(BuildContext context) {
    return FloatingActionButton(
        child: Icon(FontAwesomeIcons.slidersH),
        onPressed: () => StorageSearchLayoutSubtype.goToSearchLayout(context)
    );
  }
}

class StorageSearchLayoutSubtype extends StorageLayoutSubtype {
  static void goToSearchLayout(BuildContext context) {
    var layoutTypeContainer = LayoutSubtypeContainer.of(context);
    layoutTypeContainer.layoutSubtype = StorageSearchLayoutSubtype();
  }

  int get index => 1;

  @override
  Widget buildFloatButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.keyboard_arrow_down),
      onPressed: () => StorageListLayoutSubtype.goToListLayout(context)
    );
  }
}

class StoragePreviewLayoutSubtype extends StorageLayoutSubtype {
  static void goToPreviewLayout(BuildContext context, Film film) {
    var layoutTypeContainer = LayoutSubtypeContainer.of(context);
    layoutTypeContainer.layoutSubtype = StoragePreviewLayoutSubtype(film);
  }

  final Film film;

  int get index => 2;

  StoragePreviewLayoutSubtype(this.film);

  @override
  Widget buildFloatButton(BuildContext context) {
    return FloatingActionButton(
        child: Icon(Icons.list),
        onPressed: () => StorageListLayoutSubtype.goToListLayout(context)
    );
  }
}
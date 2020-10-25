import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts_cyrillic_ext_lite/google_fonts_cyrillic_ext_lite.dart';
import 'package:random_film_app/logic/bloc/film/random/random_film_bloc.dart';
import 'package:random_film_app/logic/bloc/film/random/random_film_bloc_events.dart';
import 'package:random_film_app/logic/bloc/film/random/random_film_bloc_states.dart';
import 'package:random_film_app/logic/bloc/status/bloc_http_status.dart';
import 'package:random_film_app/model/film/film.dart';
import 'package:random_film_app/ui/block/film_preview.dart';
import 'package:random_film_app/ui/block/film_search_filter.dart';
import 'package:random_film_app/ui/screen/home_screen.dart';

class FilmSearch extends StatefulWidget implements AbstractLayout {
  static final _filmSearchKey = GlobalKey();

  final int chosenLayoutIndex;
  final pageScrollController = PageController();

  @override
  int get layoutIndex => 0;

  @override
  bool get isLayoutChosen => layoutIndex == chosenLayoutIndex;

  @override
  GlobalKey get stateKey => _filmSearchKey;

  FilmSearch({@required this.chosenLayoutIndex}) : super(key: _filmSearchKey);

  @override
  State<StatefulWidget> createState() => _FilmSearchState();

  @override
  updateStateKey(BuildContext context) {}

  @override
  onLayoutDraw(BuildContext context) {
    SearchFilmsLayoutSubtype.goToFilmsLayout(context);
  }
}

class _FilmSearchState extends State<FilmSearch> {
  bool filmsAlreadyLoading = false;
  int filmsCount = 0;

  _FilmSearchState();

  @override
  Widget build(BuildContext context) {
    // Can't do it on initState because it may be
    // not called on new state creation
    widget.pageScrollController.addListener(_onPageChange);

    return Center(
      child: Builder(
        builder: (context) {
          var layoutSubtypeContainer = LayoutSubtypeContainer.of(context);
          if (widget.isLayoutChosen
              && !(layoutSubtypeContainer.layoutSubtype is SearchLayoutSubtype)) {
            Future.delayed(
              Duration.zero,
              () => layoutSubtypeContainer.layoutSubtype = SearchFilterLayoutSubtype(),
            );
          }

          return IndexedStack(
            index: _getLayoutTypeIndex(layoutSubtypeContainer),
            children: [
              StreamBuilder(
                stream: BlocProvider.of<RandomFilmBloc>(context),
                builder: (context, snapshot) {
                  RandomFilmState state = snapshot?.data;

                  _onNewState(state);

                  if (state != null) {
                    var status = state.status;
                    List<Film> films = state.films;

                    // Adding nothing found message
                    filmsCount = films.isEmpty ? 1 : films.length;

                    bool isLoading = status is WaitForResponse;
                    bool isError = !(isLoading || status is HttpOk);
                    // Adding message screen after film list
                    if ((isLoading || isError) && films.isNotEmpty) {
                      filmsCount++;
                    }

                    return PageView.builder(
                        scrollDirection: Axis.horizontal,
                        controller: widget.pageScrollController,
                        physics: PageScrollPhysics(),
                        itemCount: filmsCount,
                        itemBuilder: (context, index) {
                          Widget filmItem = _FilmNotFound();

                          bool isLastScreen = filmsCount - 1 == index;
                          if (isLoading && isLastScreen) {
                            filmItem = _FilmLoading();
                          } else if (isError && isLastScreen) {
                            filmItem = _FilmLoadError(_loadFilms);
                          } else {
                            if (films.isNotEmpty) {
                              Film film = films[index];
                              if (film.isLoaded) {
                                filmItem = FilmPreview(film: film);
                              } else {
                                filmItem = _FilmLoadError(_loadFilms);
                              }
                            }
                          }

                          return Container(
                              width: MediaQuery.of(context).size.width,
                              child: filmItem
                          );
                        }
                    );
                  }

                  return Container(
                      width: MediaQuery.of(context).size.width,
                      child: _FilmNotFound()
                  );
                },
              ),
              FilmSearchFilter(
                metadata: BlocProvider.of<RandomFilmBloc>(context).lastFilter
              ),
            ],
          );
        },
      )
    );
  }

  _getLayoutTypeIndex(LayoutSubtypeContainerState layoutSubtypeContainer) {
    var layoutSubtype = layoutSubtypeContainer.layoutSubtype;
    if (layoutSubtype is SearchLayoutSubtype) {
      return layoutSubtype.index;
    } else {
      return SearchLayoutSubtype.DEFAULT_INDEX;
    }
  }

  _loadFilms() {
    filmsAlreadyLoading = true;
    BlocProvider.of<RandomFilmBloc>(context).getSameFilms();
  }

  _onPageChange() {
    const preloadPageOffset = 3;
    double currentPage = widget.pageScrollController.page;

    if (filmsCount - currentPage < preloadPageOffset
        && !filmsAlreadyLoading) {
      _loadFilms();
    }
  }

  _onNewState(RandomFilmState state) {
    if (!(state?.status is WaitForResponse)) {
      filmsAlreadyLoading = false;
    }

    var event = state?.event;
    if (event != null
        && event is GetRandomFilms
        && event.cleanHistory
        && widget.pageScrollController.hasClients) {
      widget.pageScrollController
          .animateTo(0,
          duration: Duration(seconds: 1),
          curve: Curves.linear);
    }
  }

  @override
  void dispose() {
    widget.pageScrollController.removeListener(_onPageChange);

    super.dispose();
  }
}

class _FilmNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 128.0,
            color: Theme.of(context).disabledColor,
          ),
          Text(
            "Ничего не найдено",
            style: TextStyle(
                color: Theme.of(context).disabledColor,
                fontSize: 16.0,
                fontFamily: CyrillicExtendedFonts.Comfortaa,
                package: 'google_fonts_cyrillic_ext_lite'
            ),
          )
        ],
      ),
    );
  }
}

class _FilmLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Загрузка...",
              style: TextStyle(
                  color: Theme.of(context).disabledColor,
                  fontSize: 24.0,
                  fontFamily: CyrillicExtendedFonts.Comfortaa,
                  package: 'google_fonts_cyrillic_ext_lite'
              ),
            ),
          ),
          SizedBox(
            height: 64.0,
            width: 64.0,
            child: CircularProgressIndicator(),
          ),
        ]
      );
  }
}

class _FilmLoadError extends StatelessWidget {
  final Function _onRetry;

  const _FilmLoadError(this._onRetry);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.warning,
          size: 128.0,
          color: Theme.of(context).disabledColor,
        ),
        Text(
          "При загрузке произошла ошибка",
          style: TextStyle(
              color: Theme.of(context).disabledColor,
              fontSize: 24.0,
              fontFamily: CyrillicExtendedFonts.Comfortaa,
              package: 'google_fonts_cyrillic_ext_lite'
          ),
        ),
        OutlinedButton(
          child: Text("Попробовать снова"),
          onPressed: _onRetry,
        ),
      ],
    );
  }
}

abstract class SearchLayoutSubtype extends LayoutSubtype {
  static const DEFAULT_INDEX = 0;

  int get index;
}

class SearchFilmsLayoutSubtype extends SearchLayoutSubtype {
  int get index => SearchLayoutSubtype.DEFAULT_INDEX;

  static void goToFilmsLayout(BuildContext context) {
    var layoutTypeContainer = LayoutSubtypeContainer.of(context);
    layoutTypeContainer.layoutSubtype = SearchFilmsLayoutSubtype();
  }

  @override
  Widget buildFloatButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(FontAwesomeIcons.search),
      onPressed: () => SearchFilterLayoutSubtype.goToFilterLayout(context)
    );
  }
}

class SearchFilterLayoutSubtype extends SearchLayoutSubtype {
  int get index => 1;

  static void goToFilterLayout(BuildContext context) {
    var layoutTypeContainer = LayoutSubtypeContainer.of(context);
    layoutTypeContainer.layoutSubtype = SearchFilterLayoutSubtype();
  }

  @override
  Widget buildFloatButton(BuildContext context) {
    return FloatingActionButton(
        child: Icon(Icons.movie),
        onPressed: () => SearchFilmsLayoutSubtype.goToFilmsLayout(context)
    );
  }
}
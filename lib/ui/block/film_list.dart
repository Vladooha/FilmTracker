import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts_cyrillic_ext_lite/google_fonts_cyrillic_ext_lite.dart';
import 'package:random_film_app/model/film/film.dart';

class FilmList extends StatefulWidget {
  final List<Film> films;
  final Function(BuildContext, Film) onFilmTap;
  final Function(BuildContext, Film) onFilmDelete;
  final Function(BuildContext) onListScrolled;

  final scrollController = ScrollController();

  FilmList({
    Key key,
    this.films,
    this.onFilmTap,
    this.onFilmDelete,
    this.onListScrolled
  })
  : super(key: key);

  @override
  State<StatefulWidget> createState() => _FilmListState();
}

class _FilmListState extends State<FilmList> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    loading = false;

    if (null == widget.films) {
      if (widget.onListScrolled != null) {
        widget.onListScrolled(context);
      }

      return Center(
        child: SizedBox(
          width: 64.0,
          height: 64.0,
          child: CircularProgressIndicator(),
        ),
      );
    }

    widget.scrollController.addListener(_checkListScroll);

    if (widget.films.isEmpty) {
      return Center(
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
    }

    return ListView.separated(
      controller: widget.scrollController,
      itemCount: widget.films.length + (widget.onListScrolled != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (widget.films.length == index) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 32.0,
                height: 32.0,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        Film film = widget.films[index];
        return ListTile(
          title: Text(
            film.name,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
              children: [
                Text(
                  "${film.countries.isNotEmpty ? film.countries[0] : ""}, ${film.year}",
                  style: TextStyle(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                SizedBox(width: 8.0),
                Text(
                  "${film.rating.toStringAsFixed(1)}",
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                Icon(
                  Icons.star,
                  color: Theme.of(context).accentColor,
                  size: 16.0,
                ),
                SizedBox(width: 8.0),
                _getGradeIcon(film),
              ]
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            iconSize: 24.0,
            onPressed: () {
              if (widget.onFilmDelete != null) {
                widget.onFilmDelete(context, film);
              }
            },
          ),
          onTap: () {
            if (widget.onFilmTap != null) {
              widget.onFilmTap(context, film);
            }
          },
        );
      },
      separatorBuilder: (_, __) => Divider(),
    );
  }

  Widget _getGradeIcon(Film film) {
    if (FilmGrade.LIKE == film.userGrade) {
      return Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(
          Icons.thumb_up,
          color: Colors.green,
          size: 16.0,
        ),
      );
    } else if (FilmGrade.DISLIKE == film.userGrade) {
      return Padding(
        padding: EdgeInsets.all(4.0),
        child: Icon(
          Icons.thumb_down,
          color: Colors.red,
          size: 16.0,
        ),
      );
    }

    return Container();
  }

  _checkListScroll() {
    if (!loading && widget.onListScrolled != null) {
      var position = widget.scrollController.position;
      if ((position.pixels == position.maxScrollExtent)
          || position.maxScrollExtent < MediaQuery.of(context).size.height) {
        loading = true;

        widget.onListScrolled(context);
      }
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_checkListScroll);

    super.dispose();
  }
}

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:link/link.dart';
import 'package:random_film_app/logic/repo/film/film_repo.dart';
import 'package:random_film_app/model/film/film.dart';
import 'package:random_film_app/service/db/film/film_db.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class FilmPreview extends StatefulWidget {
  final Film film;

  const FilmPreview({Key key, @required this.film}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FilmPreviewState();
}

class _FilmPreviewState extends State<FilmPreview>
    with SingleTickerProviderStateMixin {
  static const PICTURE_HEIGHT_PERCENT = 5 / 7;
  static const DESCRIPTION_HEIGHT_PERCENT = 2 / 7;

  AnimationController swipeController;

  double get swipeValue => swipeController.value;
  bool get isExpanded => swipeController.value >= 0.5;

  @override
  void initState() {
    super.initState();
    swipeController = AnimationController(value: 0, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (dragInfo) {
          final double dy = dragInfo.delta.dy;
          swipeController.value += -1.25 * dy / constraints.maxHeight;
        },
        onPanEnd: (dragEndInfo) {
          if (dragEndInfo.velocity.pixelsPerSecond.dy <= 0) {
            var duration = Duration(milliseconds: (400 * (1 - swipeValue)).toInt());

            if (swipeValue > 0.1) {
              swipeController.animateTo(1.0, duration: duration);
            } else {
              swipeController.animateTo(0.0, duration: duration);
            }
          } else if (dragEndInfo.velocity.pixelsPerSecond.dy > 0) {
            var duration = Duration(milliseconds: (400 * swipeValue).toInt());

            if (swipeValue < 0.9) {
              swipeController.animateTo(0.0, duration: duration);
            } else {
              swipeController.animateTo(1.0, duration: duration);
            }
          }
        },
        child: _FilmContent(
          film: widget.film,
          animationController: swipeController,
        )
      ),
    );
  }

  @override
  void dispose() {
    swipeController.dispose();

    super.dispose();
  }
}

enum ButtonMenuStatus {
  DRAW, REMOVE, SHOWING, HIDING,
}

class _FilmAnimationHolder extends InheritedWidget {
  static _FilmAnimationHolder of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FilmAnimationHolder>();
  }

  final Film film;
  final AnimationController animationController;
  final Widget child;

  _FilmAnimationHolder({
      @required this.film,
      @required this.animationController,
      @required this.child})
    : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

class _FilmContent extends AnimatedWidget {
  final Film film;
  final AnimationController animationController;

  double get swipeValue => animationController.value;
  bool get isExpanded => animationController.value >= 0.5;

  ButtonMenuStatus buttonMenuStatus = ButtonMenuStatus.HIDING;

  _FilmContent({
        @required this.film,
        @required this.animationController,
      })
    : super(listenable: animationController);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          SizedBox(
            child: Image.network(
              film.picUrl,
              height: constraints.maxHeight * _FilmPreviewState.PICTURE_HEIGHT_PERCENT,
              width: constraints.maxWidth,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null && child is Semantics) {
                  var img = child.child;
                  if (img is RawImage && img.image != null) {
                    return child;
                  }
                }

                return Center(
                  child: SizedBox(
                    width: 64.0,
                    height: 64.0,
                    child: CircularProgressIndicator(
                        value: loadingProgress?.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                            : null),
                  ),
                );
              },
            ),
            height: _getPictureHeight(constraints.maxHeight),
          ),
          SizedBox(
            child: _FilmAnimationHolder(
              film: film,
              animationController: animationController,
              child: _FilmDescription(
                film: film,
              ),
            ),
            height: _getFilmHeight(constraints.maxHeight),
          ),
        ],
      ),
    );
  }

  _getPictureHeight(double contentHeight) =>
    contentHeight - _getFilmHeight(contentHeight);

  _getFilmHeight(double contentHeight) => contentHeight
      * (_FilmPreviewState.DESCRIPTION_HEIGHT_PERCENT
            + swipeValue * _FilmPreviewState.PICTURE_HEIGHT_PERCENT);
}

class _FilmDescription extends StatelessWidget {
  final Film film;

  _FilmDescription({
    @required this.film,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  film.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      "${film.countries.join(", ")}, ${film.year}",
                      style: TextStyle(
                        color: Theme.of(context).disabledColor,
                        fontSize: 12.0
                      ),
                    ),
                    Spacer(),
                    SmoothStarRating(
                      isReadOnly: true,
                      size: 16.0,
                      starCount: 10,
                      rating: film.rating,
                    ),
                  ],
                ),
              ),
              Container(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                  child: Text(
                    "${film.genres.join(", ")}",
                    style: TextStyle(
                        color: Theme.of(context).disabledColor,
                        fontSize: 12.0
                    ),
                  ),
                ),
              ),
              Container(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                  child: Text(
                    "Режиссёр: ${film.director}",
                    style: TextStyle(
                      color: Theme.of(context).disabledColor,
                      fontSize: 12.0
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          "${film.description}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 100,
                        ),
                      ),
                      Spacer(),
                      SizedBox(
                        height: 128.0,
                        child: _FilmMenu(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 32.0),
                        child: Link(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Источник: ",
                                  style: TextStyle(
                                      color: Colors.black
                                  ),
                                ),
                                TextSpan(
                                    text: film.sourceUrl,
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        decoration: TextDecoration.underline
                                    )
                                )
                              ],
                            ),
                          ),
                          url: "${film.sourceUrl}",
                          onError: () {},
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        ),
      ]
    );
  }
}

class _FilmMenu extends StatefulWidget {
  final actionButtonListKey = GlobalKey<AnimatedListState>();

  @override
  State<StatefulWidget> createState() => _FilmMenuState();
}

class _FilmMenuState extends State<_FilmMenu> {
  final FilmRepository _filmRepo = FilmRepository.instance;
  List<Widget> _actionButtonsCache = [];

  _FilmAnimationHolder _filmAnimationHolder;
  ButtonMenuStatus _buttonMenuStatus = ButtonMenuStatus.HIDING;

  double get swipeValue => _filmAnimationHolder.animationController.value;
  bool get isExpanded => _filmAnimationHolder.animationController.value >= 0.5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _filmAnimationHolder = _FilmAnimationHolder.of(context);
    _filmAnimationHolder.animationController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    _updateButtonMenuStatus();

    _onBuildDone();

    return Center(
      child: AnimatedList(
        key: widget.actionButtonListKey,
        scrollDirection: Axis.horizontal,
        initialItemCount: _actionButtonsCache.length,
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index, animation) {
          var curveAnimation = CurvedAnimation(
            curve: Curves.easeOut,
            parent: animation,
          );
          var tween = Tween<Offset>(
            begin: Offset(8, 0),
            end: Offset(0, 0),
          );
          var position = curveAnimation.drive(tween);

          return SlideTransition(
            position: position,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 64.0,
                height: 64.0,
                child: _actionButtonsCache[index]
              ),
            ),
          );
        }
      ),
    );
  }

  // UI parts

  List<Widget> _getActionButtons() {
    List<Widget> actionButtons = [];
    Film film = _filmAnimationHolder.film;
    if (film.isSaved) {
      actionButtons.add(
        RaisedButton(
          onPressed: () => deleteFilm(film),
          child: Icon(
            Icons.delete,
          ),
          color: Theme.of(context).accentColor,
          shape: CircleBorder(),
        )
      );
    } else {
      actionButtons.add(
        RaisedButton(
          onPressed: () => saveFilm(film),
          child: Icon(
            Icons.save,
          ),
          color: Theme.of(context).accentColor,
          shape: CircleBorder(),
        )
      );
    }

    actionButtons.add(
      RaisedButton(
        onPressed: () => saveFilm(film, withGrade: FilmGrade.LIKE),
        child: Icon(
          Icons.thumb_up,
        ),
        color: Colors.green,
        shape: CircleBorder(),
      )
    );

    actionButtons.add(
      RaisedButton(
        onPressed: () => saveFilm(film, withGrade: FilmGrade.DISLIKE),
        child: Icon(
          Icons.thumb_down,
        ),
        color: Colors.red,
        shape: CircleBorder(),
      )
    );

    return actionButtons;
  }

  // Animations

  _onBuildDone() {
    if (ButtonMenuStatus.DRAW == _buttonMenuStatus) {
      Future.delayed(Duration.zero, () {
        _addButtons();
      });
    } else if (ButtonMenuStatus.REMOVE == _buttonMenuStatus) {
      Future.delayed(Duration.zero, () {
        _removeButtons();
      });
    }
  }

  _updateButtonMenuStatus() {
    const showStatusList =
    const [ButtonMenuStatus.SHOWING, ButtonMenuStatus.DRAW];

    if (1.0 == swipeValue && !showStatusList.contains(_buttonMenuStatus)) {
      _buttonMenuStatus = ButtonMenuStatus.DRAW;
    } else if (0.0 == swipeValue) {
      _buttonMenuStatus = ButtonMenuStatus.REMOVE;
    } else if (showStatusList.contains(_buttonMenuStatus)) {
      _buttonMenuStatus = ButtonMenuStatus.SHOWING;
    } else {
      _buttonMenuStatus = ButtonMenuStatus.HIDING;
    }

    return _buttonMenuStatus;
  }

  _addButtons() {
    var listState = widget.actionButtonListKey.currentState;
    _actionButtonsCache = _getActionButtons();
    var animationDuration = const Duration(milliseconds: 150);
    if (listState != null) {
      for (int i = 0; i < _actionButtonsCache.length; i++) {
        Future.delayed(
          Duration(milliseconds: 100 * i),
            () {
              if (_actionButtonsCache.length > i) {
                listState.insertItem(i, duration: animationDuration);
              }
            });
      }
    }
  }

  _removeButtons() {
    var listState = widget.actionButtonListKey.currentState;
    if (listState != null) {
      for (int i = 0; i < _actionButtonsCache.length; i++) {
        listState.removeItem(0, (context, animation) => Container());
      }
    }
    _actionButtonsCache.clear();
  }

  // Buttons logic
  saveFilm(Film film, {FilmGrade withGrade}) async {
    if (withGrade != null) {
      film.userGrade = withGrade;
    }

    await _filmRepo.saveFilms([film]);
    setState(() {
      _actionButtonsCache = _getActionButtons();
    });
  }

  deleteFilm(Film film) async {
    await _filmRepo.deleteFilms([film]);
    setState(() {
      _actionButtonsCache = _getActionButtons();
    });
  }
}
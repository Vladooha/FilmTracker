import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:random_film_app/ui/layout/analytics.dart';
import 'package:random_film_app/ui/layout/film_search.dart';
import 'package:random_film_app/ui/layout/film_storage.dart';

enum Layout {
  FilmSearch,
  FilmStorage,
  Analytics
}

abstract class AbstractLayout {
  int get layoutIndex;

  bool get isLayoutChosen;

  GlobalKey get stateKey;

  onLayoutDraw(BuildContext context);

  updateStateKey(BuildContext context);
}

abstract class LayoutSubtype {
  Widget buildFloatButton(BuildContext context);
}

class HomeScreen extends StatefulWidget {
  final GlobalKey layoutContainerKey = GlobalKey();

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _layoutIndex = 0;
  List<Widget> get _layouts => [
    FilmSearch(chosenLayoutIndex: _layoutIndex),
    // Force update by key
    FilmStorage(chosenLayoutIndex: _layoutIndex),
    Analytics(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutSubtypeContainer(
      key: widget.layoutContainerKey,
      child: Builder(
        builder: (context) => WillPopScope(
          onWillPop: () async {
            var currentLayout = (_layouts[_layoutIndex] as AbstractLayout);
            currentLayout.onLayoutDraw(context);

            return false;
          },
          child: Scaffold(
            resizeToAvoidBottomPadding: true,
            bottomNavigationBar: BottomAppBar(
              shape: CircularNotchedRectangle(),
              notchMargin: 8.0,
              clipBehavior: Clip.antiAlias,
              child: Container(
                color: Theme.of(context).bottomAppBarColor,
                child: Padding(
                  padding: const EdgeInsets.only(right: 96.0),
                  child: BottomNavigationBar(
                    elevation: 0.0,
                    backgroundColor: Theme.of(context).bottomAppBarColor,
                    currentIndex: _layoutIndex,
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.search),
                        label: "Поиск",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.movie_filter),
                        label: "Мои фильмы",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(FontAwesomeIcons.chartPie),
                        label: "Статистика",
                      ),
                    ],
                    onTap: (layoutIndex) {
                      if (layoutIndex != _layoutIndex) {
                        setState(() {
                          if (layoutIndex >= Layout.values.length) {
                            _layoutIndex = 0;
                          } else {
                            _layoutIndex = layoutIndex;
                          }

                          var currentLayout = _layouts[_layoutIndex] as AbstractLayout;
                          currentLayout.updateStateKey(context);
                          currentLayout.onLayoutDraw(context);
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: IndexedStack(
                  index: _layoutIndex,
                  children: _layouts,
              ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(4.0),
              child: _LayoutFloatButton(),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          ),
        ),
      ),
    );
  }
}

class _LayoutSubtypeInherited extends InheritedWidget {
  final Widget child;
  final LayoutSubtypeContainerState data;

  const _LayoutSubtypeInherited({@required this.data, @required this.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      this != oldWidget;
}

class LayoutSubtypeContainer extends StatefulWidget {
  static LayoutSubtypeContainerState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_LayoutSubtypeInherited>()
        ?.data;
  }

  final Widget child;
  final Layout layout;

  const LayoutSubtypeContainer({Key key, this.child, @required this.layout})
      : super(key: key);

  @override
  State createState() => LayoutSubtypeContainerState();
}

// class _BottomMenu extends StatelessWidget {
//   final int _layoutIndex;
//   final List<Widget> _layouts;
//
//   _BottomMenu(this._layoutIndex, this._layouts)
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: _layoutIndex,
//       items: [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.search),
//           label: "Поиск",
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.movie_filter),
//           label: "Мои фильмы",
//         ),
//         BottomNavigationBarItem(
//             icon: Container(),
//             label: ""
//         )
//       ],
//       onTap: (layoutIndex) {
//         if (layoutIndex != _layoutIndex) {
//           if (layoutIndex >= Layout.values.length) {
//             _layoutIndex = 0;
//           } else {
//             _layoutIndex = layoutIndex;
//           }
//
//           var currentLayout = _layouts[_layoutIndex] as AbstractLayout;
//           currentLayout.goToDefaultSubtype(context);
//         }
//       },
//     );
//   }
//
// }

class LayoutSubtypeContainerState extends State<LayoutSubtypeContainer> {
  LayoutSubtype _layoutType;

  LayoutSubtype get layoutSubtype => _layoutType;

  set layoutSubtype(LayoutSubtype value) =>
      setState(() {
        _layoutType = value;
      });


  @override
  void initState() {
    super.initState();

    _layoutType = SearchFilmsLayoutSubtype();
  }

  @override
  Widget build(BuildContext context) {
    return _LayoutSubtypeInherited(
        data: this,
        child: widget.child
    );
  }
}

class _LayoutFloatButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LayoutFloatButtonState();
}

class _LayoutFloatButtonState extends State<_LayoutFloatButton> {
  @override
  Widget build(BuildContext context) {
    var layoutTypeContainer = LayoutSubtypeContainer.of(context);

    return layoutTypeContainer.layoutSubtype.buildFloatButton(context);
  }
}

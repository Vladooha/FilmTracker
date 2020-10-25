import 'abstract_film_metadata.dart';

class FilmQuery extends FilmMetadata {
  int limit = 0;
  int offset = 0;

  List<int> ids;
  DateTime dateFrom;
  String orderBy;
  bool isAscOrder = true;

  String get orderByQuery => orderBy != null
      ? orderBy + (isAscOrder ? " ASC" : " DESC")
      : null;
}
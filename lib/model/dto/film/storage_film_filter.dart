class StorageFilmFilter {
  List<int> ids = [];
  String nameQuery = "";

  Map<String, dynamic> mapToFilters() {
    Map<String, dynamic> filters = {};

    if (ids != null && ids.isNotEmpty) {
      filters["id"] = ids;
    }

    if (nameQuery != null && nameQuery != "") {
      filters["name"] = nameQuery;
    }

    return filters.isNotEmpty ? {} : null;
  }
}
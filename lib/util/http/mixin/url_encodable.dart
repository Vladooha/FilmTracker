class UrlEncoded {
  Map<String, Object> get urlParams => {};

  String toUrl({bool isBegin = true}) {
    String url = urlParams.entries
      .map(_mapParameterToString)
      .fold("", (value, element) => value + element);

    if (isBegin) {
      url = "?" + url?.substring(1) ?? "";
    }

    return url;
  }

  String _mapParameterToString(MapEntry<String, Object> parameter) {
    String result = "";

    String parameterName = parameter.key;
    var parameterValue = parameter.value;

    if (parameterValue != null) {
      if (parameterValue is Iterable) {
        result = parameterValue
            .map((value) => MapEntry(parameterName, value))
            .map(_mapParameterToString)
            .fold("", (url, valueStr) => url + valueStr);
      } else {
        String parameterValueStr = parameterValue.toString();
        result += "&$parameterName=$parameterValueStr";
      }
    }

    return result;
  }
}
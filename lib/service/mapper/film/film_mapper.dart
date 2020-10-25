import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:random_film_app/model/film/film.dart';
import 'package:random_film_app/model/film/film_country.dart';
import 'package:random_film_app/model/film/film_genre.dart';

class FilmJsonMapper {
  static final FilmJsonMapper instance = FilmJsonMapper._();

  final RegExp durationRegExp = RegExp(r"([\d]{1,}) мин");
  final RegExp yearRegExp = RegExp(r"\(([\d]{4})\)");
  final RegExp countryRegExp = RegExp(r"([а-яА-Я]{1,})\,");
  final RegExp genreRegExp = RegExp(r"([а-яА-Я]{1,})[\,\)]{1}");

  FilmJsonMapper._();

  Film mapFromJson(Map<String, dynamic> jsonMap, ) {
    return Film(
      id: jsonMap["id"],
      name: jsonMap["name"],
      description: jsonMap["description"],
      director: jsonMap["director"],
      duration: jsonMap["duration"],
      year: jsonMap["year"],
      rating: jsonMap["rating"],
      saveTimeMs: jsonMap["create_time"],
      userGrade: FilmGrade.values
          .firstWhere(
              (grade) => jsonMap["user_grade"] == grade.toString(),
              orElse: () => FilmGrade.NO_GRADE),
    );
  }

  Map<String, dynamic> mapToJson(Film film) {
    return <String, dynamic>{
      "id": film.id,
      "name": film.name,
      "description": film.description,
      "director": film.director,
      "duration": film.duration,
      "year": film.year,
      "rating": film.rating,
      "create_time": film.saveTimeMs,
      "user_grade": film.userGrade.toString()
    };
  }

  Future<List<Film>> mapHtmlJsonToFilmList(List<String> filmJson) async {
    return filmJson
      .map((filmHtml) {
        int id = -1;
        String name = "";
        String description = "";
        String director = "";
        int duration = -1;
        int year = -1;
        List<FilmGenre> genres = [];
        List<FilmCountry> countries = [];
        double rating = -1;

        var document = html.parse(filmHtml);
        List<Element> divs = document.getElementsByTagName("div");

        try {
          for (Element div in divs) {
            // Id
            var idStr = div?.attributes["data-id-film"];
            if (idStr != null) {
              id = int.tryParse(idStr ?? "") ?? id;

              continue;
            }

            if (div?.classes?.contains("filmName") ?? false) {
              // Name
              name = div
                  ?.getElementsByTagName("a")
                  ?.firstWhere((element) => true, orElse: () => null)
                  ?.text ?? name;

              // Duration and Year
              String durationAndYearStr =
                  div
                      ?.getElementsByTagName("span")
                      ?.firstWhere((element) => true, orElse: () => null)
                      ?.text;
              String durationStr = durationRegExp
                  .allMatches(durationAndYearStr)
                  ?.firstWhere((element) => true, orElse: () => null)
                  ?.group(1);
              duration = int.tryParse(durationStr ?? "") ?? duration;
              String yearStr =
              yearRegExp
                  .allMatches(durationAndYearStr)
                  ?.firstWhere((element) => true, orElse: () => null)
                  ?.group(1);
              year = int.tryParse(yearStr ?? "") ?? year;

              continue;
            }

            if (div?.classes?.contains("syn") ?? false) {
              // Description
              description = div?.text ?? description;

              continue;
            }

            if ((div?.classes?.contains("gray") ?? false)
                && (div?.text?.contains("реж.") ?? false)) {
              // Director
              director = div
                  ?.getElementsByTagName("a")
                  ?.firstWhere((element) => true, orElse: () => null)
                  ?.text ?? director;

              // Countries and Genres
              var divTextParts = div?.text?.split("реж.");
              String countryText = divTextParts[0];
              String genresText = divTextParts[1];
              if (countryText != null) {
                countryRegExp.allMatches(countryText)
                    ?.map((countryMatch) => countryMatch.group(1))
                    ?.map((countryName) => FilmCountry.findByName(countryName))
                    ?.where((country) => country != null)
                    ?.forEach((country) => countries.add(country));
              }
              if (genresText != null) {
                genreRegExp.allMatches(genresText)
                    ?.map((genreMatch) => genreMatch.group(1))
                    ?.map((genreName) => FilmGenre.findByName(genreName))
                    ?.where((genre) => genre != null)
                    ?.forEach((genre) => genres.add(genre));
              }
              continue;
            }

            if (div?.classes?.contains("rating") ?? false) {
              rating = double.tryParse(div?.text?.split(" ")[0] ?? "") ?? rating;
            }
          }
        } catch (error) {}

        var film = Film(
            id: id,
            name: name,
            description: description,
            director: director,
            duration: duration,
            year: year,
            genres: genres,
            countries: countries,
            rating: rating
        );

        return film;
      }).toList();
  }
}
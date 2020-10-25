import 'package:equatable/equatable.dart';

class FilmGenre extends Equatable {
  static const Anime = FilmGenre._(1750, "Аниме");
  static const Biography = FilmGenre._(22, "Биография");
  static const ActionMovie = FilmGenre._(3, "Боевик");
  static const Western = FilmGenre._(13, "Вестерн");
  static const ArmyMovie = FilmGenre._(19, "Военный");
  static const Detective = FilmGenre._(17, "Детектив");
  static const ChildrenMovie = FilmGenre._(456, "Детский");
  static const Documentary = FilmGenre._(12, "Документальный");
  static const Drama = FilmGenre._(8, "Драма");
  static const Historical = FilmGenre._(23, "История");
  static const Comedy = FilmGenre._(6, "Комедия");
  static const Concert = FilmGenre._(1747, "Концерт");
  static const ShortFilm = FilmGenre._(15, "Короткометражка");
  static const Criminal = FilmGenre._(16, "Криминал");
  static const Melodrama = FilmGenre._(7, "Мелодрама");
  static const Music = FilmGenre._(21, "Музыка");
  static const Cartoon = FilmGenre._(14, "Мультфильм");
  static const Musical = FilmGenre._(9, "Мюзикл");
  static const Adventure = FilmGenre._(10, "Приключения");
  static const Family = FilmGenre._(11, "Семейный");
  static const Sport = FilmGenre._(24, "Спорт");
  static const Thriller = FilmGenre._(4, "Триллер");
  static const Horror = FilmGenre._(1, "Ужасы");
  static const Fantastic = FilmGenre._(2, "Фантастика");
  static const Noir = FilmGenre._(18, "Фильм-нуар");
  static const Fantasy = FilmGenre._(5, "Фэнтези");

  static const List<FilmGenre> values = const [
    Anime, Biography, ActionMovie, Western, ArmyMovie, Detective, ChildrenMovie,
    Documentary, Drama, Historical, Comedy, Concert, ShortFilm, Criminal,
    Melodrama, Music, Cartoon, Musical, Adventure, Family, Sport, Thriller,
    Horror, Fantastic, Noir, Fantasy
  ];

  static FilmGenre findByIndex(int index) =>
    values.firstWhere((country) => country.index == index,
      orElse: () => null);
  static FilmGenre findByName(String name) =>
    values.firstWhere((country) => country.name.toLowerCase() == name.toLowerCase(),
      orElse: () => null);

  final int index;
  final String name;

  const FilmGenre._(this.index, this.name);

  @override
  List<Object> get props => [index, name];

  @override
  String toString() => name;
}
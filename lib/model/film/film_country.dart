import 'package:equatable/equatable.dart';

class FilmCountry extends Equatable {
  static const Russia = FilmCountry._(2, "Россия");
  static const USA = FilmCountry._(1, "США");
  static const USSR = FilmCountry._(13, "СССР");
  static const Australia = FilmCountry._(25, "Австралия");
  static const Belgium = FilmCountry._(41, "Бельгия");
  static const UK = FilmCountry._(11, "Великобритания");
  static const Germany = FilmCountry._(3, "Германия");
  static const HongKong = FilmCountry._(28, "Гонконг");
  static const Denmark = FilmCountry._(4, "Дания");
  static const India = FilmCountry._(29, "Индия");
  static const Ireland = FilmCountry._(38, "Ирландия");
  static const Spain = FilmCountry._(15, "Испания");
  static const Italy = FilmCountry._(14, "Италия");
  static const Canada = FilmCountry._(6, "Канада");
  static const China = FilmCountry._(31, "Китай");
  static const SouthKorea = FilmCountry._(26, "Корея Южная");
  static const Mexico = FilmCountry._(17, "Мексика");
  static const France = FilmCountry._(8, "Франция");
  static const Sweden = FilmCountry._(5, "Швеция");
  static const Japan = FilmCountry._(9, "Япония");

  static const List<FilmCountry> values = const [
    USA, Russia, USSR, Australia, Belgium, UK, Germany, HongKong, Denmark,
    India, Ireland, Spain, Italy, Canada, China, SouthKorea, Mexico, France,
    Sweden, Japan
  ];

  static FilmCountry findByIndex(int index) =>
    values.firstWhere((country) => country.index == index,
      orElse: () => null);
  static FilmCountry findByName(String name) =>
    values.firstWhere((country) => country.name == name,
      orElse: () => null);

  final int index;
  final String name;

  const FilmCountry._(this.index, this.name);

  @override
  List<Object> get props => [index, name];

  @override
  String toString() => name;
}
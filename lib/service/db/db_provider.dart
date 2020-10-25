
import 'package:path/path.dart';
import 'package:random_film_app/model/film/film.dart';
import 'package:random_film_app/model/film/film_country.dart';
import 'package:random_film_app/model/film/film_genre.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static final DatabaseProvider instance = DatabaseProvider._();

  Database _db;

  DatabaseProvider._();

  Future<Database> get database async {
    if (_db != null)
      return _db;

    _db = await _initializeDB();
    return _db;
  }

  Future<Database> _initializeDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'films.db'),
      onCreate: _onDatabaseCreate,
      version: 1,
    );
  }

  Future<void> _onDatabaseCreate(Database db, int version) async {
    Batch createTableBatch = db.batch();

    // Creating film genres table
    createTableBatch.execute("CREATE TABLE FILM_GENRE("
          "id INTEGER PRIMARY KEY, "
          "name TEXT "
        ")");

    // Creating film countries table
    createTableBatch.execute("CREATE TABLE FILM_COUNTRY("
          "id INTEGER PRIMARY KEY, "
          "name TEXT "
        ")");

    createTableBatch.execute(
      "CREATE TABLE FILM("
          "id INTEGER PRIMARY KEY, "
          "name TEXT, "
          "description TEXT, "
          "director TEXT, "
          "duration INTEGER, "
          "year INTEGER, "
          "rating REAL, "
          "create_time INTEGER DEFAULT 0, "
          "user_grade TEXT DEFAULT '${FilmGrade.NO_GRADE.toString()}' "
      ")",
    );

    // Creating film genre <-> films many-to-many table
    createTableBatch.execute("CREATE TABLE FILM_TO_GENRE("
          "film_id INTEGER, "
          "genre_id INTEGER, "
          "FOREIGN KEY(film_id) REFERENCES FILM(id), "
          "FOREIGN KEY(genre_id) REFERENCES FILM_GENRE(id) "
        ")");

    // Creating film countries <-> films many-to-many table
    createTableBatch.execute("CREATE TABLE FILM_TO_COUNTRY("
          "film_id INTEGER, "
          "country_id INTEGER, "
          "FOREIGN KEY(film_id) REFERENCES FILM(id), "
          "FOREIGN KEY(country_id) REFERENCES FILM_COUNTRY(id) "
        ")");

    await createTableBatch.commit(noResult: true, continueOnError: false);

    Batch fillTablesBatch = db.batch();

    FilmGenre.values
      .forEach((genre) {
        var genreJson = {
          "id": genre.index,
          "name": genre.name,
        };
        fillTablesBatch.insert('FILM_GENRE', genreJson);
      });

    FilmCountry.values
      .forEach((country) {
        var countryJson = {
          "id": country.index,
          "name": country.name,
        };
        fillTablesBatch.insert('FILM_COUNTRY', countryJson);
      });

    fillTablesBatch.commit(noResult: true, continueOnError: false);
  }

  Future<List<Map<String, dynamic>>> passRawQuery(String sql) async {
    return (await database).rawQuery(sql);
  }
}
class Database {
  static final Database _database = Database._internal();

  factory Database() {
    return _database;
  }

  Database._internal();
}

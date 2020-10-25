class IdGenerator {
  static int _idSequence = 0;
  static int get nextId => _idSequence++;
}
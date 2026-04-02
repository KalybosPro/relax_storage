abstract class IRelaxStorage {
  /// Saves a value of type T with the specified key.
  /// [key] The key to associate with the value.
  /// [value] The value to be saved.
  Future<void> save<T>(String key, T data);

  /// Reads a value of type T associated with the specified key.
  /// [key] The key whose associated value is to be returned.
  T? read<T>(String key);

  /// Deletes the value associated with the specified key.
  /// [key] The key whose associated value is to be deleted.
  Future<void> delete(String key);

  /// Clears all stored key-value pairs.
  /// This method removes all data from the storage,
  /// effectively resetting it to an empty state.
  Future<void> clear();
}

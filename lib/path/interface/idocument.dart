part of masamune.path;

/// Interface that can create the document of KeyValue pair.
///
/// Please implement and use.
abstract class IDocument<TChild extends IChild>
    implements IPath, IParent, IChild {
  /// Get number of documents.
  int get length;

  /// Get the document key list.
  Iterable<String> get keys;

  /// Get a list of values for a document.
  Iterable<TChild> get values;

  /// Get a list of key-value pairs.
  Iterable<MapEntry<String, TChild>> get entries;

  /// Get the data.
  ///
  /// Protected data.
  @protected
  SortedMap<String, TChild> get data;

  /// Set the data.
  ///
  /// Protected data.
  ///
  /// [children]: List of data.
  @protected
  void set(Iterable<TChild> children);

  /// Check if the document contains a key.
  ///
  /// True if key is included.
  ///
  /// [key]: Key to check.
  bool containsKey(String key);

  /// Iterates the contents of the document using [key] and [value].
  ///
  /// [function]: Iterative processing of [key] and [value].
  void forEach(void function(String key, TChild value));

  /// Remove data from document.
  ///
  /// [key]: Key to delete.
  void remove(String key);

  /// Remove data from document.
  ///
  /// [keys]: Keys to delete.
  void removeAll(Iterable<String> keys);

  /// Deletes the element conditionally.
  ///
  /// [predicate]: Csonditions. If True, delete.
  void removeWhere(bool predicate(String key, TChild child));

  /// Add data to the document.
  ///
  /// [child]: Data to add.
  void add(TChild child);

  /// Add data to the document.
  ///
  /// [children]: Data to add.
  void addAll(Iterable<TChild> children);

  /// Remove all data from the document.
  void clear();

  /// Interface for use with Json serialization.
  Map<String, dynamic> toJson();

  /// Processing to set a value.
  ///
  /// Do not use from outside the class.
  ///
  /// [value]: Value to set.
  @protected
  void setInternal(TChild value);

  /// Processing to delete values.
  ///
  /// Do not use from outside the class.
  ///
  /// [value]: The value to remove.
  @protected
  void unsetInternal(TChild value);
}

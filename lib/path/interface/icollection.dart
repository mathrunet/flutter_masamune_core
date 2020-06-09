part of masamune.path;

/// Interface for using collections of data.
///
/// Please implement and use.
abstract class ICollection<TChild extends IChild>
    implements IPath, IParent, Iterable<TChild> {
  /// Get number of collections.
  int get length;

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

  /// Iterator.
  ///
  /// Can be turned with for.
  Iterator<TChild> get iterator;

  /// Iterates the contents of the document using [TChild].
  ///
  /// [function]: Iterative processing of [TChild].
  void forEach(void function(TChild value));

  /// Checks if [child] is included.
  ///
  /// True if [child] is included.
  ///
  /// [child]: The object to check.
  bool contains(Object child);

  /// Check if there is an element with [id].
  ///
  /// True if [id] is present.
  ///
  /// [id]: ID to check.
  bool containsID(String id);

  /// Check if there is an element with [path].
  ///
  /// True if [path] is present.
  ///
  /// [path]: ID to check.
  bool containsPath(String path);

  /// Add a new value.
  ///
  /// [value]: Value to add.
  ICollection<TChild> operator +(TChild value);

  /// Remove a value.
  ///
  /// [value]: Value to remove.
  Collection<TChild> operator -(TChild value);

  /// Remove data from collection.
  ///
  /// [child]: Data to delete.
  void remove(TChild child);

  /// Remove data at index.
  ///
  /// [index]: The index to delete.
  void removeAt(int index);

  /// Specify the key and delete.
  ///
  /// [key]: Key to delete.
  void removeBy(String key);

  /// Remove data from collection.
  ///
  /// [children]: Data to delete.
  void removeAll(Iterable<TChild> children);

  /// Deletes the element conditionally.
  ///
  /// [predicate]: Csonditions. If True, delete.
  void removeWhere(bool predicate(TChild child));

  /// Add data to the collection.
  ///
  /// [child]: Data to add.
  void add(TChild child);

  /// Add data to the collection.
  ///
  /// [children]: Data to add.
  void addAll(Iterable<TChild> children);

  /// Remove all data from the collection.
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

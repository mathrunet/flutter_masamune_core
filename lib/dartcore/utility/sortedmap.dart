part of masamune.dartcore;

/// Map with added sorting function.
///
/// Obtaining values can be sorted while moving at O(1).
class SortedMap<K extends Object, V extends Object> implements Map<K, V> {
  final Map<K, MapEntry<K, V>> _map = {};
  final List<MapEntry<K, V>> _sort = [];

  /// Map with added sorting function.
  ///
  /// Obtaining values can be sorted while moving at O(1).
  SortedMap();

  /// Create a SortedMap from a map.
  ///
  /// Map with added sorting function.
  ///
  /// Obtaining values can be sorted while moving at O(1).
  ///
  /// [other]: the value to add.
  factory SortedMap.fromMap(Map<K, V> other) {
    SortedMap<K, V> map = SortedMapPool.get();
    map.addAll(other);
    return map;
  }

  /// Create a SortedMap using an array of MapEntry.
  ///
  /// Map with added sorting function.
  ///
  /// Obtaining values can be sorted while moving at O(1).
  ///
  /// [entries]: the value to add.
  factory SortedMap.fromEntries(Iterable<MapEntry<K, V>> entries) {
    SortedMap<K, V> map = SortedMapPool.get();
    map.addEntries(entries);
    return map;
  }

  /// Add all values.
  ///
  /// [other]: the value to add.
  void addAll(Map<K, V> other) {
    for (MapEntry<K, V> tmp in other.entries) {
      int index = this._sort.indexWhere((entry) => entry.key == tmp.key);
      this._map[tmp.key] = tmp;
      if (index >= 0)
        this._sort[index] = tmp;
      else
        this._sort.add(tmp);
    }
  }

  /// Add all entries.
  ///
  /// [entries]: the value to add.
  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    for (MapEntry<K, V> tmp in entries) {
      int index = this._sort.indexWhere((entry) => entry.key == tmp.key);
      this._map[tmp.key] = tmp;
      if (index >= 0)
        this._sort[index] = tmp;
      else
        this._sort.add(tmp);
    }
  }

  /// Cast value type.
  @override
  Map<K2, V2> cast<K2, V2>() {
    Map<K2, V2> map = MapPool.get();
    for (MapEntry<K, V> tmp in this._sort) {
      map[tmp.key as K2] = tmp.value as V2;
    }
    return map;
  }

  /// Delete all values.
  void clear() {
    this._map.clear();
    this._sort.clear();
  }

  /// Check if key is stored.
  ///
  /// True if stored.
  ///
  ///[key]: Key to check.
  bool containsKey(Object key) => this._map.containsKey(key);

  /// Check if value is stored.
  ///
  /// True if stored.
  ///
  ///[value]: Value to check.
  bool containsValue(Object value) => this._map.containsValue(value);

  /// Used when turning a map with a for statement.
  @override
  Iterable<MapEntry<K, V>> get entries => this._sort;

  /// Turn the map in order.
  ///
  /// [f]: Action to be performed.
  void forEach(void f(K key, V value)) =>
      this._sort.forEach((tmp) => f(tmp.key, tmp.value));

  /// True if the map is empty.
  bool get isEmpty => this._map.isEmpty;

  /// True if the map is not empty.
  bool get isNotEmpty => this._map.isNotEmpty;

  /// Get the key of map.
  Iterable<K> get keys sync* {
    for (MapEntry<K, V> tmp in this._sort) {
      yield tmp.key;
    }
  }

  /// Get the value of map.
  Iterable<V> get values sync* {
    for (MapEntry<K, V> tmp in this._sort) {
      yield tmp.value;
    }
  }

  /// Get the number of elements in the map.
  int get length => this._map.length;

  /// Convert map to new map.
  ///
  /// [transform]: Map conversion formula.
  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> transform(K key, V value)) {
    Map<K2, V2> map = MapPool.get();
    for (MapEntry<K, V> tmp in this._sort) {
      MapEntry<K2, V2> val = transform(tmp.key, tmp.value);
      if (val == null) continue;
      map[val.key] = val.value;
    }
    return map;
  }

  /// Put the specified value in the map if the key does not exist.
  ///
  /// [key]: Key to add.
  /// [ifAbsent]: Processing to enter a value when the key does not exist.
  V putIfAbsent(K key, V ifAbsent()) {
    MapEntry<K, V> val =
        this._map.putIfAbsent(key, () => MapEntry(key, ifAbsent()));
    if (val == null) return null;
    int index = this._sort.indexWhere((entry) => entry.key == val.key);
    if (index >= 0)
      this._sort[index] = val;
    else
      this._sort.add(val);
    return val?.value;
  }

  /// Removes the specified value and value from the map.
  ///
  /// [key]: Key to delete.
  V remove(Object key) {
    MapEntry<K, V> val = this._map.remove(key);
    if (val == null) return null;
    this._sort.remove(val);
    return val.value;
  }

  /// Specify the position and delete.
  ///
  /// [index]: Position to delete.
  V removeAt(int index) {
    MapEntry<K, V> tmp = this._sort.removeAt(index);
    if (tmp == null) return null;
    this._map.remove(tmp.key);
    return tmp.value;
  }

  /// Delete by specifying value.
  ///
  /// [value]: The value to remove.
  V removeValue(Object value) {
    this._map.removeWhere((k, v) => v == value);
    this._sort.removeWhere((v) => v == value);
    return value;
  }

  /// Delete by specifying conditions.
  ///
  /// [test]: Condition to delete. Delete if true.
  @override
  void removeWhere(bool test(K key, V value)) {
    this._map.removeWhere((k, v) => test(v.key, v.value));
    this._sort.removeWhere((v) => test(v.key, v.value));
  }

  /// Updates the value of the specified key with a conditional expression.
  ///
  /// [key]: Key to update.
  /// [update]: Update process.
  /// [ifAbsent]: Value to add if key does not exist.
  @override
  V update(K key, V update(V value), {V ifAbsent()}) {
    if (this._map.containsKey(key)) {
      V val = update(this._map[key].value);
      MapEntry<K, V> tmp = MapEntry(key, val);
      int index = this._sort.indexWhere((entry) => entry.key == key);
      this._sort[index] = tmp;
      this._map[key] = tmp;
      return val;
    } else if (ifAbsent != null) {
      V val = ifAbsent();
      MapEntry<K, V> tmp = MapEntry(key, val);
      this._map[key] = tmp;
      this._sort.add(tmp);
      return val;
    }
    return null;
  }

  /// Updates all elements according to specified processing.
  ///
  /// [update]: Update process.
  @override
  void updateAll(V update(K key, V value)) {
    for (K key in this._map.keys) {
      MapEntry<K, V> tmp = MapEntry(key, update(key, this._map[key]?.value));
      int index = this._sort.indexWhere((entry) => entry.key == key);
      this._sort[index] = tmp;
      this._map[key] = tmp;
    }
  }

  /// Gets the value for the specified key.
  ///
  /// [key]: Key to get.
  @override
  V operator [](Object key) {
    if (key is int) {
      return this._sort[key]?.value;
    } else {
      return this._map[key]?.value;
    }
  }

  /// Assigns a value to the specified key.
  ///
  /// [key]: Key to put.
  /// [value]: Value to put.
  @override
  void operator []=(Object key, V value) {
    if (key is int) {
      if (key < 0 || key >= this._sort.length) return;
      MapEntry<K, V> tmp = this._sort[key];
      if (tmp == null) return;
      K ktmp = tmp.key;
      tmp = MapEntry(ktmp, value);
      this._map[ktmp] = tmp;
      this._sort[key] = tmp;
    } else {
      MapEntry<K, V> tmp = MapEntry(key, value);
      this._map[key] = tmp;
      int index = this._sort.indexWhere((entry) => entry.key == key);
      if (index >= 0)
        this._sort[index] = tmp;
      else
        this._sort.add(tmp);
    }
  }

  /// Gets the value for the specified key.
  ///
  /// [key]: Key to get.
  V get(Object key) {
    if (!(K is int) && key is int) {
      return this._sort[key]?.value;
    } else {
      return this._map[key]?.value;
    }
  }

  /// Get value by index.
  ///
  /// [index]: Index to get.
  V getByIndex(int index) => this._sort[index]?.value;

  /// Get value by key.
  ///
  /// [key]: Key to get.
  V getByKey(String key) => this._map[key]?.value;

  /// Assigns a value to the specified key.
  ///
  /// [key]: Key to put.
  /// [value]: Value to put.
  void set(Object key, V value) {
    if (!(K is int) && key is int) {
      if (key < 0 || key >= this._sort.length) return;
      MapEntry<K, V> tmp = this._sort[key];
      if (tmp == null) return;
      K ktmp = tmp.key;
      tmp = MapEntry(ktmp, value);
      this._map[ktmp] = tmp;
      this._sort[key] = tmp;
    } else {
      MapEntry<K, V> tmp = MapEntry(key, value);
      this._map[key] = tmp;
      int index = this._sort.indexWhere((entry) => entry.key == key);
      if (index >= 0)
        this._sort[index] = tmp;
      else
        this._sort.add(tmp);
    }
  }

  /// Sorts elements according to specified processing.
  ///
  /// [compare]: Sort processing.
  void sort(int compare(MapEntry<K, V> a, MapEntry<K, V> b)) =>
      this._sort.sort(compare);

  /// Search for elements from the beginning and return the found element.
  ///
  /// [test]: Condition to search for element. Returns the element if True.
  /// [orElse]: Gets the element returned by this operation when there is no element.
  V firstWhere(bool test(K key, V value), {V Function() orElse}) => this
      ._sort
      .firstWhere((entry) => test(entry.key, entry.value),
          orElse: () => MapEntry(null, orElse()))
      ?.value;

  /// Filters the elements according to the specified conditions.
  ///
  /// [test]: Condition to search for element. Returns the element if True.
  /// [orElse]: Gets the element returned by this operation when there is no element.
  Iterable<MapEntry<K, V>> where(bool test(K key, V value),
      {V Function() orElse}) {
    return this._sort.where((entry) =>
        test(entry.key, entry.value) ?? (orElse != null ? orElse() : null));
  }
}

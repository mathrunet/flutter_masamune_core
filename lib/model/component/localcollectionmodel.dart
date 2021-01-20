part of masamune.model;

/// This model allows
/// you to save data in the device and use it as a collection.
class LocalCollectionModel extends CollectionModel {
  /// This model allows
  /// you to save data in the device and use it as a collection.
  LocalCollectionModel(String path,
      {OrderBy orderBy = OrderBy.none,
      OrderBy thenBy = OrderBy.none,
      String orderByKey,
      String thenByKey})
      : super(
          path,
          orderBy: orderBy,
          thenBy: thenBy,
          orderByKey: orderByKey,
          thenByKey: thenByKey,
        );

  /// Build the model.
  ///
  /// The [context] section contains the context needed for the model.
  ///
  /// You can return [Exposed] to reflect the data in it in the model.
  @override
  FutureOr build(ModelContext context) {
    return LocalCollection.load(
      this.path,
      orderBy: this.orderBy,
      thenBy: this.thenBy,
      orderByKey: this.orderByKey,
      thenByKey: this.thenByKey,
    );
  }
}

part of masamune.model;

/// This model allows
/// you to save data in the device and use it as a document.
class LocalDocumentModel extends DocumentModel {
  /// This model allows
  /// you to save data in the device and use it as a document.
  LocalDocumentModel(String path) : super(path);

  /// Build the model.
  ///
  /// The [context] section contains the context needed for the model.
  ///
  /// You can return [Exposed] to reflect the data in it in the model.
  @override
  FutureOr build(ModelContext context) {
    return LocalDocument.load(this.path);
  }

  /// Save the document data.
  ///
  /// The [data] is the value to be saved in the document. If the data exists in the current document, it will be overwritten.
  ///
  /// The [builder] can handle the document as it is after the data is saved.
  Future<T> save<T extends IDataDocument>(
      {Map<String, dynamic> data, void builder(T document)}) {
    LocalDocument document = LocalDocument.load(this.path);
    if (document == null || document.isDisposed)
      document = LocalDocument.create(this.path);
    return document.save(data: data, builder: builder);
  }
}

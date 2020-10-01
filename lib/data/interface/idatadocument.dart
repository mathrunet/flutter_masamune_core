part of masamune.data;

/// Document interface that stores [IDataField] by key.
///
/// Normally, instead of retrieving DataField, retrieve the data stored in [IDataField].
///
/// Please implement and use.
abstract class IDataDocument<TField extends IDataField>
    implements IDocument<TField>, IDynamicalDataMap {
  /// Get the UID of the document.
  ///
  /// If there is no value in the field, id will be output.
  String get uid;

  /// Get time.
  ///
  /// UpdatedTime is output if the field has no value.
  int get time;

  /// Update document data.
  Future<T> reload<T extends IDataDocument>();

  /// Save the data.
  ///
  /// Run if you have a remote or need to save data.
  Future<T> save<T extends IDataDocument>();

  /// Delete the data.
  ///
  /// Used when deleting data when there is a remote or when data needs to be saved.
  Future delete();
}

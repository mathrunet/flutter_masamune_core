part of masamune.interface;

/// Interface for input and output of [IDynamicDocument] collection.
///
/// At the time of input, you can enter the data in any direction,
/// and use the [get] method to get the data at the time of output.
abstract class IDynamicCollection<TDocument extends IDynamicDocument>
    implements Iterable<TDocument> {}

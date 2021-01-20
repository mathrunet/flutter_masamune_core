part of masamune.model;

/// A model that allows data to
/// be retrieved through an API and handled as a collection.
class ApiCollectionModel extends CollectionModel {
  /// URL of the endpoint.
  final String url;

  /// Request headers.
  final Map<String, String> headers;

  /// Request post data.
  final Map<String, String> postData;

  /// Request body.
  final String requestBody;

  /// Callback for constructing data from a response.
  final List<Map<String, dynamic>> Function(String response) builder;

  /// Define a mockup of the data.
  final List<Map<String, dynamic>> mockup;

  /// A model that allows data to
  /// be retrieved through an API and handled as a collection.
  ApiCollectionModel(
    String path, {
    this.url,
    this.headers,
    this.requestBody,
    this.postData,
    this.builder,
    this.mockup,
    OrderBy orderBy = OrderBy.none,
    OrderBy thenBy = OrderBy.none,
    String orderByKey,
    String thenByKey,
  }) : super(
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
    return ApiCollection.load(
      this.path,
      url: this.url,
      headers: this.headers,
      requestBody: this.requestBody,
      postData: this.postData,
      builder: this.builder,
      mockup: this.mockup,
      orderBy: this.orderBy,
      thenBy: this.thenBy,
      orderByKey: this.orderByKey,
      thenByKey: this.thenByKey,
    );
  }
}

part of masamune.model;

/// A model that allows data to
/// be retrieved through an API and handled as a document.
class ApiDocumentModel extends DocumentModel {
  /// URL of the endpoint.
  final String url;

  /// Request headers.
  final Map<String, String> headers;

  /// Request post data.
  final Map<String, String> postData;

  /// Request body.
  final String requestBody;

  /// Callback for constructing data from a response.
  final Map<String, dynamic> Function(String response) builder;

  /// Define a mockup of the data.
  final Map<String, dynamic> mockup;

  /// A model that allows data to
  /// be retrieved through an API and handled as a document.
  ApiDocumentModel(
    String path, {
    this.url,
    this.headers,
    this.requestBody,
    this.postData,
    this.builder,
    this.mockup,
  }) : super(path);

  /// Build the model.
  ///
  /// The [context] section contains the context needed for the model.
  ///
  /// You can return [Exposed] to reflect the data in it in the model.
  @override
  FutureOr build(ModelContext context) {
    return ApiDocument.load(
      this.path,
      url: this.url,
      headers: this.headers,
      requestBody: this.requestBody,
      postData: this.postData,
      builder: this.builder,
      mockup: this.mockup,
    );
  }
}

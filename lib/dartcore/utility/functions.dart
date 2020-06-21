part of masamune.dartcore;

/// Empty character check.
///
/// True if the object is null, false, empty string, 0.
///
/// [object]: The object to check.
bool isEmpty(Object object) =>
    object == null || object == false || object == "" || object == 0;

/// Empty character check.
///
/// True if the object is not null, false, empty string, 0.
///
/// [object]: The object to check.
bool isNotEmpty(Object object) => !isEmpty(object);

/// Open a new external URL.
///
/// [url]: URL to open.
Future openURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Log.error("Could not Launch %s", [url]);
  }
}

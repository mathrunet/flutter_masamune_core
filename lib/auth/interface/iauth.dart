part of masamune.auth;

/// Interface for handling authentication.
///
/// It inherits ITask and can wait for authentication.
///
/// Please implement and use
abstract class IAuth implements ITask {
  /// User / Universal ID at the time of authentication.
  String get uid;

  /// True if authenticated.
  bool get isAuthorized;

  /// Execute when authentication is completed.
  ///
  /// Do not use from external class.
  ///
  /// [uid]: User / Universal ID.
  @protected
  void authorized(String uid);
}

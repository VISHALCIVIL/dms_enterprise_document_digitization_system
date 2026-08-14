/// Base exception & failure handling classes for ScanDigitize.
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => '$runtimeType: $message${code != null ? ' ($code)' : ''}';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

class ScannerFailure extends Failure {
  const ScannerFailure(super.message, {super.code});
}

class OcrFailure extends Failure {
  const OcrFailure(super.message, {super.code});
}

class GoogleDriveFailure extends Failure {
  const GoogleDriveFailure(super.message, {super.code});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Base class for recoverable, user-presentable application failures.
///
/// Every exception carries a stable [code] that the localization layer maps to
/// a translated message, so no user-facing English is ever baked into logic.
class AppException implements Exception {
  const AppException(this.code, {this.detail});

  final String code;
  final String? detail;

  @override
  String toString() =>
      'AppException($code${detail == null ? '' : ': $detail'})';
}

class SpeechException extends AppException {
  const SpeechException(super.code, {super.detail});
}

class TtsException extends AppException {
  const TtsException(super.code, {super.detail});
}

class StorageException extends AppException {
  const StorageException(super.code, {super.detail});
}

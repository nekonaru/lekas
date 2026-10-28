import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// The Android speech recognizer behind Quick Add with voice (design
/// section 7.1), kept in one place so every screen asks for the microphone
/// the same way and no platform call escapes without a guard.
///
/// The plugin is missing in tests and on devices without a recognizer, so
/// every call turns into a plain `false` instead of an exception: the caller
/// then shows a message and the text field stays usable.
class VoiceInput {
  final SpeechToText _speech = SpeechToText();

  bool _ready = false;
  bool _listening = false;
  void Function(String errorCode, bool permanent)? _errorHandler;

  /// Bumped once per session, so a result the recognizer delivers late
  /// (after a quick stop and restart) belongs to a session that is already
  /// over and is dropped instead of re-appending an old sentence.
  int _session = 0;

  /// True while a session is running.
  bool get isListening => _listening;

  /// Prepares the recognizer once and asks for the microphone permission the
  /// first time. Returns false when the permission was denied or the
  /// platform side is not there. [onError] is called for every error of the
  /// sessions that follow, with the platform code such as "error_permission".
  Future<bool> ready({void Function(String errorCode, bool permanent)? onError}) async {
    _errorHandler = onError;
    if (_ready) return true;
    try {
      _ready = await _speech.initialize(onError: _handleError);
    } catch (_) {
      _ready = false;
    }
    return _ready;
  }

  void _handleError(SpeechRecognitionError error) {
    _errorHandler?.call(error.errorMsg, error.permanent);
  }

  /// Starts a session for [localeId] ("id_ID", "en_US"). [onText] receives
  /// the sentence recognized so far and [isFinal] marks the last one.
  Future<bool> start({
    required String localeId,
    required void Function(String text, bool isFinal) onText,
    required void Function(String errorCode, bool permanent) onError,
  }) async {
    final available = await ready(onError: onError);
    if (!available) return false;
    final session = ++_session;
    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          // The recognizer can answer after its session was replaced.
          if (session != _session) return;
          onText(result.recognizedWords, result.finalResult);
        },
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: true,
        ),
      );
      _listening = true;
    } catch (_) {
      _listening = false;
      return false;
    }
    return true;
  }

  /// Ends the session but keeps the recognizer ready for the next one.
  Future<void> stop() async {
    if (!_listening) return;
    _listening = false;
    _session++;
    try {
      await _speech.stop();
    } catch (_) {
      // The session was already gone; nothing to clean up.
    }
  }

  /// Drops the session without waiting for a final result.
  Future<void> cancel() async {
    _listening = false;
    _session++;
    try {
      await _speech.cancel();
    } catch (_) {
      // Nothing was running.
    }
  }
}

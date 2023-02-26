import 'dart:developer';

class Developer {
  static void logInstance(dynamic instance) {
    log('Start the ${instance.runtimeType} instance');
  }

  static void logError({required String errorText, required Object error, String? errorName, StackTrace? stackTrace, DateTime? time}) {
    log(errorText, error: error, stackTrace: stackTrace, time: time ?? DateTime.now(), name: errorName ?? '');
  }

  Developer._();
}

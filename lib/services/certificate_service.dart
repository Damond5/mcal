import "package:flutter/services.dart";

class CertificateService {
  static const String _channelName = "com.example.mcal/certificates";
  static const MethodChannel _channel = MethodChannel(_channelName);

  List<String>? _cachedCertificates;

  /// Reads system CA certificates from the platform.
  /// Caches the result to avoid repeated platform calls.
  Future<List<String>> getSystemCACertificates() async {
    if (_cachedCertificates != null) {
      return _cachedCertificates!;
    }

    final stopwatch = Stopwatch()..start();
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getCACertificates',
      );
      _cachedCertificates = result.cast<String>();
      stopwatch.stop();
      print(
        'Read ${_cachedCertificates!.length} CA certificates in ${stopwatch.elapsedMilliseconds}ms',
      );
      return _cachedCertificates!;
    } on PlatformException catch (e) {
      // Log error but don't crash - fallback to empty list
      stopwatch.stop();
      print(
        'Failed to read CA certificates after ${stopwatch.elapsedMilliseconds}ms: ${e.message}',
      );
      _cachedCertificates = [];
      return _cachedCertificates!;
    } catch (e) {
      stopwatch.stop();
      print(
        'Unexpected error reading CA certificates after ${stopwatch.elapsedMilliseconds}ms: $e',
      );
      _cachedCertificates = [];
      return _cachedCertificates!;
    }
  }

  /// Clears the certificate cache. Useful for testing or forced refresh.
  void clearCache() {
    _cachedCertificates = null;
  }
}

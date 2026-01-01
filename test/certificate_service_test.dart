import 'package:flutter_test/flutter_test.dart';
import 'package:mcal/services/certificate_service.dart';
import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CertificateService', () {
    late CertificateService certificateService;

    setUp(() async {
      certificateService = CertificateService();
      await clearCertificateMocks();
    });

    tearDown(() async {
      certificateService.clearCache();
      await clearCertificateMocks();
    });

    test('returns mocked certificates from channel', () async {
      final mockCerts = [
        '-----BEGIN CERTIFICATE-----\nCert 1\n-----END CERTIFICATE-----',
        '-----BEGIN CERTIFICATE-----\nCert 2\n-----END CERTIFICATE-----',
      ];
      await setupCertificateMocks(certificates: mockCerts);

      final certs = await certificateService.getSystemCACertificates();

      expect(certs, equals(mockCerts));
    });

    test('caches certificates after first read', () async {
      final mockCerts = ['cert1'];
      await setupCertificateMocks(certificates: mockCerts);

      final firstCall = await certificateService.getSystemCACertificates();
      final secondCall = await certificateService.getSystemCACertificates();

      expect(firstCall, equals(secondCall));
      expect(firstCall, equals(mockCerts));
    });

    test('clearCache forces re-reading certificates', () async {
      final firstCerts = ['cert1'];
      await setupCertificateMocks(certificates: firstCerts);

      final firstCall = await certificateService.getSystemCACertificates();
      certificateService.clearCache();

      final secondCerts = ['cert2'];
      await clearCertificateMocks();
      await setupCertificateMocks(certificates: secondCerts);

      final secondCall = await certificateService.getSystemCACertificates();

      expect(firstCall, equals(firstCerts));
      expect(secondCall, equals(secondCerts));
      expect(firstCall, isNot(equals(secondCall)));
    });

    test('returns empty list on PlatformException', () async {
      await setupCertificateMocks(
        certificates: [],
        throwException: true,
        exceptionMessage: 'Failed to read certificates',
      );

      final certs = await certificateService.getSystemCACertificates();

      expect(certs, isEmpty);
    });

    test('returns empty list for empty certificate list', () async {
      await setupCertificateMocks(certificates: []);

      final certs = await certificateService.getSystemCACertificates();

      expect(certs, isEmpty);
    });

    test('handles generic exceptions gracefully', () async {
      await setupCertificateMocks(
        certificates: [],
        throwException: true,
        exceptionCode: 'GENERIC_ERROR',
        exceptionMessage: 'Unexpected error',
      );

      final certs = await certificateService.getSystemCACertificates();

      expect(certs, isEmpty);
    });

    test('caches empty list when platform returns empty', () async {
      await setupCertificateMocks(certificates: []);

      final firstCall = await certificateService.getSystemCACertificates();
      final secondCall = await certificateService.getSystemCACertificates();

      expect(firstCall, isEmpty);
      expect(secondCall, isEmpty);
      expect(firstCall, equals(secondCall));
    });

    test('clearCache removes cached empty list', () async {
      await setupCertificateMocks(certificates: []);

      await certificateService.getSystemCACertificates();
      certificateService.clearCache();

      final newCerts = ['cert1'];
      await clearCertificateMocks();
      await setupCertificateMocks(certificates: newCerts);

      final result = await certificateService.getSystemCACertificates();

      expect(result, equals(newCerts));
    });

    test('handles single certificate correctly', () async {
      final mockCerts = [
        '-----BEGIN CERTIFICATE-----\nSingle cert\n-----END CERTIFICATE-----',
      ];
      await setupCertificateMocks(certificates: mockCerts);

      final certs = await certificateService.getSystemCACertificates();

      expect(certs.length, equals(1));
      expect(certs, equals(mockCerts));
    });

    test('handles large certificate list', () async {
      final mockCerts = List.generate(
        100,
        (i) =>
            '-----BEGIN CERTIFICATE-----\nCert $i\n-----END CERTIFICATE-----',
      );
      await setupCertificateMocks(certificates: mockCerts);

      final certs = await certificateService.getSystemCACertificates();

      expect(certs.length, equals(100));
      expect(certs, equals(mockCerts));
    });

    test('maintains cache across multiple service instances', () async {
      final mockCerts = ['cert1'];
      await setupCertificateMocks(certificates: mockCerts);

      final service1 = CertificateService();
      await service1.getSystemCACertificates();

      final service2 = CertificateService();
      service2.clearCache();

      final newCerts = ['cert2'];
      await clearCertificateMocks();
      await setupCertificateMocks(certificates: newCerts);

      final result = await service2.getSystemCACertificates();

      expect(result, equals(newCerts));
    });
  });
}

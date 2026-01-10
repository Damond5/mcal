import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mcal/api.dart';
import 'package:mcal/frb_generated.dart';
import 'package:mcal/services/certificate_service.dart';
import '../test/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await RustLib.init();
    await setupAllIntegrationMocks();
  });

  group('Certificate Integration Tests', () {
    late CertificateService certificateService;

    setUp(() {
      certificateService = CertificateService();
    });

    testWidgets(
      'reads real system certificates on Android',
      skip: !Platform.isAndroid,
      (tester) async {
        await tester.pumpAndSettle();

        final certs = await certificateService.getSystemCACertificates();

        expect(certs, isNotEmpty);
        expect(
          certs.every((cert) => cert.contains('-----BEGIN CERTIFICATE-----')),
          true,
        );
        expect(
          certs.every((cert) => cert.contains('-----END CERTIFICATE-----')),
          true,
        );
      },
    );

    testWidgets(
      'reads real system certificates on iOS',
      skip: !Platform.isIOS,
      (tester) async {
        await tester.pumpAndSettle();

        final certs = await certificateService.getSystemCACertificates();

        expect(certs, isNotEmpty);
        expect(
          certs.every((cert) => cert.contains('-----BEGIN CERTIFICATE-----')),
          true,
        );
        expect(
          certs.every((cert) => cert.contains('-----END CERTIFICATE-----')),
          true,
        );
      },
    );

    testWidgets(
      'certificates have valid PEM format on Android',
      skip: !Platform.isAndroid,
      (tester) async {
        await tester.pumpAndSettle();

        final certs = await certificateService.getSystemCACertificates();

        for (final cert in certs) {
          expect(cert.trim().startsWith('-----BEGIN CERTIFICATE-----'), true);
          expect(cert.trim().endsWith('-----END CERTIFICATE-----'), true);
          expect(
            cert.contains('\n'),
            true,
            reason: 'Certificate should have content',
          );
        }
      },
    );

    testWidgets(
      'certificates have valid PEM format on iOS',
      skip: !Platform.isIOS,
      (tester) async {
        await tester.pumpAndSettle();

        final certs = await certificateService.getSystemCACertificates();

        for (final cert in certs) {
          expect(cert.trim().startsWith('-----BEGIN CERTIFICATE-----'), true);
          expect(cert.trim().endsWith('-----END CERTIFICATE-----'), true);
          expect(
            cert.contains('\n'),
            true,
            reason: 'Certificate should have content',
          );
        }
      },
    );

    testWidgets(
      'Rust backend receives certificates via setSslCaCerts on Android',
      skip: !Platform.isAndroid,
      (tester) async {
        await tester.pumpAndSettle();

        final certs = await certificateService.getSystemCACertificates();
        expect(certs, isNotEmpty);

        await setSslCaCerts(pemCerts: certs);
      },
    );

    testWidgets(
      'Rust backend receives certificates via setSslCaCerts on iOS',
      skip: !Platform.isIOS,
      (tester) async {
        await tester.pumpAndSettle();

        final certs = await certificateService.getSystemCACertificates();
        expect(certs, isNotEmpty);

        await setSslCaCerts(pemCerts: certs);
      },
    );

    testWidgets('reads certificates on Android', skip: !Platform.isAndroid, (
      tester,
    ) async {
      await tester.pumpAndSettle();

      certificateService.clearCache();
      final certs = await certificateService.getSystemCACertificates();

      expect(certs, isNotEmpty);
    });

    testWidgets('reads certificates on iOS', skip: !Platform.isIOS, (
      tester,
    ) async {
      await tester.pumpAndSettle();

      certificateService.clearCache();
      final certs = await certificateService.getSystemCACertificates();

      expect(certs, isNotEmpty);
    });

    testWidgets(
      'certificate caching works on real devices - Android',
      skip: !Platform.isAndroid,
      (tester) async {
        await tester.pumpAndSettle();

        certificateService.clearCache();
        final firstCall = await certificateService.getSystemCACertificates();
        final secondCall = await certificateService.getSystemCACertificates();

        expect(firstCall, equals(secondCall));
        expect(firstCall, isNotEmpty);
      },
    );

    testWidgets(
      'certificate caching works on real devices - iOS',
      skip: !Platform.isIOS,
      (tester) async {
        await tester.pumpAndSettle();

        certificateService.clearCache();
        final firstCall = await certificateService.getSystemCACertificates();
        final secondCall = await certificateService.getSystemCACertificates();

        expect(firstCall, equals(secondCall));
        expect(firstCall, isNotEmpty);
      },
    );

    testWidgets(
      'clearCache forces re-reading on Android',
      skip: !Platform.isAndroid,
      (tester) async {
        await tester.pumpAndSettle();

        certificateService.clearCache();
        final firstCall = await certificateService.getSystemCACertificates();
        certificateService.clearCache();
        final secondCall = await certificateService.getSystemCACertificates();

        expect(firstCall, isNotEmpty);
        expect(secondCall, isNotEmpty);
      },
    );

    testWidgets('clearCache forces re-reading on iOS', skip: !Platform.isIOS, (
      tester,
    ) async {
      await tester.pumpAndSettle();

      certificateService.clearCache();
      final firstCall = await certificateService.getSystemCACertificates();
      certificateService.clearCache();
      final secondCall = await certificateService.getSystemCACertificates();

      expect(firstCall, isNotEmpty);
      expect(secondCall, isNotEmpty);
    });
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });
}

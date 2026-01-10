package com.mcal

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.util.Log
import java.security.KeyStore
import java.security.cert.Certificate
import java.security.cert.X509Certificate
import java.io.ByteArrayOutputStream
import java.util.Base64

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mcal/certificates"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getCACertificates") {
                try {
                    val certificates = getSystemCACertificates()
                    result.success(certificates)
                } catch (e: Exception) {
                    Log.e("MainActivity", "Error reading CA certificates", e)
                    result.success(emptyList<String>()) // Fallback to empty list
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getSystemCACertificates(): List<String> {
        val certificates = mutableListOf<String>()
        try {
            val keyStore = KeyStore.getInstance("AndroidCAStore")
            keyStore.load(null, null)

            val aliases = keyStore.aliases()
            while (aliases.hasMoreElements()) {
                val alias = aliases.nextElement()
                val cert = keyStore.getCertificate(alias)
                if (cert is X509Certificate) {
                    val pem = certificateToPEM(cert)
                    certificates.add(pem)
                }
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Failed to load system CA certificates", e)
        }
        return certificates
    }

    private fun certificateToPEM(cert: X509Certificate): String {
        val encoded = cert.encoded
        val base64 = Base64.getEncoder().encodeToString(encoded)
        return "-----BEGIN CERTIFICATE-----\n" +
               base64.chunked(64).joinToString("\n") +
               "\n-----END CERTIFICATE-----\n"
    }
}
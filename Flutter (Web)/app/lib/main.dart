import 'dart:convert';

import 'package:app/firebase_options.dart';
import 'package:app/logging_service.dart';
import 'package:app/page_not_found.dart';
import 'package:app/splash_page.dart';
import 'package:app/theme.dart';
import 'package:app/verify_page.dart';
import 'package:cryptography/cryptography.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> decrypt(String encryptedPayload, String secretKey) async {
    try {
      String fixedPayload = encryptedPayload;
      final remainder = fixedPayload.length % 4;
      if (remainder != 0) {
        fixedPayload += '=' * (4 - remainder);
      }

      final payload = base64Url.decode(fixedPayload);

      final iv = payload.sublist(0, 12);
      final tag = payload.sublist(payload.length - 16);
      final ciphertext = payload.sublist(12, payload.length - 16);

      final keyBytes = await Sha256().hash(utf8.encode(secretKey)).then((hash) => hash.bytes);

      final algorithm = AesGcm.with256bits();
      final secretBox = SecretBox(ciphertext, nonce: iv, mac: Mac(tag));
      final secretKeyObj = SecretKey(keyBytes);

      final clearBytes = await algorithm.decrypt(secretBox, secretKey: secretKeyObj);
      return utf8.decode(clearBytes);
    } catch (e) {
      LoggingService.error("Decryption failed: $e");
      rethrow;
    }
  }

  Widget page() {
    final uri = Uri.base;

    if (uri.pathSegments.isEmpty) {
      return const SplashPage();
    } else if (uri.pathSegments.length == 1 && uri.pathSegments.first == 'verify') {
      final encryptedPayload = uri.query;
      final secretKey = const String.fromEnvironment(
        'ENCRYPTION_SECRET',
        defaultValue: 'YOUR_SECRET_KEY',
      );

      return FutureBuilder(
        future: decrypt(encryptedPayload, secretKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashPage();
          } else if (snapshot.hasError) {
            return const PageNotFound();
          }

          final params = Uri.splitQueryString(snapshot.data as String);
          final email = params['email'];
          final token = params['token'];

          return VerifyPage(email: email!, token: token!);
        },
      );
    }

    return const PageNotFound();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bull Mail',
      theme: AppTheme.lightTheme,
      home: page(),
    );
  }
}

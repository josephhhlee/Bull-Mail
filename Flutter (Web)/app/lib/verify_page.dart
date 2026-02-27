import 'package:app/logging_service.dart';
import 'package:app/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VerifyPage extends StatefulWidget {
  final String token;
  final String email;

  const VerifyPage({super.key, required this.token, required this.email});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  bool? _success;
  String? _frequency;

  @override
  void initState() {
    _verify();
    super.initState();
  }

  Future<void> _verify() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .where('verificationToken', isEqualTo: widget.token)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _success = false;
        setState(() {});
        return;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();
      final expiry = data['verificationExpiry'] as Timestamp?;

      if (expiry == null || expiry.toDate().isBefore(DateTime.now())) {
        _success = false;
      } else {
        _frequency = data['frequency'] as String?;
        _success = true;
        await doc.reference.update({
          'isVerified': true,
          'verificationExpiry': FieldValue.delete(),
          'verificationToken': FieldValue.delete(),
        });
      }
    } catch (e) {
      LoggingService.error('Verification failed', error: e, tag: 'VerifyPage');
      _success = false;
    }

    setState(() {});
  }

  String message() {
    switch (_frequency!.toUpperCase()) {
      case 'DAILY':
        return 'Emails are delivered around 9:30 PM (GMT+8).';
      case 'WEEKLY':
        return 'Emails go out at approximately 9:30 PM (GMT+8), and updates are issued weekly on Mondays.';
      case 'MONTHLY':
        return 'Emails go out at approximately 9:30 PM (GMT+8), and updates are delivered on the 1st of every month';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _success == null
              ? const CircularProgressIndicator()
              : _success == false
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: AppTheme.error, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Invalid or Expired',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.error,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The verification link is invalid or has expired.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppTheme.success, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Success!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You will start receiving ${_frequency?.toLowerCase()} emails.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.info),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

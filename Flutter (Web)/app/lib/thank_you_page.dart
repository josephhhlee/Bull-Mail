import 'package:app/logging_service.dart';
import 'package:app/stock_service.dart';
import 'package:app/theme.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThankYouPage extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController frequencyController;

  const ThankYouPage({super.key, required this.emailController, required this.frequencyController});

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  bool? _success;

  @override
  void initState() {
    sendSubscription();
    super.initState();
  }

  Future<void> sendSubscription() async {
    try {
      final response = await FirebaseFunctions.instanceFor(region: 'asia-southeast1')
          .httpsCallable('enrollment')
          .call({
            'email': widget.emailController.text,
            'frequency': widget.frequencyController.text,
            'tickers': context
                .read<SelectedStockCubit>()
                .state
                .selectedStocks
                .map((e) => e.symbol)
                .toList(),
            'origin': Uri.base.origin,
          });

      _success = response.data as bool? ?? false;
    } catch (e) {
      LoggingService.error('Failed to send subscription', tag: 'ThankYouPage', error: e);
      _success = false;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: _success == null
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 10,
                trackGap: 10,
                constraints: BoxConstraints(minHeight: 150, minWidth: 150),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _success! ? Icons.check_circle : Icons.error_outline,
                  color: _success! ? AppTheme.success : AppTheme.error,
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  _success! ? 'Thank You!' : 'Oops!',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  _success!
                      ? 'Your subscription has been set up successfully.'
                      : 'Something went wrong. Please try again.',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_success!)
                  const Text(
                    'To complete verification, please click the link in your email within 24 hours.',
                    style: TextStyle(fontSize: 16, color: AppTheme.info),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
    );
  }
}

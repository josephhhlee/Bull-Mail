import 'package:app/logging_service.dart';
import 'package:app/stock_service.dart';
import 'package:app/theme.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThankYouPage extends StatefulWidget {
  final TextEditingController emailController;

  const ThankYouPage({super.key, required this.emailController});

  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  bool? _success;

  @override
  void initState() {
    super.initState();
    _sendSubscription();
  }

  Future<void> _sendSubscription() async {
    try {
      final response = await FirebaseFunctions.instanceFor(region: 'asia-southeast1')
          .httpsCallable('enrollment')
          .call({
            'email': widget.emailController.text,
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

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: _success == null
              ? const SizedBox(
                  height: 180,
                  width: 180,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 8)),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _success! ? Icons.check_circle_outline : Icons.error_outline,
                        color: _success! ? AppTheme.success : AppTheme.error,
                        size: 80,
                      ),
                      const SizedBox(height: 5),

                      Text(
                        _success! ? 'Thank You!' : 'Oops!',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      Text(
                        _success!
                            ? 'Your subscription has been set up successfully.'
                            : 'Something went wrong. Please try again.',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      if (_success!)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            'To complete verification, please click the link in your email within 24 hours.',
                            style: const TextStyle(fontSize: 14, color: AppTheme.info),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

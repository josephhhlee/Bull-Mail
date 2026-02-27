import 'package:app/stock_service.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewPage extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final TextEditingController emailController;
  final TextEditingController frequencyController;

  const ReviewPage({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.emailController,
    required this.frequencyController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Your Details', style: AppTheme.headline3),

        // Scroll to bottom message
        Text('Scroll to the bottom to confirm', style: AppTheme.hint),
        const SizedBox(height: 24),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email Section
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email Address', style: AppTheme.bodyText3),
                    subtitle: Text(emailController.text, style: AppTheme.bodyText2),
                  ),
                ),
                const SizedBox(height: 16),

                // Frequency Section
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Email Frequency', style: AppTheme.bodyText3),
                    subtitle: Text(frequencyController.text, style: AppTheme.bodyText2),
                  ),
                ),
                const SizedBox(height: 16),

                // Stock Lists Section
                Card(
                  child: BlocBuilder<SelectedStockCubit, SelectedStockState>(
                    builder: (context, state) {
                      return ListTile(
                        titleAlignment: ListTileTitleAlignment.top,
                        leading: const Icon(Icons.list),
                        title: const Text('Selected Stock Lists', style: AppTheme.bodyText3),
                        subtitle: Text(
                          state.selectedStocks
                              .map((stock) => '•  ${stock.symbol} (${stock.name})')
                              .join('\n'),
                          style: AppTheme.bodyText2,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Verification Message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.blue.shade700),
                            children: [
                              const TextSpan(
                                text:
                                    'You will need to verify your email through a verification link sent to ',
                              ),
                              TextSpan(
                                text: emailController.text,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ' in order to start receiving '),
                              TextSpan(
                                text: frequencyController.text.toLowerCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: ' emails.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: onBack,
                      child: const Text('Back', style: AppTheme.button),
                    ),
                    ElevatedButton(
                      onPressed: onNext,
                      child: const Text('Confirm', style: AppTheme.button),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

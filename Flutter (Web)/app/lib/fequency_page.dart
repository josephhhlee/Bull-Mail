import 'package:app/theme.dart';
import 'package:flutter/material.dart';

class FrequencyPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final TextEditingController controller;

  const FrequencyPage({super.key, required this.onNext, required this.onBack, required this.controller});

  final List<String> _frequencies = const ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Choose Delivery Frequency', style: AppTheme.headline2, textAlign: TextAlign.center),
        const SizedBox(height: 20),

        DropdownButtonFormField(
          initialValue: controller.text.isNotEmpty ? controller.text : null,
          borderRadius: BorderRadius.circular(20),
          decoration: InputDecoration(labelText: 'Select Frequency', floatingLabelBehavior: FloatingLabelBehavior.never),
          items: _frequencies.map<DropdownMenuItem<String>>((v) => DropdownMenuItem<String>(value: v, child: Text(v))).toList(),
          onChanged: (String? val) => controller.text = val ?? '',
        ),

        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(left: 15),
          child: const Text(
            '• Emails are delivered around 9:30 PM (GMT+8).\n'
            '• Weekly updates are sent every Monday.\n'
            '• Monthly updates are sent on the 1st of each month.',
            style: AppTheme.bodyText2,
          ),
        ),
        const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: onBack,
              child: const Text('Back', style: AppTheme.button),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onNext();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
                }
              },
              child: const Text('Next', style: AppTheme.button),
            ),
          ],
        ),
      ],
    );
  }
}

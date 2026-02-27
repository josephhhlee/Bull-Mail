import 'package:app/resource.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmailPage extends StatelessWidget {
  final VoidCallback onNext;
  final TextEditingController controller;
  const EmailPage({super.key, required this.onNext, required this.controller});

  bool _validateEmail(String email) {
    return email.isNotEmpty &&
        RegExp(
          r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+"
          r"(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@"
          r"(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+"
          r"[a-z0-9](?:[a-z0-9-]*[a-z0-9])?",
        ).hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Logo(size: 55),
            const SizedBox(width: 10),
            Flexible(
              child: const Text(
                'Bull Mail',
                style: AppTheme.headline1,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Get detailed stock updates delivered to your email at your preferred frequency.',
          textAlign: TextAlign.center,
          style: AppTheme.bodyText1,
        ),
        const SizedBox(height: 40),
        TextFormField(
          controller: controller,
          maxLength: 50,
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [LowerCaseTextFormatter()],
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          cursorColor: AppTheme.primary,
          decoration: InputDecoration(hintText: 'Enter your email', counterText: ''),
          onFieldSubmitted: (value) {
            if (_validateEmail(value)) {
              onNext();
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
            }
          },
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            if (_validateEmail(controller.text)) {
              onNext();
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
            }
          },
          child: const Text('Next', style: AppTheme.button),
        ),
      ],
    );
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toLowerCase(), selection: newValue.selection);
  }
}

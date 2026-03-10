import 'package:app/resource.dart';
import 'package:app/stock_service.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final TextEditingController controller;
  const EmailPage({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.controller,
  });

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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),

              const SizedBox(height: 20),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: _buildEmailField(context),
              ),

              const SizedBox(height: 40),

              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Logo(size: 55),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Get Stock News in Your Inbox',
                softWrap: true,
                style: AppTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        SizedBox(height: 20),

        Text(
          'We\'ll send important stock news and alerts directly to this email.',
          style: TextStyle(fontSize: 15, height: 1.4, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: true,
      maxLength: 50,
      keyboardType: TextInputType.emailAddress,
      inputFormatters: [LowerCaseTextFormatter()],
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      cursorColor: AppTheme.primary,
      decoration: InputDecoration(
        hintText: 'Enter your email',
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        prefixIcon: Icon(Icons.email, color: AppTheme.primaryVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
      onFieldSubmitted: (value) {
        if (_validateEmail(value)) {
          onNext();
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
        }
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minWidth: 80, maxWidth: 200),
            child: ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Back', style: AppTheme.button),
            ),
          ),
        ),

        const SizedBox(width: 16),

        Flexible(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minWidth: 130, maxWidth: 200),
            child: BlocBuilder<SelectedStockCubit, SelectedStockState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    if (_validateEmail(controller.text)) {
                      onNext();
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Review Details', style: AppTheme.button),
                );
              },
            ),
          ),
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

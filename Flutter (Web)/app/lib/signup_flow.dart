import 'package:app/email_page.dart';
import 'package:app/review_page.dart';
import 'package:app/stock_list_page.dart';
import 'package:app/thank_you_page.dart';
import 'package:flutter/material.dart';

class SignUpFlow extends StatefulWidget {
  const SignUpFlow({super.key});

  @override
  State<SignUpFlow> createState() => _SignUpFlowState();
}

class _SignUpFlowState extends State<SignUpFlow> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final TextEditingController _emailController = TextEditingController();

  void _nextPage() {
    if (_currentPage < 3) {
      _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget pageConstraint(Widget child) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: IntrinsicHeight(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 750),
          padding: const EdgeInsets.all(30),
          margin: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bull_mail_background.png"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.white30, BlendMode.srcOver),
          ),
        ),
        child: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) => setState(() => _currentPage = index),
          children: [
            pageConstraint(StockInputPage(onNext: _nextPage, emailController: _emailController)),
            pageConstraint(
              EmailPage(onNext: _nextPage, onBack: _previousPage, controller: _emailController),
            ),
            pageConstraint(
              ReviewPage(
                onBack: _previousPage,
                onNext: _nextPage,
                emailController: _emailController,
              ),
            ),
            pageConstraint(ThankYouPage(emailController: _emailController)),
          ],
        ),
      ),
    );
  }
}

import 'package:app/email_page.dart';
import 'package:app/fequency_page.dart';
import 'package:app/review_page.dart';
import 'package:app/stock_list_page.dart';
import 'package:app/thank_you_page.dart';
import 'package:flutter/material.dart';

class EntryFlow extends StatefulWidget {
  const EntryFlow({super.key});

  @override
  State<EntryFlow> createState() => _EntryFlowState();
}

class _EntryFlowState extends State<EntryFlow> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();

  void _nextPage() {
    if (_currentPage < 4) {
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
            pageConstraint(EmailPage(onNext: _nextPage, controller: _emailController)),
            pageConstraint(
              FrequencyPage(
                onNext: _nextPage,
                onBack: _previousPage,
                controller: _frequencyController,
              ),
            ),
            pageConstraint(
              StockInputPage(
                onNext: _nextPage,
                onBack: _previousPage,
                emailController: _emailController,
              ),
            ),
            pageConstraint(
              ReviewPage(
                onBack: _previousPage,
                onNext: _nextPage,
                emailController: _emailController,
                frequencyController: _frequencyController,
              ),
            ),
            pageConstraint(
              ThankYouPage(
                emailController: _emailController,
                frequencyController: _frequencyController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

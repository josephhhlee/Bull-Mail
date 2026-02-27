import 'package:app/entry_flow.dart';
import 'package:app/resource.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/bull_mail_background.png"), context);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (context.mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) => const EntryFlow(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });

    return const Scaffold(body: Center(child: Logo(size: 100)));
  }
}

import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double size;

  const Logo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo',
      child: Image.asset('assets/favicon-512-no-white.png', width: size, height: size),
    );
  }
}

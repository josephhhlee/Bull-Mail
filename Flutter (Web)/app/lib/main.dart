import 'package:app/firebase_options.dart';
import 'package:app/page_not_found.dart';
import 'package:app/splash_page.dart';
import 'package:app/stock_service.dart';
import 'package:app/theme.dart';
import 'package:app/verify_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<StockCubit>(create: (context) => StockCubit()),
        BlocProvider<SelectedStockCubit>(create: (context) => SelectedStockCubit()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget page() {
    final uri = Uri.base;

    if (uri.pathSegments.isEmpty) {
      return const SplashPage();
    } else if (uri.pathSegments.length == 1 && uri.pathSegments.first == 'verify') {
      final token = uri.queryParameters['token'];
      final email = uri.queryParameters['email'];
      if (token != null && token.isNotEmpty && email != null && email.isNotEmpty) {
        return VerifyPage(token: token, email: email);
      }
    }

    return const PageNotFound();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bull Mail',
      theme: AppTheme.lightTheme,
      home: page(),
    );
  }
}

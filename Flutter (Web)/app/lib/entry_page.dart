import 'package:app/resource.dart';
import 'package:app/signup_flow.dart';
import 'package:app/stock_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      3,
      (index) => AnimationController(vsync: this, duration: const Duration(milliseconds: 500)),
    );

    _animations = _controllers
        .map((controller) => CurvedAnimation(parent: controller, curve: Curves.easeOutBack))
        .toList();

    _playAnimations();
  }

  Future<void> _playAnimations() async {
    for (var controller in _controllers) {
      await Future.delayed(const Duration(milliseconds: 150));
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final screenWidth = MediaQuery.of(context).size.width;

    final steps = [
      StepCard(
        number: "1",
        title: "Add Your Watchlist",
        description: "Select the stocks you want to follow and build your personal watchlist.",
      ),
      StepCard(
        number: "2",
        title: "We Monitor the News",
        description: "Our system tracks important news and market updates related to your stocks.",
      ),
      StepCard(
        number: "3",
        title: "Get Daily Alerts",
        description: "Receive the most important updates delivered to you each day.",
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bull_mail_background.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.white30, BlendMode.srcOver),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Logo(size: 60),
                      const SizedBox(width: 15),
                      Text(
                        'Bull Mail',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 40,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Daily stock news for your watchlist',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Get the most important stock news delivered daily from your personal watchlist.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Bull Mail monitors the stocks you care about and delivers the most important news directly to you. '
                    'Add your watchlist and receive clear, relevant updates every day so you never miss critical developments.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 50),
                  screenWidth > 800
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(steps.length, (index) {
                            return Flexible(
                              child: ScaleTransition(
                                scale: _animations[index],
                                child: steps[index],
                              ),
                            );
                          }),
                        )
                      : Column(
                          children: List.generate(steps.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: ScaleTransition(
                                scale: _animations[index],
                                child: steps[index],
                              ),
                            );
                          }),
                        ),
                  const SizedBox(height: 60),
                  Ink(
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SizedBox(
                      height: 60,
                      width: 220,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, _, __) => MultiBlocProvider(
                                providers: [
                                  BlocProvider<StockCubit>(create: (context) => StockCubit()),
                                  BlocProvider<SelectedStockCubit>(
                                    create: (context) => SelectedStockCubit(),
                                  ),
                                ],
                                child: const SignUpFlow(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          backgroundColor: theme.primaryColor.withAlpha(150),
                          elevation: 3,
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'Start Monitoring',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Daily Updates • Relevant News • No Noise',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StepCard extends StatefulWidget {
  final String number;
  final String title;
  final String description;

  const StepCard({super.key, required this.number, required this.title, required this.description});

  @override
  State<StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<StepCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(isHovered ? 220 : 243),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: isHovered ? 18 : 10,
              color: Colors.black26,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.primaryColor.withAlpha(200),
              child: Text(
                widget.number,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

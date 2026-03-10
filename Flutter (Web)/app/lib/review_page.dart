import 'package:app/resource.dart';
import 'package:app/stock_service.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final TextEditingController emailController;

  const ReviewPage({
    super.key,
    required this.emailController,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrollable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkScrollable());
  }

  void _checkScrollable() {
    if (!mounted) return;

    final scrollable = _scrollController.position.maxScrollExtent > 0;
    if (_isScrollable != scrollable) {
      setState(() {
        _isScrollable = scrollable;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Logo(size: 55),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text('Review Your Details', softWrap: true, style: AppTheme.headline3),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isScrollable)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            'Scroll down to confirm your email and watchlist.',
                            style: AppTheme.hint,
                          ),
                        ),
                      if (_isScrollable) const SizedBox(height: 15),
                      _buildNotice(),
                      const SizedBox(height: 20),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          leading: const Icon(Icons.email, color: AppTheme.primary),
                          title: const Text('Email Address', style: AppTheme.bodyText3),
                          subtitle: Text(widget.emailController.text, style: AppTheme.bodyText2),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: BlocBuilder<SelectedStockCubit, SelectedStockState>(
                          builder: (context, state) {
                            return ListTile(
                              leading: const Icon(Icons.list, color: AppTheme.primary),
                              title: const Text('Watchlist', style: AppTheme.bodyText3),
                              subtitle: Text(
                                state.selectedStocks
                                    .map((stock) => '• ${stock.symbol} (${stock.name})')
                                    .join('\n'),
                                style: AppTheme.bodyText2,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              isThreeLine: true,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildActionButtons(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.blue.shade700, height: 1.4),
                children: [
                  const TextSpan(
                    text: 'You will need to verify your email through a link sent to ',
                  ),
                  TextSpan(
                    text: widget.emailController.text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' before you can start receiving stock news updates.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: widget.onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Back', style: AppTheme.button),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: widget.onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm', style: AppTheme.button),
          ),
        ),
      ],
    );
  }
}

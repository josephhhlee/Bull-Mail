import 'package:app/stock_service.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StockInputPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final TextEditingController? emailController;

  const StockInputPage({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.emailController,
  });

  @override
  State<StockInputPage> createState() => _StockInputPageState();
}

class _StockInputPageState extends State<StockInputPage> {
  final TextEditingController _symbolController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _symbolController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _searchStock() {
    final query = _symbolController.text.trim().toUpperCase();
    if (query.isNotEmpty) {
      context.read<StockCubit>().searchStock(query, widget.emailController!.text);
    }
  }

  void _selectStock() {
    final stockCubit = context.read<StockCubit>();
    if (stockCubit.state is StockLoaded) {
      final stock = (stockCubit.state as StockLoaded).stock;
      context.read<SelectedStockCubit>().addStock(stock);
      stockCubit.clearResult();
      _symbolController.clear();
      Future.delayed(Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitle(),
                const SizedBox(height: 20),
                _buildInputSection(),
                const SizedBox(height: 20),
                _buildSearchResult(),
                const SizedBox(height: 20),
                _buildSelectedStocks(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Enter Stock Symbols',
      style: AppTheme.headline2,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInputSection() {
    return Row(
      children: [
        Expanded(child: _buildTextField()),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _searchStock,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.background),
          child: const Text('Search', style: AppTheme.button),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _symbolController,
      autofocus: true,
      maxLength: 7,
      decoration: InputDecoration(
        hintText: 'Stock symbol (e.g., AAPL)',
        counterText: '',
        suffixIcon: _symbolController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                hoverColor: Colors.transparent,
                onPressed: () => setState(() {
                  _symbolController.clear();
                  context.read<StockCubit>().clearResult();
                }),
              )
            : null,
      ),
      inputFormatters: [
        UpperCaseTextFormatter(),
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9.\-:/+& ]')),
      ],
      textCapitalization: TextCapitalization.characters,
      textAlign: TextAlign.center,
      cursorColor: AppTheme.primary,
      onSubmitted: (_) => _searchStock(),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildSearchResult() {
    return BlocBuilder<StockCubit, StockState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _buildSearchResultContent(state),
        );
      },
    );
  }

  Widget _buildSearchResultContent(StockState state) {
    if (state is StockLoading) {
      return const CircularProgressIndicator(key: ValueKey('loading'));
    }
    if (state is StockError) {
      return Text('Error: ${state.message}', key: const ValueKey('error'));
    }
    if (state is StockNotFound) {
      return Text('No stocks found for "${state.input}"', key: const ValueKey('notfound'));
    }
    if (state is StockLoaded) {
      return _buildStockCard(state.stock);
    }
    return const SizedBox.shrink(key: ValueKey('empty'));
  }

  Widget _buildStockCard(stock) {
    return Card(
      key: ValueKey(stock.symbol),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ListTile(
        title: Text(stock.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(stock.symbol, style: const TextStyle(color: Colors.grey)),
        trailing: ElevatedButton(
          onPressed: _selectStock,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
          child: const Text('Add', style: AppTheme.button),
        ),
      ),
    );
  }

  Widget _buildSelectedStocks() {
    return BlocBuilder<SelectedStockCubit, SelectedStockState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: state.selectedStocks
                .map(
                  (stock) => _BouncyChip(
                    key: ValueKey(stock.symbol),
                    stock: stock,
                    onDeleted: () => context.read<SelectedStockCubit>().removeStock(stock),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: widget.onBack,
          child: const Text('Back', style: AppTheme.button),
        ),
        BlocBuilder<SelectedStockCubit, SelectedStockState>(
          builder: (context, state) {
            return ElevatedButton(
              onPressed: () {
                if (state.selectedStocks.isNotEmpty) {
                  widget.onNext.call();
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Please add at least one stock')));
                }
              },
              child: const Text('Review', style: AppTheme.button),
            );
          },
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}

class _BouncyChip extends StatefulWidget {
  final Stock stock;
  final VoidCallback onDeleted;

  const _BouncyChip({super.key, required this.stock, required this.onDeleted});

  @override
  State<_BouncyChip> createState() => _BouncyChipState();
}

class _BouncyChipState extends State<_BouncyChip> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  void _handleDelete() {
    _controller.reverse().then((_) => widget.onDeleted());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Chip(
        label: Text(widget.stock.symbol),
        onDeleted: _handleDelete,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.info, width: 1.5),
        ),
        backgroundColor: AppTheme.background,
        deleteIconColor: AppTheme.primary,
      ),
    );
  }
}

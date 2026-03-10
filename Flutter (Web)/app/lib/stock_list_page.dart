import 'package:app/resource.dart';
import 'package:app/stock_service.dart';
import 'package:app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StockInputPage extends StatefulWidget {
  final VoidCallback onNext;
  final TextEditingController? emailController;

  const StockInputPage({super.key, required this.onNext, required this.emailController});

  @override
  State<StockInputPage> createState() => _StockInputPageState();
}

class _StockInputPageState extends State<StockInputPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _symbolController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool get isMobileSize => MediaQuery.of(context).size.width <= 500;

  @override
  void dispose() {
    _symbolController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
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
      _focusNode.requestFocus();
      Future.delayed(Duration(milliseconds: 600), () {
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildTitle(),

                      const SizedBox(height: 20),

                      _buildInputSection(),

                      const SizedBox(height: 15),

                      _buildSearchResult(),

                      const SizedBox(height: 15),

                      _buildSelectedStocks(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        _buildNextButton(),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildTitle() {
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
                'Build Your Watchlist',
                softWrap: true,
                style: AppTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          'Add the stocks you want Bull Mail to monitor.\nYou will receive important news about them daily.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, height: 1.4, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 500), child: _buildTextField()),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _searchStock,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryVariant,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Search', style: AppTheme.button),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return TextField(
      focusNode: _focusNode,
      controller: _symbolController,
      autofocus: true,
      maxLength: 7,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1),
      decoration: InputDecoration(
        hintText: 'Search ticker (AAPL, TSLA, NVDA...)',
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        prefixIcon: Icon(Icons.search, color: AppTheme.primaryVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
        suffixIcon: _symbolController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _symbolController.clear();
                    context.read<StockCubit>().clearResult();
                  });
                },
              )
            : null,
      ),
      inputFormatters: [
        UpperCaseTextFormatter(),
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9.\-:/+& ]')),
      ],
      textCapitalization: TextCapitalization.characters,
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
    return Container(
      key: ValueKey(stock.symbol),
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 20, offset: const Offset(0, 6), color: Colors.black.withAlpha(15)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          if (!isMobileSize) ...[
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.primaryVariant,
              child: Text(
                stock.symbol[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(stock.symbol, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),

          Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                _selectStock();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: ElevatedButton(
              onPressed: _selectStock,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryVariant,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 18, color: AppTheme.textPrimary),
                  if (!isMobileSize) ...[
                    const SizedBox(width: 6),
                    const Text("Add", style: AppTheme.button),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedStocks() {
    return BlocBuilder<SelectedStockCubit, SelectedStockState>(
      builder: (context, state) {
        if (state.selectedStocks.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Your Watchlist",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 12),

            Wrap(
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
          ],
        );
      },
    );
  }

  Widget _buildNextButton() {
    return BlocBuilder<SelectedStockCubit, SelectedStockState>(
      builder: (context, state) {
        return SizedBox(
          width: 240,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              if (state.selectedStocks.isNotEmpty) {
                widget.onNext.call();
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Please add at least one stock')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm Watchlist', style: AppTheme.button),
          ),
        );
      },
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
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(widget.stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: _handleDelete,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.primary.withAlpha(128)),
        ),
        backgroundColor: AppTheme.primary.withAlpha(20),
      ),
    );
  }
}

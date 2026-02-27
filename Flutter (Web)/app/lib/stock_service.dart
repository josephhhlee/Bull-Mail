import 'dart:async';
import 'package:app/logging_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Stock {
  final String symbol;
  final String name;

  const Stock({required this.symbol, required this.name});

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(symbol: (json['symbol'] as String).trim(), name: (json['name'] as String).trim());
  }
}

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final Stock stock;
  const StockLoaded(this.stock);

  @override
  List<Object?> get props => [stock];
}

class StockError extends StockState {
  final String message;
  const StockError(this.message);

  @override
  List<Object?> get props => [message];
}

class StockNotFound extends StockState {
  final String input;
  const StockNotFound(this.input);

  @override
  List<Object?> get props => ['No stocks found for $input'];
}

class StockCubit extends Cubit<StockState> {
  StockCubit() : super(StockInitial());

  final StockRepository _repository = StockRepository();
  Timer? _debounce;

  Future<void> searchStock(String query, String email) async {
    query = query.trim().toUpperCase();

    _debounce?.cancel();

    if (query.isEmpty) {
      clearResult();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        emit(StockLoading());

        final stock = await _repository.fetchStock(query, email);

        if (stock == null) {
          emit(StockNotFound(query));
        } else {
          emit(StockLoaded(stock));
        }
      } catch (e) {
        emit(StockError(e.toString()));
      }
    });
  }

  void clearResult() {
    emit(StockInitial());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

class StockRepository {
  final Map<String, Stock> _cachedStocks = {};

  Future<Stock?> fetchStock(String query, String email) async {
    if (_cachedStocks.containsKey(query)) {
      return _cachedStocks[query]!;
    }

    final stock = await _apiFetch(query, email);
    if (stock == null) return null;

    _cachedStocks[query] = stock;
    return stock;
  }

  Future<Stock?> _apiFetch(String query, String email) async {
    try {
      final response = await FirebaseFunctions.instanceFor(
        region: 'asia-southeast1',
      ).httpsCallable('search_stock_ticker').call({'email': email, 'input': query});
      if (response.data == null) return null;

      final data = response.data as Map<String, dynamic>?;
      if (data == null || data.isEmpty) return null;

      return Stock.fromJson(data);
    } catch (e) {
      LoggingService.error('Failed to fetch stocks', tag: 'StockRepository', error: e);
      rethrow;
    }
  }
}

class SelectedStockState extends Equatable {
  final List<Stock> selectedStocks;
  const SelectedStockState(this.selectedStocks);

  @override
  List<Object?> get props => [selectedStocks];
}

class SelectedStockCubit extends Cubit<SelectedStockState> {
  SelectedStockCubit() : super(const SelectedStockState([]));

  void addStock(Stock stock) {
    final updated = List<Stock>.from(state.selectedStocks);
    if (!updated.contains(stock)) {
      updated.add(stock);
      emit(SelectedStockState(updated));
    }
  }

  void removeStock(Stock stock) {
    final updated = List<Stock>.from(state.selectedStocks);
    updated.remove(stock);
    emit(SelectedStockState(updated));
  }

  void clearSelection() {
    emit(const SelectedStockState([]));
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import 'product.dart';
import 'store_repository.dart';

enum StoreStatus {
  loading,
  success,
  empty,
  error,
}

class StoreState {
  final StoreStatus status;
  final String storeName;
  final List<Map<String, dynamic>> categories;
  final List<Product> allProducts;
  final String query;
  final String selectedCategory;
  final String sortBy;
  final Set<String> favoriteIds;
  final Set<String> cartIds;
  final String? errorMessage;

  const StoreState({
    this.status = StoreStatus.loading,
    this.storeName = 'GemStore',
    this.categories = const [],
    this.allProducts = const [],
    this.query = '',
    this.selectedCategory = 'all',
    this.sortBy = 'Featured',
    this.favoriteIds = const {},
    this.cartIds = const {},
    this.errorMessage,
  });

  List<Product> get visibleProducts {
    final normalizedQuery = query.trim().toLowerCase();

    final result = allProducts.where((product) {
      final matchesQuery = product.name.toLowerCase().contains(normalizedQuery);

      final matchesCategory = selectedCategory == 'all' ||
          product.category.toLowerCase() == selectedCategory.toLowerCase();

      return matchesQuery && matchesCategory;
    }).toList();

    switch (sortBy) {
      case 'Price: low to high':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;

      case 'Price: high to low':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;

      case 'Name: A to Z':
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
    }

    return result;
  }

  StoreState copyWith({
    StoreStatus? status,
    String? storeName,
    List<Map<String, dynamic>>? categories,
    List<Product>? allProducts,
    String? query,
    String? selectedCategory,
    String? sortBy,
    Set<String>? favoriteIds,
    Set<String>? cartIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StoreState(
      status: status ?? this.status,
      storeName: storeName ?? this.storeName,
      categories: categories ?? this.categories,
      allProducts: allProducts ?? this.allProducts,
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      cartIds: cartIds ?? this.cartIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class StoreCubit extends Cubit<StoreState> {
  final StoreRepository repository;

  StoreCubit(this.repository) : super(const StoreState());

  Future<void> loadStore() async {
    emit(state.copyWith(
      status: StoreStatus.loading,
      clearError: true,
    ));

    try {
      final data = await repository.loadStore();

      emit(state.copyWith(
        status: data.products.isEmpty ? StoreStatus.empty : StoreStatus.success,
        storeName: data.storeName,
        categories: data.categories,
        allProducts: data.products,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: StoreStatus.error,
        errorMessage:
            'Could not load products. Check that assets/gemstore.json '
            'exists and is listed in pubspec.yaml. Details: $error',
      ));
    }
  }

  void search(String value) {
    emit(state.copyWith(query: value));
  }

  void selectCategory(String value) {
    emit(state.copyWith(selectedCategory: value));
  }

  void sort(String value) {
    emit(state.copyWith(sortBy: value));
  }

  void toggleFavorite(String id) {
    final updated = Set<String>.from(state.favoriteIds);

    if (!updated.add(id)) {
      updated.remove(id);
    }

    emit(state.copyWith(favoriteIds: updated));
  }

  void toggleCart(String id) {
    final updated = Set<String>.from(state.cartIds);

    if (!updated.add(id)) {
      updated.remove(id);
    }

    emit(state.copyWith(cartIds: updated));
  }
}

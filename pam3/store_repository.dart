import 'dart:convert';

import 'package:flutter/services.dart';

import 'product.dart';

class StoreData {
  final String storeName;
  final List<Map<String, dynamic>> categories;
  final List<Product> products;

  const StoreData({
    required this.storeName,
    required this.categories,
    required this.products,
  });
}

class StoreRepository {
  Future<StoreData> loadStore() async {
    final rawJson = await rootBundle.loadString('assets/gemstore.json');
    final decodedValue = jsonDecode(rawJson);

    if (decodedValue is! Map<String, dynamic>) {
      throw const FormatException(
        'The root of gemstore.json must be a JSON object.',
      );
    }

    final homeValue = decodedValue['homePage'];
    final productPageValue = decodedValue['productPage'];

    final home =
        homeValue is Map<String, dynamic> ? homeValue : <String, dynamic>{};

    final productPage = productPageValue is Map<String, dynamic>
        ? productPageValue
        : <String, dynamic>{};

    final byId = <String, Map<String, dynamic>>{};

    void addProducts(dynamic value) {
      if (value is! List) return;

      for (final item in value) {
        if (item is Map<String, dynamic>) {
          final id = item['id']?.toString() ?? '';

          if (id.isNotEmpty) {
            byId[id] = item;
          }
        }
      }
    }

    addProducts(home['featureProducts']);
    addProducts(home['recommended']);

    final detailValue = productPage['product'];

    if (detailValue is Map<String, dynamic>) {
      // Prefer the detailed product-page record for duplicate IDs.
      final detailId = detailValue['id']?.toString() ?? '';

      if (detailId.isNotEmpty) {
        byId[detailId] = detailValue;
      }

      addProducts(detailValue['similarProducts']);
    }

    final products = byId.values.map(Product.fromJson).toList();

    final categoriesValue = home['categories'];
    final categories = categoriesValue is List
        ? categoriesValue.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    return StoreData(
      storeName: home['storeName']?.toString() ?? 'GemStore',
      categories: categories,
      products: products,
    );
  }
}

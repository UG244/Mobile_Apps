import 'dart:convert';

import 'package:http/http.dart' as http;

class CloudApiService {
  CloudApiService._();

  static final CloudApiService instance = CloudApiService._();

  static const _productsUrl = 'https://fakestoreapi.com/products?limit=5';
  static const _ordersUrl = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<String>> fetchRemoteProductNames() async {
    final response = await http
        .get(Uri.parse(_productsUrl))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal mengambil data produk server.');
    }

    final data = jsonDecode(response.body);
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((item) => item['title']?.toString() ?? '')
        .where((title) => title.isNotEmpty)
        .toList();
  }

  Future<void> submitOrderSummary({
    required String invoice,
    required String customerName,
    required double grandTotal,
    required int itemCount,
  }) async {
    final response = await http
        .post(
          Uri.parse(_ordersUrl),
          headers: const {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'title': invoice,
            'body':
                '$customerName membuat pesanan $itemCount item senilai $grandTotal',
            'userId': 1,
          }),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal menyimpan order ke server.');
    }
  }
}

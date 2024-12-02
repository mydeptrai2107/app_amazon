import 'dart:convert';

import 'package:flutter_amazon_clone_bloc/src/data/models/product.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/constants/strings.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/utils.dart';
import 'package:http/http.dart' as http;

class ShopRepository {
  final client = http.Client();

  Future getShop(String id) async {
    final String token = await getToken();
    try {
      http.Response res = await client.get(Uri.parse('$shopUrl/$id'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      });
      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> getShopProducts(String shopId) async {
    try {
      http.Response res =
          await client.get(Uri.parse('$shopUrl/products/$shopId'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      });
      final data = jsonDecode(res.body);
      return data;
    } catch (e) {
      throw Exception(e.toString());
    }
    
  }
}

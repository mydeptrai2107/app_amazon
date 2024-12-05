import 'dart:convert';

import 'package:flutter_amazon_clone_bloc/src/data/models/user.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/constants/strings.dart';
import 'package:http/http.dart' as http;

class AuthAPI {
  var header = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8'
  };
  Future<http.Response> signUpShop(
      {required String email,
      required String password,
      required String name}) async {
    try {
      http.Response res = await http.post(Uri.parse(signUpShopUrl),
          body: json.encode({
            'email': email,
            'password': password,
            'name': name,
          }),
          headers: header);
      return res;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<http.Response> signUpUser(User user) async {
    try {
      http.Response res = await http.post(Uri.parse(signUpUrl),
          body: user.toJson(), headers: header);
      return res;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<http.Response> signInUser(
      String email, String password, bool isShop) async {
    return await http.post(
      Uri.parse(isShop ? signInShopUrl : signInUrl),
      headers: header,
      body: jsonEncode(
        {
          'email': email,
          'password': password,
        },
      ),
    );
  }

  Future<http.Response> isTokenValid({required var token}) async {
    try {
      http.Response res =
          await http.get(Uri.parse(isTokenValidUri), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      });

      return res;
    } catch (e) {
      print('===========>' + e.toString());
      throw Exception(e.toString());
    }
  }
}

import 'dart:convert';
import 'package:flutter_amazon_clone_bloc/src/data/datasources/api/auth_api.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/user.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final AuthAPI authApi = AuthAPI();

  Future<User> signUpShop(
      {required String email,
      required String password,
      required String name}) async {
    try {
      http.Response res = await authApi.signUpShop(
          email: email, password: password, name: name);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body)['shop'];
        User user = User.fromMapForShop(data);
        return user;
      } else {
        throw jsonDecode(res.body)['msg'];
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<User> signInShop(String email, String password) async {
    try {
      final http.Response res = await authApi.signInUser(email, password, true);

      if (res.statusCode == 200) {
        User user = User.fromMapForShop(jsonDecode(res.body));
        return user;
      } else {
        throw jsonDecode(res.body)['msg'];
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<User> singUpUser(User inputUser) async {
    try {
      http.Response res = await authApi.signUpUser(inputUser);

      if (res.statusCode == 200) {
        User user = User.fromMap(jsonDecode(res.body));
        return user;
      } else {
        throw jsonDecode(res.body)['msg'];
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<User> signInUser(String email, String password) async {
    try {
      final http.Response res =
          await authApi.signInUser(email, password, false);

      if (res.statusCode == 200) {
        User user = User.fromMap(jsonDecode(res.body));
        return user;
      } else {
        throw jsonDecode(res.body)['msg'];
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> isTokenValid({required var token}) async {
    print(token);
    try {
      http.Response res = await AuthAPI().isTokenValid(token: token);

      if (res.statusCode == 200) {
        bool isTokenValid = jsonDecode(res.body);

        return isTokenValid;
      } else {
        throw jsonDecode(res.body)['msg'];
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/product.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/user.dart';
import 'package:flutter_amazon_clone_bloc/src/data/repositories/shop_repository.dart';

part 'shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  ShopCubit() : super(ShopInitial());
  final _repository = ShopRepository();
  getShop(String id) async {
    final res = await _repository.getShop(id);
    final shop = User.fromMapForShop(res);
    emit(ShopData(shop: shop, products: []));

    final products = await _repository.getShopProducts(id);
    final productList =
        (products as List).map((e) => Product.fromMap(e)).toList();
    emit(ShopData(shop: shop, products: productList));
  }
}

part of 'shop_cubit.dart';

sealed class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object> get props => [];
}

final class ShopInitial extends ShopState {}

final class ShopData extends ShopState {
  final User shop;
  final List<Product> products;
  const ShopData({required this.shop, required this.products});

  @override
  List<Object> get props => [shop, products];
}

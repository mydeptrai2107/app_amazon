import 'package:flutter/material.dart';
import 'package:flutter_amazon_clone_bloc/src/config/router/app_route_constants.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/shop/shop_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/constants/constants.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/home/single_top_category_item.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopCubit, ShopState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cửa hàng'),
          centerTitle: true,
        ),
        body: state is ShopData
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            child: Icon(
                              Icons.shopify_outlined,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Brand',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                state.shop.name,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      const Text('Danh mục',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: Constants.categoryImages.map((item) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  context.pushNamed(
                                      AppRouteConstants
                                          .categoryproductsScreenRoute.name,
                                      extra: state.shop.id,
                                      pathParameters: {
                                        'category': item['title']!,
                                      });
                                },
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        item['image']!,
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      ),
                                      Text(
                                        item['title']!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ]),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const Text('Tất cả sản phẩm',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.products.length,
                        itemBuilder: ((context, index) {
                          final product = state.products[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.images.first,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name,
                                          style: const TextStyle(fontSize: 16)),
                                      Text('${formatPrice(product.price)}đ',
                                          style: const TextStyle(fontSize: 16)),
                                      const SizedBox(height: 10),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor:
                                                Colors.orange.shade300),
                                        child: const Text('Chi tiết',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        onPressed: () {
                                          context.pushNamed(
                                              AppRouteConstants
                                                  .productDetailsScreenRoute
                                                  .name,
                                              extra: {
                                                "product": product,
                                                "deliveryDate":
                                                    getDeliveryDate(),
                                              });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      )
                    ]),
              )
            : const SizedBox.shrink(),
      );
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amazon_clone_bloc/src/config/router/app_route_constants.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/chat.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/user.dart';
import 'package:flutter_amazon_clone_bloc/src/data/repositories/user_repository.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/shop/shop_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/shop/chat_screen.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/constants/constants.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final UserRepository userRepository = UserRepository();
  late User? user;
  bool isLogin = false;

  @override
  void initState() {
    initData();
    super.initState();
  }

  initData() async {
    user = await userRepository.getUserData();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token');
    if (token == null || token.isEmpty) {
      isLogin = false;
    } else {
      isLogin = true;
    }
  }

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
                              'Thương hiệu',
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
                        const Spacer(),
                        if (isLogin)
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    chatModel: ChatModel(
                                      email: user!.address,
                                      name: user!.name,
                                      image:
                                          'https://w7.pngwing.com/pngs/340/946/png-transparent-avatar-user-computer-icons-software-developer-avatar-child-face-heroes.png',
                                      date: Timestamp.now(),
                                      uid: user!.id,
                                    ),
                                    friendId: state.shop.id,
                                    friendImage:
                                        'https://img.freepik.com/free-vector/shop-with-sign-open-design_23-2148544029.jpg',
                                    friendName: state.shop.name,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_rounded),
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
                        children: Constants.categoryImages.map(
                          (item) {
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
                                      item['name']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ).toList(),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              .productDetailsScreenRoute.name,
                                          extra: {
                                            "product": product,
                                            "deliveryDate": getDeliveryDate(),
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      );
    });
  }
}

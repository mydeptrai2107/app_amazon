import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/chat.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/user.dart';
import 'package:flutter_amazon_clone_bloc/src/data/repositories/shop_repository.dart';
import 'package:flutter_amazon_clone_bloc/src/data/repositories/user_repository.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/shop/chat_screen.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsultingScreen extends StatefulWidget {
  const ConsultingScreen({super.key});

  @override
  State<ConsultingScreen> createState() => _ConsultingScreenState();
}

class _ConsultingScreenState extends State<ConsultingScreen> {
  final _shopRepository = ShopRepository();
  final _userRepository = UserRepository();

  bool isLoading = false;

  @override
  void initState() {
    initData();
    super.initState();
  }

  ChatModel? chatModel;

  initData() async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idShop = prefs.getString('shop-id') ?? '';
    final res = await _shopRepository.getShop(idShop);
    final shop = User.fromMapForShop(res);
    chatModel = ChatModel(
      email: shop.address,
      name: shop.name,
      image: Constants.urlUser,
      date: Timestamp.now(),
      uid: shop.id,
    );
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(chatModel!.uid)
                  .collection('messages')
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.docs.length < 1) {
                    return const Center(
                      child: Text("Không có tin nhắn nào"),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      var friendId = snapshot.data.docs[index].id;
                      var lastMsg = snapshot.data.docs[index]['last_msg'];
                      return FutureBuilder(
                        future: _userRepository.getUserById(friendId),
                        builder: (context, data) {
                          if (!data.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ListTile(
                            leading: CircleAvatar(
                              child: Image.network(
                                Constants.urlUser,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons
                                      .error); // Hiển thị icon nếu không tải được ảnh
                                },
                              ),
                            ),
                            title: Text(data.data!.name),
                            subtitle: Text(
                              lastMsg,
                              style: const TextStyle(
                                color: Colors.grey,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () async {
                              // Kiểm tra null trước khi sử dụng chatModel
                              if (chatModel != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ChatScreen(
                                          chatModel: chatModel!,
                                          friendId: data.data!.id,
                                          friendName: data.data!.name,
                                          friendImage: Constants.urlUser);
                                    },
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('ChatModel không khả dụng')),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            // floatingActionButton: FloatingActionButton(
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) {
            //       return SearchScreen(widget.chatModel);
            //     }));
            //   },
            //   child: const Icon(Icons.search),
            // ),
          );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel{
  String email;
  String name;
  String image;
  Timestamp date;
  String uid;

  ChatModel({
    required this.email,
    required this.name,
    required this.image,
    required this.date,
    required this.uid
  });

  factory ChatModel.fromJson(DocumentSnapshot snapshot){
    return ChatModel(
      email: snapshot['email'], 
      name: snapshot['name'], 
      image: snapshot['image'], 
      date: snapshot['date'], 
      uid: snapshot['uid']
    );
  }
}
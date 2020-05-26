import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class User {
  final String id;
  final String email;
  final String imageUrl;
  final bool isLogin;
  final DateTime lastActivity;
  final String nom;
  final String password;
  final String provider;


  User(
      {@required this.id,
      this.email,
      this.imageUrl,
      this.isLogin,
      this.lastActivity,
      this.nom,
      this.password,
      this.provider,});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'email': this.email,
      'imageUrl': this.imageUrl,
      'isLogin': this.isLogin,
      'lastActivity': this.lastActivity,
      'nom': this.nom,
      'password': this.password,
      'provider': this.provider,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    Timestamp time = map['lastActivity'] ?? '';
    return new User(
      id: documentId,
      email: map['email'] as String,
      imageUrl: map['imageUrl'] as String,
      isLogin: map['isLogin'] as bool,
      lastActivity: time.toDate(),
      nom: map['nom'] as String,
      password: map['password'] as String,
      provider: map['provider'] as String,
    );
  }

}
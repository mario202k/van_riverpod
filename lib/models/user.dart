import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';


class User {
  String id;
  String email;
  String imageUrl;
  bool isLogin;
  DateTime lastActivity;
  String nom;
  String password;
  String provider;
  List genres;
  List types ;


  User(
      {this.id,
      this.email,
      this.imageUrl,
      this.isLogin,
      this.lastActivity,
      this.nom,
      this.password,
      this.provider,
      this.types,
      this.genres});

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
      'genres': this.genres,
      'types': this.types,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    Timestamp time = map['lastActivity'] ;

    return new User(
      id: documentId,
      email: map['email'] as String,
      imageUrl: map['imageUrl'] as String,
      isLogin: map['isLogin'] as bool,
      lastActivity: time?.toDate(),
      nom: map['nom'] as String,
      password: map['password'] as String,
      provider: map['provider'] as String,
      genres: map['genres'] as List ??[],//arraycontainsAny need somethings
      types: map['types'] as List ?? [],
    );
  }

  void setUser(Stream<User> userStream) {

    userStream.listen((user) {

      this.types = user.types;
      this.genres = user.genres;
      this.id = user.id;
      this.email = user.email;
      this.password = user.password;
      this.nom = user.nom;
      this.imageUrl = user.imageUrl;
      this.lastActivity = user.lastActivity;
      this.isLogin = user.isLogin;
      this.provider = user.provider;
    });


  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, imageUrl: $imageUrl, isLogin: $isLogin, lastActivity: $lastActivity, nom: $nom, password: $password, provider: $provider, genres: $genres, types: $types}';
  }


}

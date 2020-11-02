import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  String id;
  String email;
  String imageUrl;
  bool isLogin;
  DateTime lastActivity;
  String nom;
  String password;
  List genres;
  List types;
  int typeDeCompte;
  String stripeAccount;
  String person;
  bool isAcceptedCGUCGV;
  List lieu;
  List quand;
  GeoPoint geoPoint;

  MyUser(
      {this.id,
      this.email,
      this.imageUrl,
      this.isLogin,
      this.lastActivity,
      this.nom,
      this.password,
      this.types,
      this.genres,
      this.typeDeCompte,
      this.stripeAccount,
        this.person,
      this.isAcceptedCGUCGV,this.lieu,this.quand,this.geoPoint});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'email': this.email,
      'imageUrl': this.imageUrl,
      'isLogin': this.isLogin,
      'lastActivity': this.lastActivity,
      'nom': this.nom,
      'password': this.password,
      'genres': this.genres,
      'types': this.types,
      'typeDeCompte': this.typeDeCompte,
      'stripeAccount': this.stripeAccount,
      'person':this.person,
      'isAcceptedCGUCGV': this.isAcceptedCGUCGV,
      'lieu':this.lieu,
      'quand':this.quand,
      'geoPoint':this.geoPoint,
    };
  }

  factory MyUser.fromMap(Map<String, dynamic> map, String documentId) {
    if(map == null){
      return MyUser();
    }
    Timestamp time = map['lastActivity'];

    return MyUser(
        id: documentId,
        email: map['email'] as String ?? '',
        imageUrl: map['imageUrl'] as String ?? 'https://res.cloudinary.com/dtbudl0yx/image/fetch/w_2000,f_auto,q_auto,c_fit/https://adamtheautomator.com/wp-content/uploads/2019/10/user-1633249_1280-1024x998.png',
        isLogin: map['isLogin'] as bool ?? false,
        lastActivity: time?.toDate(),
        nom: map['nom'] as String ?? 'Anonymous',
        password: map['password'] as String,
        genres: map['genres'] as List ?? List.generate(1, (index) => null),
        types: map['types'] as List ?? List.generate(1, (index) => null),
        lieu: map['lieu'] as List ?? List.generate(1, (index) => null),
        quand: map['quand'] as List ?? List.generate(1, (index) => null),
        geoPoint: map['geoPoint'] as GeoPoint,
        typeDeCompte: map['typeDeCompte'] as int,
        //0:possede l'app//1:organisateur//2:utilisateur
        stripeAccount: map['stripeAccount'] as String,
        person: map['person'] as String,
        isAcceptedCGUCGV: map['isAcceptedCGUCGV'] as bool ?? false);
  }

  void setUser(MyUser user) {

    this.types = user.types;
    this.genres = user.genres;
    this.lieu = user.lieu;
    this.quand = user.quand;
    this.geoPoint = user.geoPoint;
    this.id = user.id;
    this.email = user.email;
    this.password = user.password;
    this.nom = user.nom;
    this.imageUrl = user.imageUrl;
    this.lastActivity = user.lastActivity;
    this.isLogin = user.isLogin;
    this.typeDeCompte = user.typeDeCompte;
    this.stripeAccount = user.stripeAccount;
    this.person = user.person;

  }

  @override
  String toString() {
    return 'MyUser{id: $id, email: $email, imageUrl: $imageUrl, isLogin: $isLogin, lastActivity: $lastActivity, nom: $nom, password: $password, genres: $genres, types: $types, typeDeCompte: $typeDeCompte, stripeAccount: $stripeAccount, person: $person, isAcceptedCGUCGV: $isAcceptedCGUCGV, lieu: $lieu, quand: $quand, geoPoint: $geoPoint}';
  }
}

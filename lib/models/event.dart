import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map_launcher/map_launcher.dart';

class MyEvent {
  final String id;
  final String titre;
  final String description;
  final String imageFlyerUrl;
  final String imageBannerUrl;
  final List imagePhotos;
  final DateTime dateDebut;
  final DateTime dateFin;
  final Coords location;
  final String address;
  final String chatId;
  final String status;
  final bool isAffiche;
  final List genres;
  final List types;

  MyEvent({
      this.id,
      this.titre,
      this.description,
      this.imageFlyerUrl,
      this.imageBannerUrl,
      this.imagePhotos,
      this.dateDebut,
      this.dateFin,
      this.location,
      this.address,
      this.chatId,
      this.status,
      this.isAffiche,
      this.genres,this.types});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'titre': this.titre,
      'description': this.description,
      'imageFlyerUrl': this.imageFlyerUrl,
      'imageBannerUrl': this.imageBannerUrl,
      'imagePhotos': this.imagePhotos,
      'dateDebut': this.dateDebut,
      'dateFin': this.dateFin,
      'location': this.location,
      'address': this.address,
      'chatId': this.chatId,
      'status': this.status,
      'isAffiche': this.isAffiche,
      'genres': this.genres,
      'types': this.types,
    };
  }

  factory MyEvent.fromMap(Map<String, dynamic> map,String documentID) {
            Timestamp dateDebut = map['dateDebut'] ?? '';
    Timestamp dateFin = map['dateFin'] ?? '';

    String coordsString = map['location'];

    String latitude =
        coordsString.substring(0, coordsString.indexOf(',')).trim();
    String longitude =
        coordsString.substring(coordsString.indexOf(',') + 1).trim();

    return new MyEvent(
      id: documentID,
      titre: map['titre'] as String,
      description: map['description'] as String,
      imageFlyerUrl: map['imageFlyerUrl'] as String,
      imageBannerUrl: map['imageBannerUrl'] as String,
      imagePhotos: map['imagePhotos'] as List,
      dateDebut: dateDebut.toDate(),
      dateFin: dateFin.toDate(),
      location: Coords(double.parse(latitude), double.parse(longitude)),
      address: map['address'] as String,
      chatId: map['chatId'] as String,
      status: map['status'] as String,
      isAffiche: map['isAffiche'] as bool,
      genres: map['genres'] as List,
      types: map['types'] as List,
    );
  }
}

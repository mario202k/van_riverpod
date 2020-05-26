import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map_launcher/map_launcher.dart';

class MyEvent {
  final String id;
  final String titre;
  final String description;
  final String imageUrl;
  final DateTime dateDebut;
  final DateTime dateFin;
  final Coords location;
  final String address;
  final String chatId;
  final String status;

  MyEvent(
      {this.id,
      this.titre,
      this.description,
      this.imageUrl,
      this.dateDebut,
      this.dateFin,
      this.location,
      this.address,
      this.chatId,
      this.status});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'titre': this.titre,
      'description': this.description,
      'imageUrl': this.imageUrl,
      'dateDebut': this.dateDebut,
      'dateFin': this.dateFin,
      'location': this.location,
      'address': this.address,
      'chatId': this.chatId,
      'status': this.status,
    };
  }

  factory MyEvent.fromMap(Map<String, dynamic> map, String documentId) {
    Timestamp dateDebut = map['dateDebut'] ?? '';
    Timestamp dateFin = map['dateFin'] ?? '';

    String coordsString = map['location'];

    String latitude =
        coordsString.substring(0, coordsString.indexOf(',')).trim();
    String longitude =
        coordsString.substring(coordsString.indexOf(',') + 1).trim();

    return MyEvent(
      id: documentId,
      titre: map['titre'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String,
      dateDebut: dateDebut.toDate(),
      dateFin: dateFin.toDate(),
      location: Coords(double.parse(latitude), double.parse(longitude)),
      address: map['adresse'] as String ?? '',
      chatId: map['chatId'] as String ?? '',
      status: map['status'] as String ?? '',
    );
  }
}

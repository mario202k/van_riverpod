import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe_payment/flutter_stripe_payment.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:multi_image_picker/src/asset.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vanevents/models/chat_membres.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/models/formule.dart';
import 'package:vanevents/models/message.dart';
import 'package:vanevents/models/myUser.dart';
import 'package:vanevents/models/my_chat.dart';
import 'package:vanevents/models/ticket.dart';
import 'package:vanevents/models/my_transport.dart';
import 'package:vanevents/services/firestore_path.dart';
import 'package:vanevents/services/firestore_service.dart';
import 'package:vanevents/shared/lieuQuandAlertDialog.dart';

class FirestoreDatabase {
  FirestoreDatabase();

  String uid; //uid of user currently login
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  final _service = FirebaseFirestoreService.instance;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final geo = Geoflutterfire();

  void setUid(String uid) {
    this.uid = uid;
  }

  FirebaseFirestore get db => _db;

  Future<void> setMyUser(MyUser user) async =>
      await _service.setData(
        path: FirestorePath.user(uid),
        data: user.toMap(),
      );

  Future<MyUser> userFuture() async =>
      await _service.documentFuture(
          path: FirestorePath.user(uid),
          builder: (data, docId) => MyUser.fromMap(data, docId));

  Stream<MyUser> userStream() =>
      _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, docId) => MyUser.fromMap(data, docId),
      );

  Stream<List<MyUser>> usersStream() =>
      _service.collectionStream(
        path: FirestorePath.users(),
        builder: (data, docId) => MyUser.fromMap(data, docId),
      );

  Stream<List<MyEvent>> allEventsAdminStream(String stripeAccount) =>
      _service.collectionStream(
          path: FirestorePath.events(),
          builder: (data, docId) => MyEvent.fromMap(data, docId),
          queryBuilder: (query) =>
              query.where('stripeAccount', isEqualTo: stripeAccount));

  Stream<List<MyEvent>> allEvents() =>
      _service.collectionStream(
          path: FirestorePath.events(),
          builder: (data, docId) => MyEvent.fromMap(data, docId));

  Stream<List<MyEvent>> eventsStreamAffiche() =>
      _service.collectionStream(
          path: FirestorePath.events(),
          builder: (data, docId) => MyEvent.fromMap(data, docId),
          queryBuilder: (query) =>
              query
                  .where('status', isEqualTo: 'A venir')
              //.where('dateDebutAffiche', isLessThan: Timestamp.now())
                  .where('dateFinAffiche', isGreaterThan: Timestamp.now())

        //.where('dateFin', isGreaterThanOrEqualTo: FieldValue.serverTimestamp())
      );

  Stream<MyEvent> eventStream(String id) =>
      _service.documentStream(
          path: FirestorePath.event(id),
          builder: (data, docId) => MyEvent.fromMap(data, docId));

  //afin d'obtenir tous les autres donc sauf moi
  Stream<List<MyUser>> usersStreamChat1() =>
      _service.collectionStream(
          path: FirestorePath.users(),
          builder: (data, docId) => MyUser.fromMap(data, docId),
          queryBuilder: (query) =>
              query
                  .where('id', isGreaterThan: uid)
                  .where('chat', arrayContains: uid)
        //.where('chatId.$uid', isLessThan : '\uf8ff')
      );

  Stream<List<MyUser>> usersStreamChat2() =>
      _service.collectionStream(
          path: FirestorePath.users(),
          builder: (data, docId) => MyUser.fromMap(data, docId),
          queryBuilder: (query) =>
              query.where('id', isLessThan: uid).where(
                  'chat', arrayContains: uid)
        //.where('chatId.$uid', isLessThan : '\uf8ff')
      );

  Stream<List<MyChat>> chatRoomsStream() {
    return db
        .collection('chats')
        .where('membres.$uid', isEqualTo: true)
        .snapshots()
        .map((docs) =>
        docs.docs.map((doc) => MyChat.fromMap(doc.data())).toList());
  }

  Stream<MyMessage> getLastChatMessage(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((doc) =>
    doc.docs
        .map((doc) => MyMessage.fromMap(doc.data()))
        .first);
  }

  Future<MyMessage> getLastChatMessagesChatRoom(String chatId) async {
    return await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .limit(1)
        .get()
        .then((doc) =>
    doc.docs
        .map((doc) => MyMessage.fromMap(doc.data()))
        .first);
  }

  Stream<int> getNbChatMessageNonLu(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('state', isLessThan: 2)
        .where('idTo', isEqualTo: uid)
        .snapshots()
        .map((doc) => doc.docs.length);
  }

  Stream<MyMessage> getChatMessageStream(String chatId, String id) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('id', isEqualTo: id)
        .snapshots()
        .map((doc) =>
    doc.docs
        .map((doc) => MyMessage.fromMap(doc.data()))
        .first);
  }

  Stream<List<MyMessage>> getChatMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .snapshots()
        .map((doc) =>
        doc.docs.map((doc) => MyMessage.fromMap(doc.data())).toList());
  }

  Future<void> sendMessage(String chatId, String messageId, String idSender,
      String text, String friendId, int type) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set({
      'id': messageId,
      'idFrom': idSender,
      'idTo': friendId,
      'message': text,
      'date': FieldValue.serverTimestamp(),
      'type': type,
    });
  }

  Future<MyUser> getMyUserFirestore(String id) async {
    return await _db
        .collection('users')
        .doc(id)
        .get()
        .then((doc) => MyUser.fromMap(doc.data(), id));
  }

  Future<String> creationChatRoom(MyUser friend) async {
    //création d'un chatRoom
    String idChatRoom = '';

    await _db
        .collection('chats')
        .where('membres.${friend.id}', isEqualTo: true)
        .where('membres.$uid', isEqualTo: true)
        .where('isGroupe', isEqualTo: false)
        .get()
        .then((docs) async {
//          List<MyChat> mychats = await docs.docs.map((doc) => MyChat.fromMap(doc.data()).toList();
//
//          mychats = mychats.where((element) => element.)

      if (docs.docs.isNotEmpty) {
        idChatRoom = docs.docs
            .elementAt(0)
            .id;
      } else {
        idChatRoom = _db
            .collection('chats')
            .doc()
            .id;
        await _db.collection('chats').doc(idChatRoom).set({
          'id': idChatRoom,
          'createdAt': FieldValue.serverTimestamp(),
          'isGroupe': false,
          'membres': {uid: true, friend.id: true},
        }, SetOptions(merge: true)).then((_) async {
          await _db
              .collection('chats')
              .doc(idChatRoom)
              .collection('chatMembres')
              .doc(uid)
              .set({
            'id': uid,
            'lastReading': FieldValue.serverTimestamp(),
            'isReading': true
          }, SetOptions(merge: true));
        }).then((_) async {
          await _db
              .collection('chats')
              .doc(idChatRoom)
              .collection('chatMembres')
              .doc(friend.id)
              .set({
            'id': friend.id,
            'lastReading': friend.lastActivity,
            'isReading': false,
          }, SetOptions(merge: true));
        });
      }
    });
    return idChatRoom;
  }

  Future<void> uploadImageChat(BuildContext context, File image, String chatId,
      String idSender, String friendId) async {
    String path = image.path.substring(image.path.lastIndexOf('/') + 1);

    StorageUploadTask uploadTask = _storageReference
        .child('chat')
        .child(chatId)
        .child("/$path")
        .putFile(image);

    await uploadImage(uploadTask).then((url) {
      String messageId = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc()
          .id;

      sendMessage(chatId, messageId, idSender, url, friendId, 1);
    });
  }

  Future<List<String>> loadPhotos(List<Asset> images, String idEvent,
      MyEvent myEvent) async {
    List<String> urlPhotos = List<String>();

    if (myEvent != null) {
      for (String urlImages in myEvent.imagePhotos) {
        await _storageReference
            .child('photos')
            .child(idEvent)
            .child(urlImages).delete();
      }
    }

    for (int i = 0; i < images.length; i++) {
      final byteData = await images[i].getByteData();

      File file = await File('${(await getTemporaryDirectory()).path}/$i.jpg')
          .writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      String path = file.path.substring(file.path.lastIndexOf('/') + 1);

      StorageUploadTask uploadTask = _storageReference
          .child('photos')
          .child(idEvent)
          .child("/$path")
          .putFile(file);

      urlPhotos.add(await uploadImage(uploadTask));
    }

    return urlPhotos;
  }

  Future<String> uploadEvent({DateTime dateDebut,
    DateTime dateFin,
    List<AddressComponent> adresse,
    Coords coords,
    String titre,
    String description,
    File flyer,
    List<Formule> formules,
    BuildContext context,
    Map<String, bool> type,
    Map<String, bool> genre,
    List<Asset> images,
    String stripeAccount,
    bool isAffiche,
    DateTime dateFinAffiche,
    DateTime dateDebutAffiche, String oldId, String oldIdChatRoom, MyEvent myEvent}) async {
    Map<String, bool> types = Map<String, bool>();
    Map<String, bool> genres = Map<String, bool>();
    types.addAll(type);
    genres.addAll(genre);

    types.removeWhere((key, value) => value == false);
    genres.removeWhere((key, value) => value == false);

    GeoFirePoint myLocation =
    geo.point(latitude: coords.latitude, longitude: coords.longitude);

    List<AddressComponent> rue = List<AddressComponent>();
    if (adresse != null) {
      rue.addAll(adresse);

      rue.removeWhere((element) =>
      element.types[0] == "locality" ||
          element.types[0] == "administrative_area_level_2" ||
          element.types[0] == "administrative_area_level_1" ||
          element.types[0] == "country" ||
          element.types[0] == "postal_code"
      );

      adresse.removeWhere((element) =>
      element.types[0] == "floor" ||
          element.types[0] == "street_number" ||
          element.types[0] == "route" || element.types[0] == 'country');
    }


    String docId = oldId ?? _db
        .collection('events')
        .doc()
        .id;

    await _db.collection("events").doc(docId).set({
      "id": docId,
      'uploadedDate': DateTime.now(),
      "dateDebut": dateDebut,
      "dateFin": dateFin,
      "adresseRue": adresse != null
          ?
      List<String>.generate(rue.length, (index) => rue[index].longName)
          : myEvent.adresseRue,
      "adresseZone": adresse != null
          ?
      List<String>.generate(adresse.length, (index) => adresse[index].longName)
          : myEvent.adresseZone,
      'position': myLocation.data,
      "titre": titre,
      'status': 'A venir',
      "description": description,
      'types': types.keys.toList(),
      'genres': genres.keys.toList(),
      'stripeAccount': stripeAccount,
      'dateFinAffiche': dateFinAffiche,
      'dateDebutAffiche': dateDebutAffiche
    }, SetOptions(merge: true)).then((doc) async {
      String urlFlyer;

      if (flyer != null) {
        //création du path pour le flyer
        String pathFlyer = flyer.path.substring(
            flyer.path.lastIndexOf('/') + 1);

        if (myEvent != null) {
          await _storageReference
              .child('Flyer')
              .child(docId)
              .delete().then((value) => print('images deleted')).catchError((
              e) =>
              print(e));
        }


        StorageUploadTask uploadTaskFlyer = _storageReference
            .child('Flyer')
            .child(docId)
        //.child("/$pathFlyer")
            .putFile(flyer);
        urlFlyer = await uploadImage(uploadTaskFlyer);
      }

      List<String> urlPhotos = await loadPhotos(images, docId, myEvent);

      print('creation chat room');
      //creation id chat
      //création d'un chatRoom
      String idChatRoom = oldIdChatRoom ?? _db
          .collection('chats')
          .doc()
          .id;

      await _db.collection('chats').doc(idChatRoom).set({
        'id': idChatRoom,
        'createdAt': FieldValue.serverTimestamp(),
        'isGroupe': true,
        'titre': titre,
        'imageFlyerUrl': urlFlyer,
      }, SetOptions(merge: true));

      if (flyer == null && images == null) {
        await _db.collection("events").doc(docId).set({
          'chatId': idChatRoom,
        }, SetOptions(merge: true));
      } else if (flyer != null && images == null) {
        await _db.collection("events").doc(docId).set({
          'chatId': idChatRoom,
          'imageFlyerUrl': urlFlyer,
        }, SetOptions(merge: true));
      } else if (flyer == null && images != null) {
        await _db.collection("events").doc(docId).set({
          'chatId': idChatRoom,
          'imagePhotos': urlPhotos,
        }, SetOptions(merge: true));
      } else if (flyer != null && images != null) {
        //Mise a niveau
        await _db.collection("events").doc(docId).set({
          'chatId': idChatRoom,
          'imageFlyerUrl': urlFlyer,
          'imagePhotos': urlPhotos,
        }, SetOptions(merge: true));
      }

      //supprimer des éventuelles formule en trop si on en retire
      await _db.collection("events").doc(docId).collection("formules")
          .get()
          .then((value) async {
        if (value.docs.length > formules.length) {
          for (int i = formules.length; i <= value.docs.length; i++) {
            await _db.collection("events")
                .doc(docId).
            collection("formules").doc('$i').delete();
          }
        }
      });

      formules.forEach((f) async {
        await _db.collection("events").doc(docId).collection("formules").doc(
            f.id).set({
          "id": f.id,
          "prix": f.prix,
          "title": f.title,
          "nb": f.nombreDePersonne,
        }, SetOptions(merge: true));
      });
    });
  }

  Future<String> uploadImage(StorageUploadTask uploadTask) async {
    var url = await (await uploadTask.onComplete).ref.getDownloadURL();

    return url.toString();
  }

  Future<StorageTaskSnapshot> uploadImageStripe(
      StorageUploadTask uploadTask) async {
    return await uploadTask.onComplete;
  }

  void showSnackBar(String val, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .error,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme
                  .of(context)
                  .colorScheme
                  .onError, fontSize: 16.0),
        )));
  }

  Future createOrUpdateMyUserOnDatabase(User user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((doc) async {
      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          "id": user.uid,
          'nom': user.displayName,
          'imageUrl': user.photoURL,
          'email': user.email,
          'lastActivity': FieldValue.serverTimestamp(),
          'provider': user.providerData,
          'isLogin': true,
        }, SetOptions(merge: true));
      } else {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'lastActivity': FieldValue.serverTimestamp(),
          'isLogin': true,
        }, SetOptions(merge: true));
      }
    });
  }

  Future<List<Future<MyUser>>> participantsEvent(String eventId) {
    return _db
        .collection('tickets')
        .where('eventId', isEqualTo: eventId)
        .get()
        .then((tickets) =>
        tickets.docs
            .map((ticket) => Ticket.fromMap(ticket.data()))
            .toList()
            .map((e) =>
            _db
                .collection('users')
                .doc(e.uid)
                .get()
                .then((users) => MyUser.fromMap(users.data(), users.id)))
            .toList());
  }

  Future<List<Formule>> getFormulasList(String id) async {
    return await _db
        .collection('events')
        .doc(id)
        .collection('formules')
        .get()
        .then((doc) =>
        doc.docs.map((doc) => Formule.fromMap(doc.data(), doc.id)).toList())
        .catchError((err) {
      print(err);
    });
  }

  Future addNewTicket(Ticket ticket) async {
    await _db
        .collection('tickets')
        .doc(ticket.id)
        .set(ticket.toMap(), SetOptions(merge: true));
  }

  Stream<List<Ticket>> streamTicketsMyUser() {
    return _db
        .collection('tickets')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((docs) =>
        docs.docs.map((doc) => Ticket.fromMap(doc.data())).toList());
  }

  Stream<List<Ticket>> streamTicketsAdmin(String eventId) {
    return _db
        .collection('tickets')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((docs) =>
        docs.docs.map((doc) => Ticket.fromMap(doc.data())).toList());
  }

  Stream<Ticket> streamTicket(String data) {
    return _db
        .collection('tickets')
        .where('id', isEqualTo: data)
        .snapshots()
        .map(
            (docs) =>
        docs.docs
            .map((doc) => Ticket.fromMap(doc.data()))
            .first);
  }

  Future<List<Formule>> formuleList(String eventId) async {
    return await _db
        .collection('events')
        .doc(eventId)
        .collection('formules')
        .get()
        .then((docs) =>
        docs.docs
            .map((doc) => Formule.fromMap(doc.data(), doc.id))
            .toList());
  }

  void cancelEvent(String id) {
    _db.collection('events').doc(id).update({'status': 'Annuler'});
  }

  void ticketValidated(String id) {
    db.collection('tickets').doc(id).update({'status': 'Validé'});
  }

  void showSnackBar2(String val, GlobalKey<ScaffoldState> scaffoldKey) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor:
        Theme
            .of(scaffoldKey.currentState.context)
            .colorScheme
            .error,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme
                  .of(scaffoldKey.currentState.context)
                  .colorScheme
                  .onError,
              fontSize: 16.0),
        )));
  }

  setToggleisHere(Map participant, String qrResult, int index) {
    String key = participant.keys.toList()[index];
    List val = participant[key];
    bool isHere = val.removeAt(1);
    isHere = !isHere;
    val.insert(1, isHere);
    db.collection('tickets').doc(qrResult).update({'participant.$key': val});
  }

  toutValider(Ticket onGoing) {
    for (int i = 0; i < onGoing.participants.length; i++) {
      setToggleisHere(onGoing.participants, onGoing.id, i);
    }
  }

  Stream<List<ChatMembre>> chatMembreStream(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('chatMembres')
        .snapshots()
        .map((docs) =>
        docs.docs.map((doc) => ChatMembre.fromMap(doc.data())).toList());
  }

  Future addAmongGroupe(String chatId) async {
    return await db.collection('chats').doc(chatId).set({
      'membres': {uid: true}
    }, SetOptions(merge: true)).then((value) async {
      await _db
          .collection('chats')
          .doc(chatId)
          .collection('chatMembres')
          .doc(uid)
          .set({
        'id': uid,
        'lastReading': FieldValue.serverTimestamp(),
        'isReading': true
      }, SetOptions(merge: true));
    });
  }

  Future<List<Ticket>> futureTicketParticipation() {
    return _db.collection('tickets').where('uid', isEqualTo: uid).get().then(
            (docs) =>
            docs.docs.map((doc) => Ticket.fromMap(doc.data())).toList());
  }

  void addMeReadMsg(String msgId, String chatId) {
    _db.collection('chats').doc(chatId).collection('messages').doc(msgId).set({
      'userGroupeMsgRead': FieldValue.arrayUnion([uid])
    }, SetOptions(merge: true));
  }

  Future<List<MyEvent>> eventsFuture() {
    return _db.collection('events').get().then((docs) =>
        docs.docs.map((doc) => MyEvent.fromMap(doc.data(), doc.id)).toList());
  }

  Future<MyEvent> eventFuture(String id) {
    return _db.collection('events').doc(id).get().then((doc) =>
        MyEvent.fromMap(doc.data(), doc.id));
  }

  Future setInactive() {
    return _db.collection('users').doc(uid).set(
        {'lastActivity': FieldValue.serverTimestamp(), 'isLogin': false},
        SetOptions(merge: true));
  }

  Future setOnline() {
    return _db.collection('users').doc(uid).set(
        {'lastActivity': FieldValue.serverTimestamp(), 'isLogin': true},
        SetOptions(merge: true));
  }

  Stream<MyUser> userFriendStream(String id) {
    return _db
        .collection('users')
        .doc(id)
        .snapshots()
        .map((doc) => MyUser.fromMap(doc.data(), doc.id));
  }

  Future<MyUser> getFriendMyUser(String idFrom) {
    return _db
        .collection('users')
        .doc(idFrom)
        .get()
        .then((doc) => MyUser.fromMap(doc.data(), doc.id));
  }

  Future<MyChat> getMyChat(String chatId) {
    return db
        .collection('chats')
        .doc(chatId)
        .get()
        .then((doc) => MyChat.fromMap(doc.data()));
  }

  Future setIsReading(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('chatMembres')
        .doc(uid)
        .set({'lastReading': FieldValue.serverTimestamp(), 'isReading': true},
        SetOptions(merge: true));
  }

  Future setIsNotReading(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('chatMembres')
        .doc(uid)
        .set({'lastReading': FieldValue.serverTimestamp(), 'isReading': false},
        SetOptions(merge: true));
  }

  Stream<ChatMembre> getChatMembre(String chatId, String idFriend) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('chatMembres')
        .doc(idFriend)
        .snapshots()
        .map((event) => ChatMembre.fromMap(event.data()));
  }

  Stream<Stream<List<MyMessage>>> nbMessagesNonLu(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('chatMembres')
        .doc(uid)
        .snapshots()
        .map((membre) =>
        _db
            .collection('chats')
            .doc(chatId)
            .collection('messages')
        //.where('idFrom', isEqualTo: uid)
            .where('date',
            isGreaterThan: ChatMembre
                .fromMap(membre.data())
                .lastReading)
            .snapshots()
            .map((docs) =>
            docs.docs
                .map((msg) => MyMessage.fromMap(msg.data()))
                .toList()));
  }

  Stream<List<MyUser>> chatMyUsersStream(MyChat myChat) {
    return _db
        .collection('users')
        .where('id', whereIn: myChat.membres.keys.toList())
        .snapshots()
        .map((users) =>
        users.docs
            .map((user) => MyUser.fromMap(user.data(), user.id))
            .toList());
  }

  Future<List<MyUser>> chatMyUsersFuture(MyChat myChat) {
    return _db
        .collection('users')
        .where('id', whereIn: myChat.membres.keys.toList())
        .get()
        .then((users) =>
        users.docs
            .map((user) => MyUser.fromMap(user.data(), user.id))
            .toList());
  }

  Future updateMyUserImageProfil(String urlFlyer) {
    return db.collection('users').doc(uid).update({
      'imageUrl': urlFlyer,
    });
  }

  void updateMyUserGenre(Map genre) {
    genre.forEach((key, value) {
      db.collection('users').doc(uid).update({
        'genres':
        value ? FieldValue.arrayUnion([key]) : FieldValue.arrayRemove([key])
      });
    });
  }

  void updateMyUserType(Map<String, bool> type) {
    type.forEach((key, value) {
      db.collection('users').doc(uid).update({
        'types':
        value ? FieldValue.arrayUnion([key]) : FieldValue.arrayRemove([key])
      });
    });
  }

  void updateMyUserLieuQuand(Lieu lieu, String address, int aroundMe,
      Quand quand,
      DateTime date) {
    switch (lieu) {
      case Lieu.address:
        db.collection('users').doc(uid).update({
          'lieu': ['address', address]
        });
        break;
      case Lieu.aroundMe:
        db.collection('users').doc(uid).update({
          'lieu': ['aroundMe', aroundMe]
        });
        break;
    }

    switch (quand) {
      case Quand.date:
        db.collection('users').doc(uid).update({
          'quand': ['date', date]
        });
        break;
      case Quand.ceSoir:
        db.collection('users').doc(uid).update({
          'quand': ['ceSoir']
        });
        break;
      case Quand.demain:
        db.collection('users').doc(uid).update({
          'quand': ['demain']
        });
        break;
      case Quand.avenir:
        db.collection('users').doc(uid).update({
          'quand': ['avenir']
        });
        break;
    }
  }

  Stream<List<MyEvent>> eventStreamMaSelectionGenre(List genres, List listLieu,
      List listQuand, GeoPoint position) {
    if (genres.isEmpty) {
      genres = ['none'];
    }

    if (listLieu.isEmpty && listQuand.isEmpty) {
      return db
          .collection('events')
          .where('genres', arrayContainsAny: genres)
          .snapshots()
          .map((docs) =>
          docs.docs
              .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
              .toList());
    }

    if (listLieu.isEmpty && listQuand.isNotEmpty) {
      switch (listQuand[0]) {
        case 'date':
          final date = (listQuand[1] as Timestamp)?.toDate() ?? DateTime.now();
          final dateTimePlusUn = date.add(Duration(days: 1));

          return db.collection('events')
              .where('genres', arrayContainsAny: genres)

              .snapshots().map(
                  (docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
          break;
        case 'ceSoir':
          final date = DateTime.now();
          final dateTimePlusUn = date.add(Duration(days: 1));

          return db.collection('events')
              .where('genres', arrayContainsAny: genres)
              .snapshots().map(
                  (docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
          break;
        case 'demain':
          final date = DateTime.now();
          date.add(Duration(days: 1));
          final dateTimePlusUn = date.add(Duration(days: 1));

          return db.collection('events')
              .where('genres', arrayContainsAny: genres)
              .snapshots().map(
                  (docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
          break;
        default:
          return db
              .collection('events')
              .where('genres', arrayContainsAny: genres)
              .snapshots()
              .map((docs) =>
              docs.docs
                  .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                  .toList());
          break;
      }
    }

    if (listQuand.isEmpty && listLieu.isNotEmpty) {
      switch (listLieu[0]) {
        case'address':
          return db
              .collection('events')
              .where('genres', arrayContainsAny: genres)
              .snapshots()
              .map((docs) =>
              docs.docs
                  .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                  .where((event) => event.adresseZone.contains(listLieu[1]))
                  .toList());
          break;
        case'aroundMe':
          if (position != null) {
            Query ref = db
                .collection('events')
                .where('genres', arrayContainsAny: genres);

            GeoFirePoint center = geo.point(
                latitude: position.latitude, longitude: position.longitude);

            Stream<List<DocumentSnapshot>> stream = geo
                .collection(collectionRef: ref)
                .within(
                center: center,
                radius: (listLieu[1] as int)?.toDouble() ?? 700,
                field: 'position');

            return stream.map((docs) =>
                docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .toList());
          } else {
            return db
                .collection('events')
                .where('genres', arrayContainsAny: genres)
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .toList());
          }


          break;
      }
    }

    switch (listLieu[0]) {
      case 'address':
        switch (listQuand[0]) {
          case 'date':
            final date = (listQuand[1] as Timestamp)?.toDate() ??
                DateTime.now();
            final dateTimePlusUn = date?.add(Duration(days: 1)) ?? null;

            return date != null && listLieu[1] != null
                ? db
                .collection('events')
                .where('genres', arrayContainsAny: genres)
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .where((event) => event.adresseZone.contains(listLieu[1]))
                    .where((element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList())
                : date != null && listLieu[1] == null
                ? db.collection('events')
                .where('genres', arrayContainsAny: genres).snapshots().map(
                    (docs) =>
                    docs.docs
                        .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                        .where((element) =>
                        dateCompriEntre(element, date, dateTimePlusUn))
                        .toList())
                : date == null && listLieu[1] != null
                ? db
                .collection('events')
                .where('genres', arrayContainsAny: genres)
                .snapshots()
                .map((docs) =>
                docs.docs.map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .where((event) => event.adresseZone.contains(listLieu[1]))
                    .where((element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList())
                : db.collection('events').where(
                'genres', arrayContainsAny: genres).snapshots().map((docs) =>
                docs.docs.map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .where((element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList());
            break;
          case 'ceSoir':
            final date = DateTime.now();
            final dateTimePlusUn = date.add(Duration(days: 1));

            return listLieu[1] != null
                ? db
                .collection('events')
                .where('genres', arrayContainsAny: genres)
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .where((event) => event.adresseZone.contains(listLieu[1]))
                    .where((element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList())
                : db
                .collection('events')
                .where('genres', arrayContainsAny: genres)
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                    element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList());
            break;
          case 'demain':
            final date = DateTime.now();
            date.add(Duration(days: 1));
            final dateTimePlusUn = date.add(Duration(days: 1));

            return listLieu[1] != null
                ? db
                .collection('events')
                .where('genres', arrayContainsAny: genres)
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .where((event) => event.adresseZone.contains(listLieu[1]))
                    .where((element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList())
                : db
                .collection('events')
                .where('genres', arrayContainsAny: genres)
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                    element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList());
            break;
          default: //A venir
            return listLieu[1] != null
                ? db
                .collection('events')
                .where('genres', arrayContainsAny: genres)
                .where('dateDebut', isGreaterThanOrEqualTo: DateTime.now())
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .where((event) => event.adresseZone.contains(listLieu[1]))
                    .toList())
                : db
                .collection('events')
                .where('genres', arrayContainsAny: genres)
                .where('dateDebut', isGreaterThanOrEqualTo: DateTime.now())
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .toList());
            break;
        }
        break;

      case 'aroundMe':
        switch (listQuand[0]) {
          case 'date':
            final date = (listQuand[1] as Timestamp)?.toDate() ??
                DateTime.now();
            final dateTimePlusUn = date.add(Duration(days: 1));


            if (position != null) {
              Query ref = db
                  .collection('events')
                  .where('genres', arrayContainsAny: genres);

              GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                  center: center,
                  radius: (listLieu[1] as int)?.toDouble() ?? 700,
                  field: 'position', strictMode: true);


              return stream.map((docs) =>
                  docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                      .where((element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
            } else {
              return db
                  .collection('events')
                  .where('genres', arrayContainsAny: genres)
                  .snapshots()
                  .map((docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                      .where((element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
            }
            break;

          case 'ceSoir':
            final date = DateTime.now();
            final dateTimePlusUn = date.add(Duration(days: 1));

            if (position != null) {
              Query ref = db
                  .collection('events')
                  .where('genres', arrayContainsAny: genres);

              GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                  center: center,
                  radius: (listLieu[1] as int)?.toDouble() ?? 700,
                  field: 'position', strictMode: true);

              return stream.map((docs) =>
                  docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
            } else {
              return db
                  .collection('events')
                  .where('genres', arrayContainsAny: genres)
                  .snapshots()
                  .map((docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
            }

            break;
          case 'demain':
            final date = DateTime.now();
            date.add(Duration(days: 1));
            final dateTimePlusUn = date.add(Duration(days: 1));

            if (position != null) {
              Query ref = db
                  .collection('events')
                  .where('genres', arrayContainsAny: genres);

              GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                  center: center,
                  radius: (listLieu[1] as int)?.toDouble() ?? 700,
                  field: 'position', strictMode: true);

              return stream.map((docs) =>
                  docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
            } else {
              return db
                  .collection('events')
                  .where('genres', arrayContainsAny: genres)
                  .snapshots()
                  .map((docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
            }

            break;
          default:
            if (position != null) {
              Query ref = db
                  .collection('events')
                  .where('genres', arrayContainsAny: genres);

              GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);


              print((listLieu[1] as int)?.toDouble() ?? 700);


              Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                  center: center,
                  radius: (listLieu[1] as int)?.toDouble() ?? 700,
                  field: 'position', strictMode: true);

              return stream.map((docs) =>
                  docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                      .toList());
            } else {
              return db
                  .collection('events')
                  .where('genres', arrayContainsAny: genres)
                  .snapshots()
                  .map((docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                      .toList());
            }

            break;
        }
        break;

      default:
        return db.collection('events').snapshots().map((docs) =>
            docs.docs
                .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                .toList());
        break;
    }
  }

  Stream<List<MyEvent>> eventStreamMaSelectionType(List types, List listLieu,
      List listQuand, GeoPoint position) {
    if (types.isEmpty) {
      types = ['none'];
    }

    if (listLieu.isEmpty && listQuand.isEmpty) {
      return db
          .collection('events')
          .where('types', arrayContainsAny: types)
          .snapshots()
          .map((docs) =>
          docs.docs
              .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
              .toList());
    }

    if (listLieu.isEmpty && listQuand.isNotEmpty) {
      switch (listQuand[0]) {
        case 'date':
          final date = (listQuand[1] as Timestamp)?.toDate() ?? DateTime.now();
          final dateTimePlusUn = date.add(Duration(days: 1));

          return db.collection('events')
              .where('types', arrayContainsAny: types)
              .snapshots().map(
                  (docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
          break;
        case 'ceSoir':
          final date = DateTime.now();
          final dateTimePlusUn = date.add(Duration(days: 1));

          return db.collection('events')
              .where('types', arrayContainsAny: types)
              .snapshots().map(
                  (docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
          break;
        case 'demain':
          final date = DateTime.now();
          date.add(Duration(days: 1));
          final dateTimePlusUn = date.add(Duration(days: 1));

          return db.collection('events')
              .where('types', arrayContainsAny: types)
              .snapshots().map(
                  (docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
          break;
        default:
          return db
              .collection('events')
              .where('types', arrayContainsAny: types)
              .snapshots()
              .map((docs) =>
              docs.docs
                  .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                  .toList());
          break;
      }
    }

    if (listQuand.isEmpty && listLieu.isNotEmpty) {
      switch (listLieu[0]) {
        case'address':
          return db
              .collection('events')
              .where('types', arrayContainsAny: types)
              .snapshots()
              .map((docs) =>
              docs.docs
                  .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                  .where((event) => event.adresseZone.contains(listLieu[1]))
                  .toList());
          break;
        case'aroundMe':
          if (position != null) {
            Query ref = db
                .collection('events')
                .where('types', arrayContainsAny: types);

            GeoFirePoint center = geo.point(
                latitude: position.latitude, longitude: position.longitude);

            Stream<List<DocumentSnapshot>> stream = geo
                .collection(collectionRef: ref)
                .within(
                center: center,
                radius: (listLieu[1] as int)?.toDouble() ?? 700,
                field: 'position');

            return stream.map((docs) =>
                docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .toList());
          } else {
            return db
                .collection('events')
                .where('types', arrayContainsAny: types)
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .toList());
          }


          break;
      }
    }

    switch (listLieu[0]) {
      case 'address':
        switch (listQuand[0]) {
          case 'date':
            final date = (listQuand[1] as Timestamp)?.toDate() ??
                DateTime.now();
            final dateTimePlusUn = date?.add(Duration(days: 1)) ?? null;

            return date != null && listLieu[1] != null
                ? db
                .collection('events')
                .where('types', arrayContainsAny: types)
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .where((event) => event.adresseZone.contains(listLieu[1]))
                    .where((element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList())
                : date != null && listLieu[1] == null
                ? db.collection('events')
                .where('types', arrayContainsAny: types).snapshots().map(
                    (docs) =>
                    docs.docs
                        .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                        .where((element) =>
                        dateCompriEntre(element, date, dateTimePlusUn))
                        .toList())
                : date == null && listLieu[1] != null
                ? db
                .collection('events')
                .where('types', arrayContainsAny: types)
                .snapshots()
                .map((docs) =>
                docs.docs.map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .where((event) => event.adresseZone.contains(listLieu[1]))
                    .where((element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList())
                : db.collection('events').where(
                'types', arrayContainsAny: types).snapshots().map((docs) =>
                docs.docs.map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .where((element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList());
            break;
          case 'ceSoir':
            final date = DateTime.now();
            final dateTimePlusUn = date.add(Duration(days: 1));

            return listLieu[1] != null
                ? db
                .collection('events')
                .where('types', arrayContainsAny: types)
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .where((event) => event.adresseZone.contains(listLieu[1]))
                    .where((element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList())
                : db
                .collection('events')
                .where('types', arrayContainsAny: types)
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                    element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList());
            break;
          case 'demain':
            final date = DateTime.now();
            date.add(Duration(days: 1));
            final dateTimePlusUn = date.add(Duration(days: 1));

            return listLieu[1] != null
                ? db
                .collection('events')
                .where('types', arrayContainsAny: types)
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .where((event) => event.adresseZone.contains(listLieu[1]))
                    .where((element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList())
                : db
                .collection('events')
                .where('types', arrayContainsAny: types)

                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                    element) =>
                    dateCompriEntre(element, date, dateTimePlusUn))
                    .toList());
            break;
          default: //A venir
            return listLieu[1] != null
                ? db
                .collection('events')
                .where('types', arrayContainsAny: types)
                .where('dateDebut', isGreaterThan: DateTime.now())
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .where((event) => event.adresseZone.contains(listLieu[1]))
                    .toList())
                : db
                .collection('events')
                .where('types', arrayContainsAny: types)
                .where('dateDebut', isGreaterThan: DateTime.now())
                .snapshots()
                .map((docs) =>
                docs.docs
                    .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                    .toList());
            break;
        }
        break;

      case 'aroundMe':
        switch (listQuand[0]) {
          case 'date':
            final date = (listQuand[1] as Timestamp)?.toDate() ??
                DateTime.now();
            final dateTimePlusUn = date.add(Duration(days: 1));

            if (position != null) {
              Query ref = db
                  .collection('events')
                  .where('types', arrayContainsAny: types);

              GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                  center: center,
                  radius: (listLieu[1] as int)?.toDouble() ?? 700,
                  field: 'position', strictMode: true);


              return stream.map((docs) =>
                  docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                      .where((element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
            } else {
              return db
                  .collection('events')
                  .where('types', arrayContainsAny: types)
                  .snapshots()
                  .map((docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
            }
            break;

          case 'ceSoir':
            final date = DateTime.now();
            final dateTimePlusUn = date.add(Duration(days: 1));

            if (position != null) {
              Query ref = db
                  .collection('events')
                  .where('types', arrayContainsAny: types);

              GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                  center: center,
                  radius: (listLieu[1] as int)?.toDouble() ?? 700,
                  field: 'position', strictMode: true);

              return stream.map((docs) =>
                  docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
            } else {
              return db
                  .collection('events')
                  .where('types', arrayContainsAny: types)
                  .snapshots()
                  .map((docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
            }

            break;
          case 'demain':
            final date = DateTime.now();
            date.add(Duration(days: 1));
            final dateTimePlusUn = date.add(Duration(days: 1));

            if (position != null) {
              Query ref = db
                  .collection('events')
                  .where('types', arrayContainsAny: types);

              GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);

              Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                  center: center,
                  radius: (listLieu[1] as int)?.toDouble() ?? 700,
                  field: 'position', strictMode: true);

              return stream.map((docs) =>
                  docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
            } else {
              return db
                  .collection('events')
                  .where('types', arrayContainsAny: types)
                  .snapshots()
                  .map((docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id)).where((
                      element) =>
                      dateCompriEntre(element, date, dateTimePlusUn))
                      .toList());
            }

            break;
          default:
            if (position != null) {
              Query ref = db
                  .collection('events')
                  .where('types', arrayContainsAny: types);

              GeoFirePoint center = geo.point(
                  latitude: position.latitude, longitude: position.longitude);


              print((listLieu[1] as int)?.toDouble() ?? 700);


              Stream<List<DocumentSnapshot>> stream = geo
                  .collection(collectionRef: ref)
                  .within(
                  center: center,
                  radius: (listLieu[1] as int)?.toDouble() ?? 700,
                  field: 'position', strictMode: true);

              return stream.map((docs) =>
                  docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                      .toList());
            } else {
              return db
                  .collection('events')
                  .where('types', arrayContainsAny: types)
                  .snapshots()
                  .map((docs) =>
                  docs.docs
                      .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                      .toList());
            }

            break;
        }
        break;

      default:
        return db.collection('events').snapshots().map((docs) =>
            docs.docs
                .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
                .toList());
        break;
    }
  }

  Future<HttpsCallableResult> allStripeAccounts() async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'allStripeAccounts',
      );
      stripeResponse = await callable.call();
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<HttpsCallableResult> deleteStripeAccount(String id) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'deleteStripeAccount',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'stripeAccount': id,
        },
      );
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<HttpsCallableResult> organisateurBalance(String id) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'balance',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'stripeAccount': id,
        },
      );
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<HttpsCallableResult> retrieveStripeAccount(String stripeId) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'retrieveStripeAccount',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'stripeAccount': stripeId,
        },
      );
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  void setUserPosition(Position position) {
    db.collection('users').doc(uid).update({
      'geoPoint': GeoPoint(position.latitude, position.longitude)
    });
  }

  bool dateCompriEntre(MyEvent event, DateTime start, DateTime end) {
    return event.dateDebut.compareTo(start) > 0 &&
        event.dateDebut.compareTo(end) < 0;
  }

  Future<HttpsCallableResult> retrievePromotionCode(String codePromo) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'retrievePromotionCode',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'code': codePromo,
        },
      );
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<HttpsCallableResult> retrieveStripeCouponList() async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'retrieveCouponList',
      );
      stripeResponse = await callable.call();
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<dynamic> paymentIntent(double amount,
      String stripeAccount,
      String description, int length) async {
    print(stripeAccount);

    final stripePayment = FlutterStripePayment();

    stripePayment.onCancel = () {
      print("User Cancelled the Payment Method Form");
    };
    stripePayment.setStripeSettings(
        'pk_test_gPlqnEqiVydntTBkyFzc4aUb001o1vGwb6',
        'merchant.com.vanina.vanevents');

    var paymentResponse =
    await stripePayment.addPaymentMethod();
    print(paymentResponse.paymentMethodId);
    print("//");
    String paymentMethodId = paymentResponse.paymentMethodId;

    print(stripeAccount);

    if (paymentResponse.status ==
        PaymentResponseStatus.succeeded) {
      HttpsCallableResult intentResponse;
      try {
        final HttpsCallable callablePaymentIntent =
        CloudFunctions.instance.getHttpsCallable(
          functionName: 'paymentIntent',
        );
        intentResponse = await callablePaymentIntent.call(
          <String, dynamic>{
            'amount': (amount).toInt(),
            'stripeAccount': stripeAccount,
            'description': description,
            'paymentMethodId': paymentMethodId,
            'nbParticipant': length
          },
        );
      } on CloudFunctionsException catch (e) {
        print(e);
        print('1');
        return 'Paiement refusé';
      } catch (e) {
        print(e);
        print('2');
        return 'Paiement refusé';
      }
      final paymentIntentX = intentResponse.data;
      final status = paymentIntentX['status'];

      if (status == 'succeeded') {
        return paymentIntentX;
      } else {
        //step 4: there is a need to authenticate
        //StripePayment.setStripeAccount(strAccount);

        var intentResponse =
        await stripePayment.confirmPaymentIntent(
            paymentIntentX['client_secret'],
            paymentResponse.paymentMethodId,
            amount);

        if (intentResponse.status ==
            PaymentResponseStatus.succeeded) {
          return paymentIntentX;
        } else if (intentResponse.status ==
            PaymentResponseStatus.failed) {
          print('3');
          return 'Paiement refusé';
        } else {
          print('4');
          return 'Paiement refusé';
        }
      }
    } else {
      return 'Paiement annulé';
    }
  }

  Future<dynamic> paymentIntentUploadEvents(double amount,
      String description,
      String idPromotionCode) async {
    final stripePayment = FlutterStripePayment();

    stripePayment.onCancel = () {
      print("User Cancelled the Payment Method Form");
    };
    stripePayment.setStripeSettings(
        'pk_test_gPlqnEqiVydntTBkyFzc4aUb001o1vGwb6',
        'merchant.com.vanina.vanevents');

    var paymentResponse =
    await stripePayment.addPaymentMethod();
    print('coucou!!!!!');

    if (paymentResponse.status ==
        PaymentResponseStatus.succeeded) {
      HttpsCallableResult intentResponse;
      try {
        final HttpsCallable callablePaymentIntent =
        CloudFunctions.instance.getHttpsCallable(
          functionName: 'paymentIntentUploadEvents',
        );
        intentResponse = await callablePaymentIntent.call(
          <String, dynamic>{
            'amount': (amount * 100).toInt(),
            'idPromotionCode': idPromotionCode,
            'description': description,
            'paymentMethodId':
            paymentResponse.paymentMethodId
          },
        );
      } on CloudFunctionsException catch (e) {
        print(e);
        return 'Paiement refusé';
      } catch (e) {
        print(e);
        return 'Paiement refusé';
      }
      final paymentIntentX = intentResponse.data;
      final status = paymentIntentX['status'];

      if (status == 'succeeded') {
        return paymentIntentX;
      } else {
        //step 4: there is a need to authenticate
        //StripePayment.setStripeAccount(strAccount);

        var intentResponse =
        await stripePayment.confirmPaymentIntent(
            paymentIntentX['client_secret'],
            paymentResponse.paymentMethodId,
            amount);

        if (intentResponse.status ==
            PaymentResponseStatus.succeeded) {
          return paymentIntentX;
        } else if (intentResponse.status ==
            PaymentResponseStatus.failed) {
          return 'Paiement refusé';
        } else {
          return 'Paiement refusé';
        }
      }
    } else {
      print('!!!!!!!!!!!!!!');
      return 'Paiement annulé';
    }
  }

  Future<HttpsCallableResult> uploadFileToStripe(String fileName,
      String stripeAccount, String person) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'uploadFileToStripe',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'fileName': fileName,
          'stripeAccount': stripeAccount,
          'person': person
        },
      );
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<HttpsCallableResult> retrievePerson(String stripeAccount,
      String person) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'retrievePerson',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'stripeAccount': stripeAccount,
          'person': person
        },
      );
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  Future<HttpsCallableResult> payoutList(String stripeAccount) async {
    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
        functionName: 'payoutList',
      );
      stripeResponse = await callable.call(
        <String, dynamic>{
          'stripeAccount': stripeAccount,
        },
      );
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
    return stripeResponse;
  }

  Future uploadTransport(MyTransport transport) async {

    await _db.collection('transports').doc(
        transport.id).set(transport.toMap());
  }

  Stream<List<MyTransport>> streamTransports() {
    return _db.collection('transports').where('userId', isEqualTo: uid)
        .snapshots()
        .map((event) =>
        event.docs.map((e) => MyTransport.fromMap(e.data())).toList());
  }

  Stream<MyTransport> streamTransport(String id) {
    return _db.collection('transports').where('id', isEqualTo: id).snapshots()
        .map((event) =>
    event.docs
        .map((e) => MyTransport.fromMap(e.data()))
        .toList()
        .first);
  }

  Future cancelTransport(String idTransport,bool isCustomer)async {

    return _db.collection('transports')
        .doc(idTransport).update({
      'statusTransport':isCustomer?'CancelledByCustomer':'CancelledByVTC'
    });


  }
}

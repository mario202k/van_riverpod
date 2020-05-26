import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:meta/meta.dart';
import 'package:vanevents/models/chat_membres.dart';
import 'package:vanevents/models/my_chat.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/models/formule.dart';
import 'package:vanevents/models/message.dart';
import 'package:vanevents/models/ticket.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/services/firestore_path.dart';
import 'package:vanevents/services/firestore_service.dart';

class FirestoreDatabase {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid; //uid of user currently login
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  final _service = FirestoreService.instance;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();
  final Firestore _db = Firestore.instance;

  Firestore get db => _db;

  Future<void> setUser(User user) async => await _service.setData(
        path: FirestorePath.user(uid),
        data: user.toMap(),
      );

  Future<User> userFuture() async => await _service.documentFuture(
      path: FirestorePath.user(uid),
      builder: (data, documentId) => User.fromMap(data, documentId));

  Stream<User> userStream() => _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

  Stream<List<User>> usersStream() => _service.collectionStream(
        path: FirestorePath.users(),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

  Stream<List<MyEvent>> allEventsAdminStream() => _service.collectionStream(
      path: FirestorePath.events(),
      builder: (data, documentId) => MyEvent.fromMap(data, documentId));

  Stream<List<MyEvent>> eventsStream() => _service.collectionStream(
      path: FirestorePath.events(),
      builder: (data, documentId) => MyEvent.fromMap(data, documentId),
      queryBuilder: (query) => query.where('status', isEqualTo: 'A venir')
      //.where('dateFin', isGreaterThanOrEqualTo: FieldValue.serverTimestamp())
      );

  Stream<MyEvent> eventStream(String id) => _service.documentStream(
      path: FirestorePath.event(id),
      builder: (data, documentId) => MyEvent.fromMap(data, documentId));

  //afin d'obtenir tous les autres donc sauf moi
  Stream<List<User>> usersStreamChat1() => _service.collectionStream(
      path: FirestorePath.users(),
      builder: (data, documentId) => User.fromMap(data, documentId),
      queryBuilder: (query) => query
          .where('id', isGreaterThan: uid)
          .where('chat', arrayContains: uid)
      //.where('chatId.$uid', isLessThan : '\uf8ff')
      );

  Stream<List<User>> usersStreamChat2() => _service.collectionStream(
      path: FirestorePath.users(),
      builder: (data, documentId) => User.fromMap(data, documentId),
      queryBuilder: (query) =>
          query.where('id', isLessThan: uid).where('chat', arrayContains: uid)
      //.where('chatId.$uid', isLessThan : '\uf8ff')
      );

  Stream<List<MyChat>> chatRoomsStream() {
    return db
        .collection('chats')
        .where('membres.$uid', isEqualTo: true)
        .snapshots()
        .map((docs) =>
            docs.documents.map((doc) => MyChat.fromMap(doc.data)).toList());
  }

  Stream<MyMessage> getLastChatMessage(String chatId) {
    return _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((doc) =>
            doc.documents.map((doc) => MyMessage.fromMap(doc.data)).first);
  }

  Future<MyMessage> getLastChatMessagesChatRoom(String chatId) async {
    return await _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .limit(1)
        .getDocuments()
        .then((doc) =>
            doc.documents.map((doc) => MyMessage.fromMap(doc.data)).first);
  }

  Stream<int> getChatMessageNonLu(String chatId) {
    return _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .where('state', isLessThan: 2)
        .where('idTo', isEqualTo: uid)
        .snapshots()
        .map((doc) => doc.documents.length);
  }

  Stream<MyMessage> getChatMessageStream(String chatId, String id) {
    return _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .where('id', isEqualTo: id)
        .snapshots()
        .map((doc) =>
            doc.documents.map((doc) => MyMessage.fromMap(doc.data)).first);
  }

  Stream<List<MyMessage>> getChatMessages(String chatId) {
    return _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .snapshots()
        .map((doc) =>
            doc.documents.map((doc) => MyMessage.fromMap(doc.data)).toList());
  }

  Future<void> sendMessage(String chatId, String messageId, String idSender,
      String text, String friendId, int type) async {
    await _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .document(messageId)
        .setData({
      'id': messageId,
      'idFrom': idSender,
      'idTo': friendId,
      'message': text,
      'date': FieldValue.serverTimestamp(),
      'type': type,
    });
  }

  Future<User> getUserFirestore(String id) async {
    return await _db
        .collection('users')
        .document(id)
        .get()
        .then((doc) => User.fromMap(doc.data, id));
  }

  Future<String> creationChatRoom(User friend, User me) async {
    //création d'un chatRoom
    String idChatRoom = '';

    await _db
        .collection('chats')
        .where('uid.${friend.id}', isEqualTo: true)
        .where('uid.$uid', isEqualTo: true)
        .where('isGroupe', isEqualTo: false)
        .getDocuments()
        .then((docs) async {
//          List<MyChat> mychats = await docs.documents.map((doc) => MyChat.fromMap(doc.data)).toList();
//
//          mychats = mychats.where((element) => element.)

      if (docs.documents.isNotEmpty) {
        idChatRoom = docs.documents.elementAt(0).documentID;
      } else {
        idChatRoom = _db.collection('chats').document().documentID;
        await _db.collection('chats').document(idChatRoom).setData({
          'id': idChatRoom,
          'createdAt': FieldValue.serverTimestamp(),
          'isGroupe': false,
          'membres': {uid: true, friend.id: true},
        }, merge: true).then((_) async {
          await _db
              .collection('chats')
              .document(idChatRoom)
              .collection('chatMembres')
              .document(me.id)
              .setData({
            'id': me.id,
            'lastReading': FieldValue.serverTimestamp(),
            'isReading': true
          }, merge: true);
        }).then((_) async {
          await _db
              .collection('chats')
              .document(idChatRoom)
              .collection('chatMembres')
              .document(friend.id)
              .setData({
            'id': friend.id,
            'lastReading': friend.lastActivity,
            'isReading': false,
          }, merge: true);
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
      String messageId = Firestore.instance
          .collection('chats')
          .document(chatId)
          .collection('messages')
          .document()
          .documentID;

      sendMessage(chatId, messageId, idSender, url, friendId, 1);
    });
  }

  Future uploadEvent(
      DateTime dateDebut,
      DateTime dateFin,
      String adresse,
      Coords coords,
      String titre,
      String description,
      File image,
      List<Formule> formules,
      BuildContext context) async {
    //création du path pour le flyer
    String path = image.path.substring(image.path.lastIndexOf('/') + 1);

    StorageUploadTask uploadTask = _storageReference
        .child('imageFlyer')
        .child(dateDebut.toString())
        .child("/$path")
        .putFile(image);

    await uploadImage(uploadTask).then((url) async {
      DocumentReference reference = _db.collection("events").document();
      String idEvent = reference.documentID;

      print('creation chat room');
      //creation id chat
      //création d'un chatRoom
      String idChatRoom = _db.collection('chats').document().documentID;

      await _db.collection('chats').document(idChatRoom).setData({
        'id': idChatRoom,
        'createdAt': FieldValue.serverTimestamp(),
        'isGroupe': true,
        'imageUrl': url,
        'titre': titre,
      }, merge: true);

      await _db.collection("events").document(idEvent).setData({
        "id": idEvent,
        'chatId': idChatRoom,
        "dateDebut": dateDebut,
        "dateFin": dateFin,
        "adresse": adresse,
        'location': '${coords.latitude},${coords.longitude}',
        "titre": titre,
        'status': 'A venir',
        "description": description,
        "imageUrl": url,
      }, merge: true).then((_) async {
        formules.forEach((f) async {
          DocumentReference reference = _db
              .collection("events")
              .document(idEvent)
              .collection("formules")
              .document();
          String idFormule = reference.documentID;

          await _db
              .collection("events")
              .document(idEvent)
              .collection("formules")
              .document(idFormule)
              .setData({
            "id": idFormule,
            "prix": f.prix,
            "title": f.title,
            "nb": f.nombreDePersonne,
          }, merge: true);
        });
      }).then((_) {
        showSnackBar("Event ajouter", context);
      }).catchError((e) {
        print(e);
        showSnackBar("impossible d'ajouter l'Event", context);
      });
    });
  }

  Future<String> uploadImage(StorageUploadTask uploadTask) async {
    var url = await (await uploadTask.onComplete).ref.getDownloadURL();

    return url.toString();
  }

  void showSnackBar(String val, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onError, fontSize: 16.0),
        )));
  }

  Future createOrUpdateUserOnDatabase(FirebaseUser user) async {
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .get()
        .then((doc) async {
      if (!doc.exists) {
        await Firestore.instance
            .collection('users')
            .document(user.uid)
            .setData({
          "id": user.uid,
          'nom': user.displayName,
          'imageUrl': user.photoUrl,
          'email': user.email,
          'lastActivity': FieldValue.serverTimestamp(),
          'provider': user.providerId,
          'isLogin': true,
        }, merge: true);
      } else {
        await Firestore.instance
            .collection('users')
            .document(user.uid)
            .setData({
          'lastActivity': FieldValue.serverTimestamp(),
          'isLogin': true,
        }, merge: true);
      }
    });
  }

  Future<List<Future<User>>> participantsEvent(String eventId) {
    return _db
        .collection('tickets')
        .where('eventId', isEqualTo: eventId)
        .getDocuments()
        .then((tickets) => tickets.documents
            .map((ticket) => Ticket.fromMap(ticket.data))
            .toList()
            .map((e) => _db
                .collection('users')
                .document(e.uid)
                .get()
                .then((users) => User.fromMap(users.data, users.documentID)))
            .toList());
  }

  Future<List<Formule>> getFormulasList(String id) async {
    return await _db
        .collection('events')
        .document(id)
        .collection('formules')
        .getDocuments()
        .then((doc) => doc.documents
            .map((doc) => Formule.fromMap(doc.data, doc.documentID))
            .toList())
        .catchError((err) {
      print(err);
    });
  }

  void addNewTicket(Ticket ticket) async {
    await _db
        .collection('tickets')
        .document(ticket.id)
        .setData(ticket.toMap(), merge: true);
  }

  Stream<List<Ticket>> streamTicketsUser() {
    return _db
        .collection('tickets')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((docs) =>
            docs.documents.map((doc) => Ticket.fromMap(doc.data)).toList());
  }

  Stream<List<Ticket>> streamTicketsAdmin(String eventId) {
    return _db
        .collection('tickets')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((docs) =>
            docs.documents.map((doc) => Ticket.fromMap(doc.data)).toList());
  }

  Stream<Ticket> streamTicket(String data) {
    return _db
        .collection('tickets')
        .where('id', isEqualTo: data)
        .snapshots()
        .map((docs) =>
            docs.documents.map((doc) => Ticket.fromMap(doc.data)).first);
  }

  Future<List<Formule>> formuleList(String eventId) async {
    return await _db
        .collection('events')
        .document(eventId)
        .collection('formules')
        .getDocuments()
        .then((docs) => docs.documents
            .map((doc) => Formule.fromMap(doc.data, doc.documentID))
            .toList());
  }

  void cancelEvent(String id) {
    _db.collection('events').document(id).updateData({'status': 'Annuler'});
  }

  void ticketValidated(String id) {
    db.collection('tickets').document(id).updateData({'status': 'Validé'});
  }

  void showSnackBar2(String val, GlobalKey<ScaffoldState> scaffoldKey) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor:
            Theme.of(scaffoldKey.currentState.context).colorScheme.error,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme.of(scaffoldKey.currentState.context)
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
    db
        .collection('tickets')
        .document(qrResult)
        .updateData({'participant.$key': val});
  }

  toutValider(Ticket onGoing) {
    for (int i = 0; i < onGoing.participants.length; i++) {
      setToggleisHere(onGoing.participants, onGoing.id, i);
    }
  }

  Stream<List<ChatMembre>> chatMembreStream(String chatId) {
    return _db
        .collection('chats')
        .document(chatId)
        .collection('chatMembres')
        .snapshots()
        .map((docs) =>
            docs.documents.map((doc) => ChatMembre.fromMap(doc.data)).toList());
  }

  Future addAmongGroupe(String chatId, String userName, String url) async {
    return await db.collection('chats').document(chatId).setData({
      'membres': {
        uid: true
      }
    }, merge: true).then((value)async {

      await _db
          .collection('chats')
          .document(chatId)
          .collection('chatMembres')
          .document(uid)
          .setData({
        'id': uid,
        'lastReading': FieldValue.serverTimestamp(),
        'isReading': true
      }, merge: true);
    });
  }

  Future<List<Ticket>> futureTicketParticipation() {
    return _db
        .collection('tickets')
        .where('uid', isEqualTo: uid)
        .getDocuments()
        .then((docs) =>
            docs.documents.map((doc) => Ticket.fromMap(doc.data)).toList());
  }

  void addMeReadMsg(String msgId, String chatId) {
    _db
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .document(msgId)
        .setData({
      'userGroupeMsgRead': FieldValue.arrayUnion([uid])
    }, merge: true);
  }

  Future<List<MyEvent>> eventsFuture() {
    return _db.collection('events').getDocuments().then((docs) => docs.documents
        .map((doc) => MyEvent.fromMap(doc.data, doc.documentID))
        .toList());
  }

  Future setInactive() {
    return _db.collection('users').document(uid).setData(
        {'lastActivity': FieldValue.serverTimestamp(), 'isLogin': false},
        merge: true);
  }

  Future setOnline() {
    return _db.collection('users').document(uid).setData(
        {'lastActivity': FieldValue.serverTimestamp(), 'isLogin': true},
        merge: true);
  }

  Stream<User> userFriendStream(String id) {
    return _db
        .collection('users')
        .document(id)
        .snapshots()
        .map((doc) => User.fromMap(doc.data, doc.documentID));
  }

  Future<User> getFriendUser(String idFrom) {
    return _db
        .collection('users')
        .document(idFrom)
        .get()
        .then((doc) => User.fromMap(doc.data, doc.documentID));
  }

  Future<MyChat> getMyChat(String chatId) {
    return db
        .collection('chats')
        .document(chatId)
        .get()
        .then((doc) => MyChat.fromMap(doc.data));
  }

  Future setIsReading(String chatId) {
    return _db
        .collection('chats')
        .document(chatId)
        .collection('chatMembres')
        .document(uid)
        .setData(
            {'lastReading': FieldValue.serverTimestamp(), 'isReading': true},
            merge: true);
  }

  Future setIsNotReading(String chatId) {
    return _db
        .collection('chats')
        .document(chatId)
        .collection('chatMembres')
        .document(uid)
        .setData(
            {'lastReading': FieldValue.serverTimestamp(), 'isReading': false},
            merge: true);
  }

  Stream<ChatMembre> getChatMembre(String chatId, String idFriend) {
    return _db
        .collection('chats')
        .document(chatId)
        .collection('chatMembres')
        .document(idFriend)
        .snapshots()
        .map((event) => ChatMembre.fromMap(event.data));
  }

  Stream<List<User>> chatUsersStream(MyChat myChat) {
    return _db
        .collection('users')
        .where('id', whereIn: myChat.membres.keys.toList())
        .snapshots()
        .map((users) => users.documents
            .map((user) => User.fromMap(user.data, user.documentID))
            .toList());
  }

  Future<List<User>> chatUsersFuture(MyChat myChat) {
    return _db
        .collection('users')
        .where('id', whereIn: myChat.membres.keys.toList())
        .getDocuments()
        .then((users) => users.documents
            .map((user) => User.fromMap(user.data, user.documentID))
            .toList());
  }
}

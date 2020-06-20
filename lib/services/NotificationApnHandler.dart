//import 'dart:io';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
//import 'package:flutter_apns/apns.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:vanevents/bloc/message/message_bloc.dart';
//import 'package:vanevents/models/message.dart';
//import 'package:vanevents/screens/chat_room.dart';
//
//class NotificationApnHandler {
//  final connector = createPushConnector();
//  final db = Firestore.instance;
//  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//
//  static final NotificationApnHandler _singleton =
//      new NotificationApnHandler._internal();
//
//  BuildContext context;
//
//  factory NotificationApnHandler() {
//    return _singleton;
//  }
//
//  NotificationApnHandler._internal();
//
//  initializeApnNotification(String uid, BuildContext context) async {
//    this.context = context;
//
//    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//
//    var initializationSettingsAndroid =
//        new AndroidInitializationSettings('app_icon');
//    var initializationSettingsIOS = new IOSInitializationSettings(
//        requestSoundPermission: true,
//        requestAlertPermission: true,
//        requestBadgePermission: true,
//        defaultPresentAlert: true,
//        defaultPresentBadge: true,
//        defaultPresentSound: true,
//        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
//    var initializationSettings = new InitializationSettings(
//        initializationSettingsAndroid, initializationSettingsIOS);
//
//    flutterLocalNotificationsPlugin.initialize(initializationSettings,
//        onSelectNotification: onSelectNotification);
//
//    connector.configure(
//      onLaunch: (data) => onPush('onLaunch', data),
//      onResume: (data) => onPush('onResume', data),
//      onMessage: (data) => onPush('onMessage', data),
//      onBackgroundMessage: _onBackgroundMessage,
//    );
//
//
//    _saveDeviceToken(uid);
//    connector.requestNotificationPermissions();
//  }
//
//  void showNotification(Map<String, dynamic> message) async {
//    String title, type, body, chatId;
//
//    if (Platform.isIOS) {
//      title = message['notification']['title'];
//      type = message['type'];
//      body = message['aps']['alert'];
//      chatId = message['chatId'];
//    } else {
//      title = message['notification']['title'];
//      type = message['data']['type'];
//      body = message['notification']['body'];
//      chatId = message['data']['chatId'];
//    }
//
//    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//        'com.vaninamario.crossroads_events',
//        'Crossroads Events',
//        'your channel description',
//        playSound: true,
//        enableVibration: true,
//        importance: Importance.Max,
//        priority: Priority.High,
//        ticker: 'ticker');
//    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//    var platformChannelSpecifics = NotificationDetails(
//        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//
//    await flutterLocalNotificationsPlugin.show(
//        0, title, type == '0' ? body : 'image', platformChannelSpecifics,
//        payload: chatId);
//  }
//
//  _saveDeviceToken(String uid) async {
//
//    connector.token.addListener(() async {
//      print('Token ${connector.token.value}');
//      String token = connector.token.value;
//
//      await db//supprimer s'il en reste
//          .collection('users')
//          .document(uid)
//          .collection('tokens')
//          .getDocuments()
//          .then((docs) async {
//        if (docs.documents.isNotEmpty) {
//          docs.documents.forEach((doc) async {
//            await db
//                .collection('users')
//                .document(uid)
//                .collection('tokens')
//                .document(doc.documentID)
//                .delete();
//          });
//        }
//
//        if (Platform.isIOS) {
//          await db
//              .collection('users')
//              .document(uid)
//              .collection('tokens')
//              .document(token)
//              .setData({
//            'token': token,
//            'createAt': FieldValue.serverTimestamp(),
//            'platform': Platform.operatingSystem,
//            'apn':true
//          }, merge: true);
//
//        }
//
//        await db
//            .collection('users')
//            .document(uid)
//            .collection('tokens')
//            .document(token)
//            .setData({
//          'token': token,
//          'createAt': FieldValue.serverTimestamp(),
//          'platform': Platform.operatingSystem,
//          'apn':false
//        }, merge: true);
//      });
//
//    });
//  }
//
//  Future<dynamic> onPush(String name, Map<String, dynamic> data) {
//    print(name);
//    print(data);
//    print('bbb');
//    showNotification(data);
//    MyMessage myMessage;
//    String chatId = '';
//    if (Platform.isAndroid) {
//      myMessage = MyMessage.fromAndroidFcm(data);
//
//      chatId = data['data']['chatId'];
//    } else {
//      myMessage = MyMessage.fromIosFcm(data);
//      chatId = data['chatId'];
//    }
//
//    if (myMessage.type <= 2) {
//      BlocProvider.of<MessageBloc>(context)
//          .add(MessageEvents(chatId, false, true, false, message: myMessage));
//    } else {}
//
//    return Future.value();
//  }
//
//  Future<dynamic> _onBackgroundMessage(Map<String, dynamic> data) =>
//      onPush('onBackgroundMessage', data);
//
//  Future<void> onDidReceiveLocalNotification(
//      int id, String title, String body, String payload) {
//    print(payload);
//  }
//
//  Future onSelectNotification(String payload) async {
//    await Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => ChatRoom(payload)),
//    );
//  }
//}

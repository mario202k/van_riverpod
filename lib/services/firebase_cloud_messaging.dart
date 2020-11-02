import 'dart:async';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vanevents/bloc/message/message_bloc.dart';
import 'package:vanevents/main.dart';
import 'package:vanevents/models/message.dart';
import 'package:flutter/services.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/screens/chat_room.dart';

class NotificationHandler {
  String _platformVersion = 'Unknown';
  bool _isShowingWindow = false;
  bool _isUpdatedWindow = false;

  FirebaseFirestore db = FirebaseFirestore.instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  FirebaseMessaging _fcm = FirebaseMessaging();
  String chatId = '';
  BuildContext context;
  StreamSubscription iosSubscription;
  static final NotificationHandler _singleton =
      new NotificationHandler._internal();

  factory NotificationHandler() {
    return _singleton;
  }

  NotificationHandler._internal();

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _platformVersion = await SystemAlertWindow.platformVersion;
    } on PlatformException {
      _platformVersion = 'Failed to get platform version.';
    }
    print(_platformVersion);
  }

  String get platformVersion => _platformVersion;

  Future<void> _checkPermissions() async {
    await SystemAlertWindow.checkPermissions;
  }

  showOverlayWindow() {
    if (!_isShowingWindow) {
      SystemWindowHeader header = SystemWindowHeader(
          title: SystemWindowText(
              text: "Incoming Call", fontSize: 10, textColor: Colors.black45),
          padding: SystemWindowPadding.setSymmetricPadding(12, 12),
          subTitle: SystemWindowText(
              text: "9898989899",
              fontSize: 14,
              fontWeight: FontWeight.BOLD,
              textColor: Colors.black87),
          decoration: SystemWindowDecoration(startColor: Colors.grey[100]),
          button: SystemWindowButton(
              text: SystemWindowText(
                  text: "Personal", fontSize: 10, textColor: Colors.black45),
              tag: "personal_btn"),
          buttonPosition: ButtonPosition.TRAILING);
      SystemWindowBody body = SystemWindowBody(
        rows: [
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(
                    text: "Some body", fontSize: 12, textColor: Colors.black45),
              ),
            ],
            gravity: ContentGravity.CENTER,
          ),
          EachRow(columns: [
            EachColumn(
                text: SystemWindowText(
                    text: "Long data of the body",
                    fontSize: 12,
                    textColor: Colors.black87,
                    fontWeight: FontWeight.BOLD),
                padding: SystemWindowPadding.setSymmetricPadding(6, 8),
                decoration: SystemWindowDecoration(
                    startColor: Colors.black12, borderRadius: 25.0),
                margin: SystemWindowMargin(top: 4)),
          ], gravity: ContentGravity.CENTER),
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(
                    text: "Notes", fontSize: 10, textColor: Colors.black45),
              ),
            ],
            gravity: ContentGravity.LEFT,
            margin: SystemWindowMargin(top: 8),
          ),
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(
                    text: "Some random notes.",
                    fontSize: 13,
                    textColor: Colors.black54,
                    fontWeight: FontWeight.BOLD),
              ),
            ],
            gravity: ContentGravity.LEFT,
          ),
        ],
        padding: SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
      );
      SystemWindowFooter footer = SystemWindowFooter(
          buttons: [
            SystemWindowButton(
              text: SystemWindowText(
                  text: "Simple button",
                  fontSize: 12,
                  textColor: Color.fromRGBO(250, 139, 97, 1)),
              tag: "simple_button",
              padding:
                  SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
              width: 0,
              height: SystemWindowButton.WRAP_CONTENT,
              decoration: SystemWindowDecoration(
                  startColor: Colors.white,
                  endColor: Colors.white,
                  borderWidth: 0,
                  borderRadius: 0.0),
            ),
            SystemWindowButton(
              text: SystemWindowText(
                  text: "Focus button", fontSize: 12, textColor: Colors.white),
              tag: "focus_button",
              width: 0,
              padding:
                  SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
              height: SystemWindowButton.WRAP_CONTENT,
              decoration: SystemWindowDecoration(
                  startColor: Color.fromRGBO(250, 139, 97, 1),
                  endColor: Color.fromRGBO(247, 28, 88, 1),
                  borderWidth: 0,
                  borderRadius: 30.0),
            )
          ],
          padding: SystemWindowPadding(left: 16, right: 16, bottom: 12),
          decoration: SystemWindowDecoration(startColor: Colors.white),
          buttonsPosition: ButtonPosition.CENTER);
      SystemAlertWindow.showSystemWindow(
          height: 230,
          header: header,
          body: body,
          footer: footer,
          margin: SystemWindowMargin(left: 8, right: 8, top: 200, bottom: 0),
          gravity: SystemWindowGravity.TOP);
      _isShowingWindow = true;
    } else if (!_isUpdatedWindow) {
      SystemWindowHeader header = SystemWindowHeader(
          title: SystemWindowText(
              text: "Outgoing Call", fontSize: 10, textColor: Colors.black45),
          padding: SystemWindowPadding.setSymmetricPadding(12, 12),
          subTitle: SystemWindowText(
              text: "8989898989",
              fontSize: 14,
              fontWeight: FontWeight.BOLD,
              textColor: Colors.black87),
          decoration: SystemWindowDecoration(startColor: Colors.grey[100]),
          button: SystemWindowButton(
              text: SystemWindowText(
                  text: "Personal", fontSize: 10, textColor: Colors.black45),
              tag: "personal_btn"),
          buttonPosition: ButtonPosition.TRAILING);
      SystemWindowBody body = SystemWindowBody(
        rows: [
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(
                    text: "Updated body",
                    fontSize: 12,
                    textColor: Colors.black45),
              ),
            ],
            gravity: ContentGravity.CENTER,
          ),
          EachRow(columns: [
            EachColumn(
                text: SystemWindowText(
                    text: "Updated long data of the body",
                    fontSize: 12,
                    textColor: Colors.black87,
                    fontWeight: FontWeight.BOLD),
                padding: SystemWindowPadding.setSymmetricPadding(6, 8),
                decoration: SystemWindowDecoration(
                    startColor: Colors.black12, borderRadius: 25.0),
                margin: SystemWindowMargin(top: 4)),
          ], gravity: ContentGravity.CENTER),
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(
                    text: "Notes", fontSize: 10, textColor: Colors.black45),
              ),
            ],
            gravity: ContentGravity.LEFT,
            margin: SystemWindowMargin(top: 8),
          ),
          EachRow(
            columns: [
              EachColumn(
                text: SystemWindowText(
                    text: "Updated random notes.",
                    fontSize: 13,
                    textColor: Colors.black54,
                    fontWeight: FontWeight.BOLD),
              ),
            ],
            gravity: ContentGravity.LEFT,
          ),
        ],
        padding: SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
      );
      SystemWindowFooter footer = SystemWindowFooter(
          buttons: [
            SystemWindowButton(
              text: SystemWindowText(
                  text: "Updated Simple button",
                  fontSize: 12,
                  textColor: Color.fromRGBO(250, 139, 97, 1)),
              tag: "updated_simple_button",
              padding:
                  SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
              width: 0,
              height: SystemWindowButton.WRAP_CONTENT,
              decoration: SystemWindowDecoration(
                  startColor: Colors.white,
                  endColor: Colors.white,
                  borderWidth: 0,
                  borderRadius: 0.0),
            ),
            SystemWindowButton(
              text: SystemWindowText(
                  text: "Focus button", fontSize: 12, textColor: Colors.white),
              tag: "focus_button",
              width: 0,
              padding:
                  SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
              height: SystemWindowButton.WRAP_CONTENT,
              decoration: SystemWindowDecoration(
                  startColor: Color.fromRGBO(250, 139, 97, 1),
                  endColor: Color.fromRGBO(247, 28, 88, 1),
                  borderWidth: 0,
                  borderRadius: 30.0),
            )
          ],
          padding: SystemWindowPadding(left: 16, right: 16, bottom: 12),
          decoration: SystemWindowDecoration(startColor: Colors.white),
          buttonsPosition: ButtonPosition.CENTER);
      SystemAlertWindow.updateSystemWindow(
          height: 230,
          header: header,
          body: body,
          footer: footer,
          margin: SystemWindowMargin(left: 8, right: 8, top: 200, bottom: 0),
          gravity: SystemWindowGravity.TOP);
      _isUpdatedWindow = true;
    } else {
      _isShowingWindow = false;
      _isUpdatedWindow = false;
      SystemAlertWindow.closeSystemWindow();
    }
  }

  initializeFcmNotification(String uid, BuildContext context) async {
    this.context = context;
//    _initPlatformState();
//    _checkPermissions();
    //SystemAlertWindow.registerOnClickListener(callBackFunction);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings(
        requestSoundPermission: true,
        requestAlertPermission: true,
        requestBadgePermission: true,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        print(data);
        //_saveDeviceToken(uid);
        // save the token  OR subscribe to a topic here
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings(
          provisional: false, sound: true, badge: true, alert: true));
    } else {
      //_saveDeviceToken(uid);
    }

    _saveDeviceToken(uid);

    _fcm.configure(
      onBackgroundMessage:
          Platform.isAndroid ? myBackgroundMessageHandler : null,
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        MyMessage myMessage;
        String chatId = '';
        if (Platform.isAndroid) {
          myMessage = MyMessage.fromAndroidFcm(message);

          chatId = message['data']['chatId'];
        } else {
          myMessage = MyMessage.fromIosFcm(message);
          chatId = message['chatId'];
        }

        if (myMessage.idFrom != uid && myMessage.type <= 2) {
          showNotification(message);
          BlocProvider.of<MessageBloc>(context).add(
              MessageEvents(chatId, false, true, false, message: myMessage));
        } else {}
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        String chatId = '';
        if (Platform.isAndroid) {
          chatId = message['data']['chatId'];
        } else {
          chatId = message['chatId'];
        }

        ExtendedNavigator.of(context).pushAndRemoveUntil(
          Routes.chatRoom,
          ModalRoute.withName(Routes.authentication),
          arguments: ChatRoomArguments(chatId: chatId),
        );

//        ExtendedNavigator.ofRouter<Router>().pushNamedAndRemoveUntil(
//          Routes.chatRoom,
//          ModalRoute.withName(Routes.authentication),
//          arguments: ChatRoomArguments(chatId: chatId),
//        );
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        String chatId = '';
        if (Platform.isAndroid) {
          chatId = message['data']['chatId'];
        } else {
          chatId = message['chatId'];
        }

//        Navigator.popUntil(context, ModalRoute.withName(Routes.authWidget));

        ExtendedNavigator.of(context).pushAndRemoveUntil(
          Routes.chatRoom,
          ModalRoute.withName(Routes.authentication),
          arguments: ChatRoomArguments(chatId: chatId),
        );
//        ExtendedNavigator.ofRouter<Router>().popUntil((route) => route.toString() == Routes.baseScreens);
//        ExtendedNavigator.ofRouter<Router>().pushNamed(
//            Routes.chatRoom,
//            arguments: ChatRoomArguments(chatId: chatId));
      },
    );
  }

  void showNotification(Map<String, dynamic> message) async {
    String title, type, body, chatId;

    if (Platform.isIOS) {
      title = message['aps'] != null
          ? message['aps']['alert']['title']
          : message['notification']['title'];
      type = message['type'];
      body = message['aps'] != null
          ? message['aps']['alert']['body']
          : message['notification']['body'];
      chatId = message['chatId'];
    } else {
      title = message['notification']['title'];
      type = message['data']['type'];
      body = message['notification']['body'];
      chatId = message['data']['chatId'];
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.vaninamario.crossroads_events',
        'Crossroads Events',
        'your channel description',
        playSound: true,
        enableVibration: true,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        badgeNumber: 3,
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, title, type == '0' ? body : 'image', platformChannelSpecifics,
        payload: chatId);
  }

  _saveDeviceToken(String uid) async {
    _fcm.getToken().then((token) async {
      print(token);
      await db //supprimer s'il en reste
          .collection('users')
          .doc(uid)
          .collection('tokens')
          .get()
          .then((docs) async {
        if (docs.docs.isNotEmpty) {
          docs.docs.forEach((doc) async {
            await db
                .collection('users')
                .doc(uid)
                .collection('tokens')
                .doc(doc.id)
                .delete();
          });
        }

        await db
            .collection('users')
            .doc(uid)
            .collection('tokens')
            .doc(token)
            .set({
          'token': token,
          'createAt': FieldValue.serverTimestamp(),
          'platform': Platform.operatingSystem,
        }, SetOptions(merge: true));
      });
    }).catchError((err) {
      print(err);
    });

    // subscribeTo();
  }

//
//  Future<void> _showBigPictureNotification(message) async {
//    var rng = new Random();
//    var notifId = rng.nextInt(100);
//
//    var largeIconPath = await _downloadAndSaveImage(
//        'https://cdn.pixabay.com/photo/2019/04/21/21/29/pattern-4145023_960_720.jpg',
//        'largeIcon');
//    var bigPicturePath = await _downloadAndSaveImage(
//        'https://cdn.pixabay.com/photo/2019/04/21/21/29/pattern-4145023_960_720.jpg',
//        'bigPicture');
//    var bigPictureStyleInformation = BigPictureStyleInformation(
//        bigPicturePath, BitmapSource.FilePath,
//        largeIcon: largeIconPath,
//        largeIconBitmapSource: BitmapSource.FilePath,
//        contentTitle: message['data']['title'],
//        htmlFormatContentTitle: true,
//        summaryText: message['data']['body'],
//        htmlFormatSummaryText: true);
//    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//        '12', 'trading_id', message['data']['body'],
//        importance: Importance.High,
//        priority: Priority.High,
//        style: AndroidNotificationStyle.BigPicture,
//        styleInformation: bigPictureStyleInformation);
//    var platformChannelSpecifics =
//    NotificationDetails(androidPlatformChannelSpecifics, null);
//    await flutterLocalNotificationsPlugin.show(
//        notifId,
//        message['data']['title'],
//        message['data']['body'],
//        platformChannelSpecifics,
//        payload: message['data']['body']);
//  }
//
//  Future<void> _showBigTextNotification(message) async {
//    var rng = new Random();
//    var notifId = rng.nextInt(100);
//    var bigTextStyleInformation = BigTextStyleInformation(
//        message['data']['body'],
//        htmlFormatBigText: true,
//        contentTitle: message['data']['title'],
//        htmlFormatContentTitle: true,
//        summaryText: message['data']['body'],
//        htmlFormatSummaryText: true);
//    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//        '12', 'trading_id', '',
//        importance: Importance.High,
//        priority: Priority.High,
//        style: AndroidNotificationStyle.BigText,
//        styleInformation: bigTextStyleInformation);
//    var platformChannelSpecifics =
//    NotificationDetails(androidPlatformChannelSpecifics, null);
//    await flutterLocalNotificationsPlugin.show(
//        notifId,
//        message['data']['title'],
//        message['data']['body'],
//        platformChannelSpecifics,
//        payload: message['data']['body']);
//  }

  Future onSelectNotification(String payload) async {
//    if (payload != null) {
//      debugPrint('notification payload: ' + payload);
//    }

    //await flutterLocalNotificationsPlugin.cancelAll();

    ExtendedNavigator.of(context).pushAndRemoveUntil(
      Routes.chatRoom,
      ModalRoute.withName(Routes.authentication),
      arguments: ChatRoomArguments(chatId: chatId),
    );

    //ExtendedNavigator.ofRouter<Router>().pushNamed(Routes.chatRoom,arguments: ChatRoomArguments(chatId: payload) );
    //await ExtendedNavigator(router: null).pushNamed(Routes.baseScreens);
    // await Navigator.push(
    //   context,
    //   new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
    // );
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoom(payload),
                ),
              );
            },
          )
        ],
      ),
    );
    //onSelectNotification(payload);
  }
//
//  Future<String> _downloadAndSaveImage(String url, String fileName) async {
//    var directory = await getApplicationDocumentsDirectory();
//    var filePath = '${directory.path}/$fileName';
//    var response = await http.get(url);
//    var file = File(filePath);
//    await file.writeAsBytes(response.bodyBytes);
//    return filePath;
//  }
}

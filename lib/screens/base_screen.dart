import 'package:after_init/after_init.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/services/firebase_cloud_messaging.dart';
import 'package:vanevents/services/firestore_database.dart';

class BaseScreens extends StatefulWidget {
  final String uid;

  BaseScreens(this.uid);

  @override
  _BaseScreensState createState() => _BaseScreensState();
}

class _BaseScreensState extends State<BaseScreens>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin, AfterInitMixin {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  @override
  void initState() {

    //registerNotification(widget.uid);

    //WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }
//
  @override
  void didInitState() {
    NotificationHandler().initializeFcmNotification(widget.uid,context);
  }

//  subscribeTo() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    bool isSubscribe = prefs.getBool('VanEvent') ?? true;
//
//    if (isSubscribe) {
//      _fcm.subscribeToTopic('VanEvent');
//      prefs.setBool('VanEvent', true);
//    } else {
//      _fcm.unsubscribeFromTopic('VanEvent');
//      prefs.setBool('VanEvent', false);
//    }
//  }

//  void registerNotification(String id) {
//    if (Platform.isIOS) {
//      _fcm.requestNotificationPermissions(
//          IosNotificationSettings(sound: true, badge: true, alert: true));
//      _fcm.onIosSettingsRegistered.listen((data) {
//        // save the token  OR subscribe to a topic here
//        _saveDeviceToken(id);
//      });
//    } else {
//      _saveDeviceToken(id);
//    }
//    print('registerNotification');
//
//    _fcm.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        MyMessage myMessage = MyMessage.fromMapFcm(message);
//        print(myMessage.message);
//        print(message['data']['chatId']);
//
//        BlocProvider.of<MessageBloc>(context).add(
//            MessageEvents(message['data']['chatId'], true, message: myMessage));
//      },
//      onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
//      onLaunch: (Map<String, dynamic> message) async {
//        print('onLaunch');
//        MyMessage myMessage = MyMessage.fromMapFcm(message);
//        print(myMessage.message);
//        print(message['data']['chatId']);
//
//        BlocProvider.of<MessageBloc>(context).add(
//            MessageEvents(message['data']['chatId'], true, message: myMessage));
//      },
//      onResume: (Map<String, dynamic> message) async {
//        MyMessage myMessage = MyMessage.fromMapFcm(message);
//        print(myMessage.message);
//        print(message['data']['chatId']);
//
//        BlocProvider.of<MessageBloc>(context).add(
//            MessageEvents(message['data']['chatId'], true, message: myMessage));
//      },
//    );
//  }
//
//  void configLocalNotification() {
//    var initializationSettingsAndroid =
//    AndroidInitializationSettings('app_icon');
//    var initializationSettingsIOS = IOSInitializationSettings(
//        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
//    var initializationSettings = InitializationSettings(
//        initializationSettingsAndroid, initializationSettingsIOS);
//    FlutterLocalNotificationsPlugin().initialize(initializationSettings,
//        onSelectNotification: onSelectNotification);
//  }
//
//  void showNotification(Map<String, dynamic> message) async {
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
//    await FlutterLocalNotificationsPlugin().show(
//        0,
//        message['notification']['title'],
//        message['data']['type'] == '0'
//            ? message['notification']['body']
//            : 'image',
//        platformChannelSpecifics,
//        payload: '');
//  }
//
//  Future onDidReceiveLocalNotification(
//      int id, String title, String body, String payload) {}
//
//  Future onSelectNotification(String payload) async {
//    if (payload != null) {
//      debugPrint('notification payload: ' + payload);
//    }
//    //await Router.navigator.pushNamed(Routes.baseScreens);
//    await ExtendedNavigator.of(context).pushNamed(Routes.baseScreens);
//    //await Navigator.of(context).pushNamed(Router.baseScreens);
//  }
//
//  _saveDeviceToken(String uid) async {
//    _fcm.getToken().then((fcmToken) async {
//      Firestore.instance
//          .collection('users')
//          .document(uid)
//          .collection('tokens')
//          .document(fcmToken)
//          .setData({
//        'token': fcmToken,
//        'createAt': FieldValue.serverTimestamp(),
//        'platform': Platform.operatingSystem
//      });
//    }).catchError((err) {
//      Scaffold.of(context).showSnackBar(SnackBar(
//          backgroundColor: Theme.of(context).colorScheme.error,
//          duration: Duration(seconds: 3),
//          content: Text(
//            err.message.toString(),
//            textAlign: TextAlign.center,
//            style: TextStyle(
//                color: Theme.of(context).colorScheme.onError, fontSize: 16.0),
//          )));
//    });
//
//    //subscribeTo();
//  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        context.read<FirestoreDatabase>().setInactive();
        break;
      case AppLifecycleState.resumed:
        context.read<FirestoreDatabase>().setOnline();
        break;
      case AppLifecycleState.inactive:
        context.read<FirestoreDatabase>().setInactive();
        break;
      case AppLifecycleState.detached:
        context.read<FirestoreDatabase>().setInactive();
        break;
    }
  }

  _afterLayout(_) {

//
//    MySingletonFCM(user.id, context).registerNotification(user.id);
//    MySingletonFCM(user.id, context).configLocalNotification();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).colorScheme.primary,
      statusBarIconBrightness: Theme.of(context).colorScheme.brightness,
      systemNavigationBarColor: Theme.of(context).colorScheme.primary,
      systemNavigationBarIconBrightness:
          Theme.of(context).colorScheme.brightness,
    ));
    return SafeArea(child: BlocBuilder<NavigationBloc, NavigationStates>(
        builder: (BuildContext context, NavigationStates state) {
      print(state.toString());
      int i = 0;
      switch (state.toString()) {
        case 'HomeEvents':
          i = 0;
          break;
        case 'Chat':
          i = 1;
          break;
        case 'Billets':
          i = 2;
          break;
        case 'Profil':
          i = 3;
          break;
      }

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: state as Widget,
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          index: i,
          color: Theme.of(context).colorScheme.primary,
          height: 45,
          onTap: (index) {
            switch (index) {
              case 0:
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigationEvents.HomeEvents);
                break;
              case 1:
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigationEvents.Chat);
                break;
              case 2:
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigationEvents.Billets);
                break;
              case 3:
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigationEvents.Profil);
                break;
            }
          },
          items: <Widget>[
            Icon(
              FontAwesomeIcons.home,
              size: 30,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            Icon(
              FontAwesomeIcons.comments,
              size: 30,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            Icon(
              FontAwesomeIcons.ticketAlt,
              size: 30,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            Icon(
              FontAwesomeIcons.user,
              size: 30,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ],
        ),
      );
    }));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;


}

//class MySingletonFCM {
//  String uid;
//  BuildContext context;
//  final FirebaseMessaging _fcm = FirebaseMessaging();
//
//  Firestore db = Firestore.instance;
//
//  factory MySingletonFCM(String uid, BuildContext context) {
//    _singleton.uid = uid;
//    _singleton.context = context;
//
//    return _singleton;
//  }
//
//  static final MySingletonFCM _singleton = MySingletonFCM._internal();
//
//  MySingletonFCM._internal() {
//    // fcm.configure
//
////    registerNotification();
////    configLocalNotification();
//  }
//
//  subscribeTo() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    bool isSubscribe = prefs.getBool('VanEvent') ?? true;
//
//    if (isSubscribe) {
//      _fcm.subscribeToTopic('VanEvent');
//      prefs.setBool('VanEvent', true);
//    } else {
//      _fcm.unsubscribeFromTopic('VanEvent');
//      prefs.setBool('VanEvent', false);
//    }
//  }
//
//  void registerNotification(String id) {
//    if (Platform.isIOS) {
//      _fcm.requestNotificationPermissions(
//          IosNotificationSettings(sound: true, badge: true, alert: true));
//      _fcm.onIosSettingsRegistered.listen((data) {
//        // save the token  OR subscribe to a topic here
//        _saveDeviceToken(id);
//      });
//    } else {
//      _saveDeviceToken(id);
//    }
//
//    _fcm.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        MyMessage myMessage = MyMessage.fromMapFcm(message);
//        print(myMessage.message);
//        print(message['data']['chatId']);
//
//        BlocProvider.of<MessageBloc>(context).add(
//            MessageEvents(message['data']['chatId'], true, message: myMessage));
//      },
//      onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
//      onLaunch: (Map<String, dynamic> message) async {
//        print('onLaunch');
//        MyMessage myMessage = MyMessage.fromMapFcm(message);
//        print(myMessage.message);
//        print(message['data']['chatId']);
//
//        BlocProvider.of<MessageBloc>(context).add(
//            MessageEvents(message['data']['chatId'], true, message: myMessage));
//      },
//      onResume: (Map<String, dynamic> message) async {
//        MyMessage myMessage = MyMessage.fromMapFcm(message);
//        print(myMessage.message);
//        print(message['data']['chatId']);
//
//        BlocProvider.of<MessageBloc>(context).add(
//            MessageEvents(message['data']['chatId'], true, message: myMessage));
//      },
//    );
//  }
//
//  void configLocalNotification() {
//    var initializationSettingsAndroid =
//        AndroidInitializationSettings('app_icon');
//    var initializationSettingsIOS = IOSInitializationSettings(
//        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
//    var initializationSettings = InitializationSettings(
//        initializationSettingsAndroid, initializationSettingsIOS);
//    FlutterLocalNotificationsPlugin().initialize(initializationSettings,
//        onSelectNotification: onSelectNotification);
//  }
//
//  void showNotification(Map<String, dynamic> message) async {
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
//    await FlutterLocalNotificationsPlugin().show(
//        0,
//        message['notification']['title'],
//        message['data']['type'] == '0'
//            ? message['notification']['body']
//            : 'image',
//        platformChannelSpecifics,
//        payload: '');
//  }
//
//  Future onDidReceiveLocalNotification(
//      int id, String title, String body, String payload) {}
//
//  Future onSelectNotification(String payload) async {
//    if (payload != null) {
//      debugPrint('notification payload: ' + payload);
//    }
//    //await Router.navigator.pushNamed(Routes.baseScreens);
//    await ExtendedNavigator.of(context).pushNamed(Routes.baseScreens);
//    //await Navigator.of(context).pushNamed(Router.baseScreens);
//  }
//
//  _saveDeviceToken(String uid) async {
//    _fcm.getToken().then((fcmToken) async {
//      db
//          .collection('users')
//          .document(uid)
//          .collection('tokens')
//          .document(fcmToken)
//          .setData({
//        'token': fcmToken,
//        'createAt': FieldValue.serverTimestamp(),
//        'platform': Platform.operatingSystem
//      });
//    }).catchError((err) {
//      Scaffold.of(context).showSnackBar(SnackBar(
//          backgroundColor: Theme.of(context).colorScheme.error,
//          duration: Duration(seconds: 3),
//          content: Text(
//            err.message.toString(),
//            textAlign: TextAlign.center,
//            style: TextStyle(
//                color: Theme.of(context).colorScheme.onError, fontSize: 16.0),
//          )));
//    });
//
//    subscribeTo();
//  }
//
//// Methods, variables ...
//}
//

//class NotificationHandler {
//  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//  FirebaseMessaging _fcm = FirebaseMessaging();
//  StreamSubscription iosSubscription;
//  static final NotificationHandler _singleton =
//  new NotificationHandler._internal();
//
//  factory NotificationHandler() {
//    return _singleton;
//  }
//  NotificationHandler._internal();
//
//  Future<dynamic> myBackgroundMessageHandler(
//      Map<String, dynamic> message) async {
//    print("onLaunch: $message");
//    _showBigPictureNotification(message);
//    // Or do other work.
//  }
//
//  initializeFcmNotification() async {
//    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//
//    var initializationSettingsAndroid =
//    new AndroidInitializationSettings('ic_launcher');
//    var initializationSettingsIOS = new IOSInitializationSettings(
//        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
//    var initializationSettings = new InitializationSettings(
//        initializationSettingsAndroid, initializationSettingsIOS);
//    flutterLocalNotificationsPlugin.initialize(initializationSettings,
//        onSelectNotification: onSelectNotification);
//
//    if (Platform.isIOS) {
//      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
//        // save the token  OR subscribe to a topic here
//      });
//
//      _fcm.requestNotificationPermissions(IosNotificationSettings());
//    } else {
//      _saveDeviceToken();
//    }
//
//    _fcm.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        print("onMessage: $message");
//        _showBigPictureNotification(message);
//      },
//      onBackgroundMessage: myBackgroundMessageHandler,
//      onLaunch: (Map<String, dynamic> message) async {
//        print("onLaunch: $message");
//      },
//      onResume: (Map<String, dynamic> message) async {
//        print("onResume: $message");
//      },
//    );
//  }
//
//  /// Get the token, save it to the database for current user
//  _saveDeviceToken() async {
//    String fcmToken = await _fcm.getToken();
//    print("FCM_TOKEN: $fcmToken");
//  }
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
//
//  Future onSelectNotification(String payload) async {
//    if (payload != null) {
//      debugPrint('notification payload: ' + payload);
//    }
//    // await Navigator.push(
//    //   context,
//    //   new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
//    // );
//  }
//
//  Future<void> onDidReceiveLocalNotification(
//      int id, String title, String body, String payload) async {
//    // display a dialog with the notification details, tap ok to go to another page
//  }
//
//  Future<String> _downloadAndSaveImage(String url, String fileName) async {
//    var directory = await getApplicationDocumentsDirectory();
//    var filePath = '${directory.path}/$fileName';
//    var response = await http.get(url);
//    var file = File(filePath);
//    await file.writeAsBytes(response.bodyBytes);
//    return filePath;
//  }
//}
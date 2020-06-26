import 'package:after_init/after_init.dart';
import 'package:auto_route/auto_route.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/screens/model_body.dart';
import 'package:vanevents/screens/model_screen.dart';
import 'package:vanevents/services/firebase_cloud_messaging.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/my_event_search_chat.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';
import 'package:vanevents/shared/topAppBar.dart';
import 'dart:math' as math;

import 'package:vanevents/shared/user_search_chat.dart';

class BaseScreens extends StatefulWidget {
  BaseScreens();

  @override
  _BaseScreensState createState() => _BaseScreensState();
}

class _BaseScreensState extends State<BaseScreens>
    with
        WidgetsBindingObserver,
        AfterInitMixin,
        TickerProviderStateMixin {
  AnimationController _animationController;
  final double maxSlide = 60.0;

  TabController tabController;

  @override
  void initState() {
    print('Basescreen');
    tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

//
  @override
  void didInitState() {
    print(Provider.of<FirestoreDatabase>(context).uid);

    //print(context.read<FirestoreDatabase>().email);
    initNotification();

    //NotificationApnHandler().initializeApnNotification(user.id,context);


  }

  void initNotification() async {
    NotificationHandler().initializeFcmNotification(
        context.read<FirestoreDatabase>().uid, context);
  }


  @override
  void dispose() {
    print('//');
    _animationController.dispose();
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

  void close() => _animationController.reverse();

  void open() => _animationController.forward();

  void toggleMenu() => _animationController.isCompleted ? close() : open();

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    return BlocBuilder<NavigationBloc, NavigationStates>(
        builder: (BuildContext context, NavigationStates state) {
      print(state.toString());
      print('Basescreen');
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

      return ModelScreen(
        child: Stack(
          children: <Widget>[
            ModelBody(child: state as Widget),
            Align(
              alignment: Alignment.bottomCenter,
              child: CurvedNavigationBar(
                backgroundColor: Colors.transparent,
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
            ),
            TopAppBar(state.toString(), true, double.infinity),
            state.toString() == 'Chat'
                ? Positioned(
                    right: 15,
                    bottom: 60,
                    child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, _) {
                          return Container(
                            width: 120,
                            height: 120,
                            child: Stack(
                              overflow: Overflow.visible,
                              children: <Widget>[
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Transform.translate(
                                    offset: Offset(
                                        -maxSlide * _animationController.value,
                                        0),
                                    child: Transform.rotate(
                                      angle: _animationController.value *
                                          2.0 *
                                          math.pi,
                                      child: Transform.scale(
                                        scale: _animationController.value,
                                        child: FloatingActionButton(
                                            heroTag: 1,
                                            child: Icon(
                                              FontAwesomeIcons.userFriends,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                            ),
                                            onPressed: () async {
                                              final User userFriend =
                                                  await showSearch(
                                                      context: context,
                                                      delegate: UserSearch(
                                                          UserBlocSearchName()));

                                              if (userFriend != null) {
                                                db
                                                    .creationChatRoom(
                                                        userFriend)
                                                    .then((chatId) {
                                                  db
                                                      .getMyChat(chatId)
                                                      .then((myChat) {
                                                    db
                                                        .chatUsersFuture(myChat)
                                                        .then((users) {
                                                      User friend;
                                                      if (!myChat.isGroupe) {
                                                        friend =
                                                            users.firstWhere(
                                                                (user) =>
                                                                    user.id !=
                                                                    db.uid);
                                                      }
                                                      ExtendedNavigator.of(
                                                              context)
                                                          .pushNamed(
                                                              Routes.chatRoom,
                                                              arguments:
                                                                  ChatRoomArguments(
                                                                      chatId:
                                                                          chatId));
                                                    }).catchError((onError) {
                                                      print(onError);
                                                    });
                                                  }).catchError((onError) {
                                                    print(onError);
                                                  });
                                                }).catchError((onError) {
                                                  print(onError);
                                                });
                                              }
                                              //ExtendedNavigator.of(context).pushNamed(Routes.uploadEvent),
                                            }),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Transform.translate(
                                    offset: Offset(0,
                                        -maxSlide * _animationController.value),
                                    child: Transform.rotate(
                                      angle: _animationController.value *
                                          2.0 *
                                          math.pi,
                                      child: Transform.scale(
                                        scale: _animationController.value,
                                        child: FloatingActionButton(
                                            heroTag: 2,
                                            child: Icon(
                                              FontAwesomeIcons.users,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                            ),
                                            onPressed: () async {
                                              await showSearch(
                                                      context: context,
                                                      delegate: MyEventSearch(
                                                          MyEventBlocSearchName()))
                                                  .then((myEvent) async {
                                                if (myEvent != null) {
                                                  await db
                                                      .addAmongGroupe(
                                                          myEvent.chatId)
                                                      .then((_) {
                                                    db
                                                        .getMyChat(
                                                            myEvent.chatId)
                                                        .then((myChat) {
                                                      db
                                                          .chatUsersFuture(
                                                              myChat)
                                                          .then((users) {
                                                        User friend;
                                                        if (!myChat.isGroupe) {
                                                          friend =
                                                              users.firstWhere(
                                                                  (user) =>
                                                                      user.id !=
                                                                      db.uid);
                                                        }
                                                        ExtendedNavigator.of(
                                                                context)
                                                            .pushNamed(
                                                                Routes.chatRoom,
                                                                arguments:
                                                                    ChatRoomArguments(
                                                                        chatId:
                                                                            myChat.id));
                                                      });
                                                    });
                                                  });
                                                }
                                              });
                                            }
                                            //ExtendedNavigator.of(context).pushNamed(Routes.uploadEvent),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: FloatingActionButton(
                                      heroTag: 3,
                                      child: Icon(
                                        FontAwesomeIcons.search,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                      ),
                                      onPressed: () {
                                        //NotificationHandler().showOverlayWindow();

                                        toggleMenu();
                                      }
                                      //ExtendedNavigator.of(context).pushNamed(Routes.uploadEvent),
                                      ),
                                ),
                              ],
                            ),
                          );
                        }),
                  )
                : SizedBox(),
          ],
        ),
      );
    });
  }

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
//    var filePath = '${directory.
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:vanevents/auth_widget.dart';
import 'package:vanevents/screens/login.dart';
import 'package:vanevents/screens/reset_password.dart';
import 'package:vanevents/screens/sign_up.dart';
import 'package:vanevents/screens/base_screen.dart';
import 'package:vanevents/screens/chat_room.dart';
import 'package:vanevents/models/my_chat.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/screens/full_photo.dart';
import 'dart:io';
import 'package:vanevents/screens/upload_event.dart';
import 'package:vanevents/screens/details.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/screens/formula_choice.dart';
import 'package:vanevents/models/formule.dart';
import 'package:vanevents/screens/qr_code.dart';
import 'package:vanevents/screens/monitoring_scanner.dart';
import 'package:vanevents/screens/admin_event.dart';
import 'package:vanevents/screens/splash_screen.dart';

abstract class Routes {
  static const authWidget = '/';
  static const login = '/login';
  static const resetPassword = '/reset-password';
  static const signUp = '/sign-up';
  static const baseScreens = '/base-screens';
  static const chatRoom = '/chat-room';
  static const fullPhoto = '/full-photo';
  static const uploadEvent = '/upload-event';
  static const details = '/details';
  static const formulaChoice = '/formula-choice';
  static const qrCode = '/qr-code';
  static const monitoringScanner = '/monitoring-scanner';
  static const adminEvents = '/admin-events';
  static const splashScreen = '/splash-screen';
  static const all = {
    authWidget,
    login,
    resetPassword,
    signUp,
    baseScreens,
    chatRoom,
    fullPhoto,
    uploadEvent,
    details,
    formulaChoice,
    qrCode,
    monitoringScanner,
    adminEvents,
    splashScreen,
  };
}

class Router extends RouterBase {
  @override
  Set<String> get allRoutes => Routes.all;

  @Deprecated('call ExtendedNavigator.ofRouter<Router>() directly')
  static ExtendedNavigatorState get navigator =>
      ExtendedNavigator.ofRouter<Router>();

  @override
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case Routes.authWidget:
        if (hasInvalidArgs<AuthWidgetArguments>(args)) {
          return misTypedArgsRoute<AuthWidgetArguments>(args);
        }
        final typedArgs = args as AuthWidgetArguments ?? AuthWidgetArguments();
        return MaterialPageRoute<dynamic>(
          builder: (context) => AuthWidget(
              key: typedArgs.key, seenOnboarding: typedArgs.seenOnboarding),
          settings: settings,
        );
      case Routes.login:
        return MaterialPageRoute<dynamic>(
          builder: (context) => Login(),
          settings: settings,
        );
      case Routes.resetPassword:
        return PageRouteBuilder<dynamic>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ResetPassword(),
          settings: settings,
          transitionsBuilder: TransitionsBuilders.zoomIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      case Routes.signUp:
        return PageRouteBuilder<dynamic>(
          pageBuilder: (context, animation, secondaryAnimation) => SignUp(),
          settings: settings,
          transitionsBuilder: TransitionsBuilders.zoomIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      case Routes.baseScreens:
        if (hasInvalidArgs<BaseScreensArguments>(args, isRequired: true)) {
          return misTypedArgsRoute<BaseScreensArguments>(args);
        }
        final typedArgs = args as BaseScreensArguments;
        return PageRouteBuilder<dynamic>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              BaseScreens(typedArgs.uid),
          settings: settings,
          transitionsBuilder: TransitionsBuilders.zoomIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      case Routes.chatRoom:
        if (hasInvalidArgs<ChatRoomArguments>(args, isRequired: true)) {
          return misTypedArgsRoute<ChatRoomArguments>(args);
        }
        final typedArgs = args as ChatRoomArguments;
        return PageRouteBuilder<dynamic>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ChatRoom(typedArgs.myChat, typedArgs.membres, typedArgs.friend),
          settings: settings,
          transitionsBuilder: TransitionsBuilders.zoomIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      case Routes.fullPhoto:
        if (hasInvalidArgs<FullPhotoArguments>(args, isRequired: true)) {
          return misTypedArgsRoute<FullPhotoArguments>(args);
        }
        final typedArgs = args as FullPhotoArguments;
        return PageRouteBuilder<dynamic>(
          pageBuilder: (context, animation, secondaryAnimation) => FullPhoto(
              key: typedArgs.key, url: typedArgs.url, file: typedArgs.file),
          settings: settings,
          transitionsBuilder: TransitionsBuilders.zoomIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      case Routes.uploadEvent:
        if (hasInvalidArgs<UploadEventArguments>(args)) {
          return misTypedArgsRoute<UploadEventArguments>(args);
        }
        final typedArgs =
            args as UploadEventArguments ?? UploadEventArguments();
        return PageRouteBuilder<dynamic>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              UploadEvent(idEvent: typedArgs.idEvent),
          settings: settings,
          transitionsBuilder: TransitionsBuilders.zoomIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      case Routes.details:
        if (hasInvalidArgs<DetailsArguments>(args, isRequired: true)) {
          return misTypedArgsRoute<DetailsArguments>(args);
        }
        final typedArgs = args as DetailsArguments;
        return PageRouteBuilder<dynamic>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              Details(typedArgs.event),
          settings: settings,
          transitionsBuilder: TransitionsBuilders.zoomIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      case Routes.formulaChoice:
        if (hasInvalidArgs<FormulaChoiceArguments>(args, isRequired: true)) {
          return misTypedArgsRoute<FormulaChoiceArguments>(args);
        }
        final typedArgs = args as FormulaChoiceArguments;
        return PageRouteBuilder<dynamic>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              FormulaChoice(
                  typedArgs.formulas, typedArgs.eventId, typedArgs.imageUrl),
          settings: settings,
          transitionsBuilder: TransitionsBuilders.zoomIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      case Routes.qrCode:
        if (hasInvalidArgs<QrCodeArguments>(args, isRequired: true)) {
          return misTypedArgsRoute<QrCodeArguments>(args);
        }
        final typedArgs = args as QrCodeArguments;
        return PageRouteBuilder<dynamic>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              QrCode(typedArgs.data),
          settings: settings,
          transitionsBuilder: TransitionsBuilders.zoomIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      case Routes.monitoringScanner:
        if (hasInvalidArgs<MonitoringScannerArguments>(args,
            isRequired: true)) {
          return misTypedArgsRoute<MonitoringScannerArguments>(args);
        }
        final typedArgs = args as MonitoringScannerArguments;
        return PageRouteBuilder<dynamic>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MonitoringScanner(typedArgs.eventId),
          settings: settings,
          transitionsBuilder: TransitionsBuilders.zoomIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      case Routes.adminEvents:
        return PageRouteBuilder<dynamic>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AdminEvents(),
          settings: settings,
          transitionsBuilder: TransitionsBuilders.zoomIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      case Routes.splashScreen:
        return MaterialPageRoute<dynamic>(
          builder: (context) => SplashScreen(),
          settings: settings,
        );
      default:
        return unknownRoutePage(settings.name);
    }
  }
}

// *************************************************************************
// Arguments holder classes
// **************************************************************************

//AuthWidget arguments holder class
class AuthWidgetArguments {
  final Key key;
  final bool seenOnboarding;
  AuthWidgetArguments({this.key, this.seenOnboarding});
}

//BaseScreens arguments holder class
class BaseScreensArguments {
  final String uid;
  BaseScreensArguments({@required this.uid});
}

//ChatRoom arguments holder class
class ChatRoomArguments {
  final MyChat myChat;
  final List<User> membres;
  final User friend;
  ChatRoomArguments(
      {@required this.myChat, @required this.membres, @required this.friend});
}

//FullPhoto arguments holder class
class FullPhotoArguments {
  final Key key;
  final String url;
  final File file;
  FullPhotoArguments({this.key, @required this.url, this.file});
}

//UploadEvent arguments holder class
class UploadEventArguments {
  final String idEvent;
  UploadEventArguments({this.idEvent});
}

//Details arguments holder class
class DetailsArguments {
  final MyEvent event;
  DetailsArguments({@required this.event});
}

//FormulaChoice arguments holder class
class FormulaChoiceArguments {
  final List<Formule> formulas;
  final String eventId;
  final String imageUrl;
  FormulaChoiceArguments(
      {@required this.formulas,
      @required this.eventId,
      @required this.imageUrl});
}

//QrCode arguments holder class
class QrCodeArguments {
  final String data;
  QrCodeArguments({@required this.data});
}

//MonitoringScanner arguments holder class
class MonitoringScannerArguments {
  final String eventId;
  MonitoringScannerArguments({@required this.eventId});
}

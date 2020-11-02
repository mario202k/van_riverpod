// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../authentication.dart';
import '../bloc/stripe_profile/screen_stripe_profile.dart';
import '../models/event.dart';
import '../models/formule.dart';
import '../models/my_transport.dart';
import '../screens/admin_event.dart';
import '../screens/admin_organisateur.dart';
import '../screens/base_screen.dart';
import '../screens/cgu_cgv_accept.dart';
import '../screens/chat_room.dart';
import '../screens/details.dart';
import '../screens/formula_choice.dart';
import '../screens/full_photo.dart';
import '../screens/login.dart';
import '../screens/monitoring_scanner.dart';
import '../screens/qr_code.dart';
import '../screens/reset_password.dart';
import '../screens/sign_up.dart';
import '../screens/splash_screen.dart';
import '../screens/transport.dart';
import '../screens/transport_details.dart';
import '../screens/upload_event.dart';
import '../screens/walkthrough.dart';

class Routes {
  static const String authentication = '/';
  static const String loginForm = '/login-form';
  static const String resetPassword = '/reset-password';
  static const String signUp = '/sign-up';
  static const String baseScreens = '/base-screens';
  static const String chatRoom = '/chat-room';
  static const String fullPhoto = '/full-photo';
  static const String uploadEvent = '/upload-event';
  static const String details = '/Details';
  static const String formulaChoice = '/formula-choice';
  static const String qrCode = '/qr-code';
  static const String monitoringScanner = '/monitoring-scanner';
  static const String adminEvents = '/admin-events';
  static const String adminOrganisateurs = '/admin-organisateurs';
  static const String mySplashScreen = '/my-splash-screen';
  static const String walkthrough = '/Walkthrough';
  static const String cguCgvAccept = '/cgu-cgv-accept';
  static const String stripeProfile = '/stripe-profile';
  static const String transport = '/Transport';
  static const String transportDetail = '/transport-detail';
  static const all = <String>{
    authentication,
    loginForm,
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
    adminOrganisateurs,
    mySplashScreen,
    walkthrough,
    cguCgvAccept,
    stripeProfile,
    transport,
    transportDetail,
  };
}

class Router extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.authentication, page: Authentication),
    RouteDef(Routes.loginForm, page: LoginForm),
    RouteDef(Routes.resetPassword, page: ResetPassword),
    RouteDef(Routes.signUp, page: SignUp),
    RouteDef(Routes.baseScreens, page: BaseScreens),
    RouteDef(Routes.chatRoom, page: ChatRoom),
    RouteDef(Routes.fullPhoto, page: FullPhoto),
    RouteDef(Routes.uploadEvent, page: UploadEvent),
    RouteDef(Routes.details, page: Details),
    RouteDef(Routes.formulaChoice, page: FormulaChoice),
    RouteDef(Routes.qrCode, page: QrCode),
    RouteDef(Routes.monitoringScanner, page: MonitoringScanner),
    RouteDef(Routes.adminEvents, page: AdminEvents),
    RouteDef(Routes.adminOrganisateurs, page: AdminOrganisateurs),
    RouteDef(Routes.mySplashScreen, page: MySplashScreen),
    RouteDef(Routes.walkthrough, page: Walkthrough),
    RouteDef(Routes.cguCgvAccept, page: CguCgvAccept),
    RouteDef(Routes.stripeProfile, page: StripeProfile),
    RouteDef(Routes.transport, page: Transport),
    RouteDef(Routes.transportDetail, page: TransportDetail),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    Authentication: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => Authentication(),
        settings: data,
      );
    },
    LoginForm: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => LoginForm(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    ResetPassword: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ResetPassword(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    SignUp: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SignUp(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    BaseScreens: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => BaseScreens(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    ChatRoom: (data) {
      final args = data.getArgs<ChatRoomArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => ChatRoom(args.chatId),
        settings: data,
        fullscreenDialog: true,
      );
    },
    FullPhoto: (data) {
      final args = data.getArgs<FullPhotoArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => FullPhoto(
          key: args.key,
          url: args.url,
          file: args.file,
        ),
        settings: data,
        fullscreenDialog: true,
      );
    },
    UploadEvent: (data) {
      final args = data.getArgs<UploadEventArguments>(
        orElse: () => UploadEventArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => UploadEvent(myEvent: args.myEvent),
        settings: data,
        fullscreenDialog: true,
      );
    },
    Details: (data) {
      final args = data.getArgs<DetailsArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => Details(args.event),
        settings: data,
        fullscreenDialog: true,
      );
    },
    FormulaChoice: (data) {
      final args = data.getArgs<FormulaChoiceArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => FormulaChoice(
          args.formulas,
          args.eventId,
          args.imageUrl,
          args.stripeAccount,
          args.latLng,
          args.dateDebut,
        ),
        settings: data,
        fullscreenDialog: true,
      );
    },
    QrCode: (data) {
      final args = data.getArgs<QrCodeArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => QrCode(args.data),
        settings: data,
        fullscreenDialog: true,
      );
    },
    MonitoringScanner: (data) {
      final args = data.getArgs<MonitoringScannerArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => MonitoringScanner(args.eventId),
        settings: data,
        fullscreenDialog: true,
      );
    },
    AdminEvents: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => AdminEvents(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    AdminOrganisateurs: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => AdminOrganisateurs(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    MySplashScreen: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => MySplashScreen(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    Walkthrough: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => Walkthrough(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    CguCgvAccept: (data) {
      final args = data.getArgs<CguCgvAcceptArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => CguCgvAccept(args.uid),
        settings: data,
        fullscreenDialog: true,
      );
    },
    StripeProfile: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => StripeProfile(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    Transport: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => Transport(),
        settings: data,
        fullscreenDialog: true,
      );
    },
    TransportDetail: (data) {
      final args = data.getArgs<TransportDetailArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => TransportDetail(
          args.myTransport,
          args.addressArriver,
        ),
        settings: data,
        fullscreenDialog: true,
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************

/// ChatRoom arguments holder class
class ChatRoomArguments {
  final String chatId;
  ChatRoomArguments({@required this.chatId});
}

/// FullPhoto arguments holder class
class FullPhotoArguments {
  final Key key;
  final String url;
  final File file;
  FullPhotoArguments({this.key, @required this.url, this.file});
}

/// UploadEvent arguments holder class
class UploadEventArguments {
  final MyEvent myEvent;
  UploadEventArguments({this.myEvent});
}

/// Details arguments holder class
class DetailsArguments {
  final MyEvent event;
  DetailsArguments({@required this.event});
}

/// FormulaChoice arguments holder class
class FormulaChoiceArguments {
  final List<Formule> formulas;
  final String eventId;
  final String imageUrl;
  final String stripeAccount;
  final LatLng latLng;
  final DateTime dateDebut;
  FormulaChoiceArguments(
      {@required this.formulas,
      @required this.eventId,
      @required this.imageUrl,
      @required this.stripeAccount,
      @required this.latLng,
      @required this.dateDebut});
}

/// QrCode arguments holder class
class QrCodeArguments {
  final String data;
  QrCodeArguments({@required this.data});
}

/// MonitoringScanner arguments holder class
class MonitoringScannerArguments {
  final String eventId;
  MonitoringScannerArguments({@required this.eventId});
}

/// CguCgvAccept arguments holder class
class CguCgvAcceptArguments {
  final String uid;
  CguCgvAcceptArguments({@required this.uid});
}

/// TransportDetail arguments holder class
class TransportDetailArguments {
  final MyTransport myTransport;
  final String addressArriver;
  TransportDetailArguments(
      {@required this.myTransport, @required this.addressArriver});
}

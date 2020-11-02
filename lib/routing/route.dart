import 'package:auto_route/auto_route_annotations.dart';
import 'package:vanevents/authentication.dart';
import 'package:vanevents/bloc/stripe_profile/screen_stripe_profile.dart';
import 'package:vanevents/screens/admin_event.dart';
import 'package:vanevents/screens/admin_organisateur.dart';
import 'package:vanevents/screens/base_screen.dart';
import 'package:vanevents/screens/cgu_cgv_accept.dart';
import 'package:vanevents/screens/chat_room.dart';
import 'package:vanevents/screens/details.dart';
import 'package:vanevents/screens/formula_choice.dart';
import 'package:vanevents/screens/full_photo.dart';
import 'package:vanevents/screens/login.dart';
import 'package:vanevents/screens/monitoring_scanner.dart';
import 'package:vanevents/screens/qr_code.dart';
import 'package:vanevents/screens/reset_password.dart';
import 'package:vanevents/screens/sign_up.dart';
import 'package:vanevents/screens/splash_screen.dart';
import 'package:vanevents/screens/transport.dart';
import 'package:vanevents/screens/transport_details.dart';
import 'package:vanevents/screens/upload_event.dart';
import 'package:vanevents/screens/walkthrough.dart';

//flutter packages pub run build_runner build
//flutter packages pub run build_runner clean

@MaterialAutoRouter(routes: <AutoRoute>[
  MaterialRoute(page: Authentication, initial: true),
  MaterialRoute(page: LoginForm, fullscreenDialog: true, initial: false),
  MaterialRoute(page: ResetPassword, fullscreenDialog: true, initial: false),
  MaterialRoute(page: BaseScreens, fullscreenDialog: true, initial: false),
  MaterialRoute(page: ChatRoom, fullscreenDialog: true, initial: false),
  MaterialRoute(page: FullPhoto, fullscreenDialog: true, initial: false),
  MaterialRoute(page: UploadEvent, fullscreenDialog: true, initial: false),
  MaterialRoute(page: Details, fullscreenDialog: true, initial: false),
  MaterialRoute(page: FormulaChoice, fullscreenDialog: true, initial: false),
  MaterialRoute(page: QrCode, fullscreenDialog: true, initial: false),
  MaterialRoute(
      page: MonitoringScanner, fullscreenDialog: true, initial: false),
  MaterialRoute(page: AdminEvents, fullscreenDialog: true, initial: false),
  MaterialRoute(
      page: AdminOrganisateurs, fullscreenDialog: true, initial: false),
  MaterialRoute(page: MySplashScreen, fullscreenDialog: true, initial: false),
  MaterialRoute(page: Walkthrough, fullscreenDialog: true, initial: false),
  MaterialRoute(page: CguCgvAccept, fullscreenDialog: true, initial: false),
  MaterialRoute(page: StripeProfile, fullscreenDialog: true, initial: false),
  MaterialRoute(page: Transport, fullscreenDialog: true, initial: false),
  MaterialRoute(page: TransportDetail, fullscreenDialog: true, initial: false),
  // This should be at the end of your routes list
  // wildcards are represented by '*'
  //MaterialRoute(path: "*", page: UnknownRouteScreen)
])
class $Router {
//flutter packages pub run build_runner build
//  @initial
//  Authentication authentication;
//
//  LoginForm login;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  ResetPassword resetPassword;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  SignUp signUp;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  BaseScreens baseScreens;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  ChatRoom chatRoom;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  FullPhoto fullPhoto;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  UploadEvent uploadEvent;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  Details details;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  FormulaChoice formulaChoice;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  QrCode qrCode;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  MonitoringScanner monitoringScanner;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  AdminEvents adminEvents;
//  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
//  AdminOrganisateurs adminOrganisateurs;
//
//  MySplashScreen splashScreen;
//
//  Walkthrough walkthrough;
//
//  CguCgvAccept cguCgvAccept;

}

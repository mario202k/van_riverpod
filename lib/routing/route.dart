import 'package:auto_route/auto_route.dart';
import 'package:auto_route/auto_route_annotations.dart';
import 'package:vanevents/auth_widget.dart';
import 'package:vanevents/screens/admin_event.dart';
import 'package:vanevents/screens/base_screen.dart';
import 'package:vanevents/screens/chat_room.dart';
import 'package:vanevents/screens/details.dart';
import 'package:vanevents/screens/formula_choice.dart';
import 'package:vanevents/screens/full_photo.dart';
import 'package:vanevents/screens/login.dart';
import 'package:vanevents/screens/qr_code.dart';
import 'package:vanevents/screens/monitoring_scanner.dart';
import 'package:vanevents/screens/reset_password.dart';
import 'package:vanevents/screens/sign_up.dart';
import 'package:vanevents/screens/splash_screen.dart';
import 'package:vanevents/screens/upload_event.dart';
import 'package:vanevents/screens/walkthrough.dart';

@MaterialAutoRouter()
class $Router {
//flutter packages pub run build_runner build
  @initial
  AuthWidget authWidget;

  Login login;
  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
  ResetPassword resetPassword;
  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
  SignUp signUp;
  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
  BaseScreens baseScreens;
  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
  ChatRoom chatRoom;
  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
  FullPhoto fullPhoto;
  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
  UploadEvent uploadEvent;
  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
  Details details;
  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
  FormulaChoice formulaChoice;
  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
  QrCode qrCode;
  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
  MonitoringScanner monitoringScanner;
  @CustomRoute(transitionsBuilder: TransitionsBuilders.zoomIn,durationInMilliseconds: 300)
  AdminEvents adminEvents;

  SplashScreen splashScreen;


}

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanevents/auth_widget_builder.dart';
import 'package:vanevents/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:vanevents/bloc/message/message_bloc.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/bloc/simple_bloc_delegate.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/repository/user_repository.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/services/firebase_auth_service.dart';
import 'package:vanevents/services/firebase_cloud_messaging.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  SharedPreferences.getInstance().then((prefs) {
    runApp(MyApp(userRepository: userRepository, prefs: prefs));
  });
}

void callBackFunction(String tag) {
  switch (tag) {
    case "simple_button":
      print("Simple button has been clicked");
      break;
    case "focus_button":
      print("Focus button has been clicked");
      break;
    case "personal_btn":
      print("Personal button has been clicked");
      break;
    default:
      print("OnClick event of $tag");
  }
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  return NotificationHandler().showNotification(message);
}

AsyncSnapshot<FirebaseUser> userSnapshotStatic;

class MyApp extends StatelessWidget {
  final SharedPreferences _prefs;
  final UserRepository _userRepository;

  MyApp(
      {Key key,
      @required UserRepository userRepository,
      @required SharedPreferences prefs})
      : assert(userRepository != null),
        assert(prefs != null),
        _userRepository = userRepository,
        _prefs = prefs,
        super(key: key);

  final ColorScheme colorScheme = ColorScheme(
      primary: const Color(0xFFe53935),
      primaryVariant: const Color(0xFFdf78ef),
      secondary: const Color(0xFFffcccb),
      secondaryVariant: const Color(0xFF039be5),
      background: const Color(0xFFFFFFFF),
      surface: const Color(0xFF039be5),
//      secondary: const Color(0xFF218b0e),
//      secondaryVariant: const Color(0xFF00600f),
//      background: const Color(0xFF790e8b),
//      surface: const Color(0xFF00600f),
      onBackground: const Color(0xFF000000),
      error: const Color(0xFF8b0e21),
      onError: const Color(0xFFFFFFFF),
      onPrimary: const Color(0xFFFFFFFF),
      onSecondary: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF000000),
      brightness: Brightness.light);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<BoolToggle>(
            create: (context) => BoolToggle(
                isEnableNotification: _prefs.getBool('VanEvent') ?? true),
          ),
          BlocProvider(
            create: (context) => AuthenticationBloc(
                userRepository: _userRepository,
                seenOnboarding: _prefs.getBool('seen') ?? false)
              ..add(AuthenticationStarted()),
          ),
          Provider<UserRepository>(
            create: (context) => _userRepository,
          ),
          Provider<FirestoreDatabase>(
            create: (context) => FirestoreDatabase(),
          ),
          Provider<User>(
            create: (context) => User(),
          ),
          ChangeNotifierProvider<ValueNotifier<bool>>(
            create: (context) => ValueNotifier<bool>(false),
          ),
          BlocProvider<NavigationBloc>(
            create: (BuildContext context) => NavigationBloc(),
          ),
          BlocProvider<MessageBloc>(
            create: (BuildContext context) => MessageBloc(),
          ),
        ],
        child: Material(
            color: Colors.black,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: colorScheme,
                primaryColor: colorScheme.primary,
                accentColor: colorScheme.secondary,
                backgroundColor: colorScheme.background,
                textTheme: TextTheme(
                  bodyText1: GoogleFonts.raleway(
                    fontSize: 25.0,
                    color: colorScheme.onBackground,
                  ),
                  bodyText2: GoogleFonts.raleway(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                  caption: GoogleFonts.sourceCodePro(
                    fontSize: 11.0,
                    color: colorScheme.onPrimary,
                  ),
                  headline6: GoogleFonts.raleway(
                    //App Bar alertdialog.title
                    fontSize: 31.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                  headline5: GoogleFonts.sourceCodePro(
                    fontSize: 16.0,
                    color: colorScheme.onBackground,
                  ),
                  overline: GoogleFonts.sourceCodePro(
                    fontSize: 11.0,
                    color: colorScheme.onPrimary,
                  ),
                  button: GoogleFonts.sourceCodePro(
                    fontSize: 17.0,
                    color: colorScheme.onPrimary,
                  ),
                  subtitle2: GoogleFonts.sourceCodePro(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                ),
                appBarTheme: AppBarTheme(
                    color: colorScheme.primary,
                    textTheme: TextTheme(
                        headline6: GoogleFonts.raleway(
                      //App Bar alertdialog.title
                      fontSize: 31.0,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ))),
                buttonTheme: ButtonThemeData(
                    textTheme: ButtonTextTheme.primary,
                    splashColor: colorScheme.primary,
                    colorScheme: colorScheme,
                    buttonColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                cursorColor: colorScheme.onBackground,
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.primary),
                inputDecorationTheme: InputDecorationTheme(
//                  filled: true,
//                  fillColor: Color(0xFFF2F2F2),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: colorScheme.onBackground,
                          style: BorderStyle.solid,
                          width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: colorScheme.onBackground,
                          style: BorderStyle.solid,
                          width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: colorScheme.onBackground,
                          style: BorderStyle.solid,
                          width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: colorScheme.onBackground,
                          style: BorderStyle.solid,
                          width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: colorScheme.error,
                          style: BorderStyle.solid,
                          width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: colorScheme.onBackground,
                          style: BorderStyle.solid,
                          width: 2),
                      borderRadius: BorderRadius.circular(25.0)),
                  labelStyle: GoogleFonts.sourceCodePro(
                    fontSize: 17.0,
                    color: colorScheme.onBackground,
                  ),
                  errorStyle: GoogleFonts.sourceCodePro(
                    fontSize: 11.0,
                    color: colorScheme.error,
                  ),
                ),
                cardTheme: CardTheme(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25))),
                dividerTheme: DividerThemeData(
                    color: colorScheme.primary,
                    thickness: 1,
                    indent: 30,
                    endIndent: 30),
              ),
              builder: ExtendedNavigator<Router>(
                router: Router(),
              ),
              navigatorObservers: [
                HeroController(),
              ],
            )));
  }
}

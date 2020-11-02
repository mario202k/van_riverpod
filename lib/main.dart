import 'package:auto_route/auto_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/authentication.dart';
import 'package:vanevents/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:vanevents/bloc/message/message_bloc.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/repository/user_repository.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/screens/home_events.dart';
import 'package:vanevents/services/firebase_cloud_messaging.dart';
import 'package:vanevents/shared/my_event_search_chat.dart';
import 'package:vanevents/shared/user_search_chat.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //BlocSupervisor.delegate = SimpleBlocDelegate();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
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


class MyApp extends StatelessWidget {
  final ColorScheme colorScheme = ColorScheme(
      primary: const Color(0xFFaf0b0b),
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
      error: const Color(0xFF039be5),
      onError: const Color(0xFFFFFFFF),
      onPrimary: const Color(0xFFFFFFFF),
      onSecondary: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF000000),
      brightness: Brightness.light);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          BlocProvider<NavigationBloc>(
            create: (BuildContext context) => NavigationBloc(HomeEvents()),
          ),
          BlocProvider<MyEventSearchNameCubit>(
            create: (context) =>
                MyEventSearchNameCubit(MyEventSearchState.loading()),
          ),
          BlocProvider<UserSearchNameCubit>(
            create: (context) => UserSearchNameCubit(UserSearchState.loading()),
          ),
          BlocProvider<MessageBloc>(
            create: (BuildContext context) =>
                MessageBloc(MessageState.loading()),
          ),
          BlocProvider(
            create: (context) =>
                AuthenticationBloc(userRepository: UserRepository())
                  ..add(AuthenticationStarted()),
          ),
        ],
        child: Material(
            color: Colors.black,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                // ... app-specific localization delegate[s] here
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                const Locale('fr', 'FR'), // English, no country code
              ],
              theme: ThemeData(
                colorScheme: colorScheme,
                primaryColor: colorScheme.primary,
                accentColor: colorScheme.primary,
                backgroundColor: colorScheme.background,
                textTheme: TextTheme(
                  bodyText1: GoogleFonts.poiretOne(
                    fontSize: 25.0,
                    color: colorScheme.onBackground,
                  ),
                  bodyText2: GoogleFonts.poiretOne(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onBackground,
                  ),
                  caption: GoogleFonts.poiretOne(
                    fontSize: 11.0,
                    color: colorScheme.onPrimary,
                  ),


                  headline6: GoogleFonts.poiretOne(
                    //App Bar alertdialog.title
                    fontSize: 31.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                  headline5: GoogleFonts.poiretOne(
                    fontSize: 17.0,
                    color: colorScheme.onBackground,
                  ),
                  headline4: GoogleFonts.poiretOne(
                    fontSize: 29.0,
                    color: colorScheme.onBackground,
                  ),
                  overline: GoogleFonts.poiretOne(
                    fontSize: 11.0,
                    color: colorScheme.onPrimary,
                  ),
                  button: GoogleFonts.poiretOne(
                    fontSize: 17.0,
                    color: colorScheme.onPrimary,
                  ),
                  subtitle2: GoogleFonts.poiretOne(
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
                  labelStyle: GoogleFonts.poiretOne(
                    fontSize: 17.0,
                    color: colorScheme.onBackground,
                  ),
                  counterStyle: GoogleFonts.poiretOne(
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
                      borderRadius: BorderRadius.circular(25)),
                  elevation: 20,
                  //color: colorScheme.secondary,
                ),
                dividerTheme: DividerThemeData(
                    color: colorScheme.primary,
                    thickness: 1,
                    indent: 30,
                    endIndent: 30),
              ),
              initialRoute: Routes.authentication,
              builder: ExtendedNavigator<Router>(
                router: Router(),
                initialRoute: Routes.authentication,
              ),
              home: Authentication(),
              navigatorObservers: [
                HeroController(),
              ],
            )));
  }
}

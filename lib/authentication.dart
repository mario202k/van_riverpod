import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/screens/base_screen.dart';
import 'package:vanevents/screens/model_screen.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/custom_drawer.dart';

class Authentication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ModelScreen(
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationFailure) {
            if (state.seenOnboarding) {
              Navigator.of(context).pushReplacementNamed(Routes.splashScreen);
            } else {
              Navigator.of(context).pushReplacementNamed(Routes.walkthrough);
            }
          }
        },
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            print(state);

            if (state is AuthenticationSuccess) {

              Provider.of<FirestoreDatabase>(context,listen: false).setUid(state.firebaseUser.uid);

              Provider.of<User>(context).setUser(Provider.of<FirestoreDatabase>(context,listen: false)
                  .userStream());



              return MultiProvider(
                  providers: [
                    StreamProvider<User>.value(
                      value: Provider.of<FirestoreDatabase>(context,listen: false)
                          .userStream(),
                      initialData: toUser(state.firebaseUser),
                      catchError: (_, __) => toUser(state.firebaseUser),
                    ),

                  ],
                  child: CustomDrawer(child: BaseScreens()));
            }

            return Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary)),
            );
          },
        ),
      ),
    );
  }

  User toUser(FirebaseUser firebaseUser) {
    return User(
        id: firebaseUser.uid,
        email: firebaseUser.email,
        imageUrl: firebaseUser.photoUrl,
        nom: firebaseUser.displayName);
  }
}

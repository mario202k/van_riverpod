import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vanevents/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:vanevents/provider/provider.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/screens/base_screen.dart';
import 'package:vanevents/screens/model_screen.dart';
import 'package:vanevents/shared/custom_drawer.dart';

class Authentication extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final firestore = context.read(firestoreDatabaseProvider);
    final myUser = context.read(myUserProvider);

    return ModelScreen(
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationFailure) {
            if (state.seenOnboarding) {
              Navigator.of(context).pushReplacementNamed(Routes.mySplashScreen);
            } else {
              Navigator.of(context).pushReplacementNamed(Routes.walkthrough);
            }
          } else if (state is AuthenticationCGUCGV) {
            Navigator.of(context).pushReplacementNamed(Routes.cguCgvAccept,
                arguments: CguCgvAcceptArguments(uid: state.firebaseUser.uid));
          }
        },
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationSuccess) {
              firestore.setUid(state.firebaseUser.uid);
              myUser.setUser(state.myUser);

              return CustomDrawer(child: BaseScreens());
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

}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:vanevents/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:vanevents/provider/provider.dart';
import 'package:vanevents/repository/user_repository.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/screens/cguCgv.dart';
import 'package:vanevents/services/firestore_database.dart';

class CguCgvAccept extends StatelessWidget {
  final String uid;

  CguCgvAccept(this.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CGU CGV'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Wrap(
              children: <Widget>[
                Text(
                  'Acceptez-vous les',
                  style: Theme.of(context).textTheme.headline5,
                ),
                InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CguCgv('cgu')));
                    },
                    child: Text(
                      'Conditions générales d\'utilisation ',
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(color: Colors.blue),
                    )),
                Text(
                  'et les',
                  style: Theme.of(context).textTheme.headline5,
                ),
                InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CguCgv('cgv')));
                    },
                    child: Text(
                      'Conditions générales de vente',
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(color: Colors.blue),
                    )),
                Text(
                  ' ?',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                    child: Text('Non'),
                    onPressed: () {

                      context.read(firestoreDatabaseProvider).setInactive();
                      context.read(userRepositoryProvider).signOut();
                      context
                          .bloc<AuthenticationBloc>()
                          .add(AuthenticationLoggedOut());
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.mySplashScreen);
                    }),
                RaisedButton(
                    child: Text('Oui'),
                    onPressed: () async {

                      await context.read(userRepositoryProvider)
                          .setIsAcceptCGUCGV(uid);
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.authentication);
                      context
                          .bloc<AuthenticationBloc>()
                          .add(AuthenticationLoggedIn());
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }
}

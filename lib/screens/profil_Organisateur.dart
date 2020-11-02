import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/screens/model_body.dart';
import 'package:vanevents/services/firestore_database.dart';

class ProfilOrganisateur extends StatelessWidget {
  final String stripeId;

  ProfilOrganisateur(this.stripeId);

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);

    return Scaffold(
      body: ModelBody(
        child: FutureBuilder(
          future: db.retrieveStripeAccount(stripeId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erreur de connection',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.secondary)),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: Text(
                  'Pas de données',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            }

            //snapshot.data.data

            return Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        AssetImage('assets/img/normal_user_icon.png'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

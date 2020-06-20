import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/models/ticket.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';
import 'package:vanevents/shared/topAppBar.dart';

class Profil extends StatefulWidget with NavigationStates {
  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  Future<List<Ticket>> futureTickets;
  bool notification = true;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();
  }

  void fcmSubscribe() {
    firebaseMessaging.subscribeToTopic('VanEvent');
  }

  void fcmUnSubscribe() {
    firebaseMessaging.unsubscribeFromTopic('VanEvent');
//    ListView.builder(
//      itemCount: ,
//        itemBuilder:(context, indext){
//
//
//
//    });
  }

  void showDialogGenres(BuildContext context, List userGenres) {
    context.read<BoolToggle>().initGenre();
    for (int i = 0; i < userGenres.length; i++) {
      if (context.read<BoolToggle>().genre.containsKey(userGenres[i])) {
        context.read<BoolToggle>().modificationGenre(userGenres[i]);
      }
    }
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Platform.isAndroid
          ? AlertDialog(
              title: Text(
                'Genres?',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                    itemCount:
                        Provider.of<BoolToggle>(context).genre.keys.length,
                    itemBuilder: (context, index) {
                      List<String> str =
                          context.read<BoolToggle>().genre.keys.toList();

                      return Consumer<BoolToggle>(
                        builder: (BuildContext context, BoolToggle boolToggle,
                            Widget child) {
                          return CheckboxListTile(
                            onChanged: (bool val) =>
                                boolToggle.modificationGenre(str[index]),
                            value:
                                context.watch<BoolToggle>().genre[str[index]],
                            activeColor: Theme.of(context).colorScheme.primary,
                            title: Text(str[index]),
                          );
                        },
                      );
                    }),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    context
                        .read<FirestoreDatabase>()
                        .updateUserGenre(context.read<BoolToggle>().genre);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          : CupertinoAlertDialog(
              title: Text(
                'Genres?',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                    itemCount:
                        Provider.of<BoolToggle>(context).genre.keys.length,
                    itemBuilder: (context, index) {
                      List<String> str =
                          context.read<BoolToggle>().genre.keys.toList();

                      return Consumer<BoolToggle>(
                        builder: (BuildContext context, BoolToggle boolToggle,
                            Widget child) {
                          return CheckboxListTile(
                            onChanged: (bool val) =>
                                boolToggle.modificationGenre(str[index]),
                            value:
                                context.watch<BoolToggle>().genre[str[index]],
                            activeColor: Theme.of(context).colorScheme.primary,
                            title: Text(str[index]),
                          );
                        },
                      );
                    }),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Caméra'),
                  onPressed: () {
                    //context.read<BoolToggle>().getImageCamera(type);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Galerie'),
                  onPressed: () {
                    //context.read<BoolToggle>().getImageGallery(type);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
    );
  }

  void showDialogTypes(BuildContext context, List userTypes) {

    context.read<BoolToggle>().initType();
    for (int i = 0; i < userTypes.length; i++) {
      if (context.read<BoolToggle>().type.containsKey(userTypes[i])) {
        context.read<BoolToggle>().modificationType(userTypes[i]);
      }
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Platform.isAndroid
          ? AlertDialog(
        title: Text(
          'Types?',
          style: Theme.of(context).textTheme.bodyText1,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
              itemCount:
              Provider.of<BoolToggle>(context).type.keys.length,
              itemBuilder: (context, index) {
                List<String> str =
                context.read<BoolToggle>().type.keys.toList();

                return Consumer<BoolToggle>(
                  builder: (BuildContext context, BoolToggle boolToggle,
                      Widget child) {
                    return CheckboxListTile(
                      onChanged: (bool val) =>
                          boolToggle.modificationType(str[index]),
                      value:
                      context.watch<BoolToggle>().type[str[index]],
                      activeColor: Theme.of(context).colorScheme.primary,
                      title: Text(str[index]),
                    );
                  },
                );
              }),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Annuler'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              context
                  .read<FirestoreDatabase>()
                  .updateUserType(context.read<BoolToggle>().type);
              Navigator.of(context).pop();
            },
          ),
        ],
      )
          : CupertinoAlertDialog(
              title: Text('Source?'),
              content: Text('Veuillez choisir une source'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Caméra'),
                  onPressed: () {
                    //context.read<BoolToggle>().getImageCamera(type);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Galerie'),
                  onPressed: () {
                    //context.read<BoolToggle>().getImageGallery(type);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context, listen: false);

    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    futureTickets = db.futureTicketParticipation();
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 100),
          child: TopAppBar('Profil', true, double.infinity),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
                child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text(
                        user.nom,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.onBackground,
                      thickness: 1,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        'Participations:',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    FutureBuilder(
                      future: futureTickets,
                      builder: (context, async) {
                        if (async.hasError) {
                          print(async.error);
                          return Center(
                            child: Text(
                              'Erreur de connexion',
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          );
                        } else if (async.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.secondary)),
                          );
                        }

                        List<Ticket> tickets = List<Ticket>();

                        tickets.addAll(async.data);

//                        for(int i=0; i<tickets.length ;i++){
//                          for(int j=0; j<tickets.length;j++){
//
//                            if()
//
//                          }
//                        }

                        return tickets.isNotEmpty
                            ? SizedBox(
                                height: 100,
                                child: ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      SizedBox(
                                    width: 12,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: tickets.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CachedNetworkImage(
                                        imageUrl: tickets[index].imageUrl,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          height: 84,
                                          width: 84,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(84)),
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Shimmer.fromColors(
                                          baseColor: Colors.white,
                                          highlightColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          child: CircleAvatar(
                                            radius: 42,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : SizedBox();
                      },
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.onBackground,
                      thickness: 1,
                    ),
                    ListTile(
                      leading: Text(
                        'Genres:',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      trailing: IconButton(
                          icon: Icon(FontAwesomeIcons.pencilAlt),
                          onPressed: () => showDialogGenres(
                              context,
                              context.read<User>().genres != null
                                  ? context.read<User>().genres.toList()
                                  : [])),
                    ),
                    Provider.of<User>(context).genres != null ?Column(
                      children: Provider.of<User>(context).genres
                          .map((e) => ListTile(
                        title: Text(
                          e,
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Colors.black),
                        ),
                        trailing: IconButton(
                          onPressed: null,
                          icon: Icon(FontAwesomeIcons.solidHeart),
                        ),
                      ))
                          .toList(),
                    ): SizedBox(),
                    Divider(
                      color: Theme.of(context).colorScheme.onBackground,
                      thickness: 1,
                    ),
                    ListTile(
                      leading: Text(
                        'Types:',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      trailing: IconButton(
                          icon: Icon(FontAwesomeIcons.pencilAlt),
                          onPressed: () => showDialogTypes(context,
                              context.read<User>().types != null
                                  ? context.read<User>().types.toList()
                                  : [])),
                    ),
                    Provider.of<User>(context).types != null ?Column(
                      children: Provider.of<User>(context).types
                          .map((e) => ListTile(
                        title: Text(
                          e,
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Colors.black),
                        ),
                        trailing: IconButton(
                          onPressed: null,
                          icon: Icon(FontAwesomeIcons.solidHeart),
                        ),
                      ))
                          .toList(),
                    ): SizedBox(),
                    Divider(
                      color: Theme.of(context).colorScheme.onBackground,
                      thickness: 1,
                    ),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.envelope,
                          color: Theme.of(context).colorScheme.onBackground),
                      title: Text(
                        user.email,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Consumer<BoolToggle>(builder: (context, boolToggle, child) {
                      return boolToggle.isEnableNotification
                          ? SwitchListTile(
                              title: Text(
                                'Notifications',
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                              value: true,
                              onChanged: (b) {
                                context
                                    .read<BoolToggle>()
                                    .setIsEnableNotification(b);

                                if (b) {
                                  fcmSubscribe();
                                } else {
                                  fcmUnSubscribe();
                                }
                              },
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                            )
                          : SwitchListTile(
                              title: Text(
                                'Notifications',
                                style: Theme.of(context).textTheme.button,
                              ),
                              value: false,
                              onChanged: (b) {
                                context
                                    .read<BoolToggle>()
                                    .setIsEnableNotification(b);

                                if (b) {
                                  fcmSubscribe();
                                } else {
                                  fcmUnSubscribe();
                                }
                              },
                              activeColor:
                                  Theme.of(context).colorScheme.secondary,
                            );
                    })
                  ],
                ),
              ),
            ));
          },
        ));
  }
}

class CustomShapeBorder extends ContinuousRectangleBorder {
  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    final double innerCircleRadius = 150.0;

    Path path = Path();
    path.lineTo(0, rect.height);
    path.quadraticBezierTo(rect.width / 2 - (innerCircleRadius / 2) - 30,
        rect.height + 15, rect.width / 2 - 75, rect.height + 50);
    path.cubicTo(
        rect.width / 2 - 40,
        rect.height + innerCircleRadius - 40,
        rect.width / 2 + 40,
        rect.height + innerCircleRadius - 40,
        rect.width / 2 + 75,
        rect.height + 50);
    path.quadraticBezierTo(rect.width / 2 + (innerCircleRadius / 2) + 30,
        rect.height + 15, rect.width, rect.height);
    path.lineTo(rect.width, 0.0);
    path.close();

    return path;
  }
}

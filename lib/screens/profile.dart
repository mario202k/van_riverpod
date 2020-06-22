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
import 'package:vanevents/screens/model_body.dart';
import 'package:vanevents/screens/model_screen.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';
import 'package:vanevents/shared/topAppBar.dart';

class Profil extends StatefulWidget with NavigationStates {
  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> with SingleTickerProviderStateMixin{
  Future<List<Ticket>> futureTickets;
  bool notification = true;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  TabController tabController;



  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2,vsync: this);
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

  void showDialogGenresEtTypes(BuildContext context, List userGenres,List userTypes,int indexStart) {
    List<Widget> containersAlertDialog =[
      genreAlertDialog(context),typeAlertDialog(context)
    ];
    List<Widget> containersCupertino =[
      genreCupertino(context),typeCupertino(context)
    ];

    context.read<BoolToggle>().initGenre();
    for (int i = 0; i < userGenres.length; i++) {
      if (context.read<BoolToggle>().genre.containsKey(userGenres[i])) {
        context.read<BoolToggle>().modificationGenre(userGenres[i]);
      }
    }

    context.read<BoolToggle>().initType();
    for (int i = 0; i < userTypes.length; i++) {
      if (context.read<BoolToggle>().type.containsKey(userTypes[i])) {
        context.read<BoolToggle>().modificationType(userTypes[i]);
      }
    }

    tabController.animateTo(indexStart);


    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Platform.isAndroid
          ? AlertDialog(
              title: Container(
                color: Theme.of(context).colorScheme.primary,
                child: TabBar(
                    tabs: <Widget>[
                  Tab(
                    text: 'Genres',
                  ),
                  Tab(
                    text: 'Types',
                  )
                ],
                  controller: tabController,
                ),
              ),
              content: SizedBox(
                height: 450,
                width: double.maxFinite,
                child: TabBarView(
                  controller: tabController,
                    children: containersAlertDialog),
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
                    context
                        .read<FirestoreDatabase>()
                        .updateUserType(context.read<BoolToggle>().type);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          : CupertinoAlertDialog(
              title: Container(
                color: Theme.of(context).colorScheme.primary,
                child: TabBar(
                    tabs: <Widget>[
                      Tab(
                        text: 'Genres',
                      ),
                      Tab(
                        text: 'Types',
                      )
                    ],
                  controller: tabController,
                ),
              ),
              content: SizedBox(
                height: 450,
                child: TabBarView(
                    controller: tabController,
                    children: containersCupertino),
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
                    context
                        .read<FirestoreDatabase>()
                        .updateUserType(context.read<BoolToggle>().type);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
    );
  }

  SizedBox genreAlertDialog(BuildContext context) {
    return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                  itemCount:
                  Provider.of<BoolToggle>(context, listen: false).genre.keys.length,
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
            );
  }

  Widget genreCupertino(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
                children: Provider.of<BoolToggle>(context, listen: false)
                    .genre
                    .keys
                    .map((e) => Consumer<BoolToggle>(
                  builder: (BuildContext context, BoolToggle boolToggle,
                      Widget child) {
                    return CheckboxListTile(
                      onChanged: (bool val) =>
                          boolToggle.modificationGenre(e),
                      value: context.watch<BoolToggle>().genre[e],
                      activeColor:
                      Theme.of(context).colorScheme.primary,
                      title: Text(e),
                    );
                  },
                ))
                    .toList(),
              ),
    );
  }

  Widget typeCupertino(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
                children: Provider.of<BoolToggle>(context, listen: false)
                    .type
                    .keys
                    .map((e) => Consumer<BoolToggle>(
                  builder: (BuildContext context, BoolToggle boolToggle,
                      Widget child) {
                    return CheckboxListTile(
                      onChanged: (bool val) =>
                          boolToggle.modificationType(e),
                      value: context.watch<BoolToggle>().type[e],
                      activeColor: Theme.of(context).colorScheme.primary,
                      title: Text(e),
                    );
                  },
                ))
                    .toList(),
              ),
    );
  }

  SizedBox typeAlertDialog(BuildContext context) {
    return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                  itemCount:
                  Provider.of<BoolToggle>(context, listen: false).type.keys.length,
                  itemBuilder: (context, index) {
                    List<String> str =
                        context.read<BoolToggle>().type.keys.toList();

                    return Consumer<BoolToggle>(
                      builder: (BuildContext context, BoolToggle boolToggle,
                          Widget child) {
                        return CheckboxListTile(
                          onChanged: (bool val) =>
                              boolToggle.modificationType(str[index]),
                          value: context.watch<BoolToggle>().type[str[index]],
                          activeColor: Theme.of(context).colorScheme.primary,
                          title: Text(str[index]),
                        );
                      },
                    );
                  }),
            );
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context, listen: false);

    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    futureTickets = db.futureTicketParticipation();
    return Padding(
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
                onPressed: () => showDialogGenresEtTypes(
                    context,
                    context.read<User>().genres != null
                        ? context.read<User>().genres.toList()
                        : [],context.read<User>().types != null
                    ? context.read<User>().types.toList()
                    : [],0)
            ),
          ),
          Provider.of<User>(context).genres != null
              ? Column(
            children: Provider.of<User>(context)
                .genres
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
          )
              : SizedBox(),
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
                onPressed: () => showDialogGenresEtTypes(
                    context,
                    context.read<User>().genres != null
                        ? context.read<User>().genres.toList()
                        : [],context.read<User>().types != null
                    ? context.read<User>().types.toList()
                    : [],1)
            ),
          ),
          Provider.of<User>(context).types != null
              ? Column(
            children: Provider.of<User>(context)
                .types
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
          )
              : SizedBox(),
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
    );
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

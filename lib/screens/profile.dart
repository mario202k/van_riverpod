import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/models/myUser.dart';
import 'package:vanevents/models/ticket.dart';
import 'package:vanevents/provider/provider.dart';

class Profil extends HookWidget with NavigationStates {
  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  void fcmSubscribe() {
    firebaseMessaging.subscribeToTopic('VanEvent');
  }

  void fcmUnSubscribe() {
    firebaseMessaging.unsubscribeFromTopic('VanEvent');
  }

  void showDialogGenresEtTypes(
      BuildContext context, List userGenres, List userTypes, int indexStart) {
    final tabController = useTabController(initialLength: 2);
    List<Widget> containersAlertDialog = [
      genreAlertDialog(context),
      typeAlertDialog(context)
    ];
    List<Widget> containersCupertino = [
      genreCupertino(context),
      typeCupertino(context)
    ];
    context.read(boolToggleProvider).initGenre();
    for (int i = 0; i < userGenres.length; i++) {
      if (context.read(boolToggleProvider).genre.containsKey(userGenres[i])) {
        context.read(boolToggleProvider).modificationGenre(userGenres[i]);
      }
    }

    context.read(boolToggleProvider).initType();
    for (int i = 0; i < userTypes.length; i++) {
      if (context.read(boolToggleProvider).type.containsKey(userTypes[i])) {
        context.read(boolToggleProvider).modificationType(userTypes[i]);
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
                    controller: tabController, children: containersAlertDialog),
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
                    context.read(firestoreDatabaseProvider).updateMyUserGenre(
                        context.read(boolToggleProvider).genre);
                    context.read(firestoreDatabaseProvider).updateMyUserType(
                        context.read(boolToggleProvider).type);
                    Navigator.of(context).pop();

                    // context.read<FirestoreDatabase>().updateUserLieu(context.read(boolToggleProvider).)
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
                    controller: tabController, children: containersCupertino),
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
                    context.read(firestoreDatabaseProvider).updateMyUserGenre(
                        context.read(boolToggleProvider).genre);
                    context.read(firestoreDatabaseProvider).updateMyUserType(
                        context.read(boolToggleProvider).type);
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
          itemCount: context.read(boolToggleProvider).genre.keys.length,
          itemBuilder: (context, index) {
            List<String> str =
                context.read(boolToggleProvider).genre.keys.toList();

            return CheckboxListTile(
              onChanged: (bool val) => context
                  .read(boolToggleProvider)
                  .modificationGenre(str[index]),
              value: useProvider(boolToggleProvider).genre[str[index]],
              activeColor: Theme.of(context).colorScheme.primary,
              title: Text(str[index]),
            );
          }),
    );
  }

  Widget genreCupertino(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: context
            .read(boolToggleProvider)
            .genre
            .keys
            .map((e) => CheckboxListTile(
                  onChanged: (bool val) =>
                      context.read(boolToggleProvider).modificationGenre(e),
                  value: useProvider(boolToggleProvider).genre[e],
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text(e),
                ))
            .toList(),
      ),
    );
  }

  Widget typeCupertino(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: context
            .read(boolToggleProvider)
            .type
            .keys
            .map((e) => CheckboxListTile(
                  onChanged: (bool val) =>
                      context.read(boolToggleProvider).modificationType(e),
                  value: useProvider(boolToggleProvider).type[e],
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text(e),
                ))
            .toList(),
      ),
    );
  }

  SizedBox typeAlertDialog(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
          itemCount: context.read(boolToggleProvider).type.keys.length,
          itemBuilder: (context, index) {
            List<String> str =
                context.read(boolToggleProvider).type.keys.toList();

            return CheckboxListTile(
              onChanged: (bool val) =>
                  context.read(boolToggleProvider).modificationType(str[index]),
              value: useProvider(boolToggleProvider).type[str[index]],
              activeColor: Theme.of(context).colorScheme.primary,
              title: Text(str[index]),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notification = useProvider(notificationProvider);

    final MyUser user = useProvider(myUserProvider);

    final db = useProvider(firestoreDatabaseProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              user.nom ?? 'Anonymous',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Divider(),
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
            future: db.futureTicketParticipation(),
            builder: (context, async) {
              if (async.hasError) {
                print(async.error);
                return Center(
                  child: Text(
                    'Erreur de connexion',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                );
              } else if (async.connectionState == ConnectionState.waiting) {
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
                        separatorBuilder: (context, index) => SizedBox(
                          width: 12,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CachedNetworkImage(
                              imageUrl: tickets[index].imageUrl,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height: 84,
                                width: 84,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(84)),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor:
                                    Theme.of(context).colorScheme.primary,
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
          Divider(),
          ListTile(
            leading: Text(
              'Genres:',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: IconButton(
                icon: Icon(FontAwesomeIcons.pencilAlt),
                onPressed: () => showDialogGenresEtTypes(
                    context,
                    context.read(myUserProvider).genres != null
                        ? context.read(myUserProvider).genres.toList()
                        : [],
                    context.read(myUserProvider).types != null
                        ? context.read(myUserProvider).types.toList()
                        : [],
                    0)),
          ),
          context.read(myUserProvider).genres != null
              ? Column(
                  children: context
                      .read(myUserProvider)
                      .genres
                      .map((e) => ListTile(
                            title: Text(
                              e ?? '',
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
          Divider(),
          ListTile(
            leading: Text(
              'Types:',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: IconButton(
                icon: Icon(FontAwesomeIcons.pencilAlt),
                onPressed: () => showDialogGenresEtTypes(
                    context,
                    context.read(myUserProvider).genres != null
                        ? context.read(myUserProvider).genres.toList()
                        : [],
                    context.read(myUserProvider).types != null
                        ? context.read(myUserProvider).types.toList()
                        : [],
                    1)),
          ),
          context.read(myUserProvider).types != null
              ? Column(
                  children: context
                      .read(myUserProvider)
                      .types
                      .map((e) => ListTile(
                            title: Text(
                              e ?? '',
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
          Divider(),
          ListTile(
            leading: Icon(FontAwesomeIcons.envelope,
                color: Theme.of(context).colorScheme.onBackground),
            title: Text(
              user.email ?? 'Anonymous@van-Event.fr',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          notification.when(
              data: (val) {
                return SwitchListTile(
                  title: Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.button,
                  ),
                  value: val,
                  onChanged: (b) {
                    context.read(boolToggleProvider).setIsEnableNotification(b);

                    if (b) {
                      fcmSubscribe();
                    } else {
                      fcmUnSubscribe();
                    }
                  },
                  activeColor: Theme.of(context).colorScheme.secondary,
                );
              },
              loading: null,
              error: null),
          SwitchListTile(
            title: Text(
              'Notifications',
              style: Theme.of(context).textTheme.subtitle2,
            ),
            value: useProvider(boolToggleProvider).isEnableNotification,
            onChanged: (b) {
              context.read(boolToggleProvider).setIsEnableNotification(b);

              if (b) {
                fcmSubscribe();
              } else {
                fcmUnSubscribe();
              }
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
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

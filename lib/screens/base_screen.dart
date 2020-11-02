import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/models/myUser.dart';
import 'package:vanevents/provider/provider.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/screens/model_body.dart';
import 'package:vanevents/screens/model_screen.dart';
import 'package:vanevents/services/firebase_cloud_messaging.dart';
import 'package:vanevents/shared/my_event_search_chat.dart';
import 'package:vanevents/shared/topAppBar.dart';
import 'package:vanevents/shared/user_search_chat.dart';

class BaseScreens extends HookWidget {
  final double maxSlide = 60.0;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    print('buildBaseScreens');
    final _animationController =
        useAnimationController(duration: Duration(milliseconds: 400),initialValue: 0.0);
    final db = context.read(firestoreDatabaseProvider);
    NotificationHandler().initializeFcmNotification(
        db.uid, context);

    return BlocBuilder<NavigationBloc, NavigationStates>(
        builder: (BuildContext context, NavigationStates state) {
      int i = 0;
      switch (state.toString()) {
        case 'HomeEvents':
          i = 0;
          break;
        case 'Chat':
          i = 1;
          break;
        case 'Billets':
          i = 2;
          break;
        case 'Profil':
          i = 3;
          break;
      }

      return ModelScreen(
        child: Stack(
          children: <Widget>[
            ModelBody(child: state as Widget),
            Align(
              alignment: Alignment.bottomCenter,
              child: CurvedNavigationBar(
                backgroundColor: Colors.transparent,
                index: i,
                color: Theme.of(context).colorScheme.primary,
                height: 45,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigationEvents.HomeEvents);
                      break;
                    case 1:
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigationEvents.Chat);
                      break;
                    case 2:
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigationEvents.Billets);
                      break;
                    case 3:
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigationEvents.Profil);
                      break;
                  }
                },
                items: <Widget>[
                  Icon(
                    FontAwesomeIcons.home,
                    size: 30,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Icon(
                    FontAwesomeIcons.comments,
                    size: 30,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Icon(
                    FontAwesomeIcons.ticketAlt,
                    size: 30,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  Icon(
                    FontAwesomeIcons.user,
                    size: 30,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
            TopAppBar(state.toString()),
            state.toString() == 'Chat'
                ? Positioned(
                    right: 15,
                    bottom: 60,
                    child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, _) {
                          return Container(
                            width: 120,
                            height: 120,
                            child: Stack(
                              overflow: Overflow.visible,
                              children: <Widget>[
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Transform.translate(
                                    offset: Offset(
                                        -maxSlide * _animationController.value,
                                        0),
                                    child: Transform.rotate(
                                      angle: _animationController.value *
                                          2.0 *
                                          math.pi,
                                      child: Transform.scale(
                                        scale: _animationController.value,
                                        child: FloatingActionButton(
                                            heroTag: 1,
                                            child: Icon(
                                              FontAwesomeIcons.userFriends,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                            ),
                                            onPressed: () async {
                                              final MyUser userFriend =
                                                  await showSearch(
                                                      context: context,
                                                      delegate: UserSearch());

                                              if (userFriend != null) {
                                                db
                                                    .creationChatRoom(
                                                        userFriend)
                                                    .then((chatId) {
                                                  db
                                                      .getMyChat(chatId)
                                                      .then((myChat) {
                                                    db
                                                        .chatMyUsersFuture(
                                                            myChat)
                                                        .then((users) {
                                                      MyUser friend;
                                                      if (!myChat.isGroupe) {
                                                        friend =
                                                            users.firstWhere(
                                                                (user) =>
                                                                    user.id !=
                                                                    db.uid);
                                                      }
                                                      ExtendedNavigator.of(
                                                              context)
                                                          .push(Routes.chatRoom,
                                                              arguments:
                                                                  ChatRoomArguments(
                                                                      chatId:
                                                                          chatId));
                                                    }).catchError((onError) {
                                                      print(onError);
                                                    });
                                                  }).catchError((onError) {
                                                    print(onError);
                                                  });
                                                }).catchError((onError) {
                                                  print(onError);
                                                });
                                              }
                                              //ExtendedNavigator.of(context).pushNamed(Routes.uploadEvent),
                                            }),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Transform.translate(
                                    offset: Offset(0,
                                        -maxSlide * _animationController.value),
                                    child: Transform.rotate(
                                      angle: _animationController.value *
                                          2.0 *
                                          math.pi,
                                      child: Transform.scale(
                                        scale: _animationController.value,
                                        child: FloatingActionButton(
                                            heroTag: 2,
                                            child: Icon(
                                              FontAwesomeIcons.users,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                            ),
                                            onPressed: () async {
                                              await showSearch(
                                                      context: context,
                                                      delegate: MyEventSearch())
                                                  .then((myEvent) async {
                                                if (myEvent != null) {
                                                  firebaseMessaging
                                                      .subscribeToTopic(
                                                          myEvent.chatId);
                                                  await db
                                                      .addAmongGroupe(
                                                          myEvent.chatId)
                                                      .then((_) {
                                                    db
                                                        .getMyChat(
                                                            myEvent.chatId)
                                                        .then((myChat) {
                                                      db
                                                          .chatMyUsersFuture(
                                                              myChat)
                                                          .then((users) {
                                                        MyUser friend;
                                                        if (!myChat.isGroupe) {
                                                          friend =
                                                              users.firstWhere(
                                                                  (user) =>
                                                                      user.id !=
                                                                      db.uid);
                                                        }
                                                        ExtendedNavigator.of(
                                                                context)
                                                            .push(
                                                                Routes.chatRoom,
                                                                arguments:
                                                                    ChatRoomArguments(
                                                                        chatId:
                                                                            myChat.id));
                                                      });
                                                    });
                                                  });
                                                }
                                              });
                                            }
                                            //ExtendedNavigator.of(context).pushNamed(Routes.uploadEvent),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: FloatingActionButton(
                                      heroTag: 3,
                                      child: Icon(
                                        FontAwesomeIcons.search,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                      ),
                                      onPressed: () {
                                        //NotificationHandler().showOverlayWindow();
                                        _animationController.isCompleted
                                            ? _animationController.reverse()
                                            : _animationController.forward();
                                      }
                                      //ExtendedNavigator.of(context).pushNamed(Routes.uploadEvent),
                                      ),
                                ),
                              ],
                            ),
                          );
                        }),
                  )
                : SizedBox(),
            Visibility(
              visible: state.toString() == 'Billets' ? true : false,
              child: Positioned(
                  right: 15,
                  bottom: 60,
                  child: FloatingActionButton(
                    child: Icon(
                      FontAwesomeIcons.car,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    onPressed: () {
                      ExtendedNavigator.of(context).push(Routes.transport);
                    },
                  )),
            )
          ],
        ),
      );
    });
  }
}

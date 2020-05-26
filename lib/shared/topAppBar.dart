import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/custom_drawer.dart';
import 'package:vanevents/shared/my_event_search_chat.dart';
import 'package:vanevents/shared/user_search_chat.dart';

class TopAppBar extends StatefulWidget {
  final String title;
  final bool isMenu;
  final double widthContainer;
  final double heightContainer = 120;

  TopAppBar(this.title, this.isMenu, this.widthContainer);

  @override
  _TopAppBarState createState() => _TopAppBarState();
}

class _TopAppBarState extends State<TopAppBar> with TickerProviderStateMixin {
  bool startAnimation = false;
  AnimationController animationController;
  bool disposed = false;
  FirestoreDatabase db;
  User user;

  _afterLayout(_) {
    setState(() {
      startAnimation = !startAnimation;
    });
  }

  @override
  void initState() {
    if (widget.isMenu) {
      animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 400));
    }
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
  }

  @override
  void dispose() {
    if (widget.isMenu) {
      disposed = true;
      if (animationController != null) animationController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMenu) {
      db = Provider.of<FirestoreDatabase>(context, listen: false);
      user = Provider.of<User>(context, listen: false);
      final toggle = Provider.of<ValueNotifier<bool>>(context, listen: false);

      toggle.addListener(() {
        if (!disposed) {
          if (toggle.value) {
            animationController.forward();
          } else {
            animationController.reverse();
          }
        }
      });
    }

    return Stack(
      children: <Widget>[
        ClipPath(
          clipper:
              widget.title == 'Chat' ? ClippingChatClass() : ClippingClass(),
          child: AnimatedContainer(
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
            height: startAnimation ? widget.heightContainer : 0,
            width: widget.widthContainer,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary
              ]),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                IconButton(
                  icon: widget.isMenu
                      ?
                      SizedBox()
//                  AnimatedIcon(
//                          icon: AnimatedIcons.menu_arrow,
//                          progress: animationController,
//                          color: Theme.of(context).colorScheme.onSecondary,
//                        )
                      : Icon(
                          Platform.isAndroid
                              ? Icons.arrow_back
                              : Icons.arrow_back_ios,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  onPressed: () {
                    widget.isMenu ? CustomDrawer.of(context).open() : Navigator.pop(context);
                  },
                ),
                Expanded(
                  child:
//                Text(
//                  widget.title,
//                  style: Theme.of(context).textTheme.headline6,
//                ),
                SizedBox()
                ),
                widget.title == 'Chat'
                    ? PopupMenuButton<String>(
                        color: Theme.of(context).colorScheme.primary,
                        onSelected: (String value) async {
                          switch (value) {
                            case 'Value1':
                              final User userFriend = await showSearch(
                                  context: context,
                                  delegate: UserSearch(UserBlocSearchName()));

                              if (userFriend != null) {
                                context.read<FirestoreDatabase>().creationChatRoom(userFriend, user).then((chatId) {
                                  db.getMyChat(chatId).then((myChat) {

                                    db.chatUsersFuture(myChat).then((users){

                                      User friend;
                                      if(!myChat.isGroupe){
                                        friend = users.firstWhere((user) => user.id != db.uid);
                                      }
                                      ExtendedNavigator.of(context).pushNamed(
                                          Routes.chatRoom,
                                          arguments: ChatRoomArguments(
                                              myChat: myChat, membres: users, friend: friend));
                                    });
                                  });
                                });


//                                db
//                                    .creationChatRoom(userFriend, user)
//                                    .then((chatId) {
//                                  db.getMyChat(chatId).then((myChat) {
//                                    ExtendedNavigator.of(context).pushNamed(
//                                        Routes.chatRoom,
//                                        arguments: ChatRoomArguments(
//                                            myChat: myChat,
//                                            idFriend: userFriend.id,
//                                            membre: {
//                                              userFriend.imageUrl:
//                                                  userFriend.nom
//                                            }));
//                                  });
//                                });
                              }

                              break;
                            case 'Value2':
                              await showSearch(
                                      context: context,
                                      delegate: MyEventSearch(
                                          MyEventBlocSearchName()))
                                  .then((myEvent) async {
                                if (myEvent != null) {
                                  await db
                                      .addAmongGroupe(myEvent.chatId, user.nom,
                                          user.imageUrl)
                                      .then((_) {
                                    db.getMyChat(myEvent.chatId).then((myChat) {

                                      db.chatUsersFuture(myChat).then((users){

                                        User friend;
                                        if(!myChat.isGroupe){
                                          friend = users.firstWhere((user) => user.id != db.uid);
                                        }
                                        ExtendedNavigator.of(context).pushNamed(
                                            Routes.chatRoom,
                                            arguments: ChatRoomArguments(
                                                myChat: myChat, membres: users, friend: friend));
                                      });



                                    });
                                  });
                                }
                              });

                              break;
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Icon(
                            FontAwesomeIcons.search,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'Value1',
                            child: Text(
                              'Par Nom',
                              style: Theme.of(context).textTheme.button,
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Value2',
                            child: Text(
                              'Groupes',
                              style: Theme.of(context).textTheme.button,
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
        widget.title == 'Profil'
            ? FractionalTranslation(
                translation: Offset(
                  0.0,
                  .3,
                ),
                child: Align(
                  alignment: FractionalOffset(0.5, 0.0),
                  child: CircleAvatar(
                    radius: 55,

                    backgroundColor: Theme.of(context).colorScheme.secondary,

                    child: CircleAvatar(
                      radius: 50,

                      backgroundImage: NetworkImage(user.imageUrl) ,

                    ),
                  ),
                ))
            : SizedBox(),
      ],
    );
  }
}

class ClippingClassBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height * 0.7);

    //path.lineTo(0.0, size.height);

    path.lineTo(size.width, 0);

    path.lineTo(size.width, size.height);

    path.lineTo(0.0, size.height);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class ClippingClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);

    path.lineTo(size.width, size.height * 0.3);

    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class ClippingChatClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);

    path.lineTo(size.width * 0.85, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.97, size.height * 0.95, size.width, size.height * .6);
    path.lineTo(size.width, size.height);

    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

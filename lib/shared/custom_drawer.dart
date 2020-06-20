import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';
import 'package:vanevents/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/repository/user_repository.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/services/firestore_database.dart';


class CustomDrawer extends StatefulWidget {
  final Widget child;

  const CustomDrawer({Key key, @required this.child}) : super(key: key);

  static CustomDrawerState of(BuildContext context) =>
      context.findAncestorStateOfType<CustomDrawerState>();

  @override
  CustomDrawerState createState() => CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  final double maxSlide = 300.0;
  AnimationController _animationController;
  bool _canBeDragged = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleDrawer() => _animationController.isCompleted ? close() : open();

  void _onDragEnd(DragEndDetails details) {
    if (_animationController.isDismissed || _animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= 365.0) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;
      _animationController.fling(velocity: visualVelocity);
    } else if (_animationController.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  void close() => _animationController.reverse();

  void open() => _animationController.forward();

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta / maxSlide;
      _animationController.value += delta;
    }
  }

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = _animationController.isDismissed;
    bool isDragCloseFromRight = _animationController.isCompleted;
    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_animationController.isCompleted) {
          close();
          return false;
        }
        return true;
      },
      child: GestureDetector(
//        onHorizontalDragStart: _onDragStart,
//        onHorizontalDragUpdate: _onDragUpdate,
//        onHorizontalDragEnd: _onDragEnd,
//        behavior: HitTestBehavior.translucent,
        //onTap: toggleDrawer,
        child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              return Stack(
                children: <Widget>[
                  Transform.translate(
                    offset:
                        Offset(maxSlide * (_animationController.value - 1), 0),
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(
                            math.pi / 2 * (1 - _animationController.value)),
                      alignment: Alignment.centerRight,
                      child: MyDrawer(),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(maxSlide * _animationController.value, 0),
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(
                            -math.pi * 0.9 * (_animationController.value) / 2),
                      alignment: Alignment.centerLeft,
                      child: widget.child,
                    ),
                  ),
                  Positioned(
                    top: 12.0 + MediaQuery.of(context).padding.top,
                    left: 4.0 + _animationController.value * maxSlide,
                    child: IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: toggleDrawer,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    top: 16.0 + MediaQuery.of(context).padding.top,
                    left: 50+_animationController.value *
                        MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    child: BlocBuilder<NavigationBloc, NavigationStates>(
                        builder: (BuildContext context, NavigationStates state) {
                      return Text(
                        state.toString(),
                        style: Theme.of(context).textTheme.headline6,
                        textAlign: TextAlign.start,
                      );
                    }),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 300,
        height: double.infinity,
        child: Material(
          color: Theme.of(context).colorScheme.secondary,
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: 30, left: 15, right: 15, bottom: 80),
                      child: Stack(
                        children: <Widget>[
                          FractionalTranslation(
                            translation: Offset(0.0, 2.1),
                            child: RawMaterialButton(
                              onPressed: () {
                                BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.Profil);

                                CustomDrawer.of(context).close();
                              },
                              elevation: 10,
                              shape: StadiumBorder(),
                              child: Container(
                                padding:
                                    EdgeInsets.only(left: 20.0, right: 20.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  height: 50,
                                  child: Center(
                                    child:

                                    Consumer<User>(
                                      builder: (context, user, child) {
                                        return Text(
                                          user.nom ?? '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                              alignment: FractionalOffset(0.5, 0.0),
                              child: CircleAvatar(
                                radius: 59,
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                child: Consumer<User>(
                                  builder: (context, user, child) {
                                    return user.imageUrl != null
                                        ? CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(user.imageUrl),
                                            radius: 57,
                                            child: RawMaterialButton(
                                              shape: const CircleBorder(),
                                              splashColor:
                                                  Colors.grey.withOpacity(0.4),
                                              onPressed: () {
                                                BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.Profil);
                                                CustomDrawer.of(context)
                                                    .close();
                                              },
                                              padding:
                                                  const EdgeInsets.all(57.0),
                                            ),
                                          )
                                        : SizedBox();
                                  },
                                ),
                              )),
                        ],
                        //mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 60,left: 15,right: 15),
                      child: SizedBox(
                        height: 340,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(25),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                              ),
                              child: ListTile(
                                title: Text(
                                  'Chat',
                                  style: Theme.of(context).textTheme.button,
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.comments,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onTap: () {
                                  BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.Chat);
                                  CustomDrawer.of(context).close();
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(25),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                              ),
                              child: ListTile(
                                title: Text(
                                  'Mes billets',
                                  style: Theme.of(context).textTheme.button,
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.ticketAlt,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onTap: () {
                                  BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.Billets);
                                  CustomDrawer.of(context).close();
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(25),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                              ),
                              child: ListTile(
                                title: Text(
                                  'Inviter un ami',
                                  style: Theme.of(context).textTheme.button,
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.shareAlt,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(25),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                              ),
                              child: ListTile(
                                title: Text(
                                  'Paramètres',
                                  style: Theme.of(context).textTheme.button,
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.cog,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(25),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary,
                              ),
                              child: ListTile(
                                title: Text(
                                  'Admin Events',
                                  style: Theme.of(context).textTheme.button,
                                ),
                                leading: Icon(
                                  FontAwesomeIcons.userCog,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onTap: () {
                                  ExtendedNavigator.of(context)
                                      .pushNamed(Routes.adminEvents);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(25),
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                      child: ListTile(
                        title: Text(
                          "Se déconnecter",
                          style: Theme.of(context).textTheme.button,
                        ),
                        leading: Icon(
                          FontAwesomeIcons.signOutAlt,
                          size: 18,
                          color: Colors.white,
                        ),
                        onTap: () async {
                          context.read<FirestoreDatabase>().setInactive();
                          context.read<UserRepository>().signOut();
                          context.bloc<AuthenticationBloc>().add(AuthenticationLoggedOut());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ));
  }
}

import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/provider/provider.dart';
import 'package:vanevents/routing/route.gr.dart';

class CustomDrawer extends StatefulWidget {
  final Widget child;

  const CustomDrawer({Key key, @required this.child}) : super(key: key);

  static CustomDrawerState of(BuildContext context) =>
      context.findAncestorStateOfType<CustomDrawerState>();

  @override
  CustomDrawerState createState() => CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer>
    with WidgetsBindingObserver,SingleTickerProviderStateMixin {
  final double maxSlide = 300.0;
  AnimationController _animationController;
  bool _canBeDragged = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        context.read(firestoreDatabaseProvider).setInactive();
        break;
      case AppLifecycleState.resumed:
        context.read(firestoreDatabaseProvider).setOnline();
        break;
      case AppLifecycleState.inactive:
        context.read(firestoreDatabaseProvider).setInactive();
        break;
      case AppLifecycleState.detached:
        context.read(firestoreDatabaseProvider).setInactive();
        break;
    }
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
                    left: 50 +
                        _animationController.value *
                            MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    child: BlocBuilder<NavigationBloc, NavigationStates>(
                        builder:
                            (BuildContext context, NavigationStates state) {
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

class MyDrawer extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final myUserStream = context.read(streamMyUserProvider);
    final myUser = context.read(myUserProvider);
    final firestore = context.read(firestoreDatabaseProvider);

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
                                BlocProvider.of<NavigationBloc>(context)
                                    .add(NavigationEvents.Profil);

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
                                    child: myUserStream.when(
                                        data: (myUser) {
                                          return Text(myUser.nom ?? 'Anonymous',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ));
                                        },
                                        loading: () => Shimmer.fromColors(
                                              baseColor: Colors.white,
                                              highlightColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              child: Container(
                                                width: 220,
                                                height: 220,
                                                //color: Colors.white,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                25)),
                                                    color: Colors.white),
                                              ),
                                            ),
                                        error: (err, stack) => SizedBox())),
                              ),
                            ),
                          ),
                          Align(
                              alignment: FractionalOffset(0.5, 0.0),
                              child: CircleAvatar(
                                radius: 59,
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                child: myUserStream.when(
                                    data: (myUser) => CircleAvatar(
                                          backgroundImage: myUser.imageUrl !=
                                                  null
                                              ? NetworkImage(myUser.imageUrl)
                                              : AssetImage(
                                                  'assets/img/normal_user_icon.png'),
                                          radius: 57,
                                          child: RawMaterialButton(
                                            shape: const CircleBorder(),
                                            splashColor:
                                                Colors.grey.withOpacity(0.4),
                                            onPressed: () {
                                              BlocProvider.of<NavigationBloc>(
                                                      context)
                                                  .add(NavigationEvents.Profil);
                                              CustomDrawer.of(context).close();
                                            },
                                            padding: const EdgeInsets.all(57.0),
                                          ),
                                        ),
                                    loading: () => Shimmer.fromColors(
                                          baseColor: Colors.white,
                                          highlightColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          child: Container(
                                            width: 220,
                                            height: 220,
                                            //color: Colors.white,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25)),
                                                color: Colors.white),
                                          ),
                                        ),
                                    error: (err, stack) => SizedBox()),
                              )),
                        ],
                        //mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 60, left: 15, right: 15),
                      child: SizedBox(
                        height: 340,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Theme.of(context).colorScheme.primary,
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
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigationEvents.Chat);
                                  CustomDrawer.of(context).close();
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Theme.of(context).colorScheme.primary,
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
                                  BlocProvider.of<NavigationBloc>(context)
                                      .add(NavigationEvents.Billets);
                                  CustomDrawer.of(context).close();
                                },
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Theme.of(context).colorScheme.primary,
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
                                borderRadius: BorderRadius.circular(25),
                                color: Theme.of(context).colorScheme.primary,
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
                                onTap: () {
                                  ExtendedNavigator.of(context)
                                      .push(Routes.stripeProfile);
                                },
                              ),
                            ),
                            myUser.typeDeCompte == 1
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        'Admin Events',
                                        style:
                                            Theme.of(context).textTheme.button,
                                      ),
                                      leading: Icon(
                                        FontAwesomeIcons.userCog,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      onTap: () {
                                        ExtendedNavigator.of(context)
                                            .push(Routes.adminEvents);
                                      },
                                    ),
                                  )
                                : myUser.typeDeCompte == 0
                                    ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            'Admin Organisateur',
                                            style: Theme.of(context)
                                                .textTheme
                                                .button,
                                          ),
                                          leading: Icon(
                                            FontAwesomeIcons.userCog,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          onTap: () {
                                            ExtendedNavigator.of(context).push(
                                                Routes.adminOrganisateurs);
                                          },
                                        ),
                                      )
                                    : SizedBox(),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Theme.of(context).colorScheme.primary,
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
                          firestore.setInactive();
                          context
                              .bloc<AuthenticationBloc>()
                              .add(AuthenticationLoggedOut());
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

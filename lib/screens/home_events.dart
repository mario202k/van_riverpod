import 'dart:io';
import 'package:async/async.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';

class HomeEvents extends StatefulWidget with NavigationStates {
  const HomeEvents();

  @override
  _HomeEventsState createState() => _HomeEventsState();
}

class _HomeEventsState extends State<HomeEvents>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  void showDialogGenresEtTypes(
      BuildContext context, List userGenres, List userTypes, int indexStart) {
    List<Widget> containersAlertDialog = [
      genreAlertDialog(context),
      typeAlertDialog(context)
    ];
    List<Widget> containersCupertino = [
      genreCupertino(context),
      typeCupertino(context)
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
            List<String> str = context.read<BoolToggle>().genre.keys.toList();

            return Consumer<BoolToggle>(
              builder:
                  (BuildContext context, BoolToggle boolToggle, Widget child) {
                return CheckboxListTile(
                  onChanged: (bool val) =>
                      boolToggle.modificationGenre(str[index]),
                  value: context.watch<BoolToggle>().genre[str[index]],
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
      physics: ClampingScrollPhysics(),
      child: Column(
        children: Provider.of<BoolToggle>(context, listen: false)
            .genre
            .keys
            .map((e) => Consumer<BoolToggle>(
                  builder: (BuildContext context, BoolToggle boolToggle,
                      Widget child) {
                    return CheckboxListTile(
                      onChanged: (bool val) => boolToggle.modificationGenre(e),
                      value: Provider.of<BoolToggle>(context).genre[e],
                      activeColor: Theme.of(context).colorScheme.primary,
                      title: Text(e),
                    );
                  },
                ))
            .toList(),
      ),
    );
  }

  Column typeCupertino(BuildContext context) {
    return Column(
      children: Provider.of<BoolToggle>(context, listen: false)
          .type
          .keys
          .map((e) => Consumer<BoolToggle>(
                builder: (BuildContext context, BoolToggle boolToggle,
                    Widget child) {
                  return CheckboxListTile(
                    onChanged: (bool val) => boolToggle.modificationType(e),
                    value: context.watch<BoolToggle>().type[e],
                    activeColor: Theme.of(context).colorScheme.primary,
                    title: Text(e),
                  );
                },
              ))
          .toList(),
    );
  }

  SizedBox typeAlertDialog(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: ListView.builder(
          itemCount:
              Provider.of<BoolToggle>(context, listen: false).type.keys.length,
          itemBuilder: (context, index) {
            List<String> str = context.read<BoolToggle>().type.keys.toList();

            return Consumer<BoolToggle>(
              builder:
                  (BuildContext context, BoolToggle boolToggle, Widget child) {
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
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    final eventsAffiche = db.eventsStreamAffiche();
    User user = Provider.of<User>(context);

    final StreamZip<List<MyEvent>> streamZipMaSelection = StreamZip([
      db.eventStreamMaSelectionGenre(user.genres != null ? user.genres : []),
      db.eventStreamMaSelectionType(user.types != null ? user.types : [])
    ]);

    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            StreamBuilder<List<MyEvent>>(
                stream: eventsAffiche,
                builder: (context, AsyncSnapshot snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.secondary)),
                    );
                  } else if (snap.hasError) {
                    print(snap.error.toString());


                    return Center(
                      child: Text(
                        'Erreur de connexion',
                        style: Theme.of(context).textTheme.display1,
                      ),
                    );
                  } else if (snap.data.length == 0) {
                    return Center(
                      child: Text(
                        'Pas d\'évenements',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    );
                  }
                  List<MyEvent> events = List<MyEvent>();
                  events.addAll(snap.data);

                  return events.isNotEmpty
                      ? SizedBox(
                    height: orientation == Orientation.portrait
                        ? size.height / 1.8
                        : size.height,
                    child: Swiper(
                      physics: ClampingScrollPhysics(),
                      itemBuilder:
                          (BuildContext context, int index) {
                        return events[index].imageFlyerUrl != null
                            ? CachedNetworkImage(
                          imageUrl:
                          events[index].imageFlyerUrl,
                          imageBuilder:
                              (context, imageProvider) =>
                              Container(
                                width: orientation ==
                                    Orientation.portrait
                                    ? size.width
                                    : 400,
                                height: orientation ==
                                    Orientation.portrait
                                    ? size.height / 1.5
                                    : size.height,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.fill),
                                    borderRadius:
                                    BorderRadius.all(
                                        Radius.circular(25)),
                                    color: Colors.white),
                              ),
                          placeholder: (context, url) =>
                              Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: Theme.of(context)
                                    .colorScheme
                                    .primary,
                                child: Container(
                                  width: orientation ==
                                      Orientation.portrait
                                      ? size.width
                                      : 400,
                                  height: orientation ==
                                      Orientation.portrait
                                      ? size.height / 1.5
                                      : size.height,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius.circular(
                                              25)),
                                      color: Colors.white),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) =>
                              Icon(Icons.error),
                        )
                            : SizedBox();
                      },
                      itemCount: events.length,
                      pagination: SwiperPagination(),
                      control: SwiperControl(
                        color:
                        Theme.of(context).colorScheme.primary,
                      ),
                      onTap: (index) {
                        ExtendedNavigator.of(context).pushNamed(
                            Routes.details,
                            arguments: DetailsArguments(
                                event: events.elementAt(index)));
                      },
                      itemWidth: orientation == Orientation.portrait
                          ? size.width
                          : 400,
                      itemHeight:
                      orientation == Orientation.portrait
                          ? size.height / 1.5
                          : size.height,
                      layout: SwiperLayout.TINDER,
                      loop: true,
                      outer: false,
                      autoplay: true,
                      autoplayDisableOnInteraction: false,
                    ),
                  )
                      : Center(
                    child: Text(
                      'Pas d\'évenements',
                      style: Theme.of(context).textTheme.button,
                    ),
                  );
                }),
            Text(
              'À l\'affiche',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
        Divider(

        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Ma selection'),
            IconButton(
                icon: Icon(FontAwesomeIcons.pencilAlt),
                onPressed: () => showDialogGenresEtTypes(
                    context,
                    context.read<User>().genres != null
                        ? context.read<User>().genres.toList()
                        : [],
                    context.read<User>().types != null
                        ? context.read<User>().types.toList()
                        : [],
                    0)),
          ],
        ),
        StreamBuilder<List<List<MyEvent>>>(
            stream: streamZipMaSelection,
            builder: (context, AsyncSnapshot snap) {

              if (snap.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary)),
                );
              } else if (snap.hasError) {
                print(snap.error.toString());

                return Center(
                  child: Text(
                    'Erreur de connexion',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                );
              } else if (snap.data[0].length == 0 &&
                  snap.data[1].length == 0) {
                return Center(
                  child: Text(
                    'Pas d\'évenements',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                );
              }

              List<MyEvent> events = List<MyEvent>();
              events.addAll(snap.data[0]);
              events.addAll(snap.data[1]);

              for (int i = 0; i < events.length; i++) {
                //doublon
                for (int j = 0; j < events.length; j++) {
                  if (j != i && events[j].id == events[i].id) {
                    events.removeAt(j);
                  }
                }
              }

              return SizedBox(
                height: 200,
                child: Center(
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => ExtendedNavigator.of(context)
                              .pushNamed(Routes.details,
                              arguments: DetailsArguments(
                                  event: events.elementAt(index))),
                          child: CachedNetworkImage(
                            imageUrl: events[index].imageFlyerUrl,
                            imageBuilder: (context, imageProvider) =>
                                Container(
                                  width: 220,
                                  height: 200,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25)),
                                      color: Colors.white),
                                ),
                            placeholder: (context, url) =>
                                Shimmer.fromColors(
                                  baseColor: Colors.white,
                                  highlightColor:
                                  Theme.of(context).colorScheme.primary,
                                  child: Container(
                                    width: 220,
                                    height: 200,
                                    //color: Colors.white,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        color: Colors.white),
                                  ),
                                ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        );
                      }),
                ),
              );
            }),
        Divider(

        ),
        Text('La selection van E.vents'),
//                ListView.separated(
//    separatorBuilder: (context,index)=>SizedBox(width: 12,),
//    scrollDirection: Axis.horizontal,
//    itemCount: tickets.length,
//    itemBuilder: (context, index) {})
      ],
    );
  }
}

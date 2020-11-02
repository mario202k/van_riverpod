import 'dart:io';

import 'package:async/async.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/models/myUser.dart';
import 'package:vanevents/provider/provider.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/shared/lieuQuandAlertDialog.dart';

class HomeEvents extends HookWidget with NavigationStates {
  void showDialogGenresEtTypes(BuildContext context, List lieu, List quand,
      List userGenres, List userTypes, int indexStart) {
    final tabController = useTabController(initialLength: 3);
    List<Widget> containersAlertDialog = [
      lieuQuandAlertDialog(context),
      genreAlertDialog(context),
      typeAlertDialog(context)
    ];
    List<Widget> containersCupertino = [
      lieuQuandAlertDialog(context),
      genreCupertino(context),
      typeCupertino(context)
    ];

    context.read(boolToggleProvider).initLieuEtLieu();

    modificationLieuEtDate(context, lieu, quand);

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
                      text: 'Lieu/Quand',
                    ),
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

                    context
                        .read(firestoreDatabaseProvider)
                        .updateMyUserLieuQuand(
                            context.read(boolToggleProvider).lieu,
                            context.read(boolToggleProvider).selectedAdress,
                            context.read(boolToggleProvider).zone == 0
                                ? 25
                                : context.read(boolToggleProvider).zone == 1 / 3
                                    ? 50
                                    : context.read(boolToggleProvider).zone ==
                                            2 / 3
                                        ? 100
                                        : null,
                            context.read(boolToggleProvider).quand,
                            context.read(boolToggleProvider).date);
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
                      text: 'Lieu/Quand',
                    ),
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
              value: context.read(boolToggleProvider).genre[str[index]],
              activeColor: Theme.of(context).colorScheme.primary,
              title: Text(str[index]),
            );
          }),
    );
  }

  Widget lieuQuandAlertDialog(BuildContext context) {
    return LieuQuandAlertDialog();
  }

  Widget genreCupertino(BuildContext context) {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
        children: context
            .read(boolToggleProvider)
            .genre
            .keys
            .map((e) => CheckboxListTile(
                  onChanged: (bool val) =>
                      context.read(boolToggleProvider).modificationGenre(e),
                  value: context.read(boolToggleProvider).genre[e],
                  activeColor: Theme.of(context).colorScheme.primary,
                  title: Text(e),
                ))
            .toList(),
      ),
    );
  }

  Column typeCupertino(BuildContext context) {
    return Column(
      children: context
          .read(boolToggleProvider)
          .type
          .keys
          .map((e) => CheckboxListTile(
                onChanged: (bool val) =>
                    context.read(boolToggleProvider).modificationType(e),
                value: context.read(boolToggleProvider).type[e],
                activeColor: Theme.of(context).colorScheme.primary,
                title: Text(e),
              ))
          .toList(),
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
              value: context.read(boolToggleProvider).type[str[index]],
              activeColor: Theme.of(context).colorScheme.primary,
              title: Text(str[index]),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('buildhome_events');
    final db = context.read(firestoreDatabaseProvider);
    final eventsAffiche = db.eventsStreamAffiche();
    final allEvents = db.allEvents();
    MyUser user = context.read(myUserProvider);

    final StreamZip<List<MyEvent>> streamZipMaSelection = StreamZip([
      db.eventStreamMaSelectionGenre(user?.genres ?? [], user?.lieu ?? [],
          user?.quand ?? [], user?.geoPoint),
      db.eventStreamMaSelectionType(user?.types ?? [], user?.lieu ?? [],
          user?.quand ?? [], user?.geoPoint),
    ]);

    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.black,),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'À l\'affiche',
              style: Theme.of(context).textTheme.headline5.copyWith(color: Theme.of(context).colorScheme.secondary,fontWeight: FontWeight.bold),
            ),
          ),
        ),
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
              events.removeWhere((element) =>
                  element.dateDebutAffiche.compareTo(DateTime.now()) > 0);

              return events.length != 0
                  ? SizedBox(
                      height: orientation == Orientation.portrait
                          ? size.height * 0.60
                          : size.height * 0.60,
                      child: Swiper(
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return events[index].imageFlyerUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: events[index].imageFlyerUrl,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
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
                                      width: orientation == Orientation.portrait
                                          ? size.width
                                          : 400,
                                      height:
                                          orientation == Orientation.portrait
                                              ? size.height / 1.5
                                              : size.height,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25)),
                                          color: Colors.white),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                )
                              : SizedBox();
                        },
                        itemCount: events.length,
                        pagination: SwiperPagination(),
                        control: SwiperControl(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onTap: (index) {
                          ExtendedNavigator.of(context).push(Routes.details,
                              arguments: DetailsArguments(
                                  event: events.elementAt(index)));
                        },
                        itemWidth: orientation == Orientation.portrait
                            ? size.height * 0.60 * 0.709 //0.709 format A6
                            : size.height * 0.60 * 0.709,
                        itemHeight: orientation == Orientation.portrait
                            ? size.height
                            : size.height,
                        layout: SwiperLayout.TINDER,
                        loop: true,
                        outer: true,
                        autoplay: true,
                        autoplayDisableOnInteraction: false,
                      ),
                    )
                  : Center(
                      child: Text(
                        'Pas d\'évenements',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    );
            }),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Ma selection',
              style: Theme.of(context).textTheme.headline5,
            ),
            IconButton(
                icon: Icon(FontAwesomeIcons.search),
                onPressed: () => showDialogGenresEtTypes(
                    context,
                    context.read(myUserProvider)?.lieu,
                    context.read(myUserProvider)?.quand,
                    context.read(myUserProvider).genres != null
                        ? context.read(myUserProvider).genres.toList()
                        : [],
                    context.read(myUserProvider).types != null
                        ? context.read(myUserProvider).types.toList()
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
              } else if (snap.data[0].length == 0 && snap.data[1].length == 0) {
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
                  child: ListView.separated(
                      separatorBuilder: (context, index) => VerticalDivider(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => ExtendedNavigator.of(context).push(
                              Routes.details,
                              arguments: DetailsArguments(
                                  event: events.elementAt(index))),
                          child: CachedNetworkImage(
                            imageUrl: events[index].imageFlyerUrl,
                            imageBuilder: (context, imageProvider) => Container(
                              width: 150,
                              height: 211,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.fill),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25)),
                                  color: Colors.white),
                            ),
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.white,
                              highlightColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Container(
                                width: 220,
                                height: 220,
                                //color: Colors.white,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
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
        Divider(),
        Text(
          'La selection van E.vents',
          style: Theme.of(context).textTheme.headline5,
        ),
        StreamBuilder<List<MyEvent>>(
            stream: allEvents,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary)),
                );
              } else if (snapshot.hasError) {
                print(snapshot.error.toString());

                return Center(
                  child: Text(
                    'Erreur de connexion',
                    style: Theme.of(context).textTheme.display1,
                  ),
                );
              } else if (snapshot.data.length == 0) {
                return Center(
                  child: Text(
                    'Pas d\'évenements',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                );
              }
              List<MyEvent> events = List<MyEvent>();
              events.addAll(snapshot.data);

              return events.isNotEmpty
                  ? SizedBox(
                      height: 220,
                      child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              VerticalDivider(),
                          scrollDirection: Axis.horizontal,
                          itemCount: events.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => ExtendedNavigator.of(context).push(
                                  Routes.details,
                                  arguments: DetailsArguments(
                                      event: events.elementAt(index))),
                              child: events[index].imageFlyerUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: events[index].imageFlyerUrl,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 150,
                                        height: 211,
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
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )
                                  : SizedBox(),
                            );
                          }),
                    )
                  : Center(
                      child: Text(
                        'Pas d\'évenements',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    );
            })
      ],
    );
  }

  Future checkPosition(BuildContext context) async {
    if (context.read(boolToggleProvider).lieu == Lieu.aroundMe) {
      LocationPermission permission = await requestPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position position =
            await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        context.read(boolToggleProvider).setPosition(position);
      } else {
        context.read(boolToggleProvider).setLieux(Lieu.address);
      }
    }
  }

  void modificationLieuEtDate(BuildContext context, List lieu, List quand) {
    if (lieu == null || lieu.isEmpty) {
      return;
    }
    print(lieu);

    switch (lieu[0]) {
      case 'address':
        context.read(boolToggleProvider).setLieux(Lieu.address);

        context.read(boolToggleProvider).setSelectedAdress(lieu[1]);
        break;
      case 'aroundMe':
        context.read(boolToggleProvider).setLieux(Lieu.aroundMe);
        break;
    }
    switch (quand[0]) {
      case 'date':
        context.read(boolToggleProvider).setQuand(Quand.date);

        if (quand[1].toString() != 'null') {
          Timestamp time = quand[1] as Timestamp;

          context.read(boolToggleProvider).setSelectedDate(time.toDate());
        }

        break;
      case 'ceSoir':
        context.read(boolToggleProvider).setQuand(Quand.ceSoir);
        break;
      case 'demain':
        context.read(boolToggleProvider).setQuand(Quand.demain);
        break;
      case 'avenir':
        context.read(boolToggleProvider).setQuand(Quand.avenir);
        break;
    }
  }
}

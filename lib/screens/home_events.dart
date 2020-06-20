import 'dart:collection';

import 'package:async/async.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/screens/model_body.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/topAppBar.dart';

class HomeEvents extends StatelessWidget with NavigationStates {
  const HomeEvents();

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    final eventsAffiche = db.eventsStreamAffiche();
    User user = Provider.of<User>(context);

    final StreamZip<List<MyEvent>> streamZipMaSelection = StreamZip([
      db.eventStreamMaSelectionGenre(user.genres),
      db.eventStreamMaSelectionType(user.types)
    ]);

    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    return Stack(
      children: <Widget>[
        ModelBody(
          child: Column(
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
//                              db.showSnackBar(
//                                  'Erreur de connexion${snap.error.toString()}',
//                                  context);

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
                color: Theme.of(context).colorScheme.primary,
                thickness: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Ma selection'),
                  IconButton(
                      icon: Icon(FontAwesomeIcons.pencilAlt),
                      onPressed: () => null),
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

                    for(int i=0; i<events.length; i++){//doublon
                      for(int j=0; j<events.length;j++){
                        if(j != i && events[j].id == events[i].id){
                          events.removeAt(j);
                        }
                      }
                    }


                    print(events.length);
                    print('//');

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

//                      return events.isNotEmpty
//                          ? Swiper(
//                        itemBuilder:
//                            (BuildContext context, int index) {
//                          return events[index].imageFlyerUrl != null
//                              ? CachedNetworkImage(
//                            imageUrl:
//                            events[index].imageFlyerUrl,
//                            imageBuilder: (context,
//                                imageProvider) =>
//                                Image(image: imageProvider),
//                            placeholder: (context, url) =>
//                                Shimmer.fromColors(
//                                  baseColor: Colors.white,
//                                  highlightColor:
//                                  Theme.of(context)
//                                      .colorScheme
//                                      .primary,
//                                  child: Container(
//                                    width: constraints.maxWidth,
//                                    height: constraints.maxHeight,
//                                    //color: Colors.white,
//                                    decoration: BoxDecoration(
//                                        borderRadius:
//                                        BorderRadius.all(
//                                            Radius.circular(
//                                                25)),
//                                        color: Colors.white),
//                                  ),
//                                ),
//                            errorWidget:
//                                (context, url, error) =>
//                                Icon(Icons.error),
//                          )
//                              : SizedBox();
//                        },
//                        itemCount: events.length,
//                        pagination: SwiperPagination(),
//                        control: SwiperControl(
//                          color:
//                          Theme.of(context).colorScheme.primary,
//                        ),
//                        onTap: (index) {
//                          ExtendedNavigator.of(context).pushNamed(
//                              Routes.details,
//                              arguments: DetailsArguments(
//                                  event: events.elementAt(index)));
//                        },
//                        itemWidth: constraints.maxWidth,
//                        itemHeight: constraints.maxHeight,
//                        layout: SwiperLayout.TINDER,
//                        loop: true,
//                        outer: false,
//                        autoplay: true,
//                        autoplayDisableOnInteraction: false,
//                      )
//                          : Center(
//                        child: Text(
//                          'Pas d\'évenements',
//                          style: Theme.of(context).textTheme.button,
//                        ),
//                      );
                  }),
              Divider(
                color: Theme.of(context).colorScheme.primary,
                thickness: 2,
              ),
              Text('La selection van E.vents'),
//                ListView.separated(
//    separatorBuilder: (context,index)=>SizedBox(width: 12,),
//    scrollDirection: Axis.horizontal,
//    itemCount: tickets.length,
//    itemBuilder: (context, index) {})
            ],
          ),
        ),
        TopAppBar('', true, double.infinity),
      ],
    );
  }
}

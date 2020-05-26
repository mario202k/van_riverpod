import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/topAppBar.dart';

class HomeEvents extends StatefulWidget with NavigationStates {

  const HomeEvents();

  @override
  _HomeEventsState createState() => _HomeEventsState();
}

class _HomeEventsState extends State<HomeEvents> {
  Stream<List<MyEvent>> slides;
  Future<List<MyEvent>> listEvent;
  List<MyEvent> lastEvents = List<MyEvent>();
  bool isDispose = false;

  int lastnb=0;

  @override
  void dispose() {
    isDispose = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreDatabase db =
        Provider.of<FirestoreDatabase>(context, listen: false);

    slides = db.eventsStream();
    listEvent = db.eventsFuture();




//    _queryDb(false, auth);
//      SystemChrome.setPreferredOrientations([
//        DeviceOrientation.portraitUp,
//        DeviceOrientation.portraitDown,
//      ]);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 100),
        child: TopAppBar('Events', true, double.infinity),
      ),
      //appBar: AppBar(backgroundColor: Colors.yellow,shape: CustomShapeBorder() ,) ,
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: (constraints.maxHeight * 4.25) / 6,
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: StreamBuilder<List<MyEvent>>(
                  stream: slides,
                  builder: (context, AsyncSnapshot snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary)),
                      );
                    } else if (snap.hasError) {

                      db.showSnackBar(
                          'Erreur de connexion${snap.error.toString()}',
                          context);

                      return Center(
                        child: Text(
                          'Erreur de connexion',
                          style: Theme.of(context).textTheme.display1,
                        ),
                      );
                    } else if (snap.data.length == 0) {

                      return Center(
                        child: Text('Pas d\'évenements',style: Theme.of(context).textTheme.bodyText1,),
                      );
                    }
                    List<MyEvent> events = List<MyEvent>();
                    events.addAll(snap.data);


                    return events.isNotEmpty
                        ? Swiper(
                            itemBuilder: (BuildContext context, int index) {

                              return CachedNetworkImage(
                                imageUrl: events[index].imageUrl,
                                imageBuilder:
                                    (context, imageProvider) =>
                                    Container(
                                      height: constraints.maxHeight * 0.88,
                                      width: (constraints.maxHeight * 0.88 * 4.25) / 6,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.white,
                                  highlightColor: Theme.of(context).colorScheme.primary,
                                  child: Container(
                                    width:
                                        (constraints.maxHeight * 4.25) / 6,
                                    height: constraints.maxHeight,
                                    //color: Colors.white,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25)),

                                      color: Colors.white
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              );
                            },
                            itemCount: events.length,
                            pagination: SwiperPagination(

                            ),
                            control: SwiperControl(
                              color:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                            onTap: (index) {
                              ExtendedNavigator.of(context).pushNamed(
                                  Routes.details,
                                  arguments: DetailsArguments(
                                      event: events.elementAt(index)));
                            },
                            itemWidth:
                                (constraints.maxHeight * 0.88 * 4.25) / 6,
                            itemHeight: constraints.maxHeight * 0.88,
                            layout: SwiperLayout.TINDER,
                            loop: true,
                            outer: false,
                            autoplay: true,
                            autoplayDisableOnInteraction: false,
                          )
                        : Center(
                            child: Text(
                              'Pas d\'évenements',
                              style: Theme.of(context).textTheme.button,
                            ),
                          );
                  }),
            ),
          ),
        );
      }),
    );
  }

//  Stream _queryDb(bool upcoming, FirestoreDatabase db) {
//    if (upcoming) {
//      //Make a query
//      Query query = db.db.collection('events');
////          .where('dateDebut', isGreaterThanOrEqualTo: DateTime.now());
//
//      slides = query
//          .snapshots()
//          .map((list) => list.documents.map((doc) => doc.data));
//    } else {
//      //Make a query
//      Query query = db.db.collection('events');
////          .where('dateDebut', isLessThan: DateTime.now());
//
//      slides = query
//          .snapshots()
//          .map((list) => list.documents.map((doc) => doc.data));
//    }
//
//    return slides;
//  }
}



import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/models/formule.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:map_launcher/map_launcher.dart';

class Details extends StatefulWidget {
  final MyEvent event;

  Details(this.event);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  Future<List<Future<User>>> participants;
  List<Formule> formulas;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    participants = db.participantsEvent(widget.event.id);
    db.getFormulasList(widget.event.id).then((form) {
      formulas = form;
    });

    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
//              actions: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.only(right: 20),
//                  child: InkWell(
//                    onTap: () {
//                      Navigator.of(context).pushNamed('/pay');
//                    },
//                    child: Icon(
//                      FontAwesomeIcons.cartArrowDown,
//                      color: Colors.white,
//                    ),
//                  ),
//                )
//              ],
                  expandedHeight: 300,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(widget.event.titre,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline),
                    background: Image(
                      image: NetworkImage(widget.event.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ];
            },
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                           // "${DateFormat('dd/MM/yyyy').format(widget.event.dateDebut)} à : ${widget.event.dateDebut.hour}:${widget.event.dateDebut.minute}"
                          '${DateFormat('dd/MM/yyyy').format(widget.event.dateDebut)} à : ${DateFormat('HH').format(widget.event.dateDebut)}h${DateFormat('mm').format(widget.event.dateDebut)}'
                          ,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black),),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FlatButton.icon(
                            onPressed: () {
                              final Event event = Event(
                                title: widget.event.titre,
                                description: widget.event.description,
                                location: widget.event.address,
                                startDate: widget.event.dateDebut,
                                endDate: widget.event.dateFin,
                              );

                              Add2Calendar.addEvent2Cal(event);
                            },
                            icon: Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            label: Text("Plannifier")),
                      ),
                      Expanded(
                        child: FlatButton.icon(
                            onPressed: () async {
                              final availableMaps =
                                  await MapLauncher.installedMaps;
                              print(
                                  availableMaps); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

                              await availableMaps.first.showMarker(
                                coords: Coords(widget.event.location.latitude,
                                    widget.event.location.longitude),
                                title: widget.event.titre,
                                description: widget.event.address,
                              );
                            },
                            icon: Icon(
                              Icons.map,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            label: Text("Y aller")),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle, color: Colors.black26),
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: new Text(
                      "Description",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black,fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    widget.event.description,style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black,fontSize: 20) ,
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle, color: Colors.black26),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Participants",
                    style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black,fontWeight: FontWeight.w600),
                  ),
                  Container(
                    height: 200,
                    child: FutureBuilder<List<Future<User>>>(
                        future: participants,
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Erreur de connection'),
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.secondary)),
                            );
                          }
                          List<Future<User>> participantsList = snapshot.data;

                          return participantsList.isNotEmpty
                              ? ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: participantsList.length,
                                  itemBuilder: (context, index) {
                                    return FutureBuilder<User>(
                                        future:
                                            participantsList.elementAt(index),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Center(
                                              child:
                                                  Text('Erreur de connection'),
                                            );
                                          } else if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .secondary)),
                                            );
                                          }

                                          User user = snapshot.data;

                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.all(6),
                                                child: CircleAvatar(
                                                  radius: 30,
                                                  backgroundImage: NetworkImage(
                                                      user.imageUrl),
                                                ),
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                )
                              : SizedBox();
                        }),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: RawMaterialButton(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Icon(
                      FontAwesomeIcons.cartArrowDown,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    PulseAnimation(
                      child: Text(
                        "PARTICIPER",
                        style: TextStyle(
                            color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              shape: StadiumBorder(),
              fillColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                ExtendedNavigator.of(context).pushNamed(Routes.formulaChoice,
                    arguments: FormulaChoiceArguments(
                        formulas: formulas,
                        eventId: widget.event.id,
                        imageUrl: widget.event.imageUrl));
              }),
        ),
      ),
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;

  const PulseAnimation({Key key, this.child}) : super(key: key);

  @override
  _PulseAnimationState createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween(begin: .2, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart));

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

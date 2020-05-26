import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/topAppBar.dart';

class AdminEvents extends StatefulWidget {
  @override
  _AdminEventsState createState() => _AdminEventsState();
}

class _AdminEventsState extends State<AdminEvents> {
  Stream streamEvents;
  List<MyEvent> events = List<MyEvent>();

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    streamEvents = db.allEventsAdminStream();

    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: PreferredSize(
            preferredSize: Size(double.infinity, 100),
            child: TopAppBar('Admin', false, double.infinity),
          ),
          body: StreamBuilder<List<MyEvent>>(
              stream: streamEvents,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur de connection',
                      style: Theme.of(context).textTheme.button,
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary)),
                  );
                }

                events.clear();
                events.addAll(snapshot.data);

                return events.isNotEmpty
                    ? ListView.separated(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.15,
                            actions: <Widget>[
                              IconSlideAction(
                                caption: 'Annuler',
                                color: Theme.of(context).colorScheme.secondary,
                                icon: FontAwesomeIcons.calendarTimes,
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (_) => Platform.isAndroid
                                          ? AlertDialog(
                                              title: Text('Annuler?'),
                                              content: Text(
                                                  'Etes vous sur de vouloir annuler l\'events'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text('Non'),
                                                  onPressed: () {},
                                                ),
                                                FlatButton(
                                                  child: Text('Oui'),
                                                  onPressed: () {
                                                    db.cancelEvent(events.elementAt(index).id);
                                                  },
                                                ),
                                              ],
                                            )
                                          : CupertinoAlertDialog(
                                              title: Text('Annuler?'),
                                              content: Text(
                                                  'Etes vous sur de vouloir annuler l\'events'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text('Non'),
                                                  onPressed: () {},
                                                ),
                                                FlatButton(
                                                  child: Text('Oui'),
                                                  onPressed: () {},
                                                ),
                                              ],
                                            ));
                                },
                              ),
                            ],
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: 'Update',
                                color: Theme.of(context).colorScheme.primaryVariant,
                                icon: FontAwesomeIcons.search,
                                onTap: () => ExtendedNavigator.of(context)
                                    .pushNamed(Routes.uploadEvent,
                                        arguments: UploadEventArguments(
                                            idEvent: events.elementAt(index).id)),
                              )
                            ],
                            child: ListTile(
                              leading: Text(
                                events.elementAt(index).titre,
                                style: Theme.of(context).textTheme.button,
                              ),
                              title: Text(
                                events.elementAt(index).status,
                                style: Theme.of(context).textTheme.button,
                              ),
                              trailing: Icon(
                                FontAwesomeIcons.qrcode,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                              onTap: () => ExtendedNavigator.of(context).pushNamed(
                                  Routes.monitoringScanner,
                                  arguments: MonitoringScannerArguments(
                                      eventId: events.elementAt(index).id)),
                            ),
                          );
                        },
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).colorScheme.secondary,
                          thickness: 1,
                        ),
                      )
                    : Center(
                        child: Text(
                          'Pas d\'évenements',
                          style: Theme.of(context).textTheme.button,
                        ),
                      );
              }),
          floatingActionButton: FloatingActionButton(
            child: Icon(
              FontAwesomeIcons.plus,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            onPressed: () =>
                ExtendedNavigator.of(context).pushNamed(Routes.uploadEvent),
          ),
        ),
      ),
    );
  }
}

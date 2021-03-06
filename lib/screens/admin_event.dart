import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/models/myUser.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/screens/model_screen.dart';
import 'package:vanevents/services/firestore_database.dart';

class AdminEvents extends StatefulWidget {
  @override
  _AdminEventsState createState() => _AdminEventsState();
}

class _AdminEventsState extends State<AdminEvents> {
  Stream streamEvents;
  List<MyEvent> events = List<MyEvent>();

  @override
  Widget build(BuildContext context) {
    final rep = RepositoryProvider.of<FirestoreDatabase>(context);
    print(rep.uid);
    final db = Provider.of<FirestoreDatabase>(context, listen: false);

    streamEvents = db.allEventsAdminStream(
        Provider.of<MyUser>(context, listen: false).stripeAccount);

    return ModelScreen(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text('Admin'),
        ),
        body: StreamBuilder<List<MyEvent>>(
            stream: streamEvents,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur de connection',
                    style: Theme.of(context).textTheme.bodyText1,
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
                                showAreYouSure(context, db, index);
                              },
                            ),
                          ],
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: 'Update',
                              color:
                                  Theme.of(context).colorScheme.primaryVariant,
                              icon: FontAwesomeIcons.search,
                              onTap: () => ExtendedNavigator.of(context).push(
                                  Routes.uploadEvent,
                                  arguments: UploadEventArguments(
                                      myEvent: events.elementAt(index))),
                            )
                          ],
                          child: ListTile(
                            leading: Text(
                              events.elementAt(index).titre,
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                            ),
                            title: Text(
                              events.elementAt(index).status,
                              style: Theme.of(context)
                                  .textTheme
                                  .button
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                            ),
                            trailing: Icon(
                              FontAwesomeIcons.qrcode,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                            onTap: () => ExtendedNavigator.of(context).push(
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
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    );
            }),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            FontAwesomeIcons.plus,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          onPressed: () =>
              ExtendedNavigator.of(context).push(Routes.uploadEvent),
        ),
      ),
    );
  }

  void showAreYouSure(BuildContext context, FirestoreDatabase db, int index) {
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Oui'),
                    onPressed: () {
                      db.cancelEvent(events
                          .elementAt(index)
                          .id);
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Oui'),
                    onPressed: () {
                      db.cancelEvent(events
                          .elementAt(index)
                          .id);
                    },
                  ),
                ],
              ));
  }
}

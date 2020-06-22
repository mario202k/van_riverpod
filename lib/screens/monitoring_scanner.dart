import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter/material.dart';
import 'package:majascan/majascan.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/ticket.dart';
import 'package:vanevents/screens/model_screen.dart';
import 'package:vanevents/services/firestore_database.dart';

class MonitoringScanner extends StatefulWidget {
  final String eventId;

  MonitoringScanner(this.eventId);

  @override
  _MonitoringScannerState createState() => _MonitoringScannerState();
}

class _MonitoringScannerState extends State<MonitoringScanner> {
  GlobalKey qrKey = GlobalKey();
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();
  int nbAttendu = 0;
  int nbPresent = 0;
  Map participants;
  String qrResult;
  List<Ticket> tickets = List<Ticket>();
  Stream<List<Ticket>> ticketsStream;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreDatabase db =
        Provider.of<FirestoreDatabase>(context, listen: false);
    ticketsStream = db.streamTicketsAdmin(widget.eventId);

    return ModelScreen(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        key: _scaffoldKey,
        appBar: AppBar(title: Text('Monitoring'),),
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight),
              child: StreamBuilder<List<Ticket>>(
                  stream: ticketsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(
                        child: Text('Erreur de connexion'),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary)),
                      );
                    }

                    tickets = snapshot.data;
                    int expected = 0, present = 0;

                    Ticket ongoingTicket;
                    for (int i = 0; i < tickets.length; i++) {
                      if (tickets[i].id == qrResult) {
                        ongoingTicket = tickets[i];
                      }

                      if(tickets[i].status != 'Annulé'){
                        for (int j = 0; j < tickets[i].participants.length; j++) {
                          expected++;

                          if (tickets[i].participants.values.toList()[j][1]) {
                            present++;
                          }
                        }
                      }
                    }

                    double totalAttendu =
                        expected.toDouble() - present.toDouble();

                    List<CircularStackEntry> data = <CircularStackEntry>[
                      new CircularStackEntry(
                        <CircularSegmentEntry>[
                          new CircularSegmentEntry(totalAttendu, Colors.red,
                              rankKey: 'Attendu'),
                          new CircularSegmentEntry(
                              present.toDouble(), Colors.green,
                              rankKey: 'Present'),
                        ],
                        rankKey: 'Quarterly Profits',
                      ),
                    ];

                    if (_chartKey.currentState != null) {
                      _chartKey.currentState.updateData(data);
                    }

                    int total = totalAttendu.toInt();

                    return tickets.isNotEmpty
                        ? Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Center(
                                        child: Text(
                                      'Present : $present',
                                      style: TextStyle(color: Colors.green),
                                    )),
                                  ),
                                  Expanded(
                                      child: Center(
                                          child: Text(
                                    'Attendu : $total',
                                    style: TextStyle(color: Colors.red),
                                  )))
                                ],
                              ),
                              AnimatedCircularChart(
                                key: _chartKey,
                                size: const Size(300.0, 300.0),
                                initialChartData: data,
                                chartType: CircularChartType.Radial,
                                //percentageValues: true,
                                holeLabel: '${(100 * present) / expected} %',
                                labelStyle: new TextStyle(
                                  color: Colors.blueGrey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.0,
                                ),
                              ),
                              ongoingTicket != null
                                  ? SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            ongoingTicket.participants.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          String key = ongoingTicket
                                              .participants.keys
                                              .toList()[index];
                                          bool isHere =
                                              ongoingTicket.participants[key][1];
                                          return SizedBox(
                                            width: 250,
                                            child: GestureDetector(
                                              onTap: () => db.setToggleisHere(
                                                  ongoingTicket.participants,
                                                  qrResult,
                                                  index),
                                              child: Card(
                                                color: isHere
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .surface,
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      key,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: isHere
                                                              ? Colors.white
                                                              : Colors.black),
                                                    ),
                                                    Text(
                                                      ongoingTicket
                                                          .participants[key][0],
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: isHere
                                                              ? Colors.white
                                                              : Colors.black),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : SizedBox(),
                              ongoingTicket != null
                                  ? RaisedButton(
                                      onPressed: () =>
                                          db.toutValider(ongoingTicket),
                                      child: Text(
                                        'Tout le monde',
                                        style: Theme.of(context).textTheme.button,
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          )
                        : Center(
                            child: Text(
                              'Aucun ticket vendu',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          );
                  }),
            ),
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(
            Icons.camera_alt,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          label: Text(
            "Scan",
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () {
            startScan(db, context);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  isValide(String data) {
    bool rep = false;
    for (int i = 0; i < tickets.length; i++) {
      if (tickets[i].id == data) {
        rep = true;
        break;
      }
    }
    return rep;
  }

  startScan(FirestoreDatabase db, BuildContext context) {
    _scanQR(db, context);
  }

  Future _scanQR(FirestoreDatabase db, BuildContext context) async {
    try {
      qrResult = await MajaScan.startScan(
          title: "QRcode scanner",
          titleColor: Colors.amberAccent[700],
          qRCornerColor: Colors.orange,
          qRScannerColor: Colors.orange);

      bool rep = false;
      int j = 0;

      for (int i = 0; i < tickets.length; i++) {
        j = i;
        if (tickets[i].id == qrResult) {
          rep = true;
          break;
        }
      }

      if (rep) {
        if (tickets[j].participants.length == 1) {


          db.showSnackBar2("Ok pour : 1 participant", _scaffoldKey);
        } else {
          db.showSnackBar2(
              "Ok pour : ${tickets[j].participants.length} participants",
              _scaffoldKey);
        }

        db.ticketValidated(tickets[j].id);
      } else {
        //db.showSnackBar("Inconnu", context);

      }
    } on PlatformException catch (ex) {
      if (ex.code == MajaScan.CameraAccessDenied) {
        //db.showSnackBar("Camera permission was denied", context);

      } else {
        //db.showSnackBar("Unknown Error $ex", context);

      }
    } on FormatException {
      //db.showSnackBar("You pressed the back button before scanning anything", context);

    } catch (ex) {
      print(ex);
      //db.showSnackBar("Unknown Error $ex", context);
    }
  }
}
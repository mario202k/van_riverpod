import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen/screen.dart';
import 'package:vanevents/models/ticket.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:flare_flutter/flare_actor.dart';

class QrCode extends StatefulWidget {
  String data;

  QrCode(this.data);

  @override
  _QrCodeState createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode>{
  double brightness;
  Stream<Ticket> streamTicket;
  bool isValidated = false;
  bool isCancel = false;

  @override
  void initState() {
    // Set the brightness:
    setBrightness();
    super.initState();
  }

  Future setBrightness() async {
    brightness = await Screen.brightness;
    Screen.setBrightness(1);
  }

  @override
  void dispose() {
    if (brightness != null) {
      Screen.setBrightness(brightness);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    streamTicket = db.streamTicket(widget.data);
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          body: Center(
            child: StreamBuilder<Ticket>(
                stream: streamTicket,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.secondary)),
                    );
                  } else if (snapshot.hasError) {
                    print('Erreur de connexion${snapshot.error.toString()}');
                    db.showSnackBar(
                        'Erreur de connexion${snapshot.error.toString()}',
                        context);
                    print('Erreur de connexion${snapshot.error.toString()}');
                    return Center(
                      child: Text(
                        'Erreur de connexion',
                        style: Theme.of(context).textTheme.display1,
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    print("pas data");
                    return Center(
                      child: Text('Erreur de connexion'),
                    );
                  }

                  Ticket ticket = snapshot.data;

                  if (ticket.status == 'Validé' && !isValidated) {
                    isValidated = true;
                  }else if(ticket.status == 'Annulé' &&!isCancel){
                    isCancel = true;
                  }


                  return Stack(
                    children: <Widget>[
                      Align(
                        alignment:Alignment.center,
                        child: QrImage(
                          data: widget.data,
                          version: QrVersions.auto,
                          size: 320,
                          gapless: false,
                        ),
                      ),
                      isValidated
                          ? FlareActor(
                              'assets/animations/ok.flr',
                              alignment: Alignment.center,
                              animation: 'Checkmark Appear',
                          )
                          : isCancel?  FlareActor(
                        'assets/animations/Nope.flr',
                        alignment: Alignment.center,
                        animation: 'Nope appear',
                      ) : SizedBox(),

                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }


}

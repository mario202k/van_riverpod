import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:vanevents/models/my_transport.dart';
import 'package:vanevents/screens/model_screen.dart';

class TransportDetail extends StatelessWidget {
  final MyTransport _myTransport;
  final String _addressArriver;

  TransportDetail(this._myTransport,this._addressArriver);

  @override
  Widget build(BuildContext context) {
    return ModelScreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Détails'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Status : ',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      _myTransport.statusTransport.toString().substring(
                          _myTransport.statusTransport.toString().indexOf('.') +
                              1),
                      style: Theme.of(context).textTheme.headline5,
                    )
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Pour le :',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      DateFormat('dd/MM/yyy à HH:mm').format(_myTransport.dateTime),
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),

                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Voiture:',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Column(
                      children: [
                        Image(
                          image: AssetImage(getPath(_myTransport.car)),
                          height: 50,
                        ),
                        Text(
                          _myTransport.car,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ],
                    ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Nombre de personnes : ',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      _myTransport.nbPersonne,
                      style: Theme.of(context).textTheme.headline5,
                    )
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Prix : ',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      getPrix(_myTransport.amount),
                      style: Theme.of(context).textTheme.headline5,
                    )
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Départ:',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Column(
                      children: [
                        Text(
                          _myTransport.adresseRue.join(" "),
                          style: Theme.of(context).textTheme.headline5,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          _myTransport.adresseZone.join(" "),
                          style: Theme.of(context).textTheme.headline5,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Distance:',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      _myTransport.distance.toStringAsFixed(2) + ' km',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Arrivée:',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      _addressArriver,
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getPath(String car) {
    print(car);

    switch (car) {
      case 'classee':
        return 'assets/images/classee.png';
      case 'van':
        return 'assets/images/van.png';
      case 'classes':
        return 'assets/images/classes.png';
      case 'suv':
        return 'assets/images/suv.png';
    }

    return 'assets/images/suv.png';
  }

  String getPrix(int amount) {
    if (amount == null) return 'non définie';

    return '${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)} €';
  }
}

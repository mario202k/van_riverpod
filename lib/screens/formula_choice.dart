import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_stripe_payment/flutter_stripe_payment.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/formule.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:vanevents/models/participant.dart';
import 'package:vanevents/models/ticket.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/screens/base_screen.dart';
import 'package:vanevents/services/firestore_database.dart';


class FormulaChoice extends StatefulWidget {
  final List<Formule> formulas;
  final String eventId;
  final String imageUrl;

  FormulaChoice(this.formulas, this.eventId,this.imageUrl);

  @override
  _FormulaChoiceState createState() => _FormulaChoiceState();
}

class _FormulaChoiceState extends State<FormulaChoice> {
  String text = 'Click the button to start the payment';

  //double totalCost = 10.0;
  double tip = 0.0;
  double tax = 0.0;
  double taxPercent = 0.2;
  int amount = 0;
  bool showSpinner = false;
  String url =
      'https://us-central1-demostripe-b9557.cloudfunctions.net/StripePI';
  String currency = 'EUR';

  //final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<Formule> _formules = List<Formule>();

  List<Participant> participants = List<Participant>();
  Map<Formule, int> nbPersonneParFormule = Map<Formule, int>();

  //List<CardFormula> listWidget;

  int indexParticipants = 0;

  double totalCost = 0;

  final _stripePayment = FlutterStripePayment();

  FirestoreDatabase db;
  User user;

  @override
  void initState() {
    _stripePayment.onCancel = () {
      print("User Cancelled the Payment Method Form");
    };
    _stripePayment.setStripeSettings(
        'pk_test_gPlqnEqiVydntTBkyFzc4aUb001o1vGwb6',
        'merchant.com.vanina.vanevents');

//    StripePayment.setOptions(
//      StripeOptions(
//        publishableKey: 'pk_test_gPlqnEqiVydntTBkyFzc4aUb001o1vGwb6', // add you key as per Stripe dashboard
//        merchantId: 'merchant.com.vanina.vanevents',
//// add you merchantId as per apple developer account
//        androidPayMode: 'test',
//      ),
//    );

    _formules = widget.formulas;

    for (int i = 0; i < _formules.length; i++) {
      nbPersonneParFormule.addAll(<Formule, int>{_formules[i]: 0});
    }

    super.initState();
  }

  void onTap(bool plus, Formule formule) {
    double prix = formule.prix;

    if (plus) {
      nbPersonneParFormule[formule]++;

      setState(() {
        totalCost = totalCost + prix;
      });
    } else {
      nbPersonneParFormule[formule]--;
      setState(() {
        totalCost = totalCost - prix;
      });
      //pour supprimer le participant;
      for (int i = participants.length - 1; i >= 0; i--) {
        if (participants[i].formule.id == formule.id) {
          participants.removeAt(i);
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    db = Provider.of<FirestoreDatabase>(context, listen: false);

    user = Provider.of<User>(context, listen: false);

    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          key: _scaffoldKey,
          appBar: AppBar(
              title: Text(
            "Formules",
          )),
          body: Stack(
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 80),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80, left: 10, right: 10),
                  child: ListView.builder(
                      itemCount: _formules.length,
                      itemBuilder: (context, index) {
                        return CardFormula(
                            formule: _formules[index],
                            onTap: onTap,
                            onChangedParticipant: onChangeParticipant);
                      }),
                ),
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Material(
                      color: Theme.of(context).colorScheme.secondary,
                      elevation: 14.0,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        topRight: Radius.circular(40.0),
                      ),
                      shadowColor: Colors.black,
                      child: _buildTotalContent(),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //onChanged(_fbKey,widget.index,widget.participant.formule, prenom, false);

  void onChangeParticipant(GlobalKey<FormBuilderState> _fbKey, int index,
      Formule formule, String val, bool isNom) {
    Participant participant;
    for (int i = 0; i < participants.length; i++) {
      if (participants[i].formule.id == formule.id &&
          participants[i].index == index) {
        participant = participants[i];
        break;
      }
    }

    if (participant == null) {
      if (isNom) {
        participants.add(Participant(
            fbKey: _fbKey, index: index, formule: formule, nom: val,isPresent: false));
      } else {
        participants.add(Participant(
            fbKey: _fbKey, index: index, formule: formule, prenom: val,isPresent: false));
      }
    } else {
      int index = participants.indexOf(participant);
      participants.removeAt(index);
      if (isNom) {
        participant.nom = val;
      } else {
        participant.prenom = val;
      }
      participants.insert(index, participant);
    }
  }

  _buildTotalContent() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
              flex: 1,
              child: Text(
                '   $totalCost €',
                textAlign: TextAlign.center,
              )),
          Flexible(
            flex: 1,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: !showSpinner
                  ? FloatingActionButton.extended(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      icon: Text(
                        'Continuer',
                        style: Theme.of(context).textTheme.button,
                      ),
                      label: Icon(
                        FontAwesomeIcons.creditCard,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      onPressed: () async {
                        if (allParticipantIsOk()) {
//                  checkIfNativePayReady();
                          //createPaymentMethodNative();

                          String description = '';

                          participants.forEach((participants) {
                            description = description +
                                participants.formule.title +
                                ' pour ' +
                                participants.nom +
                                ' ' +
                                participants.prenom +
                                '\n';
                          });

                          var paymentResponse =
                              await _stripePayment.addPaymentMethod();

                          if (paymentResponse.status ==
                              PaymentResponseStatus.succeeded) {
                            setState(() {
                              showSpinner = true;
                            });
                            HttpsCallableResult intentResponse;
                            try {
                              final HttpsCallable callablePaymentIntent =
                                  CloudFunctions.instance.getHttpsCallable(
                                functionName: 'paymentIntent',
                              );
                              intentResponse = await callablePaymentIntent.call(
                                <String, dynamic>{
                                  'amount': totalCost * 100,
                                  'description': description,
                                  'paymentMethodId':
                                      paymentResponse.paymentMethodId
                                },
                              );

                            } on CloudFunctionsException catch (e) {
                              paymentFailed();
                            } catch (e) {
                              paymentFailed();
                            }
                            final paymentIntentX = intentResponse.data;
                            final status = paymentIntentX['status'];

                            if (status == 'succeeded') {
                              paymentValider(paymentIntentX);
                            } else {
                              //step 4: there is a need to authenticate
                              //StripePayment.setStripeAccount(strAccount);

                              var intentResponse =
                                  await _stripePayment.confirmPaymentIntent(
                                      paymentIntentX['client_secret'],
                                      paymentResponse.paymentMethodId,
                                      totalCost);

                              if (intentResponse.status ==
                                  PaymentResponseStatus.succeeded) {
                                paymentValider(paymentIntentX);
                              } else if (intentResponse.status ==
                                  PaymentResponseStatus.failed) {
                                paymentFailed();
                              } else {
                                paymentFailed();
                              }


                            }
                          } else {
                            paymentFailed();
                          }
                        }
                      })
                  : CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary)),
            ),
          ),
        ],
      ),
    );
  }

  void paymentFailed() {
    setState(() {
      showSpinner = false;
    });

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: Text(
            'OOps!!!',
            style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 22),
          ),
          content: Text('Essayer avec une autre carte.'),
          actions: <Widget>[
            PlatformDialogAction(
              child: Text(
                'Ok',
                style: Theme.of(context).textTheme.subhead,
              ),
              onPressed: () {
                Navigator.of(context).pop();

              },
            ),

          ],
        );
      },
    );
  }

  void paymentValider(paymentIntentX) {
    Map participant = Map.fromIterable(participants,
        key: (key) =>
            (key as Participant).nom +
            ' ' +
            (key as Participant).prenom,
        value: (val) =>
            [(val as Participant).formule.title,false]);
    
    Ticket ticket = Ticket(
        id: paymentIntentX['id'],
        status: 'En attente',
        uid: user.id,
        eventId: widget.eventId,
        imageUrl: widget.imageUrl,
        participants: participant,
        amount: paymentIntentX['amount'],
        dateTime: DateTime.now(),
        receiptNumber: ((paymentIntentX['charges']
                ['data'] as List)[0]
            as Map)['receipt_number']);
    
    db.addNewTicket(ticket);
    
    
    //payment was confirmed by the server without need for futher authentification
    
    double amount = double.parse(
        paymentIntentX['amount'].toString());
    
    amount = amount / 100;
    
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return PlatformAlertDialog(
          title: Text(
            'Payement validé',
            style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 22),
          ),
          content: Text('$amount € montant payé avec succès\nUn nouveau billet est disponible '),
          actions: <Widget>[
            PlatformDialogAction(
              child: Text(
                'Ok',
                style: Theme.of(context).textTheme.subhead,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();

    
              },
            ),
    
          ],
        );
      },
    );
    
    
    setState(() {
      showSpinner = false;
    });
  }

  void showSnackBar(String val, ScaffoldState state) {
    state.showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onError, fontSize: 16.0),
        )));
  }

  bool allParticipantIsOk() {
    bool b = true;
    if (participants.length == 0) {
      b = false;
    }

    for (int i = 0; i < participants.length; i++) {
      if (!participants[i].fbKey.currentState.validate()) {
        b = false;
        break;
      }
    }
    return b;
  }
}

class CardParticipant extends StatefulWidget {
  final Function onChanged;
  final Participant participant;
  final int index;

  CardParticipant(this.participant, this.index, this.onChanged);

  @override
  _CardParticipantState createState() => _CardParticipantState();
}

class _CardParticipantState extends State<CardParticipant> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final FocusScopeNode _nom = FocusScopeNode();
  final FocusScopeNode _prenom = FocusScopeNode();
  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _prenomCtrl = TextEditingController();

  @override
  void initState() {
    widget.onChanged(
        _fbKey, widget.index, widget.participant.formule, '', true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        child: Container(
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary
            ]),
//                          color: Colors.blueAccent
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Participant',
                  style: Theme.of(context).textTheme.button,
                ),
                FormBuilder(
                  key: _fbKey,
                  autovalidate: false,
                  child: Column(
                    children: <Widget>[
                      FormBuilderTextField(
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        attribute: 'nom',
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(25.0)),
                          labelText: 'Nom',
                          labelStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                          errorStyle: TextStyle(color: Colors.white),
                        ),
                        focusNode: _nom,
                        onEditingComplete: () {
                          if (_fbKey.currentState.fields['nom'].currentState
                              .validate()) {
                            _nom.unfocus();
                            FocusScope.of(context).requestFocus(_prenom);
                          }
                        },
                        controller: _nomCtrl,
                        onChanged: (val) {
                          if (_nomCtrl.text.length == 0) {
                            _nomCtrl.clear();
                          }

                          String nom = val;
                          _fbKey.currentState.save();
                          widget.onChanged(_fbKey, widget.index,
                              widget.participant.formule, nom, true);
                        },
                        validators: [
                          FormBuilderValidators.required(
                              errorText: 'Champs requis'),
                      (val) {
                    RegExp regex = RegExp(
                        r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ ]{2,30}$');

                    if (regex.allMatches(val).length == 0) {
                      return 'Entre 2 et 30, ';
                    }
                  },
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      FormBuilderTextField(
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        attribute: 'prenom',
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(25.0)),
                          labelText: 'Prénom',
                          labelStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none,
                          errorStyle: TextStyle(color: Colors.white),
                        ),
                        focusNode: _prenom,
                        onEditingComplete: () {
                          if (_fbKey.currentState.fields['prenom'].currentState
                              .validate()) {
                            _prenom.unfocus();
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                          }
                        },
                        controller: _prenomCtrl,
                        onChanged: (val) {
                          if (_prenomCtrl.text.length == 0) {
                            _prenomCtrl.clear();
                          }
                          String prenom = val;
                          _fbKey.currentState.save();
                          widget.onChanged(_fbKey, widget.index,
                              widget.participant.formule, prenom, false);
                        },
                        validators: [
                          FormBuilderValidators.required(
                              errorText: 'Champs requis'),
                              (val) {
                            RegExp regex = RegExp(
                                r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ ]{2,30}$');

                            if (regex.allMatches(val).length == 0) {
                              return 'Entre 2 et 30, ';
                            }
                          },
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CardFormula extends StatefulWidget {
  final Formule formule;
  final Function onTap;
  final Function onChangedParticipant;

  CardFormula({this.formule, this.onTap, this.onChangedParticipant});

  @override
  _CardFormulaState createState() => _CardFormulaState();
}

class _CardFormulaState extends State<CardFormula>
    with AutomaticKeepAliveClientMixin {
  List<Participant> participants = List<Participant>();
  List<CardParticipant> participantsWidget;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  int nb = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            height: 128.0,
            child: Card(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(child: Text('${widget.formule.title} : ${widget.formule.prix} €',style: Theme.of(context).textTheme.bodyText1.copyWith(color:Colors.black,fontSize: 20),textAlign: TextAlign.center,)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RawMaterialButton(
                          onPressed: () {
                            if (nb > 0) {
                              widget.onTap(false, widget.formule);
                              onTap(false, participants.length - 1,
                                  widget.formule);
                            }
                          },
                          child: Icon(
                            FontAwesomeIcons.minus,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30.0,
                          ),
                          shape: CircleBorder(),
                          elevation: 5.0,
                          fillColor: Theme.of(context).colorScheme.secondary,
                          padding: const EdgeInsets.all(10.0),
                        ),
                        Text(nb.toString()),
                        RawMaterialButton(
                          onPressed: () {
                            if (nb >= 0) {
                              widget.onTap(true, widget.formule);
                              onTap(true, participants.length, widget.formule);
                            }
                          },
                          child: Icon(
                            FontAwesomeIcons.plus,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30.0,
                          ),
                          shape: CircleBorder(),
                          elevation: 5.0,
                          fillColor: Theme.of(context).colorScheme.secondary,
                          padding: const EdgeInsets.all(10.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedList(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          key: _listKey,
          initialItemCount: participants.length,
          itemBuilder:
              (BuildContext context, int index, Animation<double> animation) {
            return SizeTransition(
              axis: Axis.vertical,
              sizeFactor: animation,
              child: _buildItem(participants[index], index, animation,
                  widget.onChangedParticipant),
            );
          },
        ),
      ],
    );
  }

  Widget _buildItem(Participant participant, int index,
      Animation<double> animation, Function onChangedParticipant) {
    print('buildItem!!!');
    return CardParticipant(participant, index, onChangedParticipant);
  }

  Widget _buildRemovedItem(participant, index) {
    return CardParticipant(participant, index, onChangeParticipant);
  }

  void onChangeParticipant(GlobalKey<FormBuilderState> _fbKey, int index,
      Formule formule, String val, bool isNom) {}

  void onTap(bool plus, int index, Formule formule) {
    if (plus) {
      participants.insert(index, Participant(index: index, formule: formule));
      _listKey.currentState
          .insertItem(index, duration: Duration(milliseconds: 500));
      setState(() {
        nb++;
      });
    } else {
      Participant participant = participants.removeAt(index);
      _listKey.currentState.removeItem(
        index,
        (BuildContext context, Animation<double> animation) {
          return FadeTransition(
            opacity:
                CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0)),
            child: SizeTransition(
              sizeFactor:
                  CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
              axisAlignment: 0.0,
              child: _buildRemovedItem(participant, index),
            ),
          );
        },
        duration: Duration(milliseconds: 600),
      );
      setState(() {
        nb--;
      });
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class ShowDialogToDismiss extends StatelessWidget {
  final String content;
  final String title;
  final String buttonText;

  ShowDialogToDismiss({this.title, this.buttonText, this.content});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) {
      return AlertDialog(
        title: new Text(
          title,
        ),
        content: new Text(
          this.content,
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text(
              buttonText,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    } else {
      return CupertinoAlertDialog(
          title: Text(
            title,
          ),
          content: new Text(
            this.content,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: new Text(
                buttonText[0].toUpperCase() +
                    buttonText.substring(1).toLowerCase(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ]);
    }
  }
}

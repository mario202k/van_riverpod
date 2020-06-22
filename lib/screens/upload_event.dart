import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/formule.dart';
import 'package:vanevents/screens/model_body.dart';
import 'package:vanevents/screens/model_screen.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/indicator.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';
import 'package:vanevents/shared/topAppBar.dart';

import '../main.dart';


class UploadEvent extends StatefulWidget {
  final String idEvent;

  UploadEvent({this.idEvent});

  @override
  _UploadEventState createState() => _UploadEventState();
}

class _UploadEventState extends State<UploadEvent> {
  List<Asset> images = List<Asset>();
  List<File> imagesEvent = List<File>();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _rue = TextEditingController();
  final TextEditingController _codePostal = TextEditingController();
  final TextEditingController _ville = TextEditingController();
  final TextEditingController _coords = TextEditingController();
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();

  List<FocusScopeNode> _nodes;
  DateTime _dateDebut, _dateFin;

  List<CircularSegmentEntry> circularSegmentEntry;
  GlobalKey<FormBuilderState> _fbKey =
      GlobalKey<FormBuilderState>();
  List<CircularStackEntry> data = List<CircularStackEntry>();
  List<Indicator> _listIndicator = List<Indicator>();

  List<Widget> formulesWidgets = List<Widget>();
  List<int> listColors;

  bool showSpinner = false;

  int nbTotal = 0;
//
//  Future _getImageCamera() async {
//    var image = await ImagePicker.pickImage(source: ImageSource.camera);
//
//    if (image != null) {
//      String path = image.path;
//      print(path.substring(path.lastIndexOf('/') + 1));
//      setState(() {
//        _imageFlyer = image;
//      });
//    } else {
//      retrieveLostData();
//    }
//  }
//
//  Future _getImageGallery() async {
//    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
//
//    if (image != null) {
//      String path = image.path;
//      print(path.substring(path.lastIndexOf('/') + 1));
//      setState(() {
//        _imageFlyer = image;
//      });
//    } else {
//      ImagePicker.retrieveLostData().then((image) {
//        if (image.file != null) {
//          String path = image.file.path;
//          print(path.substring(path.lastIndexOf('/') + 1));
//          setState(() {
//            _imageFlyer = image.file;
//          });
//        }
//        print(image.file);
//        print('//');
//      });
//      retrieveLostData();
//    }
//  }
//
//  Future<void> retrieveLostData() async {
//    final LostDataResponse response = await ImagePicker.retrieveLostData();
//    if (response == null) {
//      return;
//    }
//    if (response.file != null) {
//      setState(() {
//        _imageFlyer = response.file;
//      });
//    } else {
//      print(response.exception);
//    }
//  }

  @override
  void initState() {
    listColors =
        List<int>.generate(Colors.primaries.length, (int index) => index);
    listColors.shuffle();
    _nodes = List<FocusScopeNode>.generate(8, (index) => FocusScopeNode());
    addFormule();

    super.initState();
  }

  void addFormule() {
    List<CircularSegmentEntry> circularSegmentEntry;

    if (data.isEmpty) {
      circularSegmentEntry = List<CircularSegmentEntry>();
    } else {
      circularSegmentEntry = data[0].entries;
    }

    circularSegmentEntry.add(CircularSegmentEntry(
        0, Colors.primaries[listColors[circularSegmentEntry.length]],
        rankKey: 'f${circularSegmentEntry.length}'));
    data = <CircularStackEntry>[
      CircularStackEntry(
        circularSegmentEntry,
        rankKey: 'Les formules',
      ),
    ];
    if (_chartKey.currentState != null) {
      _chartKey.currentState.updateData(data);
    }

    setState(() {
      formulesWidgets.add(CardFormula(circularSegmentEntry.length - 1, (value) {
        //nombe de personne
        String str = value;
        int index = int.parse(str.substring(0, str.indexOf('/')));
        String val = str.substring(str.indexOf('/') + 1);

        if (val.isNotEmpty) {
          double nb = double.parse(val);
          data[0].entries.removeAt(index);
          List<CircularSegmentEntry> circularSegmentEntry = data[0].entries;
          data[0].entries.insert(
              index,
              CircularSegmentEntry(nb, Colors.primaries[listColors[index]],
                  rankKey: 'f${circularSegmentEntry.length}'));
          data = <CircularStackEntry>[
            CircularStackEntry(
              circularSegmentEntry,
              rankKey: 'Les formules',
            ),
          ];
          if (_chartKey.currentState != null) {
            _chartKey.currentState.updateData(data);
          }

          nbTotal = 0;
          data[0].entries.forEach((d) {
            print(d.value.toInt());
            nbTotal += d.value.toInt();
          });
        }
      }));
      formulesWidgets.add(Divider());
      _listIndicator.add(
        Indicator(
          color: Colors.primaries[listColors[circularSegmentEntry.length - 1]],
          text: 'F${circularSegmentEntry.length}',
          isSquare: false,
          size: 16,
          textColor: Colors.white,
        ),
      );
    });
  }

  void deleteFormule() {
    data[0].entries.removeLast();
    if (_chartKey.currentState != null) {
      _chartKey.currentState.updateData(data);
    }
    setState(() {
      formulesWidgets.removeLast();
      formulesWidgets.removeLast();
      _listIndicator.removeLast();
    });
    nbTotal = 0;
    data[0].entries.forEach((d) {
      nbTotal += d.value.toInt();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nodes.forEach((node) => node.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final FirestoreDatabase db =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final image = Provider.of<BoolToggle>(context);

    return ModelScreen(
      child: Scaffold(
        appBar: AppBar(title: Text('Monitoring'),),

        body: ModelBody(
          child: Column(
            children: <Widget>[
              Text('Flyer',style: Theme.of(context).textTheme.bodyText2,),
              InkWell(
                onTap: () {
                  showDialogSource(context, 'Flyer');
                },
                child: Container(
                  child: image.flyer != null
                      ? Image.file(
                    image.flyer,
                  )
                      : Icon(
                    FontAwesomeIcons.cloudUploadAlt,
                    color: Theme.of(context).colorScheme.primary,
                    size: 220,
                  ),
                ),
              ),
              Text('Banner',style: Theme.of(context).textTheme.bodyText2,),
              InkWell(
                onTap: () {
                  showDialogSource(context, 'Banner');
                },
                child: Container(
                  child: image.banner != null
                      ? Image.file(
                    image.banner,
                  )
                      : Icon(
                    FontAwesomeIcons.cloudUploadAlt,
                    color: Theme.of(context).colorScheme.primary,
                    size: 150,
                  ),
                ),
              ),
              Text('Photos',style: Theme.of(context).textTheme.bodyText2,),
              InkWell(
                onTap: loadAssets,
                child: images.length > 0
                    ? GridView.builder(
                    itemCount: images.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                        (orientation == Orientation.landscape) ? 3 : 2),
                    itemBuilder: (BuildContext context, int index) {
                      Asset asset = images[index];

                      return AssetThumb(
                        asset: asset,
                        width: 300,
                        height: 300,
                      );
                    })
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.cloudUploadAlt,
                      color: Theme.of(context).colorScheme.primary,
                      size: 100,
                    ),
                    Icon(
                      FontAwesomeIcons.cloudUploadAlt,
                      color: Theme.of(context).colorScheme.primary,
                      size: 100,
                    ),
                    Icon(
                      FontAwesomeIcons.cloudUploadAlt,
                      color: Theme.of(context).colorScheme.primary,
                      size: 100,
                    )
                  ],
                ),
              ),
              Text('Genre',style: Theme.of(context).textTheme.bodyText2,),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: image.genre.keys
                    .map((e) => SizedBox(
                  height: 55,
                  child: Consumer<BoolToggle>(
                    builder: (BuildContext context, BoolToggle value,
                        Widget child) {
                      return CheckboxListTile(
                        onChanged: (bool val) =>
                            value.modificationGenre(e),
                        value: value.genre[e],
                        activeColor:
                        Theme.of(context).colorScheme.primary,
                        title: Text(e),
                      );
                    },
                  ),
                ))
                    .toList(),
              ),
              Text('Type',style: Theme.of(context).textTheme.bodyText2,),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: image.type.keys
                    .map((e) => SizedBox(
                  height: 55,
                  child: Consumer<BoolToggle>(
                    builder: (BuildContext context, BoolToggle value,
                        Widget child) {
                      return CheckboxListTile(
                        onChanged: (bool val) =>
                            value.modificationType(e),
                        value: value.type[e],
                        activeColor:
                        Theme.of(context).colorScheme.primary,
                        title: Text(e),
                      );
                    },
                  ),
                ))
                    .toList(),
              ),
              Text('A l\'affiche',style: Theme.of(context).textTheme.bodyText2,),
              Consumer<BoolToggle>(
                builder: (BuildContext context, BoolToggle value, Widget child) {

                  return CheckboxListTile(
                    onChanged: (bool val) =>
                        value.setIsAffiche(),
                    value: value.isAffiche,
                    activeColor:
                    Theme.of(context).colorScheme.primary,
                    title: Text('A l\'affiche'),
                  );

                },

              ),
              IntrinsicHeight(
                child: FormBuilder(
                  // context,
                  key: _fbKey,
                  autovalidate: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Divider(),
                      FormBuilderTextField(
                        controller: _title,
                        attribute: 'Titre',
                        maxLines: 1,

                        focusNode: _nodes[0],
                        onEditingComplete: () {
                          if (_fbKey.currentState.fields['Titre'].currentState
                              .validate()) {
                            _nodes[0].unfocus();

                            FocusScope.of(context).requestFocus(_nodes[1]);
                          }
                        },
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        decoration: InputDecoration(labelText: 'Titre'),
                        validators: [
                          FormBuilderValidators.required(
                              errorText: 'Champs requis'),
                        ],
                      ),
                      Divider(),
                      Text('Durée',style: Theme.of(context).textTheme.bodyText2,),
                      FormBuilderDateTimePicker(
                        firstDate: DateTime.now(),
                        attribute: "Date de debut",
                        focusNode: _nodes[1],
                        onChanged: (dt) {
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                          context.read<BoolToggle>().modificationDateDebut(dt);

                          setState(() {
                            _dateDebut = dt;

                          });
                        },
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        inputType: InputType.both,
                        format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                        decoration: InputDecoration(labelText: 'Date de debut'),
                        validators: [
                          FormBuilderValidators.required(
                              errorText: "champs requis")
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      FormBuilderDateTimePicker(
                        firstDate: DateTime.now(),
                        initialDate: _dateDebut ?? DateTime.now(),
                        attribute: "Date de fin",
                        onChanged: (dt) {
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                          setState(() => _dateFin = dt);
                        },
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        focusNode: _nodes[2],
                        onEditingComplete: () {
                          if (_fbKey
                              .currentState.fields['Date de fin'].currentState
                              .validate()) {
                            _nodes[2].unfocus();
                            //FocusScope.of(context).requestFocus(_nodes[3]);
                          }
                        },
                        inputType: InputType.both,
                        format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                        decoration: InputDecoration(labelText: 'Date de fin'),
                        validators: [
                          FormBuilderValidators.required(
                              errorText: "champs requis")
                        ],
                      ),
                      Divider(),
                      Text('Adresse',style: Theme.of(context).textTheme.bodyText2,),
                      FormBuilderTextField(
                        controller: _rue,
                        attribute: 'Rue',
                        maxLines: 1,

                        focusNode: _nodes[3],
                        onEditingComplete: () {
                          if (_fbKey.currentState.fields['Rue'].currentState
                              .validate()) {
                            _nodes[3].unfocus();

                            FocusScope.of(context).requestFocus(_nodes[4]);
                          }
                        },
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        decoration: InputDecoration(labelText: 'Rue'),
                        validators: [
                          FormBuilderValidators.required(
                              errorText: 'Champs requis'),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      FormBuilderTextField(
                        controller: _codePostal,
                        attribute: 'Code Postal',
                        maxLines: 1,

                        focusNode: _nodes[4],
                        onEditingComplete: () {
                          if (_fbKey
                              .currentState.fields['Code Postal'].currentState
                              .validate()) {
                            _nodes[4].unfocus();

                            FocusScope.of(context).requestFocus(_nodes[5]);
                          }
                        },
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        decoration: InputDecoration(labelText: 'Code Postal'),
                        validators: [
                          FormBuilderValidators.required(
                              errorText: 'Champs requis'),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      FormBuilderTextField(
                        controller: _ville,
                        attribute: 'Ville',
                        maxLines: 1,

                        focusNode: _nodes[5],
                        onEditingComplete: () {
                          if (_fbKey.currentState.fields['Ville'].currentState
                              .validate()) {
                            _nodes[5].unfocus();

                            FocusScope.of(context).requestFocus(_nodes[6]);
                          }
                        },
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        decoration: InputDecoration(labelText: 'Ville'),
                        validators: [
                          FormBuilderValidators.required(
                              errorText: 'Champs requis'),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      FormBuilderTextField(
                        controller: _coords,
                        attribute: 'Coordonnée',
                        maxLines: 1,

                        focusNode: _nodes[6],


                        onEditingComplete: () {
                          if (_fbKey
                              .currentState.fields['Coordonnée'].currentState
                              .validate()) {
                            _nodes[6].unfocus();

                            FocusScope.of(context).requestFocus(_nodes[7]);
                          }
                        },
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        decoration: InputDecoration(labelText: 'Coordonnée'),
                        validators: [
                          FormBuilderValidators.required(
                              errorText: 'Champs requis'),
                              (val) {
                            RegExp regex = RegExp(
                                r'^([-+]?)([\d]{1,2})(((\.)(\d+)(,)))(\s*)(([-+]?)([\d]{1,3})((\.)(\d+))?)$');

                            if (regex.allMatches(val).length == 0) {
                              return 'Coordonnée non valide';
                            }
                            return null;
                          },
                        ],
                      ),
                      Divider(),

                      FormBuilderTextField(
                        controller: _description,
                        attribute: 'description',



                        maxLines: 10,
                        focusNode: _nodes[7],
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground),
                        cursorColor: Theme.of(context).colorScheme.onBackground,
                        decoration: InputDecoration(labelText: 'Description'),
                        validators: [
                          FormBuilderValidators.required(
                              errorText: 'Champs requis')
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Divider(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: formulesWidgets,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RawMaterialButton(
                    onPressed: () {
                      if (formulesWidgets.length > 2) {
                        deleteFormule();
                      }
                    },
                    child: Icon(
                      FontAwesomeIcons.minus,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 5.0,
                    fillColor: Color(0xffFAF4F2),
                    padding: const EdgeInsets.all(10.0),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      addFormule();
                    },
                    child: Icon(
                      FontAwesomeIcons.plus,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30.0,
                    ),
                    shape: CircleBorder(),
                    elevation: 5.0,
                    fillColor: Color(0xffFAF4F2),
                    padding: const EdgeInsets.all(10.0),
                  ),
                ],
              ),
              Divider(),
              SizedBox(
                height: 300,
                child: AnimatedCircularChart(
                  key: _chartKey,
                  size: const Size(300.0, 300.0),
                  initialChartData: data,
                  chartType: CircularChartType.Radial,
                  //percentageValues: true,
                  holeLabel: nbTotal.toString(),
                  labelStyle: new TextStyle(
                    color: Colors.blueGrey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 40,
                direction: Axis.horizontal,
                runSpacing: 5,
                children: _listIndicator,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: !showSpinner
                          ? RaisedButton(
                        child: Text(
                          "Soumettre",
                        ),
                        onPressed: () {
                          _fbKey.currentState.save();
                          if (_fbKey.currentState.validate()) {
                            String adresse = _fbKey
                                .currentState
                                .fields['Rue']
                                .currentState
                                .value +' '+
                                _fbKey.currentState.fields['Code Postal']
                                    .currentState.value +' '+
                                _fbKey.currentState.fields['Ville']
                                    .currentState.value;
                            String coordsString = _fbKey
                                .currentState
                                .fields['Coordonnée']
                                .currentState
                                .value;
                            String latitude = coordsString
                                .substring(0, coordsString.indexOf(','))
                                .trim();
                            String longitude = coordsString
                                .substring(
                                coordsString.indexOf(',') + 1)
                                .trim();

                            Coords coords = Coords(
                                double.parse(latitude),
                                double.parse(longitude));

                            List<Formule> formules = List<Formule>();

                            formulesWidgets.forEach((f) {
                              if (f is CardFormula) {
                                if (f.fbKey.currentState.validate()) {
                                  formules.add(Formule(
                                      title: f
                                          .fbKey
                                          .currentState
                                          .fields['Nom']
                                          .currentState
                                          .value,
                                      prix: double.parse(f
                                          .fbKey
                                          .currentState
                                          .fields['Prix']
                                          .currentState
                                          .value
                                          .toString()),
                                      nombreDePersonne: int.parse(f
                                          .fbKey
                                          .currentState
                                          .fields[
                                      'Nombre de personne par formule']
                                          .currentState
                                          .value),
                                      id: f.numero.toString()));
                                } else {

                                  showSnackBar(
                                      'Corriger la formule n°${f.numero}',
                                      context);
                                }
                              }
                            });

                            if (formules.length ==
                                formulesWidgets.length / 2) {
                              setState(() {
                                showSpinner = true;
                              });

                              db.uploadEvent(
                                  context: context,
                                  type: context.read<BoolToggle>().type,
                                  genre: context.read<BoolToggle>().genre,
                                  titre: _title.text,
                                  formules: formules,
                                  adresse: adresse,
                                  coords: coords,
                                  dateDebut: _dateDebut,
                                  dateFin: _dateFin,
                                  description: _description.text,
                                  flyer: context.read<BoolToggle>().flyer,
                                  banner: context.read<BoolToggle>().banner,
                                  images: images,
                                  isAffiche: context.read<BoolToggle>().isAffiche
                              )
                                  .whenComplete(() {
                                setState(() {
                                  showSpinner = false;
                                });
                              });
                            }

                            //Navigator.pop(context);
                          } else {
                            //print(_fbKey.currentState.value);
                            print("validation failed");
                            showSnackBar(
                                'formulaire non valide', context);
                          }
                        },
                      )
                          : Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary)),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: RaisedButton(
                      //color: Theme.of(context).colorScheme,
                      child: Text(
                        "Recommencer",
                        //style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        _fbKey.currentState.reset();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadAssets() async {
    print("loadAssets");
    List<Asset> resultList = List<Asset>();


    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 20,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print(e);

    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;

    });
  }

  void showDialogSource(BuildContext context, String type) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Platform.isAndroid
          ? AlertDialog(
              title: Text('Source?'),
              content: Text('Veuillez choisir une source'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Caméra'),
                  onPressed: () {
                    context.read<BoolToggle>().getImageCamera(type);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Galerie'),
                  onPressed: () {
                    context.read<BoolToggle>().getImageGallery(type);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          : CupertinoAlertDialog(
              title: Text('Source?'),
              content: Text('Veuillez choisir une source'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Caméra'),
                  onPressed: () {
                    context.read<BoolToggle>().getImageCamera(type);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Galerie'),
                  onPressed: () {
                    context.read<BoolToggle>().getImageGallery(type);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
    );
  }

  void showSnackBar(String val, BuildContext context) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        )));
  }
}

class CardFormula extends StatefulWidget {
  final int numero;

  final Function onChangedNbPersonne;
  final GlobalKey<FormBuilderState> fbKey = GlobalKey();

  CardFormula(this.numero, this.onChangedNbPersonne);

  @override
  _CardFormulaState createState() => _CardFormulaState();
}

class _CardFormulaState extends State<CardFormula> {
  List<FocusScopeNode> _nodes;
  TextEditingController _textEditingControllerNom = TextEditingController();
  TextEditingController _textEditingControllerPrenom = TextEditingController();
  TextEditingController _textEditingControllernb = TextEditingController();

  @override
  void initState() {
    _nodes = List<FocusScopeNode>.generate(
      3,
      (index) => FocusScopeNode(),
    );
    super.initState();
  }

  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
        child: FormBuilder(
          key: widget.fbKey,
          autovalidate: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Formule n° ${widget.numero + 1}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                controller: _textEditingControllerNom,
                attribute: 'Nom',
                decoration: InputDecoration(labelText: 'Nom'),
                onChanged: (val) {
                  widget.fbKey.currentState.save();

                },

                focusNode: _nodes[0],
                onEditingComplete: () {
                  if (widget.fbKey.currentState.fields['Nom'].currentState
                      .validate()) {
                    _nodes[0].unfocus();

                    FocusScope.of(context).requestFocus(_nodes[1]);
                  }
                },
                keyboardType: TextInputType.text,
                validators: [
                  FormBuilderValidators.required(errorText: 'Champs requis'),
//                      (val) {
//                    RegExp regex = RegExp(
//                        r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ ]{2,30}$');
//
//                    if (regex.allMatches(val).length == 0) {
//                      return 'Entre 2 et 30, ';
//                    }
//                  },
                ],
              ),
              SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                controller: _textEditingControllerPrenom,
                attribute: 'Prix',
                decoration: InputDecoration(labelText: 'Prix'),

                onChanged: (val) {
                  widget.fbKey.currentState.save();

                },
                focusNode: _nodes[1],
                onEditingComplete: () {
                  if (widget.fbKey.currentState.fields['Prix'].currentState
                      .validate()) {
                    _nodes[1].unfocus();

                    FocusScope.of(context).requestFocus(_nodes[2]);
                  }
                },
                keyboardType: TextInputType.number,
                validators: [
                  FormBuilderValidators.required(errorText: 'Champs requis')
                ],
              ),
              SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                controller: _textEditingControllernb,
                attribute: 'Nombre de personne par formule',
                decoration: InputDecoration(labelText: 'Nombre de personne par formule'),


                onChanged: (value) {
                  widget.fbKey.currentState.save();

                  if (widget.onChangedNbPersonne != null) {
                    widget.fbKey.currentState.save();
                    widget.onChangedNbPersonne('${widget.numero}/$value');
                  }
                },
                focusNode: _nodes[2],
                onEditingComplete: () {
                  if (widget.fbKey.currentState
                      .fields['Nombre de personne par formule'].currentState
                      .validate()) {
                    _nodes[2].unfocus();
                  }
                },
                keyboardType: TextInputType.number,
                validators: [
                  FormBuilderValidators.required(errorText: 'Champs requis')
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

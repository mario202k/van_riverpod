import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/formule.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/indicator.dart';
import 'package:vanevents/shared/topAppBar.dart';

class UploadEvent extends StatefulWidget {

  final String idEvent;
  UploadEvent({this.idEvent});

  @override
  _UploadEventState createState() => _UploadEventState();
}

class _UploadEventState extends State<UploadEvent> {
  File _image;
  final TextEditingController _description = TextEditingController();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _coords = TextEditingController();
  final GlobalKey<AnimatedCircularChartState> _chartKey =
  new GlobalKey<AnimatedCircularChartState>();

  List<FocusScopeNode> _nodes;
  DateTime _dateDebut, _dateFin;

  List<CircularSegmentEntry> circularSegmentEntry;
  final GlobalKey<FormBuilderState> _fbKey =
      GlobalKey<FormBuilderState>(debugLabel: '_homeScreenkey');
  final GlobalKey<FormFieldState> _specifyTextFieldKey =
      GlobalKey<FormFieldState>();
  List<CircularStackEntry> data = List<CircularStackEntry>();
  List<Indicator> _listIndicator = List<Indicator>();

  List<Widget> formulesWidgets = List<Widget>();
  List<int> listColors;

  bool showSpinner = false;

  int nbTotal = 0;

  Future _getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    if(image!= null){
      String path = image.path;
      print(path.substring(path.lastIndexOf('/') + 1));
      setState(() {
        _image = image;
      });
    }else{
      retrieveLostData();
    }

  }

  Future _getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(image!= null){
      String path = image.path;
      print(path.substring(path.lastIndexOf('/') + 1));
      setState(() {
        _image = image;
      });
    }else{
      ImagePicker.retrieveLostData().then((image){
        if(image.file!= null){
          String path = image.file.path;
          print(path.substring(path.lastIndexOf('/') + 1));
          setState(() {
            _image = image.file;
          });
        }
        print(image.file);
        print('//');
      });
      retrieveLostData();
    }

  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response =
    await ImagePicker.retrieveLostData();
    if (response == null) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = response.file;
      });
    } else {
      print(response.exception);
    }
  }

  @override
  void initState() {
    listColors = List<int>.generate(Colors.primaries.length, (int index) => index);
    listColors.shuffle();
    _nodes = List<FocusScopeNode>.generate(5, (index) => FocusScopeNode());
    addFormule();

    super.initState();
  }



  void addFormule() {



    List<CircularSegmentEntry> circularSegmentEntry ;

    if(data.isEmpty){
      circularSegmentEntry = List<CircularSegmentEntry>();
    }else{
      circularSegmentEntry = data[0].entries;
    }



    circularSegmentEntry.add(CircularSegmentEntry(0, Colors.primaries[listColors[circularSegmentEntry.length]],
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



      formulesWidgets.add(CardFormula(circularSegmentEntry.length-1, (value) {
        //nombe de personne
        String str = value;
        int index = int.parse(str.substring(0, str.indexOf('/'))) ;
        String val = str.substring(str.indexOf('/') + 1);


        if (val.isNotEmpty) {
          double nb = double.parse(val);
          data[0].entries.removeAt(index);
          List<CircularSegmentEntry> circularSegmentEntry = data[0].entries;
          data[0].entries.insert(index, CircularSegmentEntry(nb, Colors.primaries[listColors[index]],
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
          data[0].entries.forEach((d){
            print(d.value.toInt());
            nbTotal += d.value.toInt();

          });


        }
      }));
      formulesWidgets.add(Divider());
      _listIndicator.add(
        Indicator(
          color: Colors.primaries[listColors[circularSegmentEntry.length-1]],
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
    data[0].entries.forEach((d){
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
    final FirestoreDatabase db =
        Provider.of<FirestoreDatabase>(context, listen: false);

    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(double.infinity, 100),
            child: TopAppBar('Upload', false,
                     double.infinity),
          ),
            backgroundColor: Theme.of(context).colorScheme.background,
            body: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                      minHeight: constraints.maxHeight),
                  child: Column(
                    children: <Widget>[

                      IntrinsicHeight(
                        child: FormBuilder(
                          // context,
                          key: _fbKey,
                          autovalidate: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return PlatformAlertDialog(
                                        title: Text(
                                          'Source?',
                                          style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 22),
                                        ),
                                        actions: <Widget>[
                                          PlatformDialogAction(
                                            child: Text(
                                              'Caméra',
                                              style: Theme.of(context).textTheme.subhead,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              _getImageCamera();
                                            },
                                          ),
                                          PlatformDialogAction(
                                            child: Text(
                                              'Galerie',
                                              style: Theme.of(context).textTheme.subhead,
                                            ),
                                            //actionType: ActionType.,
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              _getImageGallery();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  child: _image != null
                                      ? Image.file(
                                          _image,
                                        )
                                      : Icon(
                                          FontAwesomeIcons.cloudUploadAlt,
                                          color:
                                              Theme.of(context).colorScheme.secondary,
                                          size: 220,
                                        ),
                                ),
                              ),
                              Divider(),
                              FormBuilderTextField(
                                controller: _title,
                                attribute: 'Titre',
                                  maxLines:1,
                                onChanged: (val) {
                                  if (_title.text.length == 0) {
                                    _title.clear();
                                  }
                                },
                                focusNode: _nodes[0],
                                onEditingComplete: () {

                                  if (_fbKey.currentState.fields['Titre'].currentState.validate()) {
                                    _nodes[0].unfocus();

                                    FocusScope.of(context)
                                        .requestFocus(_nodes[1]);
                                  }
                                },
                                style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                                cursorColor: Theme.of(context).colorScheme.onBackground,

                                decoration: buildInputDecoration(context, 'Titre'),
                                validators: [

                                  FormBuilderValidators.required(
                                      errorText: 'Champs requis'),
//                                  (val) {
//                                RegExp regex = RegExp(
//                                    r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ ]{1,20}$');
//
//                                if (regex.allMatches(val).length == 0) {
//                                  return 'Entre 1 et 20, ';
//                                }
//                              },

                                ],
                              ),
                              Divider(),
                              FormBuilderDateTimePicker(
                                attribute: "Date de debut",
                                focusNode: _nodes[1],
                                onChanged: (dt) {
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide');
                                  setState(() => _dateDebut = dt);
                                },
                                style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                                cursorColor: Theme.of(context).colorScheme.onBackground,
                                onEditingComplete: () {

                                  if (_fbKey.currentState.fields['Date de debut'].currentState.validate()) {
                                    _nodes[1].unfocus();

                                    FocusScope.of(context)
                                        .requestFocus(_nodes[2]);
                                  }
                                },
                                inputType: InputType.both,
                                format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                                decoration:
                                    buildInputDecoration(context, 'Date de debut'),
                                validators: [
                                  FormBuilderValidators.required(
                                      errorText: "champs requis")
                                ],
                              ),
                              Divider(),
                              FormBuilderDateTimePicker(
                                attribute: "Date de fin",
                                onChanged: (dt) {
                                  SystemChannels.textInput
                                      .invokeMethod('TextInput.hide');
                                  setState(() => _dateFin = dt);
                                },
                                style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                                cursorColor: Theme.of(context).colorScheme.onBackground,
                                focusNode: _nodes[2],
                                onEditingComplete: () {

                                  if (_fbKey.currentState.fields['Date de fin'].currentState.validate()) {
                                    _nodes[2].unfocus();

                                  }
                                },
                                inputType: InputType.both,
                                format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                                decoration:
                                    buildInputDecoration(context, 'Date de fin'),
                                validators: [
                                  FormBuilderValidators.required(
                                      errorText: "champs requis")
                                ],
                              ),
                              Divider(),
                              FormBuilderCustomField(
                                attribute: 'Adresse',

                                valueTransformer: (val) {
                                  if (val == "Autre")
                                    return _specifyTextFieldKey.currentState.value;
                                  return val;
                                },
                                formField: FormField(
                                  builder: (FormFieldState<String> field) {
                                    var languages = [
                                      '18 avenue de la folie 56050 Danser',
                                      '14 rue de la discothèque 47000 Ambiance',
                                      "Autre"
                                    ];
                                    return InputDecorator(
                                      decoration:
                                          buildInputDecoration(context, 'Adresse'),
                                      child: Column(
                                        children: languages
                                            .map(
                                              (lang) => Row(
                                                children: <Widget>[
                                                  Radio<dynamic>(
                                                    activeColor: Colors.green,
                                                    value: lang,
                                                    groupValue: field.value,
                                                    onChanged: (dynamic value) {
                                                      field.didChange(lang);
                                                    },
                                                  ),
                                                  Flexible(
                                                    child: lang != "Autre"
                                                        ? Text(
                                                            lang,
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .button,
                                                            textAlign: TextAlign.left,
                                                          )
                                                        : Row(
                                                            children: <Widget>[
                                                              Text(
                                                                lang,
                                                                style:
                                                                    Theme.of(context)
                                                                        .textTheme
                                                                        .button,
                                                              ),
                                                              SizedBox(width: 20),
                                                              Expanded(
                                                                child: TextFormField(
                                                                  style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                                                                  cursorColor: Theme.of(context).colorScheme.onBackground,
                                                                  key:
                                                                      _specifyTextFieldKey,
                                                                  decoration:
                                                                      buildInputDecoration(
                                                                          context,
                                                                          ''),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(growable: false),
                                      ),
                                    );
                                  },
                                ),
                                validators: [
                                  FormBuilderValidators.required(
                                      errorText: "champs requis")
                                ],
                              ),
                              FormBuilderTextField(
                                controller: _coords,
                                attribute: 'Coordonnée',
                                maxLines:1,

                                focusNode: _nodes[3],
                                onEditingComplete: () {

                                  if (_fbKey.currentState.fields['Coordonnée'].currentState.validate()) {
                                    _nodes[3].unfocus();

                                    FocusScope.of(context)
                                        .requestFocus(_nodes[4]);
                                  }
                                },
                                style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                                cursorColor: Theme.of(context).colorScheme.onBackground,

                                decoration: buildInputDecoration(context, 'Coordonnée'),
                                validators: [

                                  FormBuilderValidators.required(
                                      errorText: 'Champs requis'),
                                      (val) {
                                    RegExp regex = RegExp(
                                        r'^([-+]?)([\d]{1,2})(((\.)(\d+)(,)))(\s*)(([-+]?)([\d]{1,3})((\.)(\d+))?)$');

                                    if (regex.allMatches(val).length == 0) {
                                      return 'Coordonnée non valide';
                                    }
                                  },
                                ],
                              ),
                              FormBuilderTextField(
                                controller: _description,
                                attribute: 'description',
                                maxLines: 10,
                                focusNode: _nodes[4],
                                style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                                cursorColor: Theme.of(context).colorScheme.onBackground,
                                decoration:
                                    buildInputDecoration(context, 'Description'),
                                validators: [
                                  FormBuilderValidators.required(
                                      errorText: 'Champs requis')
                                ],
                              ),
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
                                      color: Colors.purpleAccent,
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
                                      color: Colors.purpleAccent,
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
                                      transitionBuilder: (Widget child, Animation<double> animation) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        );
                                      },
                                      child: !showSpinner ? RaisedButton(
                                        //color: Theme.of(context).accentColor,
                                        child: Text(
                                          "Soumettre",
                                          //style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          _fbKey.currentState.save();
                                          if (_fbKey.currentState.validate()) {


                                            if (_image != null) {
                                              String adresse = _fbKey
                                                          .currentState
                                                          .fields['Adresse']
                                                          .currentState
                                                          .value ==
                                                      "Autre"
                                                  ? _specifyTextFieldKey
                                                      .currentState.value
                                                  : _fbKey
                                                      .currentState
                                                      .fields['Adresse']
                                                      .currentState
                                                      .value;
                                              String coordsString = _fbKey
                                                  .currentState
                                                  .fields['Coordonnée']
                                              .currentState.value;
                                              String latitude = coordsString.substring(0,coordsString.indexOf(',')).trim();
                                              String longitude = coordsString.substring(coordsString.indexOf(',')+1).trim();

                                              Coords coords = Coords(double.parse(latitude), double.parse(longitude));

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
                                                        prix:double.parse( f
                                                            .fbKey
                                                            .currentState
                                                            .fields['Prix']
                                                            .currentState
                                                            .value.toString()),
                                                        nombreDePersonne: int.parse(f
                                                            .fbKey
                                                            .currentState
                                                            .fields['Nombre de personne par formule']
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
                                                    _dateDebut,
                                                    _dateFin,
                                                    adresse,
                                                    coords,
                                                    _title.text,
                                                    _description.text,
                                                    _image,
                                                    formules,
                                                    context).whenComplete((){
                                                  setState(() {
                                                    showSpinner = false;
                                                  });
                                                });
                                              }

                                              //Navigator.pop(context);
                                            } else {
                                              showSnackBar(
                                                  'Il manque le Flyer', context);
                                            }
                                          } else {
                                            //print(_fbKey.currentState.value);
                                            print("validation failed");
                                            showSnackBar(
                                                'formulaire non valide', context);
                                          }
                                        },
                                      ):Center(
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
                    ],
                  ),
                ),
              );
            })),
      ),
    );
  }

  InputDecoration buildInputDecoration(BuildContext context, String labelText) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onBackground, width: 2),
          borderRadius: BorderRadius.circular(25.0)),
      labelText: labelText,
      labelStyle: Theme.of(context).textTheme.button,
      border: InputBorder.none,
      errorStyle: Theme.of(context).textTheme.button,
    );
  }

  void showSnackBar(String val, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
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
      color: Colors.green,
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
                'Formule n° ${widget.numero+1}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
              ),
              SizedBox(
                height: 10,
              ),
              FormBuilderTextField(
                controller: _textEditingControllerNom,
                attribute: 'Nom',
                decoration: buildInputDecoration(context,'Nom'),
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                cursorColor: Theme.of(context).colorScheme.onBackground,
                onChanged: (value) {
                  widget.fbKey.currentState.save();
                  if (_textEditingControllerNom.text.length == 0) {
                    _textEditingControllerNom.clear();
                  }
                },

                focusNode: _nodes[0],
                onEditingComplete: () {
                  if (widget.fbKey.currentState.fields['Nom'].currentState.validate()) {
                    _nodes[0].unfocus();

                    FocusScope.of(context)
                        .requestFocus(_nodes[1]);
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
                decoration: buildInputDecoration(context,'Prix'),
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                cursorColor: Theme.of(context).colorScheme.onBackground,
                onChanged: (value) {
                  widget.fbKey.currentState.save();
                  if (_textEditingControllerPrenom.text.length == 0) {
                    _textEditingControllerPrenom.clear();
                  }
                },
                focusNode: _nodes[1],
                onEditingComplete: () {
                  if (widget.fbKey.currentState.fields['Prix'].currentState.validate()) {
                    _nodes[1].unfocus();

                    FocusScope.of(context)
                        .requestFocus(_nodes[2]);
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
                decoration: buildInputDecoration(context,'Nombre de personne par formule'),
                style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                cursorColor: Theme.of(context).colorScheme.onBackground,
                onChanged: (value) {
                  if (_textEditingControllernb.text.length == 0) {
                    _textEditingControllernb.clear();
                  }
                  if (widget.onChangedNbPersonne != null) {
                    widget.fbKey.currentState.save();
                    widget.onChangedNbPersonne('${widget.numero}/$value');
                  }
                },

                focusNode: _nodes[2],
                onEditingComplete: () {
                  if (widget.fbKey.currentState.fields['Nombre de personne par formule'].currentState.validate()) {
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

  InputDecoration buildInputDecoration(BuildContext context, String labelText) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onBackground, width: 2),
          borderRadius: BorderRadius.circular(25.0)),
      labelText: labelText,
      labelStyle: Theme.of(context).textTheme.button,
      border: InputBorder.none,
      errorStyle: Theme.of(context).textTheme.button,
    );
  }


}

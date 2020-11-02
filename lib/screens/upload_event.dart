import 'dart:async';
import 'dart:io';

import 'package:after_init/after_init.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/credentials.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/models/formule.dart';
import 'package:vanevents/models/myUser.dart';
import 'package:vanevents/screens/model_body_login.dart';
import 'package:vanevents/screens/model_screen.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/indicator.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';

class UploadEvent extends StatefulWidget {
  final MyEvent myEvent;

  UploadEvent({this.myEvent});

  @override
  _UploadEventState createState() => _UploadEventState();
}

class _UploadEventState extends State<UploadEvent> with AfterInitMixin {
  List<Asset> images = List<Asset>();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _rue = TextEditingController();
  final TextEditingController _codePostal = TextEditingController();
  final TextEditingController _ville = TextEditingController();
  final TextEditingController _coords = TextEditingController();
  final TextEditingController _codePromo = TextEditingController();
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();
  ModelBodyLogin modelBodyLogin;

  final TextEditingController _searchEditingController =
      TextEditingController();

  String promotionCodeId;
  bool isUpdating;
  bool isUpdatingImages;
  List<Formule> formulas;

  PlacesDetailsResponse placesDetailsResponse;
  Timer _throttle;

  List<FocusScopeNode> _nodes;
  DateTime _dateDebut, _dateFin, _debutAffiche, _finAffiche;

  List<CircularSegmentEntry> circularSegmentEntry;
  GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  List<CircularStackEntry> data = List<CircularStackEntry>();
  List<Indicator> _listIndicator = List<Indicator>();

  List<Widget> formulesWidgets = List<Widget>();
  List<int> listColors;

  bool showSpinner = false;
  bool showSpinnerAppliquer = false;
  bool hasGetFormulas = false;
  bool hasGetDates = false;
  int nbTotal = 0;
  int daysAffiche;
  int daysOld;
  int percentOff;

  int amountOff;

  GlobalKey<ScaffoldState> myScaffold = GlobalKey<ScaffoldState>();

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
    context.read<BoolToggle>().initUploadEvent();
    _searchEditingController.addListener(_onSearchChanged);
    listColors =
        List<int>.generate(Colors.primaries.length, (int index) => index);
    listColors.shuffle();
    _nodes = List<FocusScopeNode>.generate(9, (index) => FocusScopeNode());
    context.read<BoolToggle>().setNullImage();
    isUpdating = widget.myEvent != null;
    isUpdatingImages = isUpdating;

    if (isUpdating) {
      context.read<BoolToggle>().initGenre(genres: widget.myEvent.genres);
      context.read<BoolToggle>().initType(types: widget.myEvent.types);

      _title.text = widget.myEvent.titre;
      _dateDebut = widget.myEvent.dateDebut;
      _dateFin = widget.myEvent.dateFin;
      _debutAffiche = widget.myEvent.dateDebutAffiche;
      _finAffiche = widget.myEvent.dateFinAffiche;
      _rue.text = widget.myEvent.adresseRue.join(' ');
      _codePostal.text = widget.myEvent.adresseZone[3];
      _ville.text = widget.myEvent.adresseZone[0];
      _coords.text = widget.myEvent.position.latitude.toString() +
          ',' +
          widget.myEvent.position.longitude.toString();
      _description.text = widget.myEvent.description;

      if (_debutAffiche != null && _finAffiche != null) {
        context.read<BoolToggle>().setIsAfficheNoNotif();

        // if (widget.myEvent.dateFinAffiche.compareTo(widget.myEvent.dateFin) !=
        //         0 &&
        //     widget.myEvent.uploadedDate.compareTo(widget.myEvent.dateDebut) !=
        //         0) {
        //   context.read<BoolToggle>().setJusquauJourJNoNotif();
        // }
      }
    } else {
      addFormule();
      context.read<BoolToggle>().initGenre();
      context.read<BoolToggle>().initType();
    }

    super.initState();
  }

  void addFormule({Formule formule}) {
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
      formulesWidgets.add(CardFormula(
        circularSegmentEntry.length - 1,
        (value) {
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
        },
        formule: formule,
      ));
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
    _searchEditingController.removeListener(_onSearchChanged);
    _searchEditingController.dispose();
  }

  _onSearchChanged() {
    if (_throttle?.isActive ?? false) {
      _throttle.cancel();
    }
    _throttle = Timer(const Duration(milliseconds: 500), () {
      getLocationResults(_searchEditingController.text, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final FirestoreDatabase db =
        Provider.of<FirestoreDatabase>(context, listen: false);
    final image = Provider.of<BoolToggle>(context);

    if (isUpdating && !hasGetFormulas) {
      hasGetFormulas = true;
      db.getFormulasList(widget.myEvent.id).then((form) {
        formulas = form;
        for (Formule formule in form) {
          addFormule(formule: formule);
        }
      });
    }
    if (context.watch<BoolToggle>().eventCost != null) {
      if (percentOff != null) {
        context.watch<BoolToggle>().setEventCostDiscountedNoNotif(
            context.watch<BoolToggle>().eventCost -
                context.watch<BoolToggle>().eventCost * (percentOff / 100));
      } else if (amountOff != null) {
        context.watch<BoolToggle>().setEventCostDiscountedNoNotif(
            context.watch<BoolToggle>().eventCost - amountOff);
      }
    }

    if (!isUpdating) {
      dateAffiche(context);
      updateDaysAffiche();
    }
    if (isUpdating && context.watch<BoolToggle>().isAffiche) {
      updateDaysAffiche();
    }

    modelBodyLogin = ModelBodyLogin(
      child: Column(
        children: <Widget>[
          Text(
            'Flyer',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          InkWell(
            onTap: () {
              showDialogSource(context, 'Flyer');
            },
            child: Container(
              child: image.flyer != null
                  ? Image.file(
                      image.flyer,
                    )
                  : isUpdating
                      ? CachedNetworkImage(
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor:
                                Theme.of(context).colorScheme.primary,
                            child: Container(
                                height: 900, width: 600, color: Colors.white),
                          ),
                          imageBuilder: (context, imageProvider) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: MediaQuery.of(context).size.width,
                            child: Image(
                              image: imageProvider,
                              fit: BoxFit.contain,
                            ),
                          ),
                          errorWidget: (context, url, error) => Material(
                            child: Image.asset(
                              'assets/img/img_not_available.jpeg',
                              width: 300.0,
                              height: 300.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                          imageUrl: widget.myEvent.imageFlyerUrl,
                          fit: BoxFit.scaleDown,
                        )
                      : Icon(
                          FontAwesomeIcons.image,
                          color: Theme.of(context).colorScheme.primary,
                          size: 220,
                        ),
            ),
          ),
          Text(
            'Photos',
            style: Theme.of(context).textTheme.bodyText2,
          ),
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
                : isUpdatingImages && widget.myEvent.imagePhotos.length > 0
                    ? GridView.builder(
                        itemCount: widget.myEvent.imagePhotos.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                (orientation == Orientation.landscape) ? 3 : 2),
                        itemBuilder: (BuildContext context, int index) {
                          return CachedNetworkImage(
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.white,
                              highlightColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Container(
                                  height: 300, width: 300, color: Colors.white),
                            ),
                            imageBuilder: (context, imageProvider) => SizedBox(
                              height: 300,
                              width: 300,
                              child: Image(
                                image: imageProvider,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'assets/img/img_not_available.jpeg',
                                width: 300.0,
                                height: 300.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: widget.myEvent.imagePhotos[index],
                            fit: BoxFit.scaleDown,
                          );
                        })
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.images,
                            color: Theme.of(context).colorScheme.primary,
                            size: 100,
                          ),
                          Icon(
                            FontAwesomeIcons.images,
                            color: Theme.of(context).colorScheme.primary,
                            size: 100,
                          ),
                          Icon(
                            FontAwesomeIcons.images,
                            color: Theme.of(context).colorScheme.primary,
                            size: 100,
                          )
                        ],
                      ),
          ),
          Text(
            'Genre',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: image.genre.keys
                .map((e) => SizedBox(
                      height: 55,
                      child: Consumer<BoolToggle>(
                        builder: (BuildContext context, BoolToggle value,
                            Widget child) {
                          return CheckboxListTile(
                            onChanged: (bool val) => value.modificationGenre(e),
                            value: value.genre[e],
                            activeColor: Theme.of(context).colorScheme.primary,
                            title: Text(
                              e,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          );
                        },
                      ),
                    ))
                .toList(),
          ),
          Text(
            'Type',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: image.type.keys
                .map((e) => SizedBox(
                      height: 55,
                      child: Consumer<BoolToggle>(
                        builder: (BuildContext context, BoolToggle value,
                            Widget child) {
                          return CheckboxListTile(
                            onChanged: (bool val) => value.modificationType(e),
                            value: value.type[e],
                            activeColor: Theme.of(context).colorScheme.primary,
                            title: Text(
                              e,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          );
                        },
                      ),
                    ))
                .toList(),
          ),
          IntrinsicHeight(
            child: FormBuilder(
              // context,
              key: _fbKey,
              //autovalidate: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
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
                    style: Theme.of(context).textTheme.headline5,
                    cursorColor: Theme.of(context).colorScheme.onBackground,
                    decoration: InputDecoration(labelText: 'Titre'),
                    validators: [
                      FormBuilderValidators.required(
                          errorText: 'Champs requis'),
                    ],
                  ),
                  Divider(),
                  Text(
                    'Durée',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  FormBuilderDateTimePicker(
                    firstDate: DateTime.now(),
                    initialDate: !isUpdating
                        ? _dateDebut ?? DateTime.now()
                        : DateTime.now(),
                    locale: Locale('fr'),
                    attribute: "Date de debut",
                    focusNode: _nodes[1],
                    onChanged: (dt) {
                      // SystemChannels.textInput
                      //     .invokeMethod('TextInput.hide');
                      context.read<BoolToggle>().modificationDateDebut(dt);

                      setState(() {
                        _dateDebut = dt;
                      });
                    },
                    style: Theme.of(context).textTheme.headline5,
                    cursorColor: Theme.of(context).colorScheme.onBackground,
                    inputType: InputType.both,
                    format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                    decoration: InputDecoration(
                        labelText: !isUpdating
                            ? 'Date de debut'
                            : DateFormat("dd/MM/yyyy 'à' HH:mm")
                                .format(widget.myEvent.dateDebut)),
                    validators: [
                      FormBuilderValidators.required(errorText: "champs requis")
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  FormBuilderDateTimePicker(
                    firstDate: _dateDebut ?? DateTime.now(),
                    initialDate: _dateDebut ?? DateTime.now(),
                    attribute: "Date de fin",
                    onChanged: (dt) {
                      // SystemChannels.textInput
                      //     .invokeMethod('TextInput.hide');
                      setState(() => _dateFin = dt);
                    },
                    style: Theme.of(context).textTheme.headline5,
                    cursorColor: Theme.of(context).colorScheme.onBackground,
                    focusNode: _nodes[2],
                    onEditingComplete: () {
                      if (_fbKey.currentState.fields['Date de fin'].currentState
                          .validate()) {
                        _nodes[2].unfocus();
                        //FocusScope.of(context).requestFocus(_nodes[3]);
                      }
                    },
                    inputType: InputType.both,
                    format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                    decoration: InputDecoration(
                        labelText: !isUpdating
                            ? 'Date de fin'
                            : DateFormat("dd/MM/yyyy 'à' HH:mm")
                                .format(widget.myEvent.dateFin)),
                    validators: [
                      FormBuilderValidators.required(errorText: "champs requis")
                    ],
                  ),
                  Divider(),
                  Text(
                    'A l\'affiche',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  Consumer<BoolToggle>(
                    builder:
                        (BuildContext context, BoolToggle value, Widget child) {
                      return CheckboxListTile(
                        onChanged: (bool val) => value.setIsAffiche(),
                        value: value.isAffiche,
                        activeColor: Theme.of(context).colorScheme.primary,
                        title: Text(
                          'A l\'affiche',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      );
                    },
                  ),
                  context.watch<BoolToggle>().isAffiche
                      ? CheckboxListTile(
                          onChanged: (bool val) =>
                              context.read<BoolToggle>().setJusquauJourJ(),
                          value: context.watch<BoolToggle>().isJusquauJourJ,
                          activeColor: Theme.of(context).colorScheme.primary,
                          title: Text(
                            context.watch<BoolToggle>().isJusquauJourJ
                                ? 'Jusqu\'au jour J'
                                : 'Durée:',
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        )
                      : SizedBox(),
                  !context.watch<BoolToggle>().isJusquauJourJ &&
                          context.watch<BoolToggle>().isAffiche
                      ? Column(
                          children: [
                            FormBuilderDateTimePicker(
                              //firstDate: !isUpdating?DateTime.now():_debutAffiche.subtract(Duration(days: 15)),
                              //initialDate: !isUpdating?DateTime.now():_debutAffiche.subtract(Duration(days: 15)),
                              attribute: "Date de début d\'affiche",
                              //focusNode: _nodes[8],
                              onChanged: (dt) {
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide');
                                if (dt != null) {
                                  setState(() {
                                    _debutAffiche = dt;
                                  });
                                }
                              },
                              style: Theme.of(context).textTheme.headline5,
                              cursorColor:
                                  Theme.of(context).colorScheme.onBackground,
                              inputType: InputType.both,
                              format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                              decoration: InputDecoration(
                                  labelText: widget.myEvent?.dateDebutAffiche !=
                                          null
                                      ? DateFormat("dd/MM/yyyy 'à' HH:mm")
                                          .format(
                                              widget.myEvent?.dateDebutAffiche)
                                      : 'Date de début d\'affiche'),
                              validators: [
                                FormBuilderValidators.required(
                                    errorText: "champs requis")
                              ],
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            FormBuilderDateTimePicker(
                              // firstDate: !isUpdating?DateTime.now():_finAffiche.add(Duration(days: 3)),
                              // initialDate: !isUpdating?DateTime.now():_finAffiche.add(Duration(days: 3)),
                              attribute: "Date de fin affiche",
                              //focusNode: _nodes[8],
                              onChanged: (dt) {
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide');
                                if (dt != null) {
                                  setState(() {
                                    _finAffiche = dt;
                                  });
                                }
                              },
                              style: Theme.of(context).textTheme.headline5,
                              cursorColor:
                                  Theme.of(context).colorScheme.onBackground,
                              inputType: InputType.both,
                              format: DateFormat("dd/MM/yyyy 'à' HH:mm"),
                              decoration: InputDecoration(
                                  labelText: widget.myEvent?.dateFinAffiche !=
                                          null
                                      ? DateFormat("dd/MM/yyyy 'à' HH:mm")
                                          .format(
                                              widget.myEvent?.dateFinAffiche)
                                      : 'Date de fin d\'affiche'),
                              validators: [
                                FormBuilderValidators.required(
                                    errorText: "champs requis")
                              ],
                            ),
                          ],
                        )
                      : SizedBox(),
                  Divider(),
                  Text(
                    'Adresse',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  FormBuilderTextField(
                    controller: _rue,
                    attribute: 'Rue',
                    maxLines: 1,
                    focusNode: _nodes[3],
                    style: Theme.of(context).textTheme.headline5,
                    onTap: () {
                      showAddress(context);
                    },
//                        style: TextStyle(
//                            color: Theme.of(context).colorScheme.onBackground),
//                        cursorColor: Theme.of(context).colorScheme.onBackground,
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
                    style: Theme.of(context).textTheme.headline5,
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
                    style: Theme.of(context).textTheme.headline5,
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
                    style: Theme.of(context).textTheme.headline5,
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
                    style: Theme.of(context).textTheme.headline5,
                    cursorColor: Theme.of(context).colorScheme.onBackground,
                    decoration: InputDecoration(labelText: 'Description'),
                    validators: [
                      FormBuilderValidators.required(errorText: 'Champs requis')
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
          Divider(),
          Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 400),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: !showSpinnerAppliquer
                      ? RaisedButton(
                          child: Text(
                            "Appliquer",
                          ),
                          onPressed: () async {
                            await findCodePromo(db, context);
                          },
                        )
                      : Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.secondary)),
                        ),
                ),
              ),
              Expanded(
                child: FormBuilderTextField(
                  controller: _codePromo,
                  attribute: 'CodePromo',
                  onEditingComplete: () async {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    await findCodePromo(db, context);
                  },
                  decoration: InputDecoration(
                      labelText: 'Code promo',
                      suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () => clearPromoCode())),
                ),
              ),
            ],
          ),
          Divider(),
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
                            submit(db, context);
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
                    "Recommencer", overflow: TextOverflow.ellipsis,
                    //style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    modelBodyLogin.scrollController.animateTo(0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut);
                    //_fbKey.currentState.reset();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return ModelScreen(
      child: Scaffold(
        key: myScaffold,
        appBar: AppBar(
          title: Text(
            'UploadEvent',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: modelBodyLogin,
        // bottomSheet: context.watch<BoolToggle>().eventCost > 0
        //     ? Container(
        //         width: MediaQuery.of(context).size.width,
        //         height: 60,
        //         color: Theme.of(context).colorScheme.secondary,
        //         child: Row(
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           mainAxisAlignment: MainAxisAlignment.spaceAround,
        //           children: <Widget>[
        //             Text(
        //               'Total',
        //               style: Theme.of(context).textTheme.headline5,
        //             ),
        //             Text(
        //               '${context.watch<BoolToggle>().eventCost.toStringAsFixed(context.watch<BoolToggle>().eventCost.truncateToDouble() == context.watch<BoolToggle>().eventCost ? 0 : 2)} €',
        //               style: Theme.of(context).textTheme.headline5,
        //             ),
        //           ],
        //         ),
        //       )
        //     : SizedBox(),
        bottomNavigationBar: Consumer<BoolToggle>(
            builder: (BuildContext context, BoolToggle value, Widget child) {
          // if(value.images.length != images.length){
          //   updateDaysAffiche();
          // }

          return value.eventCost > 0.5
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Text(
                        '${value.eventCostDiscounted == null ? value.eventCost.toStringAsFixed(value.eventCost.truncateToDouble() == value.eventCost ? 0 : 2) : value.eventCostDiscounted.toStringAsFixed(value.eventCostDiscounted.truncateToDouble() == value.eventCostDiscounted ? 0 : 2)} €',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ],
                  ),
                )
              : SizedBox();
        }),
      ),
    );
  }

  Future showAddress(BuildContext context) async {
    showGeneralDialog<String>(
        barrierDismissible: true,
        barrierLabel: "Label",
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position:
                Tween(begin: Offset(0, 1), end: Offset(0, 0))
                    .animate(anim1),
            child: child,
          );
        },
        context: context,
        pageBuilder: (BuildContext context, anim1, anim2) =>
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                //color: Colors.white,
                //height: 300,
                margin: EdgeInsets.only(
                    bottom: 50, left: 12, right: 12, top: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),

                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FormBuilderTextField(
                        keyboardType: TextInputType.text,
                        autofocus: true,
                        controller: _searchEditingController,
                        style: Theme.of(context)
                            .textTheme
                            .headline5,
                        cursorColor: Theme.of(context)
                            .colorScheme
                            .onBackground,
                        attribute: 'city',
                        maxLines: 1,
                        decoration: InputDecoration(
                            //labelText: 'Ville',
                            hintText: 'Recherche',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            disabledBorder:
                                OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedErrorBorder:
                                OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            icon: IconButton(
                              icon:
                                  Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
    //
                            ),
                        validators: [
                          (val) {
                            RegExp regex = RegExp(
                                r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ\-. ]{2,60}$');

                            if (regex
                                    .allMatches(val)
                                    .length ==
                                0) {
                              return 'Non valide';
                            }
                            return null;
                          },
                        ],
                      ),
                      Divider(),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: context
                                .watch<BoolToggle>()
                                .suggestions
                                ?.map((e) => ListTile(
                                    onTap: () {
                                      context
                                          .read<BoolToggle>()
                                          .setSelectedAdress(
                                              e.description);
                                      Navigator.of(context)
                                          .pop(e.placeId);
                                    },
                                    leading: Icon(
                                        Icons.location_on),
                                    title: Text(
                                      "${e.description}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5,
                                    )))
                                ?.toList() ??
                            List<Widget>(),
                      )
                    ],
                  ),
                ),
              ),
            )).then((value) async {
      placesDetailsResponse = await _getDetail(value);

      _rue.text =
          "${placesDetailsResponse.result?.addressComponents?.firstWhere((element) => element.types.first == 'street_number')?.longName ?? ''} ${placesDetailsResponse.result?.addressComponents?.firstWhere((element) => element.types.first == 'route')?.longName ?? ''}";

      _codePostal.text = placesDetailsResponse
              .result?.addressComponents
              ?.firstWhere((element) =>
                  element.types.first == 'postal_code')
              ?.longName ??
          '';

      _ville.text = placesDetailsResponse
              .result?.addressComponents
              ?.firstWhere((element) =>
                  element.types.first == 'locality')
              ?.longName ??
          '';

      _coords.text =
          "${placesDetailsResponse.result?.geometry?.location?.lat?.toString() ?? ''},${placesDetailsResponse.result?.geometry?.location?.lng?.toString() ?? ''}";
    });
  }

  void dateAffiche(BuildContext context) {
    if (context.watch<BoolToggle>().isAffiche &&
        context.watch<BoolToggle>().isJusquauJourJ) {
      _debutAffiche = DateTime.now();
      _finAffiche = _dateFin;
    } else if (!context.watch<BoolToggle>().isAffiche) {
      _debutAffiche = null;
      _finAffiche = null;
    } else if (context.watch<BoolToggle>().isAffiche &&
        !context.watch<BoolToggle>().isJusquauJourJ) {
      _debutAffiche = _fbKey
          .currentState.fields['Date de début d\'affiche']?.currentState?.value;
      _finAffiche = _fbKey
          .currentState.fields['Date de fin affiche']?.currentState?.value;
    }
  }

  void updateDaysAffiche() {
    if (_debutAffiche == null || _finAffiche == null) {
      daysAffiche = 0;
    } else {
      if (isUpdating && !hasGetDates) {
        hasGetDates = true;
        daysOld = _finAffiche.difference(_debutAffiche).inDays;
      }
      daysAffiche = _finAffiche.difference(_debutAffiche).inDays;
    }
    eventCostChanges();
    //context.watch<BoolToggle>().eventCostChangeWithoutNotif(images.length,daysAffiche);
  }

  Future<void> submit(FirestoreDatabase db, BuildContext context) async {
    setState(() {
      showSpinner = true;
    });

    //Flyer obligatoire
    if (context.read<BoolToggle>()?.flyer == null && widget.myEvent == null) {
      showSnackBar('Flyer obligatoire');
      setState(() {
        showSpinner = false;
      });
      return;
    }
    if (!context.read<BoolToggle>().genre.values.contains(true)) {
      showSnackBar('Genre obligatoire');
      setState(() {
        showSpinner = false;
      });
      return;
    }
    if (!context.read<BoolToggle>().type.values.contains(true)) {
      showSnackBar('Type obligatoire');
      setState(() {
        showSpinner = false;
      });
      return;
    }
    //au moins 3 jours de plus pris pour pouvoir faire 0.5€
    if (isUpdating &&
        daysAffiche != null &&
        _finAffiche != widget.myEvent.dateFinAffiche &&
        daysAffiche < daysOld + 3) {
      showSnackBar('Affiche doit être supérieur à 3 de plus');
      setState(() {
        showSpinner = false;
      });
      return;
    }
    _fbKey.currentState.save();

    if (_fbKey.currentState.validate()) {
      String coordsString =
          _fbKey.currentState.fields['Coordonnée'].currentState.value;
      String latitude =
          coordsString.substring(0, coordsString.indexOf(',')).trim();
      String longitude =
          coordsString.substring(coordsString.indexOf(',') + 1).trim();

      Coords coords = Coords(double.parse(latitude), double.parse(longitude));

      List<Formule> formules = List<Formule>();

      formulesWidgets.forEach((f) {
        if (f is CardFormula) {
          if (f.fbKey.currentState.validate()) {
            formules.add(Formule(
                title: f.fbKey.currentState.fields['Nom'].currentState.value,
                prix: double.parse(f
                    .fbKey.currentState.fields['Prix'].currentState.value
                    .toString()),
                nombreDePersonne: int.parse(f
                    .fbKey
                    .currentState
                    .fields['Nombre de personne par formule']
                    .currentState
                    .value),
                id: f.numero.toString()));
          } else {
            showSnackBar('Corriger la formule n°${f.numero}');
          }
        }
      });

      if (formules.length == formulesWidgets.length / 2) {
        print('//');
        print('upload started');

        if ((context.read<BoolToggle>().eventCostDiscounted != null
                ? context.read<BoolToggle>().eventCostDiscounted
                : context.read<BoolToggle>().eventCost) <
            0.5) {
          await upload(db, context, formules, coords);
          return;
        }

        await db
            .paymentIntentUploadEvents(
                context.read<BoolToggle>().eventCostDiscounted != null
                    ? context.read<BoolToggle>().eventCostDiscounted
                    : context.read<BoolToggle>().eventCost,
                _title.text,
                context.read<BoolToggle>().eventCostDiscounted != null
                    ? promotionCodeId
                    : null)
            .then((value) async {
          if (value is String) {
            showSnackBar(value);
            setState(() {
              showSpinner = false;
            });
            return;
          }

          if (value is Map) {
            showSnackBar('Paiement accepté');
            showSnackBar('Chargement de l\'événement...');
            await upload(db, context, formules, coords);
          }
        });
      }

      //Navigator.pop(context);
    } else {
      //print(_fbKey.currentState.value);
      print("validation failed");
      showSnackBar('Formulaire non valide');
    }
    setState(() {
      showSpinner = false;
    });
  }

  Future upload(FirestoreDatabase db, BuildContext context,
      List<Formule> formules, Coords coords) async {
    await db
        .uploadEvent(
      oldId: widget.myEvent?.id,
      oldIdChatRoom: widget.myEvent?.chatId,
      myEvent: widget.myEvent,
      type: context.read<BoolToggle>().type,
      genre: context.read<BoolToggle>().genre,
      titre: _title.text,
      formules: formules,
      adresse: placesDetailsResponse?.result?.addressComponents,
      coords: coords,
      dateDebut: _dateDebut,
      dateFin: _dateFin,
      dateDebutAffiche:
          context.read<BoolToggle>().isAffiche ? _debutAffiche : null,
      dateFinAffiche: context.read<BoolToggle>().isAffiche ? _finAffiche : null,
      description: _description.text,
      flyer: context.read<BoolToggle>()?.flyer,
      images: images,
      stripeAccount: context.read<MyUser>().stripeAccount,
    )
        .whenComplete(() {
      print('event ajouter');
      setState(() {
        showSpinner = false;
        showSnackBar("Event ajouter");
      });
    }).catchError((e) {
      print(e);
      showSnackBar("Impossible d'ajouter l'Event");
    });
  }

  Future findCodePromo(FirestoreDatabase db, BuildContext context) async {
    setState(() {
      showSpinnerAppliquer = true;
    });
    await db.retrievePromotionCode(_codePromo.text.trim()).then((rep) {
      if (rep?.data != null) {
        print(rep.data);
        Map promotionCode = rep.data['data'][0];
        //check restriction
        int minimumAmount = promotionCode['restrictions']['minimum_amount'];
        if (minimumAmount != null) {
          double min = minimumAmount / 100;
          if (context.read<BoolToggle>().eventCost >= min) {
            applyPercentOff(promotionCode, context);
          } else {
            context.read<BoolToggle>().setEventCostDiscounted(null);
            promotionCodeId = null;
            showSnackBar('Montant minimum : $min €');
          }
        } else {
          applyPercentOff(promotionCode, context);
        }
      } else {
        context.read<BoolToggle>().setEventCostDiscounted(null);
        promotionCodeId = null;
        showSnackBar('Code invalide');
      }
    });
    setState(() {
      showSpinnerAppliquer = false;
    });
  }

  void applyPercentOff(Map promotionCode, BuildContext context) {
    if (promotionCodeId != promotionCode['id']) {
      promotionCodeId = promotionCode['id'];
      percentOff = promotionCode['coupon']['percent_off'];
      amountOff = promotionCode['coupon']['amount_off'];

      if (percentOff != null) {
        context.read<BoolToggle>().setEventCostDiscounted(
            context.read<BoolToggle>().eventCost -
                context.read<BoolToggle>().eventCost * (percentOff / 100));
      } else if (amountOff != null) {
        context.read<BoolToggle>().setEventCostDiscounted(
            context.read<BoolToggle>().eventCost - amountOff);
      }

      showSnackBar('Code bon');
    } else {
      showSnackBar('Déjà utilisé');
      print(context.read<BoolToggle>().eventCostDiscounted);
    }
  }

  void getLocationResults(String text, BuildContext context) async {
    if (text.isEmpty) {
      context.read<BoolToggle>().setSuggestions(List<Prediction>());
      return;
    }

    GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: PLACES_API_KEY);

    PlacesAutocompleteResponse placesAutocompleteResponse =
        await _places.autocomplete(
      text,
      components: [Component(Component.country, "fr")],
      language: 'fr',
      types: ['address'],
    );

    if (placesAutocompleteResponse.isOkay) {
      context
          .read<BoolToggle>()
          .setSuggestions(placesAutocompleteResponse.predictions);
    } else {
      context.read<BoolToggle>().setSuggestions(null);
    }

//    String baseURL =
//        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
//
//    String components = 'country:fr';
//
//    String language = 'fr';
//
//    String types = 'address';
//
//    String request =
//        '$baseURL?input=$text&key=$PLACES_API_KEY&components=$components&language=$language'
//        '&types=$types';
//
//    Response response = await Dio().get(request);
//    print(response);
//    print('//');
//
//    final predictions = response.data['predictions'];
//
//    List<Prediction> suggestions = List<Prediction>();
//
//    for (dynamic prediction in predictions) {
//      // String name = prediction['description'];
//
//      suggestions.add(Prediction.fromJson(prediction));
//    }
//
//    _getLatLng(suggestions.elementAt(0));
//
//    context.read<BoolToggle>().setSuggestions(suggestions);
  }

  Future<PlacesDetailsResponse> _getDetail(String placeId) async {
    GoogleMapsPlaces _places =
        GoogleMapsPlaces(apiKey: PLACES_API_KEY); //Same API_KEY as above

    return await _places.getDetailsByPlaceId(placeId);

//    double latitude = detail.result.geometry.location.lat;
//    double longitude = detail.result.geometry.location.lng;
//
//    String address = detail.result.adrAddress;
//
//    for (AddressComponent component in detail.result.addressComponents) {
//      print(component.longName);
//
//      for (String type in component.types) {
//        print(type);
//      }
//      print('//');
//    }
//
//    print('//');
//    print(address);
//    print(latitude);
//    print(longitude);
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

    images.clear();

    setState(() {
      images.addAll(resultList);
    });
    eventCostChanges();
  }

  void eventCostChanges() {
    print("eventCostChanges");
    print(widget.myEvent?.imagePhotos?.length);
    print(images.length);
    print(daysOld);
    print(daysAffiche);

    if (isUpdating &&
            widget.myEvent != null &&
            widget.myEvent.imagePhotos.length <= images.length ||
        isUpdating && daysOld != null && daysAffiche >= daysOld) {
      print('isUpdating!!!');
      print(images.length - widget.myEvent.imagePhotos.length);
      print(daysOld - daysAffiche);

      Provider.of<BoolToggle>(context, listen: false)
          .eventCostChangeWithoutNotif(
              images.length - widget.myEvent.imagePhotos.length >= 0
                  ? images.length - widget.myEvent.imagePhotos.length
                  : 0,
              daysAffiche - daysOld >= 0 ? daysAffiche - daysOld : 0);
    } else if (!isUpdating) {
      Provider.of<BoolToggle>(context, listen: false)
          .eventCostChangeWithoutNotif(images.length, daysAffiche);
    }
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

  void showSnackBar(String val) {
    myScaffold.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
        content: Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        )));
  }

  // @override
  // void afterFirstLayout(BuildContext context) {
  //   if (isUpdating) {
  //     _fbKey.currentState.fields['Date de debut'].currentState
  //         .setValue(widget.myEvent.dateDebut);
  //     _fbKey.currentState.fields['Date de fin'].currentState
  //         .setValue(widget.myEvent.dateFin);
  //   }
  // }

  @override
  void didInitState() {
    //context.read<BoolToggle>().eventCostChangeWithoutNotif(images.length, daysAffiche);
  }

  clearPromoCode() {
    _codePromo.clear();
    amountOff = null;
    percentOff = null;
    promotionCodeId = null;
    context.read<BoolToggle>().clearPromoCode();
  }
}

class CardFormula extends StatefulWidget {
  final int numero;

  final Function onChangedNbPersonne;
  final GlobalKey<FormBuilderState> fbKey = GlobalKey();
  final Formule formule;

  CardFormula(this.numero, this.onChangedNbPersonne, {this.formule});

  @override
  _CardFormulaState createState() => _CardFormulaState();
}

class _CardFormulaState extends State<CardFormula> {
  List<FocusScopeNode> _nodes;
  TextEditingController _textEditingControllerTitle = TextEditingController();
  TextEditingController _textEditingControllerPrix = TextEditingController();
  TextEditingController _textEditingControllernb = TextEditingController();

  @override
  void initState() {
    _nodes = List<FocusScopeNode>.generate(
      3,
      (index) => FocusScopeNode(),
    );

    if (widget.formule != null) {
      _textEditingControllerTitle.text = widget.formule.title;
      _textEditingControllerPrix.text = widget.formule.prix.toString();
      _textEditingControllernb.text =
          widget.formule.nombreDePersonne.toString();

      widget.onChangedNbPersonne(
          '${widget.numero}/${_textEditingControllernb.text}');
    }
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
          //gradient: LinearGradient(begin: AlignmentGeometry.),
//                          color: Colors.blueAccent
        ),
        child: FormBuilder(
          key: widget.fbKey,
          //autovalidate: false,
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
                controller: _textEditingControllerTitle,
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
                controller: _textEditingControllerPrix,
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
                decoration: InputDecoration(
                    labelText: 'Nombre de personne par formule'),
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

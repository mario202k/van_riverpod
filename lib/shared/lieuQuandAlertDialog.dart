import 'dart:async';

import 'package:after_init/after_init.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:vanevents/credentials.dart';
import 'package:vanevents/models/myUser.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

enum Lieu { address, aroundMe}
enum Quand { date, ceSoir, demain, avenir }

class LieuQuandAlertDialog extends StatefulWidget {
  @override
  _LieuQuandAlertDialogState createState() => _LieuQuandAlertDialogState();
}

class _LieuQuandAlertDialogState extends State<LieuQuandAlertDialog>
    with AfterInitMixin {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchEditingController =
      TextEditingController();
  Timer _throttle;

  @override
  void initState() {
    super.initState();
    _searchEditingController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchEditingController.removeListener(_onSearchChanged);
    _searchEditingController.dispose();
    super.dispose();
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
    return Scrollbar(
      isAlwaysShown: true,
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Text(
              'Lieu',
              style: Theme.of(context).textTheme.bodyText2,
            ),
            RadioListTile(
              value: Lieu.address,
              groupValue: context.watch<BoolToggle>().lieu,
              onChanged: (Lieu value) {
                context.read<BoolToggle>().setLieux(value);
              },
              title: InkWell(
                  onTap: () async {
                    showGeneralDialog(
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
                                            disabledBorder: OutlineInputBorder(
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
                                              icon: Icon(Icons.arrow_back_ios),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            )
//
                                            ),
                                      ),
                                      Divider(),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: context
                                            .watch<BoolToggle>()
                                            .suggestions
                                            .map((e) => ListTile(
                                                onTap: () {
                                                  context
                                                      .read<BoolToggle>()
                                                      .setSelectedAdress(
                                                      e.terms[0].value);
                                                  Navigator.of(context).pop();
                                                },
                                                leading:
                                                    Icon(Icons.location_on),
                                                title: Text(
                                                  "${e.description}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5,
                                                )))
                                            .toList(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ));
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(25)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 16),
                        child: Text(
                          context.watch<BoolToggle>().selectedAdress ??
                              'Recherche',
                          style: Theme.of(context).textTheme.headline5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))),
            ),
            RadioListTile(
              value: Lieu.aroundMe,
              groupValue: context.watch<BoolToggle>().lieu,
              onChanged: (Lieu value) async {
                context.read<BoolToggle>().setLieux(value);
                if(value == Lieu.aroundMe){
                  LocationPermission permission = await requestPermission();

                  if(permission == LocationPermission.always || permission == LocationPermission.whileInUse ){

                    Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

                    context.read<FirestoreDatabase>().setUserPosition(position);


                  }else{

                    context.read<BoolToggle>().setLieux(Lieu.address);

                  }

                }
              },
              title: Text(
                'Autour de moi',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            context.watch<BoolToggle>().lieu == Lieu.aroundMe
                ? Slider.adaptive(
                    value: context.watch<BoolToggle>().zone,
                    onChanged: (newZone) =>
                        context.read<BoolToggle>().newZone(newZone),
                    divisions: 3,

                    label: context.watch<BoolToggle>().zone == 0
                        ? '25 km'
                        : context.watch<BoolToggle>().zone == 1 / 3
                            ? '50 km'
                            : context.watch<BoolToggle>().zone == 2 / 3?'100 km':'Partout',
                  )
                : SizedBox(),

            Text(
              'Quand',
              style: Theme.of(context).textTheme.bodyText2,
            ),
            RadioListTile(
              value: Quand.date,
              groupValue: context.watch<BoolToggle>().quand,
              onChanged: (Quand value) {
                context.read<BoolToggle>().setQuand(value);
              },
              title: FormBuilderDateTimePicker(
                initialValue:
                    Provider.of<MyUser>(context, listen: false).quand[0] == 'date'
                        ? (Provider.of<MyUser>(context, listen: false).quand[1]
                                    as Timestamp)
                                ?.toDate() ??
                            null
                        : null,
                firstDate: DateTime.now(),
                attribute: "Date",
                //focusNode: _nodes[1],
                onChanged: (dt) {
                  context.read<BoolToggle>().setSelectedDate(dt);

//                    SystemChannels.textInput
//                        .invokeMethod('TextInput.hide');
//                    context.read<BoolToggle>().modificationDateDebut(dt);
//
//                    setState(() {
//                      _dateDebut = dt;
//                    });
                },
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
                cursorColor: Theme.of(context).colorScheme.onBackground,
                inputType: InputType.date,
                format: DateFormat("dd/MM/yyyy"),
                decoration: InputDecoration(labelText: 'Date'),
                validators: [
                  FormBuilderValidators.required(errorText: "champs requis")
                ],
              ),
            ),
            RadioListTile(
              value: Quand.ceSoir,
              groupValue: context.watch<BoolToggle>().quand,
              title: Text(
                'Ce soir',
                style: Theme.of(context).textTheme.headline5,
              ),
              onChanged: (Quand value) {
                context.read<BoolToggle>().setQuand(value);
              },
            ),
            RadioListTile(
              value: Quand.demain,
              groupValue: context.watch<BoolToggle>().quand,
              title: Text(
                'Demain',
                style: Theme.of(context).textTheme.headline5,
              ),
              onChanged: (Quand value) {
                context.read<BoolToggle>().setQuand(value);
              },
            ),
            RadioListTile(
              value: Quand.avenir,
              groupValue: context.watch<BoolToggle>().quand,
              title: Text(
                'À venir',
                style: Theme.of(context).textTheme.headline5,
              ),
              onChanged: (Quand value) {
                context.read<BoolToggle>().setQuand(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  void getLocationResults(String text, BuildContext context) async {
    if (text.isEmpty) {
      context.read<BoolToggle>().setSuggestions(List<Prediction>());
      return;
    }

    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';

    String components = 'country:fr';

    String language = 'fr';

    String types = '(regions)';

    String request =
        '$baseURL?input=$text&key=$PLACES_API_KEY&components=$components&language=$language&types=$types';

    Response response = await Dio().get(request);
    print(response);

    final predictions = response.data['predictions'];

    List<Prediction> suggestions = List<Prediction>();

    for (dynamic prediction in predictions) {
      // String name = prediction['description'];

      suggestions.add(Prediction.fromJson(prediction));
    }

    context.read<BoolToggle>().setSuggestions(suggestions);
  }

  @override
  void didInitState() {

    if (Provider.of<MyUser>(context, listen: false).lieu.isNotEmpty && Provider.of<MyUser>(context, listen: false).lieu[0] == 'address') {
      Provider.of<BoolToggle>(context, listen: false).initSelectedAdress(
          Provider.of<MyUser>(context, listen: false).lieu[1] ?? null);
    }
  }
}

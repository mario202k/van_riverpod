import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vanevents/credentials.dart';
import 'package:vanevents/provider/provider.dart';

class Show {
  static Future<PlacesDetailsResponse> showAddress(BuildContext context) async {
    Timer _throttle;

    String str = await showGeneralDialog<String>(
        barrierDismissible: true,
        barrierLabel: "Label",
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 500),
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position:
                Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
            child: child,
          );
        },
        context: context,
        pageBuilder: (BuildContext context, anim1, anim2) => Align(
              alignment: Alignment.topCenter,
              child: Container(
//color: Colors.white,
//height: 300,
                margin:
                    EdgeInsets.only(bottom: 50, left: 12, right: 12, top: 30),
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
                        onChanged: (value) {
                          if (_throttle?.isActive ?? false) {
                            _throttle.cancel();
                          }
                          _throttle = Timer(const Duration(milliseconds: 500),
                              () async {
                            if (value.toString().isEmpty) {
                              context
                                  .read(boolToggleProvider)
                                  .setSuggestions(List<Prediction>());
                              return;
                            }

                            GoogleMapsPlaces _places =
                                GoogleMapsPlaces(apiKey: PLACES_API_KEY);

                            PlacesAutocompleteResponse
                                placesAutocompleteResponse =
                                await _places.autocomplete(
                              value.toString(),
                              components: [Component(Component.country, "fr")],
                              language: 'fr',
                              types: ['address'],
                            );

                            if (placesAutocompleteResponse.isOkay) {
                              context.read(boolToggleProvider).setSuggestions(
                                  placesAutocompleteResponse.predictions);
                            } else {
                              context
                                  .read(boolToggleProvider)
                                  .setSuggestions(null);
                            }
                          });
                        },
                        style: Theme.of(context).textTheme.headline5,
                        cursorColor: Theme.of(context).colorScheme.onBackground,
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
                            focusedErrorBorder: OutlineInputBorder(
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
                        validators: [
                          (val) {
                            RegExp regex = RegExp(
                                r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ\-. ]{2,60}$');

                            if (regex.allMatches(val).length == 0) {
                              return 'Non valide';
                            }
                            return null;
                          },
                        ],
                      ),
                      Divider(),
                      Consumer(
                        builder: (context, watch, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: watch(boolToggleProvider)
                                    .suggestions
                                    ?.map((e) => ListTile(
                                        onTap: () {
                                          context
                                              .read(boolToggleProvider)
                                              .setSelectedAdress(e.description);
                                          Navigator.of(context).pop(e.placeId);
                                        },
                                        leading: Icon(Icons.location_on),
                                        title: Text(
                                          "${e.description}",
                                          style:
                                              Theme.of(context).textTheme.headline5,
                                        )))
                                    ?.toList() ??
                                List<Widget>(),
                          );
                        }
                      )
                    ],
                  ),
                ),
              ),
            ));

    GoogleMapsPlaces _places =
        GoogleMapsPlaces(apiKey: PLACES_API_KEY); //Same API_KEY as above

    if(str==null){
      return null;
    }

    return await _places.getDetailsByPlaceId(str);
  }

  static void showDialogToDismiss(BuildContext context,String title,String content, String button){
    showDialog(context: context,
        builder: (_){
          if (!Platform.isIOS) {
            return AlertDialog(
              title: Text(
                title,
              ),
              content: Text(
                content,
              ),
              actions: <Widget>[
                new FlatButton(
                  child: Text(
                    button,
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
                content: Text(
                  content,
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text(
                      button[0].toUpperCase() +
                          button.substring(1).toLowerCase(),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ]);
          }
        });
  }
}

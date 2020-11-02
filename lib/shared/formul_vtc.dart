import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:vanevents/models/formule.dart';
import 'package:vanevents/models/participant.dart';
import 'package:vanevents/screens/formula_choice.dart';

final formuleVTCProvider = ChangeNotifierProvider<FormuleVTC>((ref) {
  return FormuleVTC();
});

class FormuleVTC extends ChangeNotifier {
  bool showSpinner = false;
  bool isNotDisplay = true;
  Map<CardFormula, CardFormIntParticipant> formuleParticipant =
      Map<CardFormula, CardFormIntParticipant>();
  Map<Formule,List<GlobalKey<FormBuilderState>>> listFbKey = Map<Formule,List<GlobalKey<FormBuilderState>>>();

  List<Formule> formules = List<Formule>();
  String placeDistance;
  int indexParticipants = 0;
  double totalCost = 0;
  Set<Marker> markers = {};
  LatLng latLngDepart;
  bool autoPlay = true;
  PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};
  double totalDistance = 0;
  String onGoingCar;
  GoogleMapController controller;
  PlacesDetailsResponse placesDetailsResponse;



  setplacesDetailsResponse(PlacesDetailsResponse placesDetailsResponse) {
    this.placesDetailsResponse = placesDetailsResponse;
  }

  setcontroller(GoogleMapController controller) {
    this.controller = controller;
    notifyListeners();
  }

  setformuleParticipant(
      Map<CardFormula, CardFormIntParticipant> formuleParticipant) {
    this.formuleParticipant = formuleParticipant;
    //notifyListeners();
  }

  setFormule(List<Formule> formules) {
    this.formules = formules;
    notifyListeners();
  }

  setshowSpinner() {
    showSpinner = !showSpinner;
    notifyListeners();
  }

  setisNotDisplay() {
    isNotDisplay = !isNotDisplay;
    notifyListeners();
  }


  setplaceDistance(String value) {
    placeDistance = value;
    notifyListeners();
  }

  setindexParticipants(int value) {
    indexParticipants = value;
    notifyListeners();
  }

  settotalCostMoins(double value) {
    totalCost -= value;
    notifyListeners();
  }

  settotalCostPlus(double value) {
    totalCost += value;
    notifyListeners();
  }

  setmarkers(Set<Marker> value) {
    markers = value;
    notifyListeners();
  }

  setlatLngDepart(LatLng value) {
    latLngDepart = value;
    notifyListeners();
  }

  setautoPlay(bool value) {
    autoPlay = value;
    notifyListeners();
  }

  setpolylinePoints(PolylinePoints value) {
    polylinePoints = value;
    notifyListeners();
  }

  setpolylineCoordinates(List<LatLng> value) {
    polylineCoordinates = value;
    notifyListeners();
  }

  setpolylines(Set<Polyline> value) {
    polylines = value;
    notifyListeners();
  }

  settotalDistance(double value) {
    totalDistance = value;
    notifyListeners();
  }

  settotalDistancePlus(double value) {
    totalDistance += value;
    notifyListeners();
  }

  setonGoingCar(String value) {
    onGoingCar = value;
    //notifyListeners();
  }

  void onChangeParticipant(Formule formule,GlobalKey<FormBuilderState> fbKey, int index, bool isToDestroy, bool isNewKey) {
    print('onChangeParticipant');
    print(index);

    if(isToDestroy){
      print('isToDestroy');

      if(listFbKey[formule].isNotEmpty){
        listFbKey[formule].removeAt(index);
      }
    }else if(!listFbKey.keys.contains(formule) ){
      print('firstEntrie');

      listFbKey.addAll({formule:[fbKey]});
      print(listFbKey[formule].length);
    }else if( isNewKey){
      print('newKey');
      listFbKey[formule].insert(index, fbKey);

    }else{
      print('changefbKey');
      print(fbKey);
      print('each');
      for(GlobalKey<FormBuilderState> azerty in listFbKey[formule]){

        print(azerty.toString());
      }
      if(listFbKey[formule].isNotEmpty){
        listFbKey[formule].removeAt(index);
      }

      print('insert');
      listFbKey[formule].insert(index, fbKey);

      print(listFbKey[formule].length);
    }

    // if(!listFbKey.keys.contains(formule) ){
    //   print('azert');
    //   listFbKey.addAll({formule:[fbKey]});
    //   print(listFbKey[formule].length);
    // }else if(index != null) {
    //   print('*///');
    //   print(fbKey.toString());
    //   print(listFbKey[formule].length);
    //   if(listFbKey[formule].isNotEmpty){
    //     listFbKey[formule].removeAt(0);
    //   }
    //
    //   listFbKey[formule].insert(0, fbKey);
    //
    // }
  }


  void setNb(Formule formule, int nb) {

    formuleParticipant[formuleParticipant.keys
        .firstWhere((element) => element.formule.id == formule.id)].setNb(nb);

    // final cardFormula = formuleParticipant.keys
    //     .firstWhere((element) => element.formule.id == formule.id);
    //
    // final cardFormIntParticipant = formuleParticipant.remove(formuleParticipant.keys
    //     .firstWhere((element) => element.formule.id == formule.id));
    //
    // cardFormIntParticipant.setNb(nb);
    //
    // formuleParticipant.addAll({cardFormula:cardFormIntParticipant});

    notifyListeners();
  }

  void setNewStateFbKey() {}

  int getNb(String formuleId) {
    return formuleParticipant[formuleParticipant.keys
            .firstWhere((element) => element.formule.id == formuleId)]
        .nb;

  }

  void setCarParticipants(Formule formule, int index) {
    print('setCarParticipants');
    if(!formuleParticipant.containsKey(formule)){
      print('azert');
    }
    formuleParticipant[formuleParticipant.keys
        .firstWhere((element) => element.formule.id == formule.id)]
        .cardParticipant
        .add(CardParticipant(formule: formule,index: index,isToDestroy: false,));

    //notifyListeners();
  }

  void removeCardParticipants(Formule formule, int index) {
    print('removeCardParticipants');
   formuleParticipant[formuleParticipant.keys
       .firstWhere((element) => element.formule.id == formule.id)]
        .cardParticipant
        .removeAt(index);

  }

  List<CardParticipant> getCardParticipants(String formuleId) {

    return formuleParticipant[formuleParticipant?.keys?.firstWhere((element) {

          return element.formule.id == formuleId;
        })]
            .cardParticipant ??
        List<CardParticipant>();
  }

  List<CardParticipant> getAllCardParticipants() {

    List<CardParticipant> myList = List<CardParticipant>();

    for(List<CardParticipant>  cardParticipant in formuleParticipant.values
        .map((e) => e.cardParticipant)){

      myList.addAll(cardParticipant);
    }

    return myList;
  }




}

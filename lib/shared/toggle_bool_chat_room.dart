import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:vanevents/shared/lieuQuandAlertDialog.dart';

class BoolToggle with ChangeNotifier {
  File imageProfil, flyer, idFront;
  double eventCost = 0;
  double eventCostDiscounted;

  List<Asset> images;

  int nbPhotos = 0;
  List<Prediction> suggestions = List<Prediction>();
  Lieu lieu;

  Quand quand;

  Position position;

  Map<String, bool> genre = {
    'Classique': false,
    'Dancehall/Reggae/Soca': false,
    'Électro': false,
    'Jazz': false,
    'Pop': false,
    'RAP': false,
    'RnB': false,
    'Rock': false,
    'Variété française': false,
    'Zouk/Kompa': false,
  };

  Map<String, bool> type = {
    'Concert': false,
    'Dîner': false,
    'Festival': false,
    'Foire': false,
    'Kids': false,
    'Salon': false,
    'Soirée clubbing': false,
    'Spectacle': false,
  };

  bool isAffiche = false;
  bool isJusquauJourJ = true;

  DateTime dateDebut, dateFin;

  bool cguCgv = false;
  bool showSpinner = false;

  bool obscureTextLogin = true;
  bool obscuretextRegister = true;
  bool showSendBotton = false;
  bool showEmojiContainer = false;
  bool isEnableNotification;
  Map<String, int> listTempMessages =
      Map<String, int>(); //-1 error; 0 loading; 1 success
  Map<String, File> listPhoto = Map<String, File>();

  String selectedAdress;

  DateTime date;

  double zone = 1 / 3;

  String urlIdFront, urlIdBack, urlJD;

  BoolToggle({this.isEnableNotification});


  void setIsAffiche() {
    isAffiche = !isAffiche;

    notifyListeners();
  }

  void modificationDateDebut(DateTime dateDebut) {
    this.dateDebut = dateDebut;
    notifyListeners();
  }

  void modificationGenre(String key) {
    genre[key] = !genre[key];
    notifyListeners();
  }

  void modificationType(String key) {
    type[key] = !type[key];
    notifyListeners();
  }

  void modificationGenreNONotif(String key) {
    genre[key] = !genre[key];
  }

  void modificationTypeNONotif(String key) {
    type[key] = !type[key];
  }

  Future<dynamic> getImageGallery(String type) async {
    final _picker = ImagePicker();

    switch (type) {
      case 'Profil':
        imageProfil =
            File((await _picker.getImage(source: ImageSource.gallery)).path);
        break;
      case 'Flyer':
        flyer =
            File((await _picker.getImage(source: ImageSource.gallery)).path);
        break;
      case 'idFront':
        return File((await _picker.getImage(source: ImageSource.gallery)).path);
      case 'Photos':
        break;
    }
    notifyListeners();
  }

  Future<dynamic> getImageCamera(String type) async {
    final _picker = ImagePicker();

    switch (type) {
      case 'Profil':
        imageProfil =
            File((await _picker.getImage(source: ImageSource.camera)).path);
        break;
      case 'Flyer':
        flyer = File((await _picker.getImage(source: ImageSource.camera)).path);
        break;
      case 'idFront':
        return File((await _picker.getImage(source: ImageSource.camera)).path);

      case 'Photos':
        break;
    }
    notifyListeners();
  }

  void setNullImage() {
    print('//coucou');
    imageProfil = null;
    flyer = null;
  }

  void setObscureTextRegister() {
    obscuretextRegister = !obscuretextRegister;
    notifyListeners();
  }

  void setObscureTextLogin() {
    obscureTextLogin = !obscureTextLogin;
    notifyListeners();
  }

  void setIsEnableNotification(bool val) {
    isEnableNotification = val;
    notifyListeners();
  }

  void setShowSendButtonTo(bool val) {
    showSendBotton = val;
    notifyListeners();
  }

  void setShowEmojiContainer(bool val) {
    showEmojiContainer = val;
    notifyListeners();
  }

  void setAllFalse() {
    showSendBotton = false;
    showEmojiContainer = false;
    listTempMessages = Map<String, int>(); //-1 error; 0 loading; 1 success
    listPhoto = Map<String, File>();
  }

  void addTempMessage(String id) {
    listTempMessages.addAll({id: 0});
    notifyListeners();
  }

  void setTempMessageToError(String id) {
    listTempMessages[id] = -1;
    notifyListeners();
  }

  void setTempMessageToloaded(String id) {
    listTempMessages[id] = 1;
    notifyListeners();
  }

  void addListPhoto(String path, File image) {
    listPhoto.addAll({path: image});
    notifyListeners();
  }

  void initGenre({List genres}) {
    genre = genres == null
        ? {
            'Classique': false,
            'Dancehall/Reggae/Soca': false,
            'Électro': false,
            'Jazz': false,
            'Pop': false,
            'RAP': false,
            'RnB': false,
            'Rock': false,
            'Variété française': false,
            'Zouk/Kompa': false,
          }
        : {
            'Classique': genres.contains('Classique'),
            'Dancehall/Reggae/Soca': genres.contains('Dancehall/Reggae/Soca'),
            'Électro': genres.contains('Électro'),
            'Jazz': genres.contains('Jazz'),
            'Pop': genres.contains('Pop'),
            'RAP': genres.contains('RAP'),
            'RnB': genres.contains('RnB'),
            'Rock': genres.contains('Rock'),
            'Variété française': genres.contains('Variété française'),
            'Zouk/Kompa': genres.contains('Zouk/Kompa'),
          };
  }

  void initType({List types}) {
    type = types == null
        ? {
            'Concert': false,
            'Dîner': false,
            'Spectacle': false,
            'Foire': false,
            'Salon': false,
            'Soirée clubbing': false,
            'Festival': false,
            'Kids': false,
          }
        : {
            'Concert': types.contains('Concert'),
            'Dîner': types.contains('Dîner'),
            'Spectacle': types.contains('Spectacle'),
            'Foire': types.contains('Foire'),
            'Salon': types.contains('Salon'),
            'Soirée clubbing': types.contains('Soirée clubbing'),
            'Festival': types.contains('Festival'),
            'Kids': types.contains('Kids'),
          };
  }

  changeCGUCGV() {
    cguCgv = !cguCgv;
    notifyListeners();
  }

  void eventCostChange(int nbPhotos, int day) {
    this.nbPhotos = nbPhotos;
    if (nbPhotos >= 1) {
      nbPhotos--;
    }

    print('eventCostChange');
    eventCost = ((nbPhotos ?? 0) * 0.5 + (day ?? 0) * 0.2).toDouble();

    notifyListeners();
  }

  setJusquauJourJ() {
    isJusquauJourJ = !isJusquauJourJ;
    notifyListeners();
  }

  void modificationDateFinAffiche(DateTime dt) {}

  void eventCostChangeWithoutNotif(int nbPhotos, int day) {
    print('eventCostChangeWithoutNotif');

    this.nbPhotos = nbPhotos;
    if (nbPhotos >= 1) {
      nbPhotos--;
    }

    eventCost = ((nbPhotos ?? 0) * 0.5 + (day ?? 0) * 0.2).toDouble();
  }

  void setSuggestions(List<Prediction> suggestions) {
    this.suggestions = suggestions;
    notifyListeners();
  }

  void setLieux(Lieu value) {
    lieu = value;

    notifyListeners();
  }

  void setSelectedAdress(String e) {
    selectedAdress = e;
    notifyListeners();
  }

  void setQuand(Quand value) {
    quand = value;
    notifyListeners();
  }

  void initLieuEtLieu() {
    lieu = Lieu.address;
    quand = Quand.avenir;
  }

  void modificationLieuEtDate(List<String> myLieu, List<String> myQuand) {}

  void setSelectedDate(DateTime date) {
    this.date = date;
  }

  void initSelectedAdress(String e) {
    selectedAdress = e;
  }

  newZone(double newZone) {
    print(newZone);
    this.zone = newZone;
    notifyListeners();
  }

  void setPosition(Position position) {
    this.position = position;
  }

  void setIsAfficheNoNotif() {
    isAffiche = true;
    isJusquauJourJ = false;
  }

  void setJusquauJourJNoNotif() {
    isJusquauJourJ = !isJusquauJourJ;
  }

  void setEventCost(double cost) {
    eventCost = cost;

    notifyListeners();
  }

  void setEventCostDiscounted(double cost) {
    eventCostDiscounted = cost;
    notifyListeners();
  }

  void initUploadEvent() {
    isAffiche = false;
    eventCostDiscounted = null;
    eventCost = 0;
    isJusquauJourJ = true;
    nbPhotos = null;
    type = null;
    genre = null;
  }

  void setInitAllUploadEventNull() {
    isAffiche = false;
    isJusquauJourJ = true;
  }

  void initForUpdating() {}

  void setEventCostDiscountedNoNotif(double cost) {
    eventCostDiscounted = cost;
  }

  void clearPromoCode() {
    eventCostDiscounted = null;
    notifyListeners();
  }

  void setUrlFront(String url) {
    urlIdFront = url;
    notifyListeners();
  }

  void setJD(String url) {
    urlJD = url;
    notifyListeners();
  }
}

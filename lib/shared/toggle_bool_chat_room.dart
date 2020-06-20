import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class BoolToggle with ChangeNotifier {
  File imageProfil, flyer, banner;
  List<File> photos;
  Map<String,bool> genre = {
    'RAP': false,
    'Zouk': false,
    'Pop': false,
    'Kompa': false,
    'Soca': false,
    'Reggae': false,
    'dancehall': false,
    'RnB': false
  };

  Map<String,bool> type = {
    'Concert': false,
    'Dîner': false,
    'Spectacle': false,
    'Foire': false,
    'Salon': false,
    'Soirée clubbing': false,
    'Festival': false,
    'Kids': false,
  };

  bool isAffiche = false;

  DateTime dateDebut, dateFin;

  bool obscureTextLogin = true;
  bool obscuretextRegister = true;
  bool showSendBotton = false;
  bool showEmojiContainer = false;
  bool isEnableNotification;
  Map<String, int> listTempMessages =
      Map<String, int>(); //-1 error; 0 loading; 1 success
  Map<String, File> listPhoto = Map<String, File>();

  BoolToggle({this.isEnableNotification});

  void setIsAffiche(){
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

  Future getImageGallery(String type) async {
    switch (type) {
      case 'Profil':
        imageProfil = await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
      case 'Flyer':
        flyer = await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
      case 'Banner':
        banner = await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
      case 'Photos':
        break;
    }
    notifyListeners();
  }

  Future getImageCamera(String type) async {
    switch (type) {
      case 'Profil':
        imageProfil = await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case 'Flyer':
        flyer = await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case 'Banner':
        banner = await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case 'Photos':
        break;
    }
    notifyListeners();
  }

  void setNullImage() {
    imageProfil = null;
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

  void initGenre() {

    genre = {
      'RAP': false,
      'Zouk': false,
      'Pop': false,
      'Kompa': false,
      'Soca': false,
      'Reggae': false,
      'dancehall': false,
      'RnB': false
    };

  }

  void initType() {

    type = {
      'Concert': false,
      'Dîner': false,
      'Spectacle': false,
      'Foire': false,
      'Salon': false,
      'Soirée clubbing': false,
      'Festival': false,
      'Kids': false,
    };

  }
}

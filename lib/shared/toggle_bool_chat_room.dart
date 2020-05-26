import 'dart:io';

import 'package:flutter/foundation.dart';

class BoolToggle with ChangeNotifier{
  bool showSendBotton = false;
  bool showEmojiContainer = false;
  bool isEnableNotification;
  Map<String,int> listTempMessages = Map<String,int>();//-1 error; 0 loading; 1 success
  Map<String, File>listPhoto = Map<String,File>();
  BoolToggle({this.isEnableNotification});

  void setIsEnableNotification(bool val){
    isEnableNotification = val;
    notifyListeners();
  }

  void setShowSendButtonTo(bool val){
    showSendBotton = val;
    notifyListeners();
  }
  
  void setShowEmojiContainer(bool val){
    showEmojiContainer = val;
    notifyListeners();
  }

  void setAllFalse(){
    showSendBotton = false;
    showEmojiContainer = false;
    listTempMessages = Map<String,int>();//-1 error; 0 loading; 1 success
    listPhoto = Map<String,File>();
  }

  void addTempMessage(String id) {
    listTempMessages.addAll({id:0});
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
    listPhoto.addAll({path:image});
    notifyListeners();
  }

}
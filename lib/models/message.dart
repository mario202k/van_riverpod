import 'package:cloud_firestore/cloud_firestore.dart';

class MyMessage {
  final String id;
  final String idFrom;
  final String idTo;
  final String message;
  final DateTime date;
  final int type;


  MyMessage(
      {this.id,
        this.idFrom,
        this.idTo,
        this.message,
        this.date,
        this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idFrom': idFrom,
      'idTo': idTo,
      'message': message,
      'date': date,
      'type': type,
    };
  }


  factory MyMessage.fromMap(Map data) {

    Timestamp time = data['date'] ?? '';

    return MyMessage(
        id: data['id'] ?? '',
        idFrom: data['idFrom'] ?? '',
        idTo: data['idTo'] ?? '',
        message: data['message'] ?? '',
        date: time.toDate() ?? '',
        type: data['type'] ?? '');
  }

  factory MyMessage.fromIosFcm(Map data) {

    int type = int.parse(data['type'].toString());

    String date = data['date'].toString();

    return MyMessage(
        id: data['id'] ?? '',
        idFrom: data['idFrom'] ?? '',
        idTo: data['idTo'] ?? '',
        message: data['aps'] != null ? data['aps']['alert']['body'] : data['notification']['body'],
        date: DateTime.parse(date) ?? '',
        type: type ?? '');
  }


  factory MyMessage.fromAndroidFcm(Map data) {
    print(data['notification']['body']);
    print(int.parse(data['data']['type'].toString()));
    print(data['data']['type']);


    int type = int.parse(data['data']['type'].toString());

    String date = data['data']['date'].toString();
    print(DateTime.parse(date).toString());
    print(date);

    return MyMessage(
        id: data['data']['id'] ?? '',
        idFrom: data['data']['idFrom'] ?? '',
        idTo: data['data']['idTo'] ?? '',
        message: data['notification']['body'] ?? '',
        date: DateTime.parse(date) ?? '',
        type: type ?? '');
  }
}

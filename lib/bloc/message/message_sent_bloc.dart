import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanevents/models/message.dart';

class MessageSentBloc extends Bloc<MessageSentEvent,MessageSentStates>{
  MessageSentBloc(MessageSentStates initialState) : super(initialState);

  @override
  MessageSentStates get initialState => MessageSentStates.onLoading();

  @override
  Stream<MessageSentStates> mapEventToState(MessageSentEvent event) async*{

    if(event.onLoading){
      yield MessageSentStates.onLoading();
    }else if(event.onServer){
      MyMessage myMessage = await FirebaseFirestore.instance
          .collection('chats')
          .doc(event.chatId)
          .collection('messages')
          .orderBy('date', descending: true)
          .limit(1)
          .get()
          .then((doc) => doc.docs.map((doc) => MyMessage.fromMap(doc.data())).first);
      yield MessageSentStates.onServer(myMessage);
    }else if(event.onReceived){
      yield MessageSentStates.onReceived();
    }else if(event.onRead){
      yield MessageSentStates.onRead();
    }
  }
}

class MessageSentEvent{
  final String chatId;
  final bool onLoading;
  final bool onServer;
  final bool onReceived;
  final bool onRead;

  MessageSentEvent({
      this.chatId, this.onLoading, this.onServer, this.onReceived, this.onRead});
}

class MessageSentStates{
  final bool onLoading;
  final bool onServer;
  final bool onReceived;
  final bool onRead;
  final MyMessage myMessage;

  MessageSentStates({
      this.onLoading, this.onServer, this.onReceived, this.onRead,this.myMessage});


  factory MessageSentStates.onLoading(){
    return MessageSentStates(onLoading: true,onServer: false,onRead: false,onReceived: false);
  }

  factory MessageSentStates.onServer(MyMessage myMessage){
    return MessageSentStates(onServer: true,myMessage: myMessage,onRead: false,onReceived: false,onLoading: false);
  }

  factory MessageSentStates.onReceived(){
    return MessageSentStates(onReceived: true,onServer: false,onRead: false,onLoading: false);
  }

  factory MessageSentStates.onRead(){
    return MessageSentStates(onRead: true,onServer: false,onReceived: false,onLoading: false);
  }
}


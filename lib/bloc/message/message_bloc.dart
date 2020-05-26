import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanevents/models/message.dart';


class MessageBloc extends Bloc<MessageEvents, MessageState> {
  @override
  // TODO: implement initialState
  MessageState get initialState {
    return MessageState.loading();
  }

  @override
  Stream<MessageState> mapEventToState(MessageEvents event) async* {

    if (event.isNewMessage) {
      yield MessageState.newMessage(event.message, event.chatId);
    } else if(event.isAllMessages) {
      //yield MessageState.loading();
      try {
        List<MyMessage> messages = await getChatMessages(
            event.chatId); //chargement de tous les messages
        yield MessageState.allMessages(messages, event.chatId);

      } catch (err) {
        yield MessageState.error();
      }
    }else if(event.isNewMessage){

      yield MessageState.newMessage(event.message, event.chatId);
    }

  }

  Future<List<MyMessage>> getChatMessages(String chatId) {
    return Firestore.instance
        .collection('chats')
        .document(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .getDocuments()
        .then((value) =>
            value.documents.map((doc) => MyMessage.fromMap(doc.data)).toList());
  }

}

class MessageEvents {
  final String chatId;
  final bool isLoading;
  final bool isNewMessage;
  final bool isAllMessages;
  final MyMessage message;

  const MessageEvents(this.chatId, this.isLoading,this.isNewMessage, this.isAllMessages, {this.message});
}

class MessageState {
  final String chatId;
  final bool isLoading;
  final bool isAllMessages;
  final List<MyMessage> messages;
  final bool isNewMessage;
  final MyMessage newMessage;
  final bool hasError;

  const MessageState(
      {this.chatId, this.isLoading, this.isAllMessages, this.messages, this.isNewMessage, this.newMessage, this.hasError});

  factory MessageState.loading() {
    return MessageState(
      isAllMessages: false,
      isLoading: true,
      hasError: false,
      isNewMessage: false
    );
  }

  factory MessageState.allMessages(List<MyMessage> messages, String chatId) {
    return MessageState(
      chatId: chatId,
      messages: messages,
      isAllMessages: true,
      isLoading: false,
      hasError: false,
      isNewMessage: false
    );
  }

  factory MessageState.newMessage(MyMessage message, String chatId) {
    return MessageState(
      chatId: chatId,
      newMessage: message,
      isAllMessages: false,
      isNewMessage: true,
      isLoading: false,
      hasError: false,
    );
  }

  factory MessageState.error() {
    return MessageState(
      messages: [],
      isAllMessages: false,
      isLoading: false,
      isNewMessage: false,
      hasError: true,
    );
  }

  @override
  String toString() =>
      'MessageState {message: ${messages.toString()}, isLoading: $isLoading, hasError: $hasError, isNewMsg: $isNewMessage, isAllMsg: $isAllMessages }';
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanevents/models/chat_membres.dart';
import 'package:vanevents/models/message.dart';
import 'package:vanevents/models/my_chat.dart';
import 'package:vanevents/models/user.dart';

class MessageBloc extends Bloc<MessageEvents, MessageState> {
  String lastChatId = '';

  @override
  // TODO: implement initialState
  MessageState get initialState {
    return MessageState.loading();
  }

  @override
  Stream<MessageState> mapEventToState(MessageEvents event) async* {

    if (event.isNewMessage && lastChatId == event.chatId) {
      yield MessageState.newMessage(event.message, event.chatId);
    } else if (event.isAllMessages) {
      yield MessageState.loading();
      try {
        List<MyMessage> messages = await getChatMessages(
            event.chatId); //chargement de tous les messages
        lastChatId = event.chatId;

        MyChat myChat = await getMyChat(event.chatId);
        List<User> membres = await chatUsers(myChat);

        yield MessageState.allMessages(messages, event.chatId,myChat,membres);
      } catch (err) {

        yield MessageState.error();
      }
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

  Future<MyChat> getMyChat(String chatId) {
    return Firestore.instance
        .collection('chats')
        .document(chatId)
        .get()
        .then((doc) => MyChat.fromMap(doc.data));
  }

  Future<List<User>> chatUsers(MyChat myChat) {
    return Firestore.instance
        .collection('users')
        .where('id', whereIn: myChat.membres.keys.toList())
        .getDocuments()
        .then((users) => users.documents
            .map((user) => User.fromMap(user.data, user.documentID))
            .toList());
  }
}

class MessageEvents {
  final String chatId;
  final bool isLoading;
  final bool isNewMessage;
  final bool isAllMessages;
  final MyMessage message;

  const MessageEvents(
      this.chatId, this.isLoading, this.isNewMessage, this.isAllMessages,
      {this.message});
}

class MessageState {
  final String chatId;
  final bool isLoading;
  final bool isAllMessages;
  final List<MyMessage> messages;
  final bool isNewMessage;
  final MyMessage newMessage;
  final bool hasError;
  final MyChat myChat;
  final List<User> membres;

  const MessageState(
      {this.chatId,
      this.isLoading,
      this.isAllMessages,
      this.myChat,
      this.membres,
      this.messages,
      this.isNewMessage,
      this.newMessage,
      this.hasError});

  factory MessageState.loading() {
    return MessageState(
        isAllMessages: false,
        isLoading: true,
        hasError: false,
        isNewMessage: false);
  }

  factory MessageState.allMessages(List<MyMessage> messages, String chatId, MyChat myChat,List<User> membres) {
    return MessageState(
        chatId: chatId,
        messages: messages,
        myChat: myChat,
        membres: membres,
        isAllMessages: true,
        isLoading: false,
        hasError: false,
        isNewMessage: false);
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
  String toString() => 'MessageState {newMessage: ${newMessage.toString()},'
      ' isLoading: $isLoading, '
      'hasError: $hasError, '
      'isNewMsg: $isNewMessage, '
      'isAllMsg: $isAllMessages '
      'chatId: $chatId}';
}

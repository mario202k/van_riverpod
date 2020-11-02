import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanevents/models/message.dart';
import 'package:vanevents/models/myUser.dart';
import 'package:vanevents/models/my_chat.dart';

class MessageBloc extends Bloc<MessageEvents, MessageState> {
  String lastChatId = '';

  MessageBloc(MessageState initialState) : super(initialState);

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
        List<MyUser> membres = await chatUsers(myChat);

        yield MessageState.allMessages(messages, event.chatId, myChat, membres);
      } catch (err) {
        yield MessageState.error();
      }
    }
  }

  Future<List<MyMessage>> getChatMessages(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('date', descending: true)
        .get()
        .then((value) =>
            value.docs.map((doc) => MyMessage.fromMap(doc.data())).toList());
  }

  Future<MyChat> getMyChat(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .get()
        .then((doc) => MyChat.fromMap(doc.data()));
  }

  Future<List<MyUser>> chatUsers(MyChat myChat) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('id', whereIn: myChat.membres.keys.toList())
        .get()
        .then((users) => users.docs
            .map((user) => MyUser.fromMap(user.data(), user.id))
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
  final List<MyUser> membres;

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

  factory MessageState.allMessages(List<MyMessage> messages, String chatId,
      MyChat myChat, List<MyUser> membres) {
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

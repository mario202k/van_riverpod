import 'dart:async';
import 'dart:io';
import 'package:after_init/after_init.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/bloc/message/message_bloc.dart';
import 'package:vanevents/models/chat_membres.dart';
import 'package:vanevents/models/message.dart';
import 'package:vanevents/models/my_chat.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/screens/full_photo.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';

class ChatRoom extends StatefulWidget {

  final String chatId;

  ChatRoom(this.chatId);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with WidgetsBindingObserver,AfterInitMixin {
  List<MyMessage> _messages = List<MyMessage>();
  String lastMsgId;

  //BuildContext contextAnimatedList;
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  TextEditingController _textEditingController = TextEditingController();

  List membresGroupe = List();
  bool showLoading = true;
  ScrollController _scrollController = ScrollController();
  FocusNode textFieldFocus = FocusNode();
  bool showEmojiPicker = true;
  MyMessage lastMessage;
  BoolToggle boolChatRoom;
  Stream<User> streamUserFriend;
  FirestoreDatabase db;
  bool isChatRoom = true;
  StreamSubscription<List<User>> streamSubscription;
  List<User> membres;
  MyChat myChat;
  User friend;

  _afterLayout(_) {
    if (listKey.currentState != null) {
      _messages.insert(0, lastMessage);

      listKey.currentState.insertItem(0, duration: Duration(milliseconds: 500));
    }

//    SchedulerBinding.instance.addPostFrameCallback((_) {
//      _scrollController.animateTo(
//          _scrollController.position.minScrollExtent,
//          duration: Duration(milliseconds: 250),
//          curve: Curves.easeInOut);
//    });
  }

  @override
  void didUpdateWidget(ChatRoom oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didInitState() {
//    BlocProvider.of<MessageBloc>(context)
//        .add(MessageEvents(widget.chatId, false, false, true));
  }

  @override
  void dispose() {

    if (streamSubscription != null) {
      streamSubscription.cancel();
    }

    isChatRoom = false;
    WidgetsBinding.instance.removeObserver(this);
    if (!myChat.isGroupe) {
      db.setIsNotReading(widget.chatId);
    }
    boolChatRoom.setAllFalse();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (isChatRoom) {
      switch (state) {
        case AppLifecycleState.paused:
          if (!myChat.isGroupe) {
            db.setIsNotReading(myChat.id);
          }
          break;
        case AppLifecycleState.resumed:
          if (!myChat.isGroupe) {
            db.setIsReading(myChat.id);
            //context.select<FirestoreDatabase,void>((value) => null)
          }
          break;
        case AppLifecycleState.inactive:
          if (!myChat.isGroupe) {
            db.setIsNotReading(myChat.id);
          }
          break;
        case AppLifecycleState.detached:
          if (!myChat.isGroupe) {
            db.setIsNotReading(myChat.id);
          }
          break;
      }
    }
  }

  @override
  void deactivate() {
    if (!myChat.isGroupe) {
      db.setIsNotReading(myChat.id);
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {

    BlocProvider.of<MessageBloc>(context)
        .add(MessageEvents(widget.chatId, false, false, true));

    db = Provider.of<FirestoreDatabase>(context, listen: false);

    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: SafeArea(
        child: BlocBuilder<MessageBloc, MessageState>(
            builder: (BuildContext context, MessageState state) {

              if(state.isAllMessages){
                initChat(state, context);
              }

            return myChat != null? Scaffold(
                appBar: AppBar(
                    elevation: 0.4,
                    iconTheme: IconThemeData(color: Colors.black),
                    backgroundColor: Colors.white,
                    leading: IconButton(
                        onPressed: () {
                          ExtendedNavigator.of(context).pop();
                        },
                        icon: Icon(
                          Platform.isAndroid
                              ? Icons.arrow_back
                              : Icons.arrow_back_ios,
                          color: Colors.black,
                        )),
                    title: Row(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
                            child: CachedNetworkImage(
                              imageUrl: !myChat.isGroupe
                                  ? friend.imageUrl
                                  : myChat.imageUrl,
                              imageBuilder: (context, imageProvider) => Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(44)),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor:
                                    Theme.of(context).colorScheme.primary,
                                child: CircleAvatar(
                                  radius: 22,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                !myChat.isGroupe
                                    ? friend.nom
                                    : myChat.titre,
                                style: TextStyle(color: Colors.black),
                              ),
                              !myChat.isGroupe
                                  ? StreamBuilder<User>(
                                      stream: streamUserFriend,
                                      builder: (context, snapshot) {
                                        User user = snapshot.data;

                                        return user != null
                                            ? Text(
                                                user.isLogin
                                                    ? 'En ligne'
                                                    : isToday(user.lastActivity)
                                                        ? 'Vu aujourd\'hui à ${DateFormat.Hm().format(user.lastActivity)}'
                                                        : DateFormat('dd/MM/yy')
                                                            .format(
                                                                user.lastActivity),
                                                style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 12),
                                              )
                                            : SizedBox();
                                      })
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ],
                    )),
                body: Column(
                  //mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: BlocBuilder<MessageBloc, MessageState>(
                          builder: (BuildContext context, MessageState state) {
                            print('diana');
                            if (state.isLoading) {

                              return Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary)),
                              );
                            } else if (state.isAllMessages) {

                              print('coucou');

                              
                              //initChat(state, context);

                              


                              if (state.messages.isNotEmpty) {
                                _messages.clear();
                                _messages.addAll(state.messages);
                                return returnMessages(false);
                              } else {
                                return Center(
                                  child: Text(
                                    'Pas de messages',
                                    style: Theme.of(context).textTheme.subtitle2,
                                  ),
                                );
                              }
                            } else if (state.isNewMessage) {

                              lastMessage = state.newMessage;
                              WidgetsBinding.instance
                                  .addPostFrameCallback(_afterLayout);
                              return returnMessages(true);
                            } else if (state.hasError) {
                              return Center(
                                child: Text(
                                  'Erreur de connexion',
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              );
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.primary)),
                            );
                          },
                        ),
                      ),
                    ),
                    Divider(
                      height: 1.0,
                      thickness: 2,
                    ),
                    Container(
                        decoration:
                            BoxDecoration(color: Theme.of(context).cardColor),
                        child: _buildTextComposer(db, boolChatRoom)),
                    Container(
                      color: Colors.green,
                      child: Consumer<BoolToggle>(
                        builder: (context, boolChatRoom, child) {
                          return boolChatRoom.showEmojiContainer
                              ? emojiContainer(boolChatRoom)
                              : SizedBox();
                        },
                      ),
                    ),
                  ],
                )): Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary)),
            );
          }
        ),
      ),
    );
  }

  void initChat(MessageState state, BuildContext context) {
    myChat = state.myChat;
    membres = state.membres;
    
    friend = state.membres.firstWhere(
            (user) => user.id != db.uid);
    
    if (!myChat.isGroupe) {
      db.setIsReading(myChat.id);
      streamUserFriend = db.userFriendStream(friend.id);
      //context.select<FirestoreDatabase,void>((value) => null)
    }
    
    boolChatRoom = Provider.of<BoolToggle>(context, listen: false);
    
    if (myChat.isGroupe) {
      streamSubscription = db.chatUsersStream(myChat).listen((users) {
        membres = users;
      });
    }
  }

  Widget returnMessages(bool isNew) {

    return _messages.isNotEmpty || lastMessage!= null
        ? AnimatedList(
            initialItemCount: _messages.length,
            key: listKey,
            controller: _scrollController,
            padding: EdgeInsets.all(8.0),
            reverse: true,
            itemBuilder:
                (BuildContext context, int index, Animation<double> animation) {

              User userFrom = membres
                  .firstWhere((user) => user.id == _messages[index].idFrom);

              return SizeTransition(
                  axis: Axis.vertical,
                  sizeFactor: animation,
                  child: isAnotherDay(index, _messages)
                      ? Column(
                          children: <Widget>[
                            Text(
                              isToday(_messages[index].date)
                                  ? 'Aujourd\'hui'
                                  : isYesterday(_messages[index].date)
                                      ? 'Hier'
                                      : ' ${day(_messages[index].date.weekday)} ${_messages[index].date.day} ${month(_messages[index].date.month)}',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            ChatMessageListItem(
                                _messages[index],
                                db.uid == _messages[index].idFrom,
                                myChat.id,
                                myChat.isGroupe,
                                userFrom.nom,
                                //name
                                userFrom.imageUrl,
                                isNew,
                                _messages[index].idTo //url
                                )
                          ],
                        )
                      : ChatMessageListItem(
                          _messages[index],
                          db.uid == _messages[index].idFrom,
                          myChat.id,
                          myChat.isGroupe,
                          userFrom.nom,
                          //name
                          userFrom.imageUrl,
                          isNew,
                          _messages[index].idTo //url
                          ));
            },
          )
        : Center(
            child: Text('Pas de messages'),
          );
  }

  emojiContainer(BoolToggle boolChatRoom) {
    double height = MediaQuery.of(context).size.height;
    return EmojiPicker(
      bgColor: Theme.of(context).colorScheme.primary,
      indicatorColor: Theme.of(context).colorScheme.secondary,
      rows: height < 700 ? 1 : 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        boolChatRoom.setShowSendButtonTo(true);
        _textEditingController.text = _textEditingController.text + emoji.emoji;
      },
    );
  }

  String day(int week) {
    switch (week) {
      case DateTime.monday:
        return 'Lundi';
      case DateTime.tuesday:
        return 'Mardi';
      case DateTime.wednesday:
        return 'Mercredi';
      case DateTime.thursday:
        return 'Jeudi';
      case DateTime.friday:
        return 'Vendredi';
      case DateTime.saturday:
        return 'Samedi';
      case DateTime.sunday:
        return 'Dimanche';
    }
  }

  String month(int month) {
    switch (month) {
      case DateTime.january:
        return 'Janvier';
      case DateTime.february:
        return 'Février';
      case DateTime.march:
        return 'Mars';
      case DateTime.april:
        return 'Avril';
      case DateTime.may:
        return 'Mai';
      case DateTime.june:
        return 'Juin';
      case DateTime.july:
        return 'Juillet';
      case DateTime.august:
        return 'Août';
      case DateTime.september:
        return 'Septembre';
      case DateTime.october:
        return 'Octobre';
      case DateTime.november:
        return 'Novembre';
      case DateTime.december:
        return 'Décembre';
    }
  }

  bool isAnotherDay(int index, List<MyMessage> messages) {
    if (index == messages.length - 1) {
      return true;
    }

    bool b = false;

    if (index > 0 && index < messages.length - 1) {
      if (messages[index].date.day > messages[index + 1].date.day) {
        b = true;
      }
    }


    return b;
  }

  bool isToday(DateTime date) {
    bool b = false;

    if (date.day == DateTime.now().day) {
      b = true;
    }

    return b;
  }

  bool isYesterday(DateTime date) {
    bool b = false;

    if (date.day + 1 == DateTime.now().day) {
      b = true;
    }
    print(date.day);

    return b;
  }

  Future _getImageCamera(FirestoreDatabase db) async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);

    displayAndSendImage(image, db);
  }

  void displayAndSendImage(File image, FirestoreDatabase db) {
    String path = image.path;

    print(path.substring(path.lastIndexOf('/') + 1));

    String idTo;

    if (!myChat.isGroupe) {
      idTo = friend.id;
    }

    MyMessage myMessage = MyMessage(
        id: path, idTo: idTo, idFrom: db.uid, type: 1, date: DateTime.now());

    boolChatRoom.addListPhoto(path, image);
    boolChatRoom.addTempMessage(path);

    BlocProvider.of<MessageBloc>(context).add(MessageEvents(
        myChat.id, false, true, false,
        message: myMessage));

    db
        .uploadImageChat(context, image, myChat.id, db.uid, idTo)
        .then((_) => boolChatRoom.setTempMessageToloaded(path))
        .catchError((e) {
      print(e);
      boolChatRoom.setTempMessageToError(path);
    });
  }

  Future _getImageGallery(FirestoreDatabase db) async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    displayAndSendImage(image, db);
  }

  Widget _buildTextComposer(FirestoreDatabase db, BoolToggle boolChatRoom) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(children: [
        Container(
          child: IconButton(
            icon: Icon(Icons.photo),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return PlatformAlertDialog(
                    title: Text(
                      'Source?',
                      style: Theme.of(context).textTheme.display2,
                    ),
                    actions: <Widget>[
                      PlatformDialogAction(
                        child: Text(
                          'Caméra',
                          style: Theme.of(context).textTheme.display2,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _getImageCamera(db);
                        },
                      ),
                      PlatformDialogAction(
                        child: Text(
                          'Galerie',
                          style: Theme.of(context).textTheme.display2,
                        ),
                        //actionType: ActionType.,
                        onPressed: () {
                          Navigator.of(context).pop();
                          _getImageGallery(db);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        Container(
          child: IconButton(
            icon: Icon(Icons.gif),
            onPressed: () {
              pickGif(context, db);
            },
          ),
        ),
        Flexible(
          child: Stack(
            children: <Widget>[
              TextField(
                controller: _textEditingController,
                focusNode: textFieldFocus,
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(color: Colors.black),
                onTap: () {
                  boolChatRoom.setShowEmojiContainer(false);
                },
                onChanged: (val) {
                  if (val.length > 0 && val.trim() != '') {
                    boolChatRoom.setShowSendButtonTo(true);
                  } else {
                    boolChatRoom.setShowSendButtonTo(false);
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Saisir un message',
                  hintStyle: Theme.of(context).textTheme.subhead,
                ),
                maxLines: null,
              ),
              Positioned(
                right: 0,
                child: IconButton(
                    icon: Icon(FontAwesomeIcons.smile),
                    onPressed: () {
                      if (!boolChatRoom.showEmojiContainer) {
                        textFieldFocus.unfocus();

                        boolChatRoom.setShowEmojiContainer(true);
                      } else {
                        textFieldFocus.requestFocus();
                        boolChatRoom.setShowEmojiContainer(false);
                      }
                    }),
              ),
            ],
          ),
        ),
        Consumer<BoolToggle>(
          builder: (context, boolChatRoom, child) {
            return boolChatRoom.showSendBotton
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () =>
                            _sendMessage(_textEditingController.text, db)))
                : SizedBox();
          },
        )
      ]),
    );
  }

  void pickGif(BuildContext context, FirestoreDatabase db) async {
    final gif = await GiphyPicker.pickGif(
        context: context, apiKey: 'nZXOSODAIyJlsmNBMXzz55JvV5f8kd0D');

    if (gif != null) {
      String messageId = Firestore.instance
          .collection('chats')
          .document(myChat.id)
          .collection('messages')
          .document()
          .documentID;

      String idTo;

      if (!myChat.isGroupe) {
        idTo = friend.id;
      }
      MyMessage myMessage = MyMessage(
          id: messageId,
          message: gif.images.original.url,
          idTo: idTo,
          idFrom: db.uid,
          type: 2,
          date: DateTime.now());

      BlocProvider.of<MessageBloc>(context).add(MessageEvents(
          myChat.id, false, true, false,
          message: myMessage));

      db.sendMessage(myChat.id, messageId, db.uid,
          gif.images.original.url, idTo, 2);
    }
  }

  void _sendMessage(String text, FirestoreDatabase db) {
    String messageId = Firestore.instance
        .collection('chats')
        .document(myChat.id)
        .collection('messages')
        .document()
        .documentID;

    String idTo;

    if (!myChat.isGroupe) {
      idTo = friend.id;
    }
    MyMessage myMessage = MyMessage(
        id: messageId,
        message: text,
        idTo: idTo,
        idFrom: db.uid,
        type: 0,
        date: DateTime.now());

    boolChatRoom.addTempMessage(myMessage.id);

    BlocProvider.of<MessageBloc>(context).add(MessageEvents(
        myChat.id, false, true, false,
        message: myMessage)); //affichage immediat du message

    if (text.trim() != '') {
      boolChatRoom.setShowSendButtonTo(false);
      _textEditingController.clear();
      db
          .sendMessage(myChat.id, messageId, db.uid, text, idTo, 0)
          .catchError((err) {
        boolChatRoom.setShowSendButtonTo(true);
        boolChatRoom.setTempMessageToError(myMessage.id);
        _textEditingController.text = text;
      }).whenComplete(() {
        boolChatRoom.setShowSendButtonTo(false);

        boolChatRoom.setTempMessageToloaded(myMessage.id);
      });
    } else {
      print('Text vide ou null');
    }
  }


}

class ChatMessageListItem extends StatefulWidget {
  final MyMessage message;
  final bool isMe;
  final String chatId;
  final bool isGroupe;
  final String friendName;
  final String friendUrl;
  final bool isNew;
  final String idFrom;

  ChatMessageListItem(this.message, this.isMe, this.chatId, this.isGroupe,
      this.friendName, this.friendUrl, this.isNew, this.idFrom);

  @override
  _ChatMessageListItemState createState() => _ChatMessageListItemState();
}

class _ChatMessageListItemState extends State<ChatMessageListItem> {
  bool isReceive = false;
  bool isRead = false;
  String id;
  bool isNew;

  Stream<ChatMembre> chatMembreFuture;

  Widget build(BuildContext context) {
    id = widget.message.id; //Car l'animated list reconstruit que le build
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    final boolChatRoom = Provider.of<BoolToggle>(context, listen: false);
    chatMembreFuture = db.getChatMembre(widget.chatId, widget.idFrom);

    return Row(
      mainAxisAlignment:
          widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        !widget.isMe
            ? CachedNetworkImage(
                imageUrl: widget.friendUrl,
                imageBuilder: (context, imageProvider) => Container(
                  height: 29,
                  width: 29,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(29)),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Theme.of(context).colorScheme.primary,
                  child: CircleAvatar(
                    radius: 15,
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              )
            : SizedBox(),
        Container(
          margin: EdgeInsets.only(top: 4, bottom: 4),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
          child: widget.message.type == 0 //message text
              ? Row(
                  mainAxisAlignment: widget.isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    horodatage(boolChatRoom),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.isMe
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                        borderRadius: widget.isMe
                            ? BorderRadius.only(
                                topRight: Radius.circular(15),
                                topLeft: Radius.circular(15),
                                bottomRight: Radius.circular(0),
                                bottomLeft: Radius.circular(15),
                              )
                            : BorderRadius.only(
                                topRight: Radius.circular(15),
                                topLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                                bottomLeft: Radius.circular(0),
                              ),
                      ),
                      child: Column(
                        children: <Widget>[
                          widget.isGroupe && !widget.isMe
                              ? Text(
                                  widget.friendName,
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context).textTheme.button,
                                )
                              : SizedBox(),
                          Text(
                            widget.message.message,
                            textAlign:
                                widget.isMe ? TextAlign.end : TextAlign.start,
                            style: Theme.of(context).textTheme.button.copyWith(
                                fontSize: 17,
                                color:
                                    widget.isMe ? Colors.black : Colors.white),
                          ),
                        ],
                      ),
                    ),
                    !widget.isMe
                        ? Text(
                            //horaire
                            '${widget.message.date.hour.toString().length == 1 ? 0 : ''}${widget.message.date.hour}:${widget.message.date.minute.toString().length == 1 ? 0 : ''}${widget.message.date.minute}',
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          )
                        : SizedBox(),
                  ],
                )
              : widget.message.type == 1 //photo
                  ? Row(
                      mainAxisAlignment: widget.isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FullPhoto(
                                          url: widget.message.message,
                                          file: boolChatRoom.listPhoto[id],
                                        )));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              !boolChatRoom.listPhoto.containsKey(id) && widget.message.message != null
                                  ? CachedNetworkImage(
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                        baseColor: Colors.white,
                                        highlightColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        child: Container(
                                            height: 200,
                                            width: 200,
                                            color: Colors.white),
                                      ),
                                      imageBuilder: (context, imageProvider) =>
                                          SizedBox(
                                              height: 220,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                alignment: widget.isMe
                                                    ? Alignment.centerRight
                                                    : Alignment.centerLeft,
                                                child:
                                                    Image(image: imageProvider),
                                              )),
                                      errorWidget: (context, url, error) =>
                                          Material(
                                        child: Image.asset(
                                          'assets/img/img_not_available.jpeg',
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                      imageUrl: widget.message.message,
                                      fit: BoxFit.scaleDown,
                                    )
                                  : SizedBox(
                                      height: 220,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        alignment: widget.isMe
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: boolChatRoom.listPhoto[id] !=
                                                null
                                            ? Image(
                                                image: FileImage(
                                                    boolChatRoom.listPhoto[id]))
                                            : SizedBox(),
                                      )),
                              horodatage(boolChatRoom),
                            ],
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FullPhoto(url: widget.message.message)));
                      },
                      child: Row(
                        mainAxisAlignment: widget.isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          //horodatage(boolChatRoom),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              CachedNetworkImage(
                                //gif
                                imageUrl: widget.message.message,
                                imageBuilder: (context, imageProvider) =>
                                    SizedBox(
                                        height: 220,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: FittedBox(
                                            fit: BoxFit.contain,
                                            alignment: widget.isMe
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child:
                                                Image(image: imageProvider))),
                                fit: BoxFit.fitHeight,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.white,
                                  highlightColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: Container(
                                      height: 200,
                                      width: 200,
                                      color: Colors.white),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              horodatage(boolChatRoom)
                            ],
                          ),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  Widget horodatage(BoolToggle boolChatRoom) {
    return widget.isMe && !widget.isGroupe
        ? !boolChatRoom.listTempMessages.containsKey(id)
            ? StreamBuilder<ChatMembre>(
                stream: chatMembreFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    ChatMembre chatMembre = snapshot.data;
                    if (widget.message.date.compareTo(chatMembre.lastReading) ==
                            -1 ||
                        chatMembre.isReading) {
                      return Row(
                        children: <Widget>[
                          Icon(
                            IconData(0xf382, fontFamily: "CupertinoIcons"),
                            size: 19,
                            color: Colors.green,
                          ),
                          Text(
                            DateFormat('HH:mm').format(widget.message.date),
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(color: Colors.black),
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        children: <Widget>[
                          Icon(
                            IconData(0xf3d0, fontFamily: "CupertinoIcons"),
                            size: 19,
                            color: Colors.grey,
                          ),
                          Text(
                            DateFormat('HH:mm').format(widget.message.date),
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(color: Colors.black),
                          ),
                        ],
                      );
                    }
                  }

                  return SizedBox();
                })
            : Consumer<BoolToggle>(builder: (context, boolChatRoom, child) {
                return boolChatRoom.listTempMessages[id] == -1
                    ? Icon(Icons.error)
                    : boolChatRoom.listTempMessages[id] == 0
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary))
                        : StreamBuilder<ChatMembre>(
                            stream: chatMembreFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                ChatMembre chatMembre = snapshot.data;
                                if (widget.message.date.compareTo(
                                            chatMembre.lastReading) ==
                                        -1 ||
                                    chatMembre.isReading) {
                                  return Row(
                                    children: <Widget>[
                                      Icon(
                                        IconData(0xf382,
                                            fontFamily: "CupertinoIcons"),
                                        size: 19,
                                        color: Colors.green,
                                      ),
                                      Text(
                                        DateFormat('HH:mm')
                                            .format(widget.message.date),
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .copyWith(color: Colors.black),
                                      ),
                                    ],
                                  );
                                }
                              }

                              return Row(
                                children: <Widget>[
                                  Icon(
                                    IconData(0xf3d0,
                                        fontFamily: "CupertinoIcons"),
                                    size: 19,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    DateFormat('HH:mm')
                                        .format(widget.message.date),
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(color: Colors.black),
                                  ),
                                ],
                              );
                            });

                return SizedBox();
              })
        : SizedBox();
  }
}

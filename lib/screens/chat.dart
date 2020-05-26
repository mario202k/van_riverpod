import 'package:auto_route/auto_route.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/models/my_chat.dart';
import 'package:vanevents/models/message.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/topAppBar.dart';

class Chat extends StatefulWidget with NavigationStates {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  Stream<List<MyChat>> allChat;
  Stream<List<User>> streamUserFriend;

  @override
  void dispose() {
    if (allChat != null) {
      allChat = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    allChat = db.chatRoomsStream();

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 100),
          child: TopAppBar('Chat', true, double.infinity),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight),
                child: StreamBuilder<List<Object>>(
                  stream: allChat,
                  //qui ont deja discuter
                  initialData: [],
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Erreur de connexion'),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary)),
                      );
                    }
                    List<MyChat> myChat = snapshot.data;
                    return myChat.isNotEmpty
                        ? ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder: (context, index) => Divider(
                                  color: Theme.of(context).colorScheme.primary,
                                  thickness: 1,
                                ),
                            itemCount: myChat.length,
                            itemBuilder: (context, index) {
                              MyChat chat = myChat.elementAt(index);

                              streamUserFriend = db.chatUsersStream(chat);
//
                              Stream<MyMessage> lastMsg =
                                  db.getLastChatMessage(chat.id);

                              Stream<int> msgNonLu =
                                  db.getChatMessageNonLu(chat.id);

                              return StreamBuilder<List<User>>(
                                  stream: streamUserFriend,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return SizedBox();
                                    }
                                    List<User> users = snapshot.data;
                                    User userFriend;
                                    if (!chat.isGroupe) {
                                      userFriend = users.firstWhere(
                                          (user) => user.id != db.uid);
                                    }
                                    String titre;
                                    if (chat.isGroupe) {
                                      titre = chat.titre;
                                    } else {
                                      titre = userFriend.nom;
                                    }

                                    return buildListTile(titre, chat, users,
                                        lastMsg, userFriend, msgNonLu);
                                  });
                            })
                        : Center(
                            child: Text(
                              'Pas de conversation',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          );
                  },
                ),
              ),
            );
          },
        ));
  }

  ListTile buildListTile(String titre, MyChat chat, List<User> users,
      Stream<MyMessage> lastMsg, User friend, Stream<int> msgNonLu) {
    MyMessage lastMessage;
    return ListTile(
      title: Text(
        titre,
        style: Theme.of(context).textTheme.subtitle2,
      ),
      subtitle: StreamBuilder<MyMessage>(
          stream: lastMsg,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              lastMessage = MyMessage(message: 'aucun message');
            } else {
              lastMessage = snapshot.data;
            }
            return subtitle(lastMessage, context);
          }),
      onTap: () {
        ExtendedNavigator.of(context).pushNamed(Routes.chatRoom,
            arguments: ChatRoomArguments(
                myChat: chat, membres: users, friend: friend));
      },

      leading: Stack(
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: !chat.isGroupe ? friend.imageUrl : chat.imageUrl,
            imageBuilder: (context, imageProvider) => Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
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
                radius: 25,
              ),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          !chat.isGroupe
              ? Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                        color: friend.isLogin ? Colors.green : Colors.orange),
                  ),
                )
              : SizedBox()
        ],
      ),

//                                      leading: CircleAvatar(
//                                        backgroundImage: NetworkImage(isUser
//                                            ? userFriend.imageUrl
//                                            : chatGroupe.imageUrl),
//                                        radius: 25,
//                                      ),
      trailing: Column(
        children: <Widget>[
          lastMessage != null
              ? Text(
                  //si c'est aujourh'hui l'heure sinon date
                  DateTime.now().day == lastMessage.date.day
                      ? 'aujourd\'hui'
                      : DateFormat('dd/MM/yyyy').format(lastMessage.date),
                  style: Theme.of(context).textTheme.subtitle1,
                )
              : SizedBox(),
          StreamBuilder(
              stream: msgNonLu,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                }

                int i = 0;

//                                                snapshot.data.documents
//                                                    .forEach((doc) {
//                                                  i++;
//                                                });

                return i != 0
                    ? Badge(
                        badgeContent: Text('$i'),
                        child: Icon(Icons.markunread),
                      )
                    : SizedBox();
              }),
        ],
      ),
    );
  }

  Widget subtitle(MyMessage message, BuildContext context) {
    return message.type == 0
        ? Text(
            message.message,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.subtitle1,
          )
        : message.type == 1
            ? Row(
                children: <Widget>[
                  Icon(FontAwesomeIcons.photoVideo),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Photo',
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                ],
              )
            : Row(
                children: <Widget>[
                  Icon(FontAwesomeIcons.photoVideo),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'gif',
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                ],
              );
  }
}
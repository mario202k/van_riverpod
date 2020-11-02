import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/models/event.dart';

class MyEventSearch extends SearchDelegate<MyEvent> {

  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  MyEventSearch();

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: BackButtonIcon(),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    context.bloc<MyEventSearchNameCubit>().myEventSearchNameCubit(query);

    return BlocBuilder<MyEventSearchNameCubit, MyEventSearchState>(
      builder: (BuildContext context, MyEventSearchState state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary)),
          );
        }

        if (state.hasError) {
          return Container(
            child: Text('Error', style: Theme.of(context).textTheme.button),
          );
        }

        return ListView.builder(
          itemBuilder: (context, index) {

            return ListTile(
              title: Text(state.myEvents[index].titre ?? ''),
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage(state.myEvents[index].imageFlyerUrl),
                radius: 25,
              ),
              onTap: () {
                firebaseMessaging
                    .subscribeToTopic(state.myEvents[index].chatId);
                close(context, state.myEvents[index]);
              },
            );
          },
          itemCount: state.myEvents.length,
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.

    context.bloc<MyEventSearchNameCubit>().myEventSearchNameCubit(query);

    return BlocBuilder<MyEventSearchNameCubit, MyEventSearchState>(
      builder: (BuildContext context, MyEventSearchState state) {
        if (state.isLoading) {
          return Container(
            color: Theme.of(context).colorScheme.background,
            child: Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.secondary)),
            ),
          );
        }

        if (state.hasError) {
          return Container(
            color: Theme.of(context).colorScheme.background,
            child: Center(
                child:
                    Text('Error', style: Theme.of(context).textTheme.button)),
          );
        }

//        int j;
//
//        for (int i = 0; i < state.users.length; i++) {
//          if (state.users[i].id == user.uid) {
//            j = i;
//            break;
//          }
//        }
//
//        if (j != null) state.users.removeAt(j);

        return Container(
          color: Theme.of(context).colorScheme.background,
          child: ListView.builder(
            itemBuilder: (context, index) {

              return ListTile(
                title: Text(
                  state.myEvents[index].titre ?? '',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                leading: CachedNetworkImage(
                  imageUrl: state.myEvents[index].imageFlyerUrl,
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
                    highlightColor: Colors.grey,
                    child: CircleAvatar(
                      radius: 25,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                onTap: () {
                  close(context, state.myEvents[index]);
                },
              );
            },
            itemCount: state.myEvents.length,
          ),
        );
      },
    );
  }
}

class MyEventSearchNameCubit extends Cubit<MyEventSearchState> {
  List<MyEvent> myEvents = List<MyEvent>();

  MyEventSearchNameCubit(MyEventSearchState initialState) : super(initialState);

  void myEventSearchNameCubit(String query) async {
    emit(MyEventSearchState.loading());

    try {
      List<MyEvent> myEvents = await _getSearchResults(query);
      emit(MyEventSearchState.success(myEvents));
    } catch (err) {
      emit(MyEventSearchState.error());
    }
  }

  Future<List<MyEvent>> _getSearchResults(String query) async {
    List<MyEvent> result = List<MyEvent>();

//    Firestore.instance
//        .collection('collection-name')
//        .orderBy('name')
//        .startAt([query])
//        .endAt([query + '\uf8ff']).snapshots()

    if (myEvents.isEmpty) {
//      List<MyEvent> user1 = await Firestore.instance
//          .collection('users')
//          .where('id', isGreaterThan: myId)
//          .getDocuments()
//          .then((docs) => docs.documents
//              .map((doc) => MyEvent.fromMap(doc.data, doc.documentID))
//              .toList());
//      List<MyEvent> user2 = await Firestore.instance
//          .collection('users')
//          .where('id', isLessThan: myId)
//          .getDocuments()
//          .then((docs) => docs.documents
//              .map((doc) => MyEvent.fromMap(doc.data, doc.documentID))
//              .toList());

      myEvents = await FirebaseFirestore.instance
          .collection('events')
          .get()
          .then((docs) => docs.docs
              .map((doc) => MyEvent.fromMap(doc.data(), doc.id))
              .toList());

      //users = List.from(user1)..addAll(user2); //Tout le monde sauf moi

      result.addAll(myEvents);
    } else {
      myEvents.forEach((myEvent) {
        if (myEvent.titre.contains(query)) {
          result.add(myEvent);
        }
      });
    }
    return result;
  }
}

class MyEventSearchState  {
  final bool isLoading;
  final List<MyEvent> myEvents;
  final bool hasError;

  MyEventSearchState({this.isLoading, this.myEvents, this.hasError});

  factory MyEventSearchState.initial() {
    return MyEventSearchState(
      myEvents: [],
      isLoading: false,
      hasError: false,
    );
  }

  factory MyEventSearchState.loading() {
    return MyEventSearchState(
      myEvents: [],
      isLoading: true,
      hasError: false,
    );
  }

  factory MyEventSearchState.success(List<MyEvent> users) {
    return MyEventSearchState(
      myEvents: users,
      isLoading: false,
      hasError: false,
    );
  }

  factory MyEventSearchState.error() {
    return MyEventSearchState(
      myEvents: [],
      isLoading: false,
      hasError: true,
    );
  }

  @override
  String toString() =>
      'MyEventSearchState {users: ${myEvents.toString()}, isLoading: $isLoading, hasError: $hasError }';
}

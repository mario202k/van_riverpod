import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/models/user.dart';


class UserSearch extends SearchDelegate<User> {
  final Bloc<UserSearchEvent, UserSearchState> userBloc;

  UserSearch(this.userBloc);

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
    User user = Provider.of<User>(context);
    userBloc.add(UserSearchEvent(query, user.id));

    return BlocBuilder(
      bloc: userBloc,
      builder: (BuildContext context, UserSearchState state) {
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
              title: Text(state.users[index].nom ?? ''),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(state.users[index].imageUrl),
                radius: 25,
              ),
              onTap: () {
                close(context, state.users[index]);
              },
            );
          },
          itemCount: state.users.length,
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    User user = Provider.of<User>(context);
    userBloc.add(UserSearchEvent(query, user.id));

    return BlocBuilder(
      bloc: userBloc,
      builder: (BuildContext context, UserSearchState state) {
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

              print(state.users[index]);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    state.users[index].nom ?? '',
                    style: Theme.of(context).textTheme.button,
                  ),

                  leading: CachedNetworkImage(
                    imageUrl: state.users[index].imageUrl,
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
                    placeholder:(context, url)=> Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: Colors.grey,
                      child: CircleAvatar(
                      radius: 25,
                  ),
                    ),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.error),
                  ),

//                leading: CircleAvatar(
//                  backgroundImage: NetworkImage(state.users[index].imageUrl),
//                  radius: 25,
//                ),
                  onTap: () {
                    close(context, state.users[index]);
                  },
                ),
              );
            },
            itemCount: state.users.length,
          ),
        );
      },
    );
  }
}

class UserBlocSearchName extends Bloc<UserSearchEvent, UserSearchState> {
  List<User> users = List<User>();

  @override
  UserSearchState get initialState => UserSearchState.initial();

  @override
  void onTransition(Transition<UserSearchEvent, UserSearchState> transition) {

  }

  @override
  Stream<UserSearchState> mapEventToState(UserSearchEvent event) async* {
    yield UserSearchState.loading();

    try {
      List<User> users = await _getSearchResults(event.query, event.myId);
      yield UserSearchState.success(users);
    } catch (err) {

      yield UserSearchState.error();
    }
  }

  Future<List<User>> _getSearchResults(String query, String myId) async {
    List<User> result = List<User>();

//    Firestore.instance
//        .collection('collection-name')
//        .orderBy('name')
//        .startAt([query])
//        .endAt([query + '\uf8ff']).snapshots()

    if (users.isEmpty) {
//      List<User> user1 = await Firestore.instance
//          .collection('users')
//          .where('id', isGreaterThan: myId)
//          .getDocuments()
//          .then((docs) => docs.documents
//              .map((doc) => User.fromMap(doc.data, doc.documentID))
//              .toList());
//      List<User> user2 = await Firestore.instance
//          .collection('users')
//          .where('id', isLessThan: myId)
//          .getDocuments()
//          .then((docs) => docs.documents
//              .map((doc) => User.fromMap(doc.data, doc.documentID))
//              .toList());

      users = await Firestore.instance.collection('users')
          .where('email',isGreaterThan:'')

          .getDocuments().then(
          (docs) => docs.documents
              .map((doc) => User.fromMap(doc.data, doc.documentID))
              .toList());

      users.removeWhere((user) => user.id == myId);

      //users = List.from(user1)..addAll(user2); //Tout le monde sauf moi

      result.addAll(users);
    } else {
      users.forEach((user) {
        if (user.nom.contains(query)) {
          result.add(user);
        }
      });
    }

    return result;
  }
}

class UserSearchEvent {
  final String query;
  final String myId;

  const UserSearchEvent(this.query, this.myId);

  @override
  String toString() => 'UserSearchEvent { query: $query }';
}

class UserSearchState {
  final bool isLoading;
  final List<User> users;
  final bool hasError;

  const UserSearchState({this.isLoading, this.users, this.hasError});

  factory UserSearchState.initial() {
    return UserSearchState(
      users: [],
      isLoading: false,
      hasError: false,
    );
  }

  factory UserSearchState.loading() {
    return UserSearchState(
      users: [],
      isLoading: true,
      hasError: false,
    );
  }

  factory UserSearchState.success(List<User> users) {
    return UserSearchState(
      users: users,
      isLoading: false,
      hasError: false,
    );
  }

  factory UserSearchState.error() {
    return UserSearchState(
      users: [],
      isLoading: false,
      hasError: true,
    );
  }

  @override
  String toString() {
    return 'UserSearchState{isLoading: $isLoading, users: $users, hasError: $hasError}';
  }
}
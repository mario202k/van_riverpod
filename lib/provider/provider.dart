import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanevents/models/myUser.dart';
import 'package:vanevents/repository/user_repository.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';

final notificationProvider = FutureProvider<bool>((ref)async {
  return (await SharedPreferences.getInstance()).getBool('VanEvent') ?? false;
});

//(await SharedPreferences.getInstance()).getBool('seen') ?? false

final boolToggleProvider = ChangeNotifierProvider<BoolToggle>((ref) {

  return BoolToggle();

});

final firestoreDatabaseProvider = Provider<FirestoreDatabase>((ref) {
  return FirestoreDatabase();
});

final streamMyUserProvider = StreamProvider<MyUser>((ref) {

  return ref.read(firestoreDatabaseProvider).userStream();
});


final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final myUserProvider = Provider<MyUser>((ref) {
  return MyUser();
});
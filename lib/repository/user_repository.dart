import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  Future<AuthResult> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<AuthResult> signInWithCredentials(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  
  
  Future<String> signUp({File image,String nomPrenom,String email, String password}) async {
    //Si l'utilisateur est bien inconnu
    return await _firebaseAuth
        .fetchSignInMethodsForEmail(email: email)
        // ignore: missing_return
        .then((list) async {
      if (list.isEmpty) {
        //création du user
        await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((user) async {

              if(image != null){
                //création du path pour la photo profil
                String path = image.path.substring(image.path.lastIndexOf('/') + 1);

                StorageUploadTask uploadTask = _storageReference
                    .child('imageProfile')
                    .child(user.user.uid)
                    .child("/$path")
                    .putFile(image);
                //création de l'url pour la photo profil
                await uploadImage(uploadTask).then((url) async {
                  //création du user dans la _db
                  await Firestore.instance
                      .collection('users')
                      .document(user.user.uid)
                      .setData({
                    "id": user.user.uid,
                    'nom': nomPrenom,
                    'imageUrl': url,
                    'email': email,
                    'password': password,
                    'lastActivity': DateTime.now(),
                    'provider': user.user.providerId,
                    'isLogin': false,
                  }, merge: true).then((_) async {
                    //envoi de l'email de vérification
                    await user.user.sendEmailVerification().then((_) {
                      return 'un email de validation a été envoyé';
                    }).catchError((e) {
                      print(e);
                      return 'Impossible d\'envoyer l\'e-mail';
                    });
                  });
                }).catchError((e) {
                  print(e);
                  return 'Impossible de joindre le serveur';
                });
              }else{
                //envoi de l'email de vérification
                await user.user.sendEmailVerification().then((_) {
                  return 'un email de validation a été envoyé';
                }).catchError((e) {
                  print(e);
                  return 'Impossible d\'envoyer l\'e-mail';
                });
              }

        }).catchError((e) {
          print(e);
          return 'Impossible de joindre le serveur';
        });
      } else {
        return 'L\' email existe déjà';
      }

    }).catchError((e) {
      return 'Impossible de joindre le serveur';
    });

    //return 'All done';
  }

  Future resetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);

  }


  Future<String> uploadImage(StorageUploadTask uploadTask) async {
    var url = await (await uploadTask.onComplete).ref.getDownloadURL();

    return url.toString();
  }

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<FirebaseUser> getUser() async {

    return (await _firebaseAuth.currentUser());
  }


  Future createOrUpdateUserOnDatabase(FirebaseUser user) async {
    await Firestore.instance
        .collection('users')
        .document(user.uid)
        .get()
        .then((doc) async {
      if (!doc.exists) {
        await Firestore.instance
            .collection('users')
            .document(user.uid)
            .setData({
          "id": user.uid,
          'nom': user.displayName,
          'imageUrl': user.photoUrl,
          'email': user.email,
          'lastActivity': FieldValue.serverTimestamp(),
          'provider': user.providerId,
          'isLogin': true,
        }, merge: true);
      } else {
        await Firestore.instance
            .collection('users')
            .document(user.uid)
            .setData({
          'lastActivity': FieldValue.serverTimestamp(),
          'isLogin': true,
        }, merge: true);
      }
    });
  }
}

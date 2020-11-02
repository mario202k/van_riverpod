import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vanevents/models/myUser.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithCredentials(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> loginAnonymous() {
    return _firebaseAuth.signInAnonymously();
  }

  Future<String> signUp(
      {File image,
      String nomPrenom,
      String email,
      String password,
      int typeDeCompte,
      String stripeAccount, String person}) async {
    String rep = 'Impossible de joindre le serveur';
    //Si l'utilisateur est bien inconnu
    await _firebaseAuth.fetchSignInMethodsForEmail(email)
        // ignore: missing_return
        .then((list) async {
      if (list.isEmpty) {
        //création du user
        await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((user) async {
          String uid = user.user.uid;

          if (image != null) {
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
              await _firebaseFirestore.collection('users').doc(uid).set({
                "id": uid,
                'nom': nomPrenom,
                'imageUrl': url,
                'email': email,
                'password': password,
                'lastActivity': DateTime.now(),
                'isLogin': false,
                'typeDeCompte': typeDeCompte,
                'isAcceptedCGUCGV': false,
                'stripeAccount': stripeAccount,
                'person': person,
              }, SetOptions(merge: true)).then((_) async {
                //envoi de l'email de vérification
                await user.user.sendEmailVerification().then((value) {
                  return 'Un email de validation a été envoyé';
                }).catchError((e) {
                  return 'Impossible d\'envoyer l\'email';
                });
              });
            }).catchError((e) {
              print(e);
              return 'Impossible de charger l\'image';
            });
          } else {
            //sans image
            await _firebaseFirestore.collection('users').doc(uid).set({
              "id": uid,
              'nom': nomPrenom,
              'email': email,
              'password': password,
              'lastActivity': DateTime.now(),
              'isLogin': false,
              'typeDeCompte': typeDeCompte,
              'isAcceptedCGUCGV': false,
              'stripeAccount': stripeAccount,
              'person': person,
            }, SetOptions(merge: true)).then((value) async {
              print('I love you Diana');
              await user.user.sendEmailVerification().then((value) {
                print('Un email de validation a été envoyé');
                rep = 'Un email de validation a été envoyé';
                return rep;
              }).catchError((e) {
                print(e);
                print('//');
                rep = 'Impossible d\'envoyer l\'email';
              });
            }).catchError((e) {
              print(e);
              rep = 'Impossible de joindre le serveur';
            });
          }
          //rep = 'un email de validation a été envoyé';
        }).catchError((e) {
          print(e);
          rep = 'Impossible de joindre le serveur';
        });

        //rep = 'un email de validation a été envoyé';
      } else {
        rep = 'L\' email existe déjà';
      }
    }).catchError((e) {
      print(e);
      rep = 'Impossible de joindre le serveur';
    });

    return rep;
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
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  Future<User> getFireBaseUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<bool> createOrUpdateUserOnDatabase(User user) async {
    bool isAcceptedCGUCGV = false;

    if (user.isAnonymous) {
      await _firebaseFirestore.collection('users').doc(user.uid).set({
        "id": user?.uid,
        'lastActivity': FieldValue.serverTimestamp(),
        'provider': user?.providerData,
      }, SetOptions(merge: true));

      return isAcceptedCGUCGV;
    }

    await _firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .get()
        .then((doc) async {
      if (!doc.exists) {
        await _firebaseFirestore.collection('users').doc(user.uid).set({
          "id": user.uid,
          'nom': user.displayName,
          'imageUrl': user.photoURL,
          'email': user.email,
          'lastActivity': FieldValue.serverTimestamp(),
          'isLogin': false,
          'isAcceptedCGUCGV': false,
        }, SetOptions(merge: true));
      } else {
        MyUser usr = MyUser.fromMap(doc.data(), doc.id);

        if (usr.isAcceptedCGUCGV) {
          isAcceptedCGUCGV = true;
        }

        await _firebaseFirestore.collection('users').doc(user.uid).set({
          'lastActivity': FieldValue.serverTimestamp(),
          'isLogin': true,
        }, SetOptions(merge: true));
      }
      //return doc;
    });

    return isAcceptedCGUCGV;
  }

  Future<HttpsCallableResult> createStripeAccount(
      String nomSociete,
      String email,
      String supportEmail,
      String phone,
      String url,
      String city,
      String line1,
      String line2,
      String postal_code,
      String state,
      String account_holder_name,
      String account_holder_type,
      String account_number,
      String business_type,
      String password,
      String nom,
      String prenom,
      String SIREN, String date_of_birth) async {
    business_type = toStripeBusinessType(business_type);
    account_holder_type = toStripeAccountHolderType(account_holder_type);

    print(business_type);
    print(account_holder_type);

    HttpsCallableResult stripeResponse;
    try {
      final HttpsCallable callablePaymentIntent =
          CloudFunctions.instance.getHttpsCallable(
        functionName: 'createStripeAccount',
      );
      stripeResponse = await callablePaymentIntent.call(
        <String, dynamic>{
          'nomSociete': nomSociete,
          'email': email,
          'support_email': supportEmail,
          'phone': phone,
          'url': url,
          'city': city,
          'line1': line1,
          'line2': line2,
          'postal_code': postal_code,
          'state': state,
          'account_holder_name': account_holder_name,
          'account_holder_type': account_holder_type,
          'account_number': account_number,
          'business_type': business_type,
          'password': password,
          'siren': SIREN,
          'first_name': prenom,
          'last_name': nom,
          'date_of_birth':date_of_birth
        },
      );
    } on CloudFunctionsException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }

    return stripeResponse;
  }

  String toStripeBusinessType(String business_type) {
    switch (business_type) {
      case 'Entreprise':
        return 'company';
      case 'Entité gouvernementale':
        return 'government_entity';
      case 'Particulier':
        return 'individual';
      case 'Association':
        return 'non_profit';
    }
    return '';
  }

  String toStripeAccountHolderType(String account_holder_type) {
    switch (account_holder_type) {
      case 'Entreprise':
        return 'company';
      case 'Individuel':
        return 'individual';
    }
    return '';
  }

  Future<MyUser> getMyUser(String uid) async {
    return await _firebaseFirestore
        .collection('users')
        .doc(uid)
        .get()
        .then((doc) => MyUser.fromMap(doc.data(), doc.id));
  }

  Future setIsAcceptCGUCGV(String uid) async {
    return await _firebaseFirestore.collection('users').doc(uid).set({
      'isAcceptedCGUCGV': true,
    }, SetOptions(merge: true));
  }
}

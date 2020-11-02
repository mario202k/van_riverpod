import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/bloc/stripe_profile/cubit/stripe_profile_cubit.dart';
import 'package:vanevents/models/balance.dart';
import 'package:vanevents/models/listPayout.dart';
import 'package:vanevents/models/myUser.dart';
import 'package:vanevents/screens/model_body_login.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';

class StripeProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Profile stripe'),
      ),
      body: ModelBodyLogin(
        child: BlocProvider<StripeProfileCubit>(
          create: (context) => StripeProfileCubit(context),
          child: BlocListener<StripeProfileCubit, StripeProfileState>(
            listener: (context, state) {
              if (state is StripeProfileLoading) {
                showSnackBar(context, 'Chargement...');
              } else if (state is StripeProfileFailed) {
                showSnackBar(context, state.message);
              } else if (state is StripeProfileSuccess) {
                Scaffold.of(context)..hideCurrentSnackBar();
              }
            },
            //cubit:StripeProfileCubit(context) ,
            child: BlocBuilder<StripeProfileCubit, StripeProfileState>(
              builder: (context, state) {
                if (state is StripeProfileInitial) {
                  context.bloc<StripeProfileCubit>().fetchStripeProfile(
                      Provider.of<MyUser>(context).stripeAccount,
                      Provider.of<MyUser>(context).person);
                }

                if (state is StripeProfileSuccess) {

                  return Column(

                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        direction: Axis.horizontal,
                        children: [
                          Text(state.result.businessProfile.name),
                          FittedBox(
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: state.person.verification.status ==
                                          'verified'
                                      ? Colors.greenAccent
                                      : Colors.grey,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text(buildStatus(state),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(fontSize: 22)),
                                      state.person.verification.status ==
                                              'verified'
                                          ? Icon(FontAwesomeIcons.check)
                                          : SizedBox()
                                    ],
                                  ),
                                )),
                          )
                        ],
                      ),
                      Divider(),
                      Card(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          direction: Axis.vertical,
                          children: [
                            Text(
                              'Solde non disponible :',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 22),
                            ),
                            Text(
                              toNormalAmount(
                                  toTotalPending(state.balance.pending)),
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            Text(
                              'Solde disponible :',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 22),
                            ),
                            Text(
                              toNormalAmount(
                                  toTotalAvailable(state.balance.available)),
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            Text(
                              'En transit vers la banque :',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 22),
                            ),
                            Text(
                              toTotalEnTransit(state.payoutList.data),
                              style: Theme.of(context).textTheme.headline4,
                            ),
                            Text(
                              'Volume total :',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 22),
                            ),
                            Text(
                              '0',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // direction: Axis.vertical,
                          children: [
                            Text(
                              'Créer le : ' +
                                  DateFormat('dd/MM/yyyy').format(
                                      Timestamp.fromMillisecondsSinceEpoch(
                                              state.person.created*1000)
                                          .toDate()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 22),
                            ),
                            Text(
                              'SIREN : ' +
                                  isProvided(
                                      state.result.company.taxIdProvided),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontSize: 22)
                            ),
                            Text(
                              'Site internet : ' +
                                  isProvided(
                                      state.result.businessProfile.url !=
                                          null),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(fontSize: 22)
                            ),
                            Center(
                              child: Text(
                                'Numéro de téléphone : ' +
                                    state.result.businessProfile.supportPhone,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(fontSize: 22),
                                overflow: TextOverflow.fade,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Text(
                              'Adresse: ' +
                                  state.result.company.address.line1 +
                                  ' ' +
                                  state.result.company.address.postalCode +
                                  ' ' +
                                  state.result.company.address.city,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 22),
                                textAlign: TextAlign.center
                            ),
                            Text(
                              'Compte Bancaire : ' +
                                  state.result.externalAccounts.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 22),
                                textAlign: TextAlign.center
                            ),
                            Text(
                              'Représentant : ' +
                                  state.person.firstName +
                                  ' ' +
                                  state.person.lastName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 22),
                                textAlign: TextAlign.center
                            ),
                            Text(
                              'Status : ' + buildStatus(state),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(fontSize: 22),
                                textAlign: TextAlign.center
                            ),

                          ],
                        ),
                      ),
                      Divider(),
                      Text(
                        'Document d\'indentité recto',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      InkWell(
                        onTap: () async {
                          File file =
                          await showDialogSource(context, 'idFront');

                          if (file != null) {
                            StorageUploadTask uploadTask = FirebaseStorage
                                .instance
                                .ref()
                                .child('front' +
                                Provider.of<MyUser>(context).id)
                                .putFile(file);

                            StorageTaskSnapshot storageTaskSnapshot =
                            await context
                                .read<FirestoreDatabase>()
                                .uploadImageStripe(uploadTask);

                            print(storageTaskSnapshot);
                            print('!!!!!');
                            print("wait...");

                            HttpsCallableResult response = await context
                                .read<FirestoreDatabase>()
                                .uploadFileToStripe(
                                storageTaskSnapshot
                                    .storageMetadata.path,
                                Provider.of<MyUser>(context)
                                    .stripeAccount,
                                Provider.of<MyUser>(context).person);

                            if (response != null) {
                              context.read<BoolToggle>().setUrlFront(
                                  await storageTaskSnapshot.ref
                                      .getDownloadURL());
                            }
                            print(response?.data);
                          }
                        },
                        child: Container(
                          child: context.watch<BoolToggle>().urlIdFront !=
                              null
                              ? CachedNetworkImage(
                            placeholder: (context, url) =>
                                Shimmer.fromColors(
                                  baseColor: Colors.white,
                                  highlightColor: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  child: Container(
                                      height: 900,
                                      width: 600,
                                      color: Colors.white),
                                ),
                            imageBuilder:
                                (context, imageProvider) =>
                                SizedBox(
                                  height: MediaQuery.of(context)
                                      .size
                                      .height *
                                      0.5,
                                  width:
                                  MediaQuery.of(context).size.width,
                                  child: Image(
                                    image: imageProvider,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                            errorWidget: (context, url, error) =>
                                Material(
                                  child: Image.asset(
                                    'assets/img/img_not_available.jpeg',
                                    width: 300.0,
                                    height: 300.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                            imageUrl: context
                                .watch<BoolToggle>()
                                .urlIdFront,
                            fit: BoxFit.scaleDown,
                          )
                              : Icon(
                            FontAwesomeIcons.image,
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            size: 220,
                          ),
                        ),
                      ),
                      Text(
                        'Document d\'indentité verso',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      InkWell(
                        onTap: () async {
                          File file =
                          await showDialogSource(context, 'idFront');

                          if (file != null) {
                            StorageUploadTask uploadTask = FirebaseStorage
                                .instance
                                .ref()
                                .child('back' +
                                Provider.of<MyUser>(context).id)
                                .putFile(file);

                            StorageTaskSnapshot storageTaskSnapshot =
                            await context
                                .read<FirestoreDatabase>()
                                .uploadImageStripe(uploadTask);

                            print(storageTaskSnapshot);
                            print('!!!!!');
                            print("wait...");

                            HttpsCallableResult response = await context
                                .read<FirestoreDatabase>()
                                .uploadFileToStripe(
                                storageTaskSnapshot
                                    .storageMetadata.path,
                                Provider.of<MyUser>(context)
                                    .stripeAccount,
                                Provider.of<MyUser>(context).person);

                            print(response?.data);
                          }
                        },
                        child: Container(
                          child: context.watch<BoolToggle>().urlIdBack !=
                              null
                              ? CachedNetworkImage(
                            placeholder: (context, url) =>
                                Shimmer.fromColors(
                                  baseColor: Colors.white,
                                  highlightColor: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  child: Container(
                                      height: 900,
                                      width: 600,
                                      color: Colors.white),
                                ),
                            imageBuilder:
                                (context, imageProvider) =>
                                SizedBox(
                                  height: MediaQuery.of(context)
                                      .size
                                      .height *
                                      0.5,
                                  width:
                                  MediaQuery.of(context).size.width,
                                  child: Image(
                                    image: imageProvider,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                            errorWidget: (context, url, error) =>
                                Material(
                                  child: Image.asset(
                                    'assets/img/img_not_available.jpeg',
                                    width: 300.0,
                                    height: 300.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                            imageUrl: context
                                .watch<BoolToggle>()
                                .urlIdBack,
                            fit: BoxFit.scaleDown,
                          )
                              : Icon(
                            FontAwesomeIcons.image,
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            size: 220,
                          ),
                        ),
                      ),
                      Text(
                        'Justificatif de domicile',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      InkWell(
                        onTap: () async {
                          File file =
                          await showDialogSource(context, 'idFront');

                          if (file != null) {
                            StorageUploadTask uploadTask = FirebaseStorage
                                .instance
                                .ref()
                                .child('justificatifDomicile' +
                                Provider.of<MyUser>(context).id)
                                .putFile(file);

                            StorageTaskSnapshot storageTaskSnapshot =
                            await context
                                .read<FirestoreDatabase>()
                                .uploadImageStripe(uploadTask);

                            print(storageTaskSnapshot);
                            print('!!!!!');
                            print("wait...");

                            HttpsCallableResult response = await context
                                .read<FirestoreDatabase>()
                                .uploadFileToStripe(
                                storageTaskSnapshot
                                    .storageMetadata.path,
                                Provider.of<MyUser>(context)
                                    .stripeAccount,
                                Provider.of<MyUser>(context).person);

                            if (response != null) {
                              context.read<BoolToggle>().setJD(
                                  await storageTaskSnapshot.ref
                                      .getDownloadURL());
                            }
                            print(response?.data);
                          }
                        },
                        child: Container(
                          child: context.watch<BoolToggle>().urlJD != null
                              ? CachedNetworkImage(
                            placeholder: (context, url) =>
                                Shimmer.fromColors(
                                  baseColor: Colors.white,
                                  highlightColor: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  child: Container(
                                      height: 900,
                                      width: 600,
                                      color: Colors.white),
                                ),
                            imageBuilder:
                                (context, imageProvider) =>
                                SizedBox(
                                  height: MediaQuery.of(context)
                                      .size
                                      .height *
                                      0.5,
                                  width:
                                  MediaQuery.of(context).size.width,
                                  child: Image(
                                    image: imageProvider,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                            errorWidget: (context, url, error) =>
                                Material(
                                  child: Image.asset(
                                    'assets/img/img_not_available.jpeg',
                                    width: 300.0,
                                    height: 300.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                            imageUrl:
                            context.watch<BoolToggle>().urlJD,
                            fit: BoxFit.scaleDown,
                          )
                              : Icon(
                            FontAwesomeIcons.image,
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            size: 220,
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<File> showDialogSource(BuildContext context, String type) {
    return showDialog<File>(
      context: context,
      builder: (BuildContext context) => Platform.isAndroid
          ? AlertDialog(
              title: Text('Source?'),
              content: Text('Veuillez choisir une source'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Caméra'),
                  onPressed: () async {
                    File file =
                        await context.read<BoolToggle>().getImageCamera(type);
                    Navigator.of(context).pop(file);
                  },
                ),
                FlatButton(
                  child: Text('Galerie'),
                  onPressed: () async {
                    File file =
                        await context.read<BoolToggle>().getImageGallery(type);

                    Navigator.of(context).pop(file);
                  },
                ),
              ],
            )
          : CupertinoAlertDialog(
              title: Text('Source?'),
              content: Text('Veuillez choisir une source'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Caméra'),
                  onPressed: () async {
                    File file =
                        await context.read<BoolToggle>().getImageCamera(type);
                    Navigator.of(context).pop(file);
                  },
                ),
                FlatButton(
                  child: Text('Galerie'),
                  onPressed: () async {
                    File file =
                        await context.read<BoolToggle>().getImageGallery(type);
                    Navigator.of(context).pop(file);
                  },
                ),
              ],
            ),
    );
  }

  String buildStatus(StripeProfileSuccess state) =>
      state.person.verification.status == 'verified'
          ? 'Vérifié'
          : 'Non vérifié';

  String toNormalAmount(int amount) {
    return (amount / 100).toStringAsFixed(
            (amount / 100).truncateToDouble() == (amount / 100) ? 0 : 2) +
        ' €';
  }

  void showSnackBar(BuildContext context, String content) {
    Scaffold.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(content),
              content == 'Chargement du profil...'
                  ? CircularProgressIndicator()
                  : SizedBox(),
            ],
          ),
          duration: Duration(minutes: 1),
        ),
      );
  }

  String isProvided(bool taxIdProvided) {
    return taxIdProvided ? 'Fournie' : 'Non Fournie';
  }

  int toTotalPending(List<Pending> pending) {
    int total = 0;
    for (int i = 0; i < pending.length; i++) {
      total += pending.elementAt(i).amount;
    }

    return total;
  }

  int toTotalAvailable(List<Available> available) {
    int total = 0;
    for (int i = 0; i < available.length; i++) {
      total += available.elementAt(i).amount;
    }

    return total;
  }

  String toTotalEnTransit(List<Data> data) {
    int total = 0;

    data.removeWhere((element) => element.status != "pending");

    for (int i = 0; i < data.length; i++) {
      total += data.elementAt(i).amount;
    }

    return toNormalAmount(total * 100);
  }
}

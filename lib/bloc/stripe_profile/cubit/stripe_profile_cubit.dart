import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/balance.dart';
import 'package:vanevents/models/connected_account.dart';
import 'package:vanevents/models/listPayout.dart';
import 'package:vanevents/models/person.dart';
import 'package:vanevents/services/firestore_database.dart';

part 'stripe_profile_state.dart';

class StripeProfileCubit extends Cubit<StripeProfileState> {
  final BuildContext _context;

  StripeProfileCubit(this._context) : super(StripeProfileInitial());

  void fetchStripeProfile(String stripeAccount, String person) async {
    emit(StripeProfileLoading());
    HttpsCallableResult httpsCallableResultPayoutList =
        await _context.read<FirestoreDatabase>().payoutList(stripeAccount);

    HttpsCallableResult httpsCallableResultAccount = await _context
        .read<FirestoreDatabase>()
        .retrieveStripeAccount(stripeAccount);
    HttpsCallableResult httpsCallableResultBalance = await _context
        .read<FirestoreDatabase>()
        .organisateurBalance(stripeAccount);
    HttpsCallableResult httpsCallableResultPerson = await _context
        .read<FirestoreDatabase>()
        .retrievePerson(stripeAccount, person);

    if (httpsCallableResultAccount == null ||
        httpsCallableResultBalance == null ||
        httpsCallableResultPerson == null ||
        httpsCallableResultPayoutList == null) {
      emit(StripeProfileFailed('Impossible de charger le profil'));
      return;
    }

    print(httpsCallableResultPayoutList.data);

    emit(StripeProfileSuccess(
        payoutList: ListPayout.fromMap(httpsCallableResultPayoutList.data),
        result: ConnectedAccount.fromMap(httpsCallableResultAccount.data),
        balance: Balance.fromMap(httpsCallableResultBalance.data),
        person: Person.fromMap(httpsCallableResultPerson.data)));
  }
}

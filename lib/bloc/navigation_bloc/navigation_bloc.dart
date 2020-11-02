import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanevents/screens/billets.dart';
import 'package:vanevents/screens/chat.dart';
import 'package:vanevents/screens/home_events.dart';
import 'package:vanevents/screens/profile.dart';

enum NavigationEvents{HomeEvents,Chat,Billets,Profil}

abstract class NavigationStates{

}

class NavigationBloc extends Bloc<NavigationEvents,NavigationStates>{
  NavigationBloc(NavigationStates initialState) : super(initialState);

  @override

  NavigationStates get initialState => HomeEvents();

  @override
  Stream<NavigationStates> mapEventToState(NavigationEvents event) async*{

    switch(event){

      case NavigationEvents.HomeEvents:
        yield HomeEvents();
        break;
      case NavigationEvents.Chat:
        yield Chat();
        break;
      case NavigationEvents.Billets:
        yield Billets();
        break;
      case NavigationEvents.Profil:
        yield Profil();
        break;
    }
  }
}
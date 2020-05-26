import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/models/ticket.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/toggle_bool_chat_room.dart';
import 'package:vanevents/shared/topAppBar.dart';

class Profil extends StatefulWidget with NavigationStates{

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  Future<List<Ticket>> futureTickets;
  bool notification = true;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();



  @override
  void initState() {


    super.initState();
  }

  void fcmSubscribe() {
    firebaseMessaging.subscribeToTopic('VanEvent');


  }

  void fcmUnSubscribe() {
    firebaseMessaging.unsubscribeFromTopic('VanEvent');

  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context, listen: true);
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    futureTickets = db.futureTicketParticipation();
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 100),
          child: TopAppBar(
              'Profil',
              true,
              double.infinity),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
                child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text(
                        user.nom,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.onBackground,
                      thickness: 1,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        'Participations:',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    FutureBuilder(
                      future: futureTickets,
                      builder: (context, async) {
                        if (async.hasError) {
                          print(async.error);
                          return Center(
                            child: Text('Erreur de connexion',style: Theme.of(context).textTheme.subtitle2,),
                          );
                        } else if (async.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.secondary)),
                          );
                        }

                        List<Ticket> tickets = List<Ticket>();

                        tickets.addAll(async.data);

//                        for(int i=0; i<tickets.length ;i++){
//                          for(int j=0; j<tickets.length;j++){
//
//                            if()
//
//                          }
//                        }

                        return tickets.isNotEmpty
                            ? SizedBox(
                                height: 100,
                                child: ListView.separated(
                                  separatorBuilder: (context,index)=>SizedBox(width: 12,),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: tickets.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CachedNetworkImage(
                                        imageUrl: tickets[index].imageUrl,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          height: 84,
                                          width: 84,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(84)),
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Shimmer.fromColors(
                                          baseColor: Colors.white,
                                          highlightColor: Theme.of(context).colorScheme.primary,
                                          child: CircleAvatar(
                                            radius: 42,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : SizedBox();
                      },
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.onBackground,
                      thickness: 1,
                    ),
                    ListTile(
                      leading: Icon(FontAwesomeIcons.envelope,
                          color: Theme.of(context).colorScheme.onBackground),
                      title: Text(
                        user.email,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Consumer<BoolToggle>(
                      builder: (context,boolToggle, child) {
                        return boolToggle.isEnableNotification? SwitchListTile(
                          title: Text(
                            'Notifications',
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                          value: true,
                          onChanged: (b) {
                            context.read<BoolToggle>().setIsEnableNotification(b);

                            if(b){
                              fcmSubscribe();
                            }else{
                              fcmUnSubscribe();
                            }
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        ):SwitchListTile(
                          title: Text(
                            'Notifications',
                            style: Theme.of(context).textTheme.button,
                          ),
                          value: false,
                          onChanged: (b) {
                            context.read<BoolToggle>().setIsEnableNotification(b);

                            if(b){
                              fcmSubscribe();
                            }else{
                              fcmUnSubscribe();
                            }
                          },
                          activeColor: Theme.of(context).colorScheme.secondary,
                        );
                      }
                    )
                  ],
                ),
              ),
            ));
          },
        ));
  }
}

class CustomShapeBorder extends ContinuousRectangleBorder {
  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    final double innerCircleRadius = 150.0;

    Path path = Path();
    path.lineTo(0, rect.height);
    path.quadraticBezierTo(rect.width / 2 - (innerCircleRadius / 2) - 30,
        rect.height + 15, rect.width / 2 - 75, rect.height + 50);
    path.cubicTo(
        rect.width / 2 - 40,
        rect.height + innerCircleRadius - 40,
        rect.width / 2 + 40,
        rect.height + innerCircleRadius - 40,
        rect.width / 2 + 75,
        rect.height + 50);
    path.quadraticBezierTo(rect.width / 2 + (innerCircleRadius / 2) + 30,
        rect.height + 15, rect.width, rect.height);
    path.lineTo(rect.width, 0.0);
    path.close();

    return path;
  }
}

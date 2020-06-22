import 'dart:io';
import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/bloc/navigation_bloc/navigation_bloc.dart';
import 'package:vanevents/models/ticket.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/screens/model_body.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/topAppBar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_extend/share_extend.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';


class Billets extends StatefulWidget with NavigationStates{


  Billets() ;

  @override
  _BilletsState createState() => _BilletsState();
}

class _BilletsState extends State<Billets> {
  Stream<List<Ticket>> streamTickets;
  List<Ticket> tickets = List<Ticket>();

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    streamTickets = db.streamTicketsUser();
    return StreamBuilder(
      stream: streamTickets,
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

        tickets.clear();
        tickets.addAll(snapshot.data);

        return tickets.isNotEmpty ? ListView.separated(
          physics: ClampingScrollPhysics(),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.15,
              actions: <Widget>[
                IconSlideAction(
                  caption: 'Rembourser',
                  color: Theme.of(context).colorScheme.secondary,
                  icon: FontAwesomeIcons.moneyBillWave,
                  onTap: () =>
                      db.showSnackBar('Archive', context),
                ),
              ],
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: 'Detail',
                  color: Theme.of(context)
                      .colorScheme
                      .primaryVariant,
                  icon: FontAwesomeIcons.search,
                  onTap: () => db.showSnackBar('Search', context),
                ),
                IconSlideAction(
                    caption: 'Partager',
                    color: Theme.of(context)
                        .colorScheme
                        .primaryVariant,
                    icon: FontAwesomeIcons.shareAlt,
                    onTap: () =>
                        partager(tickets.elementAt(index).id))
              ],
              child: ListTile(
                leading:
                dateDachat(tickets.elementAt(index).dateTime),
                title: Text(tickets.elementAt(index).status,style: Theme.of(context).textTheme.button,),
                trailing: Icon(FontAwesomeIcons.qrcode,color: Theme.of(context).colorScheme.onBackground,),
                onTap: () => ExtendedNavigator.of(context)
                    .pushNamed(Routes.qrCode,
                    arguments: QrCodeArguments(
                        data: tickets.elementAt(index).id)),
              ),
            );
          },
          shrinkWrap: true,
          separatorBuilder: (context, index) => Divider(
            color: Theme.of(context).colorScheme.secondary,
            thickness: 1,
          ),
        ):Center(
          child: Text(
            'Pas de billets',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        );
      },
    );
  }

  Widget dateDachat(DateTime dateTime) {

    final date = DateFormat(
      'dd/MM/yy',
    );

    return Text(date.format(dateTime),style: Theme.of(context).textTheme.button,);
  }

  partager(String id) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.QrCodeWidget(data: id, size: 320,backgroundColor: PdfColor.fromInt(Colors.white.value)),
          ); // Center
        })); //

    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    String tempPath = directory.path;

    final file = File('$tempPath/QrCode.pdf');
    await file.writeAsBytes(pdf.save());

    ShareExtend.share(file.path, "file");

//    try {
//      print('//');
//      final ByteData bytes = await rootBundle.load('$tempPath/$id.pdf');
//      print(tempPath);
//      print('//');
//      await WcFlutterShare.share(
//          sharePopupTitle: 'Billet',
//          fileName: 'Billet.pdf',
//          mimeType: 'application/pdf',
//          bytesOfFile: bytes.buffer.asUint8List());
//    } catch (e) {
//      print('error: $e');
//    }

//    Uint8List bytes = file.readAsBytesSync();
//
//
//    print(file.path);
//
//    final ByteData bytesData = ByteData.view(bytes.buffer);
//    await WcFlutterShare.share(
//        sharePopupTitle: 'Billet',
//        fileName: 'Billet.pdf',
//        mimeType: 'application/pdf',
//        bytesOfFile: bytesData.buffer.asUint8List());
  }
}


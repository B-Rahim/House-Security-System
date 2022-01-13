import 'package:flutter/material.dart';
import 'package:safe/models/house_model.dart';
import 'package:safe/utils/houseCard.dart';
import 'package:safe/utils/dataBaseHelper.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';
import 'package:safe/models/message_model.dart';
import 'package:vibration/vibration.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
  String date =
      DateFormat('yyyy-MM-dd \n kk:mm').format(DateTime.now()).toString();
  DataBaseHelper().insertMsg(
      Message(content: message.body, datetime: date, phone: message.address));
  print('received SMS: ${message.body}');
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _message;
  final telephony = Telephony.instance;

  DataBaseHelper dbHelper = DataBaseHelper();
  List<House> houses;
  int count;
  @override
  void initState() {
    // TODO: implement initState
    var fut = dbHelper.getCount();
    fut.then((value) => count = value);
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    if (houses == null) {
      houses = [];
      updateListView();
    }
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("${widget.title}: $count"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: houses.length,
        itemBuilder: (context, index) {
          return HouseCard(houses[index], () async {
            int result = await dbHelper.deleteHouse(houses[index]);
            if (true) {
              updateListView();
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('House Deleted Successfully')));
            }
          }, () async {
            updateListView();
          });
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/new',
              arguments: House(name: '', phone: '', address: ''));
          updateListView();
        },
        tooltip: 'Add house',
        child: Icon(Icons.add),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  updateListView() {
    Future<List<House>> FutureHouseList = dbHelper.getHouseList();
    dbHelper.getCount().then((value){count=value;});
    FutureHouseList.then((houseList) {
      setState(() {
        this.houses = houseList;
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  onMessage(SmsMessage message) async {
    Vibration.vibrate(duration: 1000);
  }

  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool result = await telephony.requestPhoneAndSmsPermissions;

    if (result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  _showDialog(String title, String content) {
    return showDialog(
        context: context,
        builder: (context) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.pop(context);
          });
          return AlertDialog(
            title: Text(title),
            content: Text(content),
          );
        });
  }
}

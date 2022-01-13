import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safe/models/house_model.dart';
import 'package:safe/utils/houseCard.dart';
import 'package:safe/utils/dataBaseHelper.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';
import 'package:safe/models/message_model.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
  String date =
      DateFormat('yyyy-MM-dd \n kk:mm').format(DateTime.now()).toString();
  DataBaseHelper().insertMsg(
      Message(content: message.body, datetime: date, phone: message.address));
  print('received SMS: ${message.body}');
}

class MyHomeScreen extends StatefulWidget {
  MyHomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
         final result = await Navigator.pushNamed(context, '/scan');
          if(result==null)
            return;
          await Navigator.pushNamed(context, "/new",
              arguments: House(
                  phone: result, name: "", address: ""));
          updateListView();
        },
        tooltip: 'Add house',
        label: Container(
          padding: const EdgeInsets.all(20.0),
          child: Text("Add New Device", style: TextStyle(fontSize: 20)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  updateListView() {
    Future<List<House>> futureHouseList = dbHelper.getHouseList();
    futureHouseList.then((houseList) {
      count = houseList.length;
      setState(() {
        print("updating list view");
        this.houses = houseList;
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  onMessage(SmsMessage message) async {
    //Vibration.vibrate(duration: 1000);
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

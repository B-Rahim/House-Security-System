import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safe/timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';
import 'package:safe/models/house_model.dart';
import 'package:safe/models/message_model.dart';
import 'package:safe/utils/dataBaseHelper.dart';
import 'package:telephony/telephony.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
  String date = DateFormat('yyyy-MM-dd \n kk:mm').format(DateTime.now()).toString();
  DataBaseHelper().insertMsg(Message(content: message.body, datetime: date, phone: message.address ));
  /*Vibration.vibrate(
    pattern: [500, 1000, 500, 2000, 500, 3000, 500],
  );*/
  print('received SMS: ${message.body}');
}

class History extends StatefulWidget {
  final House house;

  History(this.house);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  DataBaseHelper dbHelper = DataBaseHelper();
  Future<List<Message>> messages;
  String _datetime;
  final String cameraSMS = "Test message, confirm reception!";
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    _getTime();
    _updateMessageList();
    telephony.listenIncomingSms(onNewMessage:  onMessage, onBackgroundMessage: onBackgroundMessage );
  }

  _updateMessageList() {
    setState(() {
      messages = dbHelper
          .getMsgList(widget.house.phone); //TODO retrieve messages for specific house not all !!
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      appBar: AppBar(
        title: Text('${widget.house.name} messaging history'),
      ),
      body: FutureBuilder(
          future: messages,
          builder: (context, snapshot) {
            return !snapshot.hasData
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.all(20),
                    reverse: true,
                    itemCount:  snapshot.data.length,
                    itemBuilder: (context, index) {
                      return TimelineTile(
                        alignment: TimelineAlign.manual,
                        lineXY: 0.3,
                        startChild: Container(
                            margin: EdgeInsets.symmetric(vertical: 30),
                            child: widget.house.id==null? Text(_datetime):
                        Text(snapshot.data[snapshot.data.length-1-index].datetime)),
                        endChild: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(widget.house.id == null?
                              '$index Here you find the message body'
                              :snapshot.data[snapshot.data.length-1-index].content,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            )),
                        isFirst: index == (snapshot.data.length) -1,
                        isLast: index == 0,
                        afterLineStyle: LineStyle(color: Colors.deepOrange),
                        beforeLineStyle: LineStyle(color: Colors.deepOrange),
                        indicatorStyle: IndicatorStyle(
                            width: 30,
                            height: 30,
                            color: Colors.deepOrange,
                            indicator: Icon(Icons.circle,
                                size: 30, color: Colors.deepOrange)),
                      );
                    },
                  );
          }),
      bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: Icon(Icons.delete_forever), onPressed: (){
                messages.then((msgs){
                  for(var msg in msgs)
                    dbHelper.deleteMsg(msg);
                });
                _updateMessageList();
              }),
              IconButton(
                  icon: Icon(Icons.camera_alt_outlined),
                  onPressed: () {
                    startRec();
                  })
            ],
          )),
    );
  }
  startRec(){
    telephony.sendSms(
        to: widget.house.phone,
        message: cameraSMS,
        statusListener: (SendStatus status) {
          // Handle the status
          bool delivered = false;
          switch(status){
            case SendStatus.DELIVERED:
              delivered = true;
              dbHelper.insertMsg(Message(
                  content: cameraSMS,
                  phone: widget.house.phone,
                  datetime: _getTime()));
              _showDialog('Status', "SMS sent and Delivered");
              _updateMessageList();
              break;
            case SendStatus.SENT:
              Future.delayed(Duration(seconds: 4),(){
                if(delivered)
                  _showDialog("Status", "SMS was not delivered.");
              });

          }
        });}

  onMessage(SmsMessage message) async {
    String date = DateFormat('yyyy-MM-dd \n kk:mm').format(DateTime.now()).toString();
    DataBaseHelper().insertMsg(Message(content: message.body, datetime: date, phone: message.address ));
    _updateMessageList();
   // Vibration.vibrate(duration: 1000);
    print('received SMS: ${message.body}');
    _showDialog('Notification', 'Recieved new message');
  }
  String _getTime() {
    final String formattedDateTime =
        DateFormat('yyyy-MM-dd \n kk:mm').format(DateTime.now()).toString();
    setState(() {
      _datetime = formattedDateTime;
    });
    return formattedDateTime;
  }
  _showDialog(String title, String content){
    return showDialog(context: context, builder: (context){
      Future.delayed(Duration(seconds: 2),(){ Navigator.pop(context);});
      return AlertDialog(
        title: Text(title),
        content: Text(content),
      );
    });
  }
}

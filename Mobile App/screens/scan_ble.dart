import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:safe/utils/ble_widget.dart';
import 'package:safe/models/house_model.dart';
import 'package:safe/screens/new_edit.dart';

class ScanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return FindDevicesScreen();
          }
          return BluetoothOffScreen(state: state);
        });
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);

  final BluetoothState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: StreamBuilder<List<ScanResult>>(
            stream: FlutterBlue.instance.scanResults,
            initialData: [],
            builder: (c, snapshot) => Column(
              children: snapshot.data
                  .map(
                    (r) => (r.device.name == "PSESI_SAFE")
                        ? ScanResultTile(
                            result: r,
                            onTap: () async {
                              final result = await Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return LoadingScreen(device: r.device);
                              }));
                              if (result != null)
                                Navigator.pop(context, result);
                              else
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      Future.delayed(Duration(seconds: 2), () {
                                        Navigator.pop(context);
                                      });
                                      return AlertDialog(
                                        title: Text("Pairing failed !"),
                                        // content: Text(content),
                                      );
                                    });
                            },
                          )
                        : Container(),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final enc = AsciiEncoder();
  final dec = AsciiDecoder();

  String phone = "";
  Widget loading = SpinKitFadingCircle(
    color: Colors.white,
    size: 150.0,
  );
  void pairing() async {
    var d = widget.device;
    await d.connect();
    var state = await d.state.first;
    print("state $state");
    int RDWR = 0;

    if (state != BluetoothDeviceState.connected) Navigator.of(context).pop();

    List<BluetoothService> services = await d.discoverServices();
    var service = services.last;

    if (service.uuid.toString().substring(4, 8) != 'aaaa') {
      d.disconnect();
      Navigator.of(context).pop();
    }

    for (var c in service.characteristics) {
      if (c.uuid.toString().substring(0, 4) == "0000") {
        phone = dec.convert(await c.read());
        print("read");
        RDWR++;
      }
      if (c.uuid.toString().substring(0, 4) == "1111") {
        await c.write(enc.convert("+33780777616"));
        print("write");
        RDWR++;
      }
    }
    d.disconnect();

    if (RDWR != 2)
      Navigator.of(context).pop();

    setState(() {
      loading = Icon(
        Icons.check_circle,
        color: Colors.white,
        size: 150,
      );
    });
    await Future.delayed(Duration(milliseconds: 1000));
    Navigator.of(context).pop(phone);
  }

  @override
  void initState() {
    // TODO: implement initState
    pairing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: loading,
      ),
    );
  }
}

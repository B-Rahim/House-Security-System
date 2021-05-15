import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'widgets.dart';

void main() {
  runApp(FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

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
              children: snapshot.data!
                  .map(
                    (r) => (r.device.name == "PSESI_SAFE")
                        ? ScanResultTile(
                            result: r,
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return LoadingScreen(device: r.device);
                              }));
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
          if (snapshot.data!) {
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
  LoadingScreen({Key? key, required this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final enc = AsciiEncoder();
  final dec = AsciiDecoder();

  String  phone = "";
  Widget loading = SpinKitFadingCircle(
    color: Colors.white,
    size: 150.0,
  );
  void pairing() async {
    var d = widget.device;
    await d.connect();
    var state = await d.state.first;
    print("state $state");
    BluetoothCharacteristic readC ;

    if (state == BluetoothDeviceState.connected) {
      List<BluetoothService> services = await d.discoverServices();
      var service = services.last;
      if (service.uuid.toString().substring(4, 8) == 'aaaa') {
        for (var c in service.characteristics){
          if (c.uuid.toString().substring(0, 4) == "0000")
            phone = dec.convert(await c.read());
          if (c.uuid.toString().substring(0, 4) == "1111")
            await c.write(enc.convert("+33780777616"));
        }
          setState(() {
            loading = Icon(Icons.check_circle, color: Colors.white, size:150,);
          });
      }


      print(phone);
      d.disconnect();
    }
    await Future.delayed(Duration(milliseconds: 500));
    Navigator.of(context).pop();
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

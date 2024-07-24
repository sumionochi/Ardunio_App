import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Arduino HC-05',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  List<BluetoothService>? _services;

  void connectToDevice() async {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    // ignore: unused_local_variable
    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name == 'HC-05') {
          setState(() {
            _device = r.device;
          });
          flutterBlue.stopScan();
          connect(_device!);
          break;
        }
      }
    });
  }

  void connect(BluetoothDevice device) async {
    await device.connect();
    _services = await device.discoverServices();
    setState(() {
      _services = _services;
    });

    for (BluetoothService service in _services!) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.properties.notify || c.properties.read) {
          _characteristic = c;
          c.value.listen((value) {
            print('Received: ${String.fromCharCodes(value)}');
          });
          await c.setNotifyValue(true);
        }
      }
    }
  }

  void sendMessage(String message) async {
    if (_characteristic != null) {
      await _characteristic!.write(message.codeUnits);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Arduino HC-05'),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: connectToDevice,
            child: Text('Connect to HC-05'),
          ),
          if (_device != null)
            Text('Connected to: ${_device!.name}'),
          if (_characteristic != null)
            TextField(
              onSubmitted: sendMessage,
              decoration: InputDecoration(
                labelText: 'Send a message',
              ),
            ),
        ],
      ),
    );
  }
}

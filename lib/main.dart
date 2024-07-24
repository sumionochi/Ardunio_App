import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<BluetoothDevice> _devices = [];
  late BluetoothConnection connection;
  String address = "00:21:07:00:50:69"; // your Bluetooth device MAC Address

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      _devices = devices;
    });
  }

  Future<void> sendData(String data) async {
    data = data.trim();
    try {
      List<int> list = data.codeUnits;
      Uint8List bytes = Uint8List.fromList(list);
      connection.output.add(bytes);
      await connection.output.allSent;
      if (kDebugMode) {
        // print('Data sent successfully');
      }
    } catch (e) {
      //print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Bluetooth Single LED Control"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("MAC Address: 00:22:09:01:86:17"),
              ElevatedButton(
                child: const Text("Connect"),
                onPressed: () {
                  connect(address);
                },
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                child: const Text(" OPEN "),
                onPressed: () {
                  sendData("on");
                },
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                child: const Text("CLOSE"),
                onPressed: () {
                  sendData("off");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future connect(String address) async {
    try {
      connection = await BluetoothConnection.toAddress(address);
      sendData('111');
      connection.input!.listen((Uint8List data) {
        // Data entry point
      });
    } catch (exception) {
      // Handle connection exception
    }
  }
}

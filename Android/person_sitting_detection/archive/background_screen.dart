import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:workmanager/workmanager.dart';
import 'package:location_permissions/location_permissions.dart';
import 'login_screen.dart';

const simplePeriodicTask = "simplePeriodicTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simplePeriodicTask:
        String deviceAddress = 'b3:7d:3c:10:7f:96';
        String value = '[null]';

        // await Firebase.initializeApp();
        // var firestore = FirebaseFirestore.instance;
        // await auth.signInWithEmailAndPassword(email: inputData!['email']!, password: inputData!['password']!);

        Uuid serviceID = Uuid.parse('1101');
        Uuid characteristicsID = Uuid.parse('2101');


        final FlutterReactiveBle _ble = FlutterReactiveBle();
        StreamSubscription? _subscription;
        StreamSubscription<ConnectionStateUpdate>? _connection;

        void _disconnect() async {
          if (_subscription != null) {
            _subscription!.cancel();
          }
          // if (_connection != null) {
          //   await _connection.cancel();
          // }
          print("Disconnect the device.");
        }


        Future<void> _connectBLE() async {
          final completerDevice = Completer();
          final completerStatus = Completer();

          print(_ble.status);
          _subscription = _ble.scanForDevices(
              withServices: [serviceID],
              scanMode: ScanMode.lowLatency,
              requireLocationServicesEnabled: false).listen((device) {
            print(device.name);
            if (device.name == 'PersonDetection') {
              print('PersonDetection found!');
              _connection = _ble
                  .connectToDevice(
                id: device.id,
                connectionTimeout: const Duration(seconds: 5),
              )
                  .listen((connectionState) async {
                // Handle connection state updates
                print(device.name);
                print(device.id);
                print('connection state:');
                print(connectionState.connectionState);
                if (connectionState.connectionState ==
                    DeviceConnectionState.connected) {
                  final characteristic = QualifiedCharacteristic(
                      serviceId: serviceID,
                      characteristicId: characteristicsID,
                      deviceId: device.id);
                  final response = await _ble.readCharacteristic(characteristic);
                  print(response);
                  completerStatus.complete(connectionState.connectionState ==
                      DeviceConnectionState.connected);
                  _disconnect();
                  print('disconnected');
                }
              }, onError: (dynamic error) {
                // Handle a possible error
                print(error.toString());
              });
            }
            completerDevice.complete(device.name == 'PersonDetection');
          }, onError: (error) {
            print('error!');
            print(error.toString());
          });
        }

        final completerStart = Completer();

        _ble.statusStream.listen((status) async {
          //code for handling status update
          print(status);
          await completerStart.future;
          completerStart.complete(status != BleStatus.unknown);
        });
        // Try to delay the process
        await Future.delayed(Duration(seconds: 3));
        _connectBLE();


        // flutterReactiveBle.scanForDevices(withServices: [serviceID], scanMode: ScanMode.lowLatency).listen((device) {
        //   //code for handling results
        //   print('PersonDetection found.');
        // },);
        //
        // flutterReactiveBle.connectToAdvertisingDevice(
        //   id: deviceAddress,
        //   withServices: [serviceID],
        //   prescanDuration: const Duration(seconds: 5),
        //   servicesWithCharacteristicsToDiscover: {serviceID: [characteristicsId]},
        //   connectionTimeout: const Duration(seconds:  2),
        // ).listen((connectionState) {
        //   // Handle connection state updates
        // },);
        //
        // final characteristic = QualifiedCharacteristic(serviceId: serviceID, characteristicId: characteristicsId, deviceId: deviceAddress);
        // final response = await flutterReactiveBle.readCharacteristic(characteristic);
        // print(response);
        // FlutterBlue flutterBlue = FlutterBlue.instance;
        // print('Scanning ready to start...');
        // flutterBlue.startScan(timeout: Duration(seconds: 5));
        // print('Scan complete.');
        // flutterBlue.scanResults.listen((results) async {
        //   for (ScanResult r in results) {
        //     if(r.device.name == 'PersonDetection') {
        //       print('PersonDetection found.');
        //       device = r.device;
        //       await device.connect();
        //       List<BluetoothService> services = await device.discoverServices();
        //       services.forEach((service) async {
        //         if (service.uuid.toString().toUpperCase().substring(4, 8) == inputData!['serviceID']!) {
        //           var characteristics = service.characteristics;
        //           for(BluetoothCharacteristic c in characteristics) {
        //             if(c.uuid.toString().toUpperCase().substring(4, 8) == inputData!['characteristicsID']) {
        //               List<int> valueList = await c.read();
        //               value = valueList.toString();
        //             }
        //           }
        //         }
        //       });
        //     } else {
        //       print('PersonDetection not found.');
        //     }
        //   }
        // });
        // flutterBlue.stopScan();


        // firestore.collection('bluetooth_data').add({
        //   'person': value,
        //   'time': inputData!['time']!,
        //   'user': inputData!['user']!,
        // });
        // print("Data write into the database.");
        break;
    }
    return Future.value(true);
  });
}

class BLE extends StatelessWidget {
  static const String id = 'BLE_screen';
  final flutterReactiveBle = FlutterReactiveBle();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<BleStatus>(
          stream: flutterReactiveBle.statusStream,
          initialData: BleStatus.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BleStatus.poweredOff) {
              return BluetoothOffScreen(state: state);
            } else if (state == BleStatus.locationServicesDisabled) {
              LocationPermissions().requestPermissions();
            } else if (state == BleStatus.unauthorized) {
              LocationPermissions().requestPermissions();
            }
            return BackgroundService();
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BleStatus? state;

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

class BackgroundService extends StatelessWidget {
  const BackgroundService({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter WorkManager Example"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Plugin initialization",
              style: Theme.of(context).textTheme.headline5,
            ),
            ElevatedButton(
              child: Text("Start the Flutter background service"),
              onPressed: () {
                Workmanager().initialize(
                  callbackDispatcher,
                  isInDebugMode: true,
                );
              },
            ),
            Text(
              "Periodic Tasks (Android only)",
              style: Theme.of(context).textTheme.headline5,
            ),
            //This task runs periodically
            //It will wait at least 10 seconds before its first launch
            //Since we have not provided a frequency it will be the default 15 minutes
            ElevatedButton(
                child: Text("Register Periodic Task"),
                onPressed: () {
                  Workmanager().registerPeriodicTask(
                    "3",
                    simplePeriodicTask,
                    inputData: <String, dynamic> {
                      'email': email,
                      'password': password,
                    },
                    initialDelay: Duration(seconds: 10),
                  );
                }),
            ElevatedButton(
              child: Text("Cancel All"),
              onPressed: () async {
                await Workmanager().cancelAll();
                print('Cancel all tasks completed');
              },
            ),
          ],
        ),
      ),
    );
  }
}

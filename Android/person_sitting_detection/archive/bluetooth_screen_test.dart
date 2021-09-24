// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class BLE extends StatefulWidget {
  static const String id = 'BLE_screen';

  @override
  _BLEState createState() => _BLEState();
}

class _BLEState extends State<BLE> {
  static const platform = MethodChannel('samples.flutter.dev/battery');

  Future<void> _startBleScan() async {
    try {
      await platform.invokeMethod('startBleScan');
    } on PlatformException catch (e) {
      print('Cannot use the Kotlin function: startBleScan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        child: Text('Start Scan'),
        onPressed: _startBleScan,
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

final _firestore = FirebaseFirestore.instance;

class BleLogScreen extends StatefulWidget {
  static const String id = 'log_screen';

  @override
  _BleLogScreenState createState() => _BleLogScreenState();
}

class _BleLogScreenState extends State<BleLogScreen> {
  String logText = '';

  @override
  void initState() {
    super.initState();
  }

  void logStream() async {
    await for (var snapshot
        in _firestore.collection('bluetooth_data').snapshots()) {
      for (var log in snapshot.docs) {
        print(log.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                logStream();
              },
              icon: Icon(Icons.refresh))
        ],
        title: Text('Log'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            LogsStream(),
          ],
        ),
      ),
    );
  }
}

class LogsStream extends StatelessWidget {
  User? loggedInUser = auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("bluetooth_data").orderBy("time").snapshots(),
      builder: (context, snapshot) {
        List<LogSection> logMessages = [];
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final logs = snapshot.data!.docs;
        for (var log in logs) {
          final logUser = log['user'].toString();
          final currentUser = loggedInUser!.email.toString();
          print('Current User: ${currentUser}');
          print('Log User: ${logUser}');


          if (currentUser == logUser) {
            final logText = log['person'].toString();
            final logTime = log['time'].toString();

            final logMessage = LogSection(
              text: logText,
              time: logTime,
              user: currentUser,
            );

            logMessages.add(logMessage);
          }
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: logMessages,
          ),
        );
      },
    );
  }
}

class LogSection extends StatelessWidget {
  LogSection({required this.text, required this.time, required this.user});

  final String text;
  final String time;
  final String user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$user',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        Text(
          '$time',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        Text(
          '$text',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

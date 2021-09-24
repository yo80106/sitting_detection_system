import 'package:flutter/material.dart';
import 'package:person_sitting_detection/screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/time_tracking_screen.dart';
import '../screens/log_screen.dart';
import '../screens/bluetooth_screen.dart';
import '../screens/manual_screen.dart';

class BottomNavigator extends StatefulWidget {
  static const String id = 'bottom_navigator';
  @override
  _BottomNavigatorState createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _selectedPage = 0;

  Future<bool> _onBackPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Are you sure?"),
        content: Text("You are going to sign out."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              print(auth.currentUser!.email.toString());
            },
            child: Text("NO"),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: () {
              auth.signOut();
              Navigator.pushNamed(context, WelcomeScreen.id);
            },
            child: Text("YES"),
          ),
        ],
      ),
    );
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Detect Your Sitting'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text("Are you sure?"),
                  content: Text("You are going to sign out."),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        print(auth.currentUser!.email.toString());
                      },
                      child: Text("NO"),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        auth.signOut();
                        Navigator.pushNamed(context, WelcomeScreen.id);
                      },
                      child: Text("YES"),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.bluetooth),
              onPressed: () {
                Navigator.pushNamed(context, BleScreen.id);
              },
            )
          ],
        ),
        // body: _pageOptions[_selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Theme.of(context).accentColor,
          unselectedItemColor: Colors.black26,
          currentIndex: _selectedPage,
          onTap: (int index) {
            setState(() {
              _selectedPage = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              label: 'Time Tracking',
              icon: Icon(Icons.timer),
            ),
            BottomNavigationBarItem(
              label: 'Log',
              icon: Icon(Icons.view_list),
            ),
            BottomNavigationBarItem(
              label: 'Register Manually',
              icon: Icon(Icons.keyboard),
            ),
          ],
        ),
        body: IndexedStack(
          children: <Widget>[
            TimeTrackerScreen(),
            LogScreen(),
            ManualScreen(),
          ],
          index: _selectedPage,
        ),
      ),
    );
  }
}

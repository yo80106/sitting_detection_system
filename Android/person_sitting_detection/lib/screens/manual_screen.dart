import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../util/summerise_functions.dart';
import 'login_screen.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({Key? key}) : super(key: key);

  @override
  _ManualScreenState createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  DateTime date = DateTime.now();
  String duration = '';
  String user = auth.currentUser!.email.toString();
  String dropdownValue = '1';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Enter date: ${date.toString().substring(0, 10)}",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              ElevatedButton(
                child: Text("Select the date"),
                onPressed: () {
                  selectDate(context);
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Duration (at least 1 hour):',
              style: TextStyle(
                fontSize: 16,
              ),),
              DropdownButton<String>(
                value: dropdownValue,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 2,
                  color: Colors.blueAccent,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                  duration = dropdownValue;
                },
                items: <String>[for (var i = 1; i < 13; i++) i.toString()]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          ElevatedButton(
            child: Text("ADD"),
            onPressed: () {
              checkManualRecord(DateFormat.yMd().format(date).toString(),
                  user).then((value) {
                if (value) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text("Warning"),
                      content: Text("This date has data. Do you want to overwrite it ?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text("NO"),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            updateData();
                            Navigator.of(context).pop(false);
                          },
                          child: Text("YES"),
                        ),
                      ],
                    ),
                  );
                } else {
                  saveData();
                }
              });
            },
          ),
          SizedBox(height: 40.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Enter date: ${date.toString().substring(0, 10)}",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.redAccent
                ),
                child: Text("Select the date"),
                onPressed: () {
                  selectDate(context);
                },
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.redAccent
            ),
            child: Text("REMOVE"),
            onPressed: () {
              checkManualRecord(DateFormat.yMd().format(date).toString(),
                  user).then((value) {
                if (value) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text("Warning"),
                      content: Text("You are going to remove the data. Are you sure ?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text("NO"),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            removeData();
                            Navigator.of(context).pop(false);
                          },
                          child: Text("YES"),
                        ),
                      ],
                    ),
                  );
                } else {
                  final snackBar = SnackBar(
                    content: Text('No data in this date. Nothing is removed.'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Future<Null> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: new DateTime(date.year - 1),
      lastDate: new DateTime(date.year + 1),
    );
    setState(() {
      date = picked!;
    });
  }

  void saveData() {
    var firestore = FirebaseFirestore.instance;
    firestore.collection('manual_data')
    .doc(DateFormat("yyyy-MM-dd").format(date).toString() + '_' + user)
    .set({
      'date': DateFormat.yMd().format(date).toString(),
      'duration': duration,
      'user': user,
    });
  }

  void updateData() {
    var firestore = FirebaseFirestore.instance;
    firestore.collection('manual_data')
        .doc(DateFormat("yyyy-MM-dd").format(date).toString() + '_' + user)
        .update({'duration': duration});
  }

  void removeData() {
    var firestore = FirebaseFirestore.instance;
    firestore.collection('manual_data')
        .doc(DateFormat("yyyy-MM-dd").format(date).toString() + '_' + user)
        .delete();
  }

}

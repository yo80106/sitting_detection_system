import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_data.dart';
import 'package:intl/intl.dart';
import '../util/time_series.dart';

final _firestore = FirebaseFirestore.instance;

Future<bool> checkManualRecord(String date, String currentUser) async {
  bool result = false;

  await _firestore
      .collection('manual_data')
      .where('user', isEqualTo: currentUser)
      .where('date', isEqualTo: date)
      .get()
      .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.size > 0) {
          result = true;
        } else {
          result = false;
        }
      });
  return result;
}

Future<String> getManualRecordData(DateTime date, String currentUser) async {
  String duration = '';
  String formatDate = DateFormat("yyyy-MM-dd").format(date).toString();
  await _firestore
      .collection('manual_data')
      .doc(formatDate + '_' + currentUser)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot['duration'] == '') {
          duration = '0';
        } else {
          duration = documentSnapshot['duration'];
        }
  });
  return duration;
}

Future<List<UserData>> logStream(String date, String currentUser) async {
  List<UserData> userDataList = [];

  await _firestore
      .collection('bluetooth_data')
      .orderBy('time')
      .startAt([date])
      .endAt([date + '\uf8ff'])
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((tmpData) {
      UserData userData =
      UserData(tmpData['person'], tmpData['time'], tmpData['user']);
      if (currentUser == userData.getUser()) {
        // Only include the data that a person sitting
        if (userData.getValue()) {
          print(userData.getTime());
          userDataList.add(userData);
          print(userDataList.length);
        }
      }
    });
  });
  return userDataList;
}

bool checkTimeCount(int numTrue, List<UserData> dataList) {
  if (dataList.length >= numTrue) {
    return true;
  }
  return false;
}

DateTime updateTotalTime(List<UserData> userDataList) {
  DateTime time = DateFormat("H:m:s").parse('00:00:00');

  // No user data in this date
  if (userDataList.length == 0) {
    print('Nothing inside the userDataList.');
    return time;
  }

  List<UserData> tmpList = [];
  for (UserData userData in userDataList) {
    if (tmpList.length == 0) {
      print('Add data to tmpList: ${userData.getTime()}');
      tmpList.add(userData);
    } else {
      if (userData.getMinute() == tmpList.last.getMinute()) {
        print('Last minute: ${tmpList.last.getMinute()}');
        print('Get minute: ${userData.getMinute()}');
        print('Add data to tmpList: ${userData.getTime()}');
        tmpList.add(userData);
      } else {
        if (checkTimeCount(2, tmpList)) {
          time = time.add(const Duration(minutes: 1));
        }
        tmpList.clear();
        print('======Clear Data======');
        tmpList.add(userData);
        print('Add data to tmpList: ${userData.getTime()}');
      }
    }
  }
  // Check for the last minute
  // If the last minute should be added, there is no chance
  // for the last minute to enter the if-statement in the for-loop
  if (checkTimeCount(2, tmpList)) {
    time = time.add(const Duration(minutes: 1));
  }
  return time;
}

Future<TimeSeriesDaily> getDailyData(int day, String currentUser) async {
  DateTime targetDate = DateTime.now().subtract(Duration(days: day));
  List<UserData> tmpUserDataList = [];
  int totalTime = 0;
  TimeSeriesDaily timeSeriesDaily =
  TimeSeriesDaily(DateFormat('Hms').parse('00:00:00'), 0);
  String dayStr = DateFormat.yMd()
      .format(targetDate)
      .toString();

  // // Check if user add the data manually
  await checkManualRecord(dayStr, currentUser).then((value) async {
    if (value) {
      await getManualRecordData(targetDate, currentUser).then((value) {
        totalTime = int.parse(value) * 60;
        timeSeriesDaily = TimeSeriesDaily(targetDate, totalTime);
      });
    } else {
      await logStream(dayStr, currentUser).then((value) {
        tmpUserDataList = value;
        DateTime tmpTotalTime = updateTotalTime(tmpUserDataList);
        // totalTime = updateTotalTime(tmpUserDataList).minute;
        totalTime = tmpTotalTime.hour * 60 + tmpTotalTime.minute;
        timeSeriesDaily = TimeSeriesDaily(targetDate, totalTime);
      });
    }
  });
  return timeSeriesDaily;
}
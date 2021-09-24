import 'package:intl/intl.dart';

class UserData {
  String value = '';
  String time = '';
  String user = '';

  UserData(String value, String time, String user) {
    this.value = value;
    this.time = time;
    this.user = user;
  }

  String getUser() {
    return user;
  }

  bool getValue() {
    final regexp = RegExp(r'\[(.*?)\]');
    final match = regexp.firstMatch(value);
    final matchedText = match?.group(1);
    bool valueBool = matchedText!.toLowerCase() == '1';
    return valueBool;
  }

  DateTime getTime() {
    return DateFormat.yMd().add_Hms().parse(time);
  }

  int getMinute() {
    return DateFormat.yMd().add_Hms().parse(time).minute;
  }
}
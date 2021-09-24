import 'package:intl/intl.dart';

class TimeSeriesDaily {
  final DateTime date;
  final int totalTime;

  TimeSeriesDaily(this.date, this.totalTime);

  String getWeekDay() {
    return DateFormat('EEEE').format(date);
  }

  int getTotalTime() {
    return totalTime;
  }

  String getDate() {
    return DateFormat.yMd().format(date).toString();
  }

  String formatTotalTime() {
    var d = Duration(minutes:totalTime);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }
}
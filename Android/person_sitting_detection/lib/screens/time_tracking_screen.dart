import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'login_screen.dart';
import '../components/rounded_button.dart';
import '../util/user_data.dart';
import '../util/summerise_functions.dart';
import '../util/time_series.dart';

class TimeTrackerScreen extends StatefulWidget {
  static const String id = 'time_tracker_screen';

  @override
  _TimeTrackerScreenState createState() => _TimeTrackerScreenState();
}

class _TimeTrackerScreenState extends State<TimeTrackerScreen> {
  String loggedInUser = auth.currentUser!.email.toString();
  String _todayDateOnScreen =
      DateFormat.yMMMMd().format(DateTime.now()).toString();
  String _todayDateInternal =
      DateFormat.yMd().format(DateTime.now()).toString();
  String _totalTimeToday = '00:00';
  bool isLoading = false;
  String duration = '';

  List<UserData> userDataListToday = [];
  List<TimeSeriesDaily> fiveDaysData = [];

  // late TimeSeriesDaily tmpDay;
  late charts.TimeSeriesChart summaryPlot;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(
                    "Today",
                    style: TextStyle(fontSize: 36.0),
                  ),
                  Text(
                    _todayDateOnScreen,
                    style: TextStyle(fontSize: 32.0),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    'Time you have been sitting today',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  Text(
                    '(Hour : Minute)',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    _totalTimeToday,
                    style: TextStyle(fontSize: 36.0),
                  ),
                  RoundedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });

                      await getDailyData(0, loggedInUser).then((tmpDay) {
                        print(tmpDay.date);
                        print(tmpDay.totalTime);
                        setState(() {
                          _totalTimeToday = tmpDay.formatTotalTime();
                          isLoading = false;
                        });
                      });
                    },
                    padding: 10.0,
                    colour: Colors.lightBlueAccent,
                    title: 'Fetch User Data',
                  ),
                  RoundedButton(
                    onPressed: () async {
                      // String firstDayStr = DateFormat.yMd().format(DateTime.now().subtract(Duration(days: 3))).toString();
                      // String secondDayStr = DateFormat.yMd().format(DateTime.now().subtract(Duration(days: 2))).toString();
                      // String thirdDayStr = DateFormat.yMd().format(DateTime.now().subtract(Duration(days: 1))).toString();
                      // String todayStr = DateFormat.yMd().format(DateTime.now()).toString();

                      // int totalTimeFirst = 0;
                      // int totalTimeSecond = 0;
                      // int totalTimeThird = 0;
                      // int totalTimeToday = 0;

                      // logStream(firstDayStr).then((value) {
                      //   userDataListFirst = value;
                      //   totalTimeFirst = updateTotalTime(userDataListFirst).minute;
                      //   firstDay = TimeSeriesDaily(DateTime.now().subtract(Duration(days: 3)), totalTimeFirst);
                      // });
                      //
                      // logStream(secondDayStr).then((value) {
                      //   userDataListSecond = value;
                      //   totalTimeSecond = updateTotalTime(userDataListSecond).minute;
                      //   secondDay = TimeSeriesDaily(DateTime.now().subtract(Duration(days: 2)), totalTimeSecond);
                      // });
                      //
                      // logStream(thirdDayStr).then((value) {
                      //   userDataListThird = value;
                      //   totalTimeThird = updateTotalTime(userDataListThird).minute;
                      //   thirdDay = TimeSeriesDaily(DateTime.now().subtract(Duration(days: 1)), totalTimeThird);
                      // });
                      //
                      // logStream(todayStr).then((value) {
                      //   userDataListToday = value;
                      //   totalTimeToday = updateTotalTime(userDataListToday).minute;
                      //   today = TimeSeriesDaily(DateTime.now(), totalTimeToday);
                      // });

                      // firstDay = await getDailyData(3);
                      // secondDay = await getDailyData(2);
                      // thirdDay = await getDailyData(1);
                      // today = await getDailyData(0);
                      setState(() {
                        isLoading = true;
                      });

                      fiveDaysData.clear();
                      for (int n = 4; n >= 0; n--) {
                        await getDailyData(n, loggedInUser).then((tmpDay) {
                          print(tmpDay.date);
                          print(tmpDay.totalTime);
                          fiveDaysData.add(tmpDay);
                        });
                      }

                      setState(() {
                        summaryPlot = charts.TimeSeriesChart(
                          _createSampleData(fiveDaysData),
                          domainAxis: charts.EndPointsTimeAxisSpec(),
                        );
                        isLoading = false;
                      });
                    },
                    padding: 5.0,
                    colour: Colors.blueAccent,
                    title: 'Summary Plot',
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: (fiveDaysData.length == 0)
                        ? SizedBox.shrink()
                        : summaryPlot,
                    // (fiveDaysData.length == 0) ? SizedBox.shrink() : summaryPlot
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // Timer.periodic(Duration(seconds: 15), (Timer t) => _getTimeUpdate());
    super.initState();
  }

  // void _getTimeUpdate() {
  //   print('Time update');
  //   if (this.mounted) {
  //     setState(() {
  //       logStream(_todayDateInternal, loggedInUser);
  //     });
  //   }
  // }

  static List<charts.Series<TimeSeriesDaily, DateTime>> _createSampleData(
      List<TimeSeriesDaily> inputList) {
    final data = inputList;

    return [
      charts.Series<TimeSeriesDaily, DateTime>(
        id: 'Time',
        domainFn: (TimeSeriesDaily daily, _) => daily.date,
        measureFn: (TimeSeriesDaily daily, _) => daily.totalTime,
        data: data,
      )
    ];
  }
}

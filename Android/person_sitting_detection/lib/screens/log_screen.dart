import 'package:flutter/material.dart';
import '../util/summerise_functions.dart';
import 'login_screen.dart';
import '../util/time_series.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  List<TimeSeriesDaily> fiveDaysData = [];
  late TimeSeriesDaily tmpDay;
  String loggedInUser = auth.currentUser!.email.toString();

  int _currentSortColumn = 0;
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    collectFiveDaysData();
  }

  Future<void> collectFiveDaysData() async {
    fiveDaysData.clear();
    for (int n = 4; n >= 0; n--) {
      tmpDay = await getDailyData(n, loggedInUser);
      fiveDaysData.add(tmpDay);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RefreshIndicator(
        onRefresh: collectFiveDaysData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: DataTable(
            sortColumnIndex: _currentSortColumn,
            sortAscending: _isAscending,
            columns: [
              DataColumn(label: Text('Weekday')),
              DataColumn(label: Text('Date')),
              DataColumn(
                  label: Text('Time'),
                  onSort: (columnIndex, _) {
                    setState(() {
                      _currentSortColumn = columnIndex;
                      if (_isAscending == true) {
                        _isAscending = false;
                        // sort the product list in Ascending, order by Time
                        fiveDaysData.sort((timeA, timeB) =>
                            timeA.getTotalTime().compareTo(timeB.getTotalTime()));
                      } else {
                        _isAscending = true;
                        // sort the product list in Descending, order by Time
                        fiveDaysData.sort((timeA, timeB) =>
                            timeB.getTotalTime().compareTo(timeA.getTotalTime()));
                      }
                    });
                  }),
            ],
            rows: fiveDaysData.map((element) {
              return DataRow(cells: [
                DataCell(Text(element.getWeekDay())),
                DataCell(Text(element.getDate())),
                DataCell(Text(element.formatTotalTime())),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

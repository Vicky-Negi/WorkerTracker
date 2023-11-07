import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:WorkerTracker/main.dart';
import '../db/database_helper.dart' as DBHelper; // Import the database helper
import '../db/models.dart' as DBModels; // Import the database models

class TrackPage extends StatefulWidget {
  final String selectedItemText;
  final int selectedItemId;
  double amountPayable;

  TrackPage({
    required this.selectedItemText,
    required this.amountPayable,
    required this.selectedItemId,
  });

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  Map<DateTime, bool> attendance = {}; // Map to track attendance
  DateTime _focusedMonth = DateTime.now();
  double previousAmount = 0.0; // Store previous amount for reference
  List<double> payPerDayHistory = [];
  double totalPayableTillYesterday = 0; // Track total payable till yesterday

  @override
  void initState() {
    super.initState();
    _initAttendanceData(_focusedMonth);
    _fetchAbsentDatesForMonth(_focusedMonth);
  }

  // // Method to fetch absent dates for the focused month
  // void _fetchAbsentDatesForMonth(DateTime focusedMonth) async {
  //   List<DBModels.AbsentDate> absentDates = await DBHelper
  //       .DatabaseHelper.instance
  //       .getAbsentDatesForMonth(widget.selectedItemId, focusedMonth);

  //   // Update the attendance map with fetched absent dates
  //   for (var date in absentDates) {
  //     attendance[DateTime.parse(date.date)] = true;
  //   }
  //   setState(() {}); // Update the UI to reflect the changes
  // }
  void _fetchAbsentDatesForMonth(DateTime focusedMonth) async {
  List<DBModels.AbsentDate> absentDates = await DBHelper
      .DatabaseHelper.instance
      .getAbsentDatesForMonth(widget.selectedItemId, focusedMonth);

  // Update the attendance map with fetched absent dates
  for (var date in absentDates) {
    try {
      DateTime parsedDate = DateTime.parse(date.date);
      attendance[parsedDate] = true;
    } catch (e) {
      // Handle the date parsing issue or log the error
      print("Error parsing date: ${date.date}");
    }
  }
  setState(() {});
}


  void _initAttendanceData(DateTime focusedMonth) {
    DateTime firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    DateTime lastDay = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);

    for (DateTime date = firstDay;
        date.isBefore(lastDay) || date == lastDay;
        date = date.add(Duration(days: 1))) {
      attendance.putIfAbsent(date, () => false);
    }
  }

  void updatePayPerDay(double newPayPerDay) {
    // If the pay per day is updated, add it to history
    payPerDayHistory.add(newPayPerDay);

    setState(() {
      widget.amountPayable = newPayPerDay;
    });
  }

  // Updated method to store marked absent dates in the database
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (selectedDay.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      // Do not allow marking future days
      return;
    }

    // Toggle the attendance for the selected day
    setState(() {
      attendance[selectedDay] = !(attendance[selectedDay] ?? false);
    });

    if (attendance[selectedDay] == true) {
      DBModels.AbsentDate newAbsentDate = DBModels.AbsentDate(
        actionId: widget.selectedItemId,
        date: selectedDay.toIso8601String(),
      );

      await DBHelper.DatabaseHelper.instance
          .insertOrUpdateAbsentDate(newAbsentDate);
    } else {
      // If the day is unmarked, delete it from the database
      await DBHelper.DatabaseHelper.instance.deleteAbsentDateByDate(
          widget.selectedItemId, selectedDay.toIso8601String());
    }
  }

void _onPageChanged(DateTime focusedMonth) async {
  if (focusedMonth.isBefore(DateTime.now())) {
    List<DBModels.AbsentDate> absentDates = await DBHelper.DatabaseHelper.instance.getAbsentDatesForMonth(
      widget.selectedItemId,
      focusedMonth,
    );

    if (absentDates.isNotEmpty) {
      setState(() {
        _focusedMonth = focusedMonth;
        _initAttendanceData(focusedMonth);
      });
    }
  }
}

  int getAbsentDaysCount() {
    return attendance.values.where((value) => value).length;
  }

  double calculateTotalPayable() {
    print("here");
    print(widget.amountPayable);
    int absentDays = getAbsentDaysCount();
    int totalDaysInMonth = DateTime.now().day;
    print((totalDaysInMonth - absentDays) * widget.amountPayable);
    return ((totalDaysInMonth - absentDays) * widget.amountPayable);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
      // Navigate back to the main.dart
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
      return false; // Do not allow normal back button behavior
    },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Attendance'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
TableCalendar(
  firstDay: DateTime(_focusedMonth.year, _focusedMonth.month),
  lastDay: DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0),
  focusedDay: _focusedMonth,
  onPageChanged: _onPageChanged,
enabledDayPredicate: (DateTime date) {
  // Allow marking the current date and past dates that have been marked as absent
  return date.isBefore(DateTime.now()) ||
      (attendance[date] != null && attendance[date] == true);
},
  onDaySelected: _onDaySelected,
  eventLoader: (day) {
  return [
    if (attendance[day] == true)
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red, // Customize color or use an icon for absent days
        ),
        child: Center(
          child: Text(
            'X',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
  ];
},
),
              SizedBox(height: 20),
              Card(
                margin: EdgeInsets.all(16),
                child: ListTile(
                  title: Text(
                    'Selected Action: ${widget.selectedItemText}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.all(16),
                child: ListTile(
                  title: Text(
                    'Pay per day: ${widget.amountPayable.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.all(16),
                child: ListTile(
                  title: Text(
                    'Total Absent Days: ${getAbsentDaysCount().toString()}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.all(16),
                child: ListTile(
                  title: Text(
                    'Total Amount Payable: ${calculateTotalPayable().toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

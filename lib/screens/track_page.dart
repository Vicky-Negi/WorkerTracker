import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../main.dart'; // Import the main.dart file or specify the path correctly

class TrackPage extends StatelessWidget {
  final String selectedActionText;
  final double amountPayable;

  TrackPage({required this.selectedActionText, required this.amountPayable});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(selectedActionText),
        ),
        body: SingleChildScrollView(
          child: CalendarPage(amountPayable: amountPayable),
        ),
      ),
    );
  }
}



class CalendarPage extends StatefulWidget {
  double amountPayable;

  CalendarPage({required this.amountPayable});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List> _events;
  late Map<DateTime, bool> _markedDates;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {}; // You can populate this with events for specific days if needed
    _markedDates = {};
  }

  int countRedCrossesThisMonth() {
    int count = 0;
    _markedDates.forEach((key, value) {
      if (value && key.month == _focusedDay.month && key.year == _focusedDay.year) {
        count++;
      }
    });
    return count;
  }

  double calculatePayableAmount() {
    double totalPayable = 0;
    _markedDates.forEach((key, value) {
      if (value && key.month == _focusedDay.month && key.year == _focusedDay.year) {
        totalPayable += widget.amountPayable;
      }
    });
    return totalPayable;
  }

  void updatePayableAmount(double newAmount) {
    setState(() {
      widget.amountPayable = newAmount;
    });
  }

  Future<void> _showPayableAmountDialog() async {
    double newAmount = widget.amountPayable;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Payable Amount'),
          content: TextFormField(
            decoration: InputDecoration(labelText: 'New Payable Amount'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              newAmount = double.tryParse(value) ?? newAmount;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                updatePayableAmount(newAmount);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime startDay = DateTime(now.year, now.month - 2);
    final DateTime endDay = DateTime(now.year, now.month + 3);

    return Column(
      children: <Widget>[
        TableCalendar(
          firstDay: startDay,
          lastDay: endDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              if (_markedDates.containsKey(selectedDay)) {
                _markedDates[selectedDay] = !_markedDates[selectedDay]!;
              } else {
                _markedDates[selectedDay] = true;
              }
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) {
            return _markedDates[day] != null && _markedDates[day]! ? [true] : [];
          },
        ),
        SizedBox(height: 20), // Add space between the calendar and the data

        Card(
          elevation: 4,
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Red Crosses this month',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  '${countRedCrossesThisMonth()}',
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ),
              ],
            ),
          ),
        ),

        Card(
          elevation: 4,
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Payable amount',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  '₹${calculatePayableAmount().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, color: Colors.green),
                ),
              ],
            ),
          ),
        ),

        ElevatedButton(
          onPressed: () {
            _showPayableAmountDialog();
          },
          child: Text('Change Payable Amount'),
        ),
        // Any additional widgets or functionalities can be added below the calendar
      ],
    );
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: TrackPage(
//       selectedActionText: 'Track Page',
//       amountPayable: 10.0, // Initial payable amount
//     ),
//   ));
// }
void main() {
  runApp(MaterialApp(
    home: TrackPage(
      selectedActionText: 'Track Page',
      amountPayable: 10.0, // Initial payable amount
    ),
  ));
}
import 'package:flutter/material.dart';
import '../db/database_helper.dart' as DBHelper; // Import the database helper
import '../screens/track_page.dart';

class SetupPage extends StatefulWidget {
  final String selectedActionText;
  final String selectedActionId;

  SetupPage({required this.selectedActionText, required this.selectedActionId});

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  double amountPayable = 0.0; // Default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pay per month to ${widget.selectedActionId}"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context,false);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              elevation: 5,
              margin: EdgeInsets.all(20),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Set Amount Payable Per Day:',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Enter Amount'),
                      onChanged: (value) {
                        setState(() {
                          amountPayable = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (amountPayable <= 0) {
                          // Show a dialog to prompt the user to enter a valid amount
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Invalid Amount'),
                                content: Text(
                                    'Please enter a valid payable amount.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          int actionId = int.tryParse(widget.selectedActionId) ?? 0;
                          // Update the pay per day in the database
                          await DBHelper.DatabaseHelper.instance.updatePayableAmountPerDay(actionId, amountPayable);
                          print(actionId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackPage(
                                selectedItemText: widget.selectedActionText,
                                amountPayable: amountPayable,
                                selectedItemId: actionId,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text('Next'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

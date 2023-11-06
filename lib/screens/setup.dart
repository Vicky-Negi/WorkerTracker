import 'package:flutter/material.dart';
import '../db/action_repository.dart';
import '../screens/track_page.dart';
class SetupPage extends StatefulWidget {
  final String selectedActionText;

  SetupPage({required this.selectedActionText});

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  double amountPayable = 0.0; // Default value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pay per month to ${widget.selectedActionText}"),
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
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                                content: Text('Please enter a valid payable amount.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TrackPage(
        selectedActionText: widget.selectedActionText,
        amountPayable: amountPayable,
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

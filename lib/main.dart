

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './screens/track_page.dart';
import './screens/setup.dart';
import './db/database_helper.dart' as DBHelper; // Using an alias for clarity
import './db/models.dart' as DBModels; // Using an alias for clarity
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter bindings are initialized
  String path = join(await getDatabasesPath(), 'worker_tracker.db');
  DBHelper.DatabaseHelper.instance.initializeDatabase(path); // Initialize the database

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DBModels.Action> actionList = []; // Change to a list of Action objects

  @override
  void initState() {
    super.initState();
    fetchActionsFromDatabase(); // Fetch actions when the widget initializes
  }
  

  Future<void> fetchActionsFromDatabase() async {
    List<DBModels.Action> actions =
        await DBHelper.DatabaseHelper.instance.getActions();
    setState(() {
      actionList = actions;
    });
  }

  void addCard() async {
    DBModels.Action newAction =
        DBModels.Action(name: 'New Action', payPerDay: 0);
    await DBHelper.DatabaseHelper.instance.insertAction(newAction);
    fetchActionsFromDatabase();
  }
    void refreshData() {
    fetchActionsFromDatabase(); // Refresh data after returning from pushed page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Worker Tracker'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Action List',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              actionList.isEmpty // Check if the actionList is empty
                  ? Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No actions created.'),
                    )
                  : Container(
                      width: 500,
                      child: Column(
                        children: List.generate(
                          actionList.length,
                          (index) => ActionCard(
                            id: actionList[index].id ?? 0,
                            title: actionList[index].name,
                            payPerDay: actionList[index].payPerDay,
                            refreshParent: refreshData,
                            onChanged: (newName) {
                              setState(() {
                                actionList[index].name = newName;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addCard,
        child: Icon(Icons.add),
      ),
    );
  }
}


class ActionCard extends StatefulWidget {
  final int id; // Define the id for ActionCard
  final String title;
  final ValueChanged<String> onChanged;
  final Function() refreshParent; // Callback function from ActionCard to MyHomePage
  final double payPerDay;

  ActionCard({required this.id, required this.title, required this.onChanged, required this.refreshParent,required this.payPerDay});

  @override
  _ActionCardState createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  bool _isEditing = false;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.title);
  }

  Future<void> updateActionName(String newName) async {
    await DBHelper.DatabaseHelper.instance
        .updateActionName(widget.id.toString(), newName);
  }
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        width: 250,
        height: 100,
        child: GestureDetector(
          onTap: () async{
            if (!_isEditing) {
              if(widget.payPerDay>0.0){
                print(widget.title);
                await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TrackPage(selectedItemText: widget.title,amountPayable: widget.payPerDay, selectedItemId: widget.id),
                ),
              );
              setState(() {
                  widget.refreshParent(); // Trigger data refresh in MyHomePage
              });
              }
              else if(widget.payPerDay<=0.0){
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SetupPage(selectedActionText: widget.title,selectedActionId: widget.id.toString(),),
                ),
              );
              setState(() {
                  widget.refreshParent(); // Trigger data refresh in MyHomePage
              });
               // After navigation, fetch the updated data from the database.
              }
            }
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Center(
                  child: !_isEditing
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: _textEditingController,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            onSubmitted: (newName) async {
                              // Update the database with the new name
                              await updateActionName(newName);
                              // Notify the parent widget about the change
                              widget.onChanged(newName);
                              setState(() {
                                _isEditing = false;
                              });
                            },
                            decoration:
                                InputDecoration(border: InputBorder.none),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

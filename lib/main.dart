import 'package:flutter/material.dart';
import './screens/track_page.dart';
import './screens/setup.dart';
import './db/action_repository.dart';
import './db/database_helper.dart';
import './db/models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future main() async {
  // Initialize FFI
sqfliteFfiInit();

 databaseFactory = databaseFactoryFfi;
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
  List<String> actionList = ['Action 1', 'Action 2', 'Action 3', 'Action 4', 'Action 5'];
  @override
  void initState() {
    super.initState();
  }
  void addCard() {
    setState(() {
      actionList.add('New Action');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editable Cards'),
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
              Container( // Wrap your Column with a Container to specify width
                width: 500, // Set the width as needed
                child: Column(
                  children: List.generate(
                    actionList.length,
                    (index) => ActionCard(
                      title: actionList[index],
                      onChanged: (newName) {
                        setState(() {
                          actionList[index] = newName;
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
  final String title;
  final ValueChanged<String> onChanged;

  ActionCard({required this.title, required this.onChanged});

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
    void updateActionName(String newName) {
    // Update the name in the database here
    // Use the repository or helper class to perform database operations
    // For example, assuming you have an ActionRepository
    DbOperations().updateActionName(widget.title, newName);
    widget.onChanged(newName); // Notify the parent widget about the change
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        width: 250,
        height: 100,
        child: GestureDetector(
          onTap: () {
            if (!_isEditing) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SetupPage(selectedActionText: widget.title),
                ),
              );
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
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: _textEditingController,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            onSubmitted: (newName) {
                              widget.onChanged(newName);
                              setState(() {
                                _isEditing = false;
                              });
                            },
                            decoration: InputDecoration(border: InputBorder.none),
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







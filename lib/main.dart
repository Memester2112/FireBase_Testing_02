import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

List<String> user = [
  'Aryendra',
  'Prateek',
  'Utkarsh',
  'Parth',
  'Arnesh',
  'Ayush'
];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'List of current users'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void addUser() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          DocumentReference docref =
              Firestore.instance.collection('users').document();
          return Scaffold(
            appBar: AppBar(
              title: Text('New User Registration'),
              backgroundColor: Colors.black,
            ),
            body: Center(
              child: TextFormField(
                onFieldSubmitted: (value) => {
                  docref //if you add the document id as document('documentID') then we can use
                      .setData({'name': value, 'docId': docref.documentID}),
                  Navigator.pop(context),
                  //updateData({'name' :'XYZ' }) we can update the particular document
                },
                textAlign: TextAlign.left,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter New User name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> confirmDelete(DocumentSnapshot ds) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red.shade50,
          title: Text('CONFIRM DELETION ?'),
          actions: <Widget>[
            Column(
              children: <Widget>[
                FlatButton(
                  child: Text('Yes,delete this user'),
                  onPressed: () {
                    Firestore.instance
                        .collection('users')
                        .document(ds['docId'])
                        .delete();

                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('No, don\'t delete, go back'),
                  onPressed: () {
                    Navigator.pop(context); //try also Navigator.of(context).pop
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.documents[index];
              return ListTile(
                title: Text(ds['name']),
                subtitle: Text(ds['docId']),
                trailing: IconButton(
                  tooltip: 'Delete User',
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => confirmDelete(ds),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addUser,
        tooltip: 'Add User',
        child: Icon(Icons.add),
      ),
    );
  }
}

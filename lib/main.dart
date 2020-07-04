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
  MyHomePage({Key key, this.title})
      : super(key: key); //constructor to set title as an input
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void addUser() {
    //the page to add a User
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          DocumentReference
              docref = //creates a document reference which is useful to fetch a document by reference
              Firestore
                  .instance //creates an instance of our Firestore data base
                  .collection('users') //from the collection called users
                  .document();
          return Scaffold(
            appBar: AppBar(
              title: Text('New User Registration'),
              backgroundColor: Colors.black,
            ),
            body: Center(
              child: TextFormField(
                //a text input field
                onFieldSubmitted: (value) => {
                  //on pressing enter this gets executed
                  docref //if you add the document id as document('documentID') then we can use
                      .setData({
                    'name': value,
                    'docId': docref.documentID
                  }), //this docref's major
                  Navigator.pop(
                      context), //functionality is in this docref.documentID
                }, //I am saving this as a separate field in my document as we need this docID to delete the
                //document, there should be a better way of directly accessing this field from firestore but I
                //have not been able to find it. Therefore this works, though it uses extra space.
                textAlign: TextAlign.left,
                autofocus:
                    true, //automatically opens up the keyboard for the user
                decoration: InputDecoration(
                  hintText: 'Enter New User name',
                  border:
                      OutlineInputBorder(), //just some decoration of the field box
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> confirmDelete(DocumentSnapshot ds) async {
    //a dialog is an async event as it depends on
    //the user pressing the button, thus this function, confirmDelete returns a Future
    return showDialog(
      //creates the pop up dialog box
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
                        .document(ds[
                            'docId']) //here is where the docId field created by us in the database is useful
                        .delete(); //we can directly refer to it to delete the document.
                    Navigator.pop(
                        context); //after deletion we remove the pop-up
                  },
                ),
                FlatButton(
                  child: Text('No, don\'t delete, go back'),
                  onPressed: () {
                    Navigator.pop(
                        context); //simply go back to the previous screen
                  },
                ),
              ],
            ),
          ],
        );
      }, //builder
    ); //showDialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder(
        //stream builder provides us with a continuous stream of data, this gives us auto updation
        //we can achieve a lot of functions without this too, reloading the data when needed but this is convenient
        stream: Firestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return LinearProgressIndicator(); //The loading effect if the data has not been loaded yet
          return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              //goes through all the documents
              DocumentSnapshot ds = snapshot.data.documents[index];
              return ListTile(
                title: Text(ds['name']), //first field
                subtitle: Text(ds['docId']), //second field
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

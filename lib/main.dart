import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  //helps to init application and connect it to firebase platform
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}


class HomePageState extends State<HomePage> {

  //editable fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollnoController = TextEditingController();

  //access collection from firebase
  final CollectionReference studentProfile = FirebaseFirestore.instance.collection("studentprofile");

  // add method
  Future<void> createData([DocumentSnapshot? documentSnapshot]) async {
    await showDialog(context: context,
        builder: (context) {
          return AlertDialog(
                title: const Text("Adding Data.."),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      controller: rollnoController,
                      decoration: const InputDecoration(labelText: 'Roll No.'),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    ElevatedButton(
                      child: const Text('ADD'),

                      onPressed: () async {
                        final String name = nameController.text;
                        final String rollno = rollnoController.text;

                        if(name != "" && rollno != "" ) {
                            await studentProfile.add({"name" : name, "rollno" : rollno});
                            nameController.text = '';
                            rollnoController.text = '';
                            Navigator.of(context).pop();

                        //pop up when data is successfully added
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('student detail successfully added..')));
                          }
                        //   else {
                        //     Navigator.of(context).pop();
                        // //pop up when data(ie. roll no) is from existing data
                        //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        //         content: Text('enter a new roll number..!!')));
                        //
                        //   }

                        else {
                          Navigator.of(context).pop();
                      //pop when data fields are empty..
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Empty TextFields are not Allowed..!!')));
                        }
                      },
                    )
                  ])
            );
        });
  }

  //update method
  Future<void> updateData([DocumentSnapshot? documentSnapshot]) async {
    if(documentSnapshot != null) {
      nameController.text = documentSnapshot['name'];
      rollnoController.text = documentSnapshot['rollno'].toString();
    }

    await showDialog(context: context,
        builder: (context) {
            return AlertDialog(
                title: const Text("Updating Data.."),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      controller: rollnoController,
                      decoration: const InputDecoration(labelText: 'Roll No.'),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ElevatedButton(
                      child: const Text('UPDATE'),
                      onPressed: () async {
                        final String name = nameController.text;
                        final String rollno = rollnoController.text;

                        if (name != "" && rollno != "") {
                          await studentProfile.doc(documentSnapshot!.id)
                              .update({"name": name, "rollno": rollno});
                          Navigator.of(context).pop();

                        //pop up when data is successfully updated
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('student detail successfully updated..')));
                        }
                      },
                    ),
                  ])
            );
        });
  }

  //delete method
  Future<void> deleteData(String studentId) async {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text("Deleting Data.."),
        actions: [
          TextButton(child: const Text("Cancel"),
              onPressed: () => {
                Navigator.of(context).pop()
              }),
          TextButton(child: const Text("Delete"),
              onPressed: () async => {
                await studentProfile.doc(studentId).delete(),
                Navigator.of(context).pop(),

              //pop up when data is successfully deleted
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('successfully deleted a student detail..')))

              }),
        ]);
    });// ShowDialog

  }

  @override build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Data")),
      body: StreamBuilder(
        stream: studentProfile.snapshots(), //build connection
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.hasData)
          {
            return ListView.builder (
            itemCount: snapshot.data!.docs.length, //number of rows
            itemBuilder: (context, index) {

              //DocumentSnapshots represents a rows, help to access a field
              final DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];

              return Card(
                child: ListTile(
                  title: Text(documentSnapshot['name']),
                  subtitle: Text(documentSnapshot['rollno'].toString()),

     //trailing- used to position to right of the title and subtitle
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        //edit n delete buttons
                        IconButton(icon: const Icon(Icons.edit),
                            onPressed: () => {
                                updateData(documentSnapshot)
                            }),
                        IconButton(icon: const Icon(Icons.delete),
                             onPressed: () => {
                                 deleteData(documentSnapshot.id)
                             })
                      ],
                    ),
                  ),
                ),
              );
            });
          }
          else
          {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }),

      //Add button
      floatingActionButton : FloatingActionButton(onPressed: () => {
           createData()
      },
      child: const Icon(Icons.add) ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat

    );

  }
}



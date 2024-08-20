import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crud/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // firestore
  final FirestoreService firestoreServices = FirestoreService();

  // text controller
  final TextEditingController textController = TextEditingController();

  // open a dialog vox to add a note
  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // text user input
        content: TextField(
          controller: textController,
        ),
        actions: [
          // button to save
          ElevatedButton(
              onPressed: () {
                // add a new note
                if (docID == null) {
                  firestoreServices.addNote(textController.text);
                }
                // update an exiting note
                else {
                  firestoreServices.updateNote(docID, textController.text);
                }
                // clear the text controller
                textController.clear();
                // close the box
                Navigator.pop(context);
              },
              child: const Text("Add"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreServices.getNotesStream(),
          builder: (context, snapshot) {
            // if we have data, get all the docs
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;

              //display as a list
              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  // get each individual doc
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;

                  // get note from each note
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText = data['note'];

                  // display as a list tile
                  return ListTile(
                      title: Text(noteText),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // update button
                          IconButton(
                              onPressed: () => openNoteBox(docID: docID),
                              icon: const Icon(Icons.settings)),
                          // delete button
                          IconButton(
                              onPressed: () =>
                                  firestoreServices.deleteNote(docID),
                              icon: const Icon(Icons.delete)),
                        ],
                      ));
                },
              );
            } else {
              return const Text("No notes...");
            }
          }),
    );
  }
}

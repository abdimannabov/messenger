import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TextEditingController _textEditingController;

  @override
  void initState(){
    super.initState();
    _textEditingController = TextEditingController();
  }

  void submit(){
    String text = _textEditingController.text;
    if (text.isNotEmpty){
      FirebaseFirestore.instance.collection('messages').add({
        "text":text,
        "createdAt":Timestamp.now()
      });
      _textEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('messages').orderBy('createdAt').snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                      if (snapshot.hasError){
                        return Text("Something went wrong");
                      }
                      if (snapshot.connectionState == ConnectionState.waiting){
                        return CircularProgressIndicator();
                      }
                      var docs = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index){
                          var doc = docs[index];
                          var text = doc['text'];
                          return Text(text);
                        },
                      );
                    },
                  ),
                ),
                    TextField(controller: _textEditingController,),
                    ElevatedButton(onPressed: submit, child: Text("Submit"))
                  ],
            ),
          )
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
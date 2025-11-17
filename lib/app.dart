import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TextEditingController _textEditingController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Give Firebase time to initialize
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing app: $e');
    }
  }

  void submit() {
    String text = _textEditingController.text;
    if (text.isNotEmpty) {
      try {
        FirebaseFirestore.instance.collection('messages').add({
          "text": text,
          "createdAt": Timestamp.now(),
        });
        _textEditingController.clear();
      } catch (e) {
        print('Error submitting message: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _editMessage(BuildContext context, String docId, String currentText) {
    final editController = TextEditingController(text: currentText);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Message'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: 'Edit your message',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                editController.dispose();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String updatedText = editController.text;
                if (updatedText.isNotEmpty) {
                  try {
                    FirebaseFirestore.instance
                        .collection('messages')
                        .doc(docId)
                        .update({'text': updatedText});
                  } catch (e) {
                    print('Error updating message: $e');
                  }
                }
                Navigator.of(context).pop();
                editController.dispose();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(String docId) {
    try {
      FirebaseFirestore.instance.collection('messages').doc(docId).delete();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Messenger App')),
        body: !_isInitialized
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Initializing Firebase...'),
                  ],
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('messages')
                              .orderBy('createdAt', descending: false)
                              .snapshots(),
                          builder:
                              (
                                BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot,
                              ) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(height: 10),
                                        const Text("Error loading messages"),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Error: ${snapshot.error}',
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                var docs = snapshot.data!.docs;
                                if (docs.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'No messages yet. Start a conversation!',
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    var doc = docs[index];
                                    var text = doc['text'];
                                    var docId = doc.id;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      padding: const EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              text,
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          ElevatedButton(
                                            onPressed: () => _editMessage(
                                              context,
                                              docId,
                                              text,
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                  ),
                                            ),
                                            child: const Text(
                                              'Edit',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _deleteMessage(docId),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                  ),
                                            ),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textEditingController,
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          ElevatedButton(
                            onPressed: submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 12.0,
                              ),
                            ),
                            child: const Text(
                              "Submit",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

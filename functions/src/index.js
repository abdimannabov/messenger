const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// HTTP-triggered Function - Returns JSON with a greeting message
exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info('Hello logs!', { structuredData: true });
  
  response.json({
    status: 'success',
    message: 'Hello from Cloud Functions!',
    timestamp: new Date().toISOString(),
    data: {
      greeting: 'Welcome to Firebase Cloud Functions',
      version: '1.0.0'
    }
  });
});

// Firestore-triggered Function - Logs new messages
exports.onNewMessage = functions.firestore
  .document('messages/{docId}')
  .onCreate((snap, context) => {
    const newMessage = snap.data();
    const docId = context.params.docId;
    
    functions.logger.info(`New message created with ID: ${docId}`, {
      message: newMessage.text,
      createdAt: newMessage.createdAt,
      timestamp: new Date().toISOString()
    });
    
    console.log(`New message from Firestore:`, {
      docId: docId,
      text: newMessage.text,
      createdAt: newMessage.createdAt
    });
    
    return null;
  });

// Firestore-triggered Function - Logs message updates
exports.onMessageUpdate = functions.firestore
  .document('messages/{docId}')
  .onUpdate((change, context) => {
    const previousMessage = change.before.data();
    const updatedMessage = change.after.data();
    const docId = context.params.docId;
    
    functions.logger.info(`Message updated with ID: ${docId}`, {
      previousText: previousMessage.text,
      updatedText: updatedMessage.text,
      timestamp: new Date().toISOString()
    });
    
    console.log(`Message updated in Firestore:`, {
      docId: docId,
      previousText: previousMessage.text,
      updatedText: updatedMessage.text
    });
    
    return null;
  });

// Firestore-triggered Function - Logs message deletions
exports.onMessageDelete = functions.firestore
  .document('messages/{docId}')
  .onDelete((snap, context) => {
    const deletedMessage = snap.data();
    const docId = context.params.docId;
    
    functions.logger.info(`Message deleted with ID: ${docId}`, {
      message: deletedMessage.text,
      timestamp: new Date().toISOString()
    });
    
    console.log(`Message deleted from Firestore:`, {
      docId: docId,
      text: deletedMessage.text
    });
    
    return null;
  });

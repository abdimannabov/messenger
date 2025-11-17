# Cloud Functions Documentation

This directory contains the Firebase Cloud Functions for the Messenger app.

## Functions Included

### 1. HTTP-triggered Function: `helloWorld`

- **Trigger Type**: HTTPS
- **Description**: Returns a JSON response with a greeting message
- **Endpoint**: `https://region-projectId.cloudfunctions.net/helloWorld`
- **Response Format**:
  ```json
  {
    "status": "success",
    "message": "Hello from Cloud Functions!",
    "timestamp": "2024-11-17T10:30:00.000Z",
    "data": {
      "greeting": "Welcome to Firebase Cloud Functions",
      "version": "1.0.0"
    }
  }
  ```

### 2. Firestore-triggered Function: `onNewMessage`

- **Trigger Type**: Firestore (onCreate)
- **Trigger Path**: `/messages/{docId}`
- **Description**: Logs new messages when they are created in Firestore
- **Logs**:
  - Document ID
  - Message text
  - Creation timestamp
  - Server timestamp when triggered

### 3. Firestore-triggered Function: `onMessageUpdate`

- **Trigger Type**: Firestore (onUpdate)
- **Trigger Path**: `/messages/{docId}`
- **Description**: Logs updates to messages
- **Logs**:
  - Previous message text
  - Updated message text
  - Server timestamp

### 4. Firestore-triggered Function: `onMessageDelete`

- **Trigger Type**: Firestore (onDelete)
- **Trigger Path**: `/messages/{docId}`
- **Description**: Logs when messages are deleted
- **Logs**:
  - Document ID
  - Deleted message text
  - Deletion timestamp

## Deployment Instructions

1. **Install Firebase CLI** (if not already installed):

   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:

   ```bash
   firebase login
   ```

3. **Navigate to project directory**:

   ```bash
   cd path/to/messenger
   ```

4. **Deploy Cloud Functions**:

   ```bash
   firebase deploy --only functions
   ```

5. **View Logs**:
   - Using Firebase CLI:
     ```bash
     firebase functions:log
     ```
   - Or in Firebase Console:
     - Navigate to your project
     - Go to Functions
     - Click on the function name
     - View the Logs tab

## Local Testing

To test Cloud Functions locally:

1. **Install dependencies**:

   ```bash
   cd functions
   npm install
   ```

2. **Start the emulator**:

   ```bash
   npm run serve
   ```

3. **Test the HTTP function**:

   - Open `http://localhost:5001/YOUR_PROJECT_ID/us-central1/helloWorld` in your browser

4. **Test Firestore triggers**:
   - Use the Firestore emulator to create/update/delete messages
   - View logs in the terminal

## Testing Steps for Requirements

### To verify HTTP function:

1. Deploy the functions
2. Visit the endpoint URL
3. Confirm you receive JSON response with status, message, and data

### To verify Firestore triggers:

1. Deploy the functions
2. In your Flutter app, create a new message
3. Go to Firebase Console > Functions > Logs
4. You should see logs for `onNewMessage` trigger
5. Edit a message in the app
6. You should see logs for `onMessageUpdate` trigger
7. Delete a message
8. You should see logs for `onMessageDelete` trigger

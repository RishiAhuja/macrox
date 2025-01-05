/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const cors = require('cors')({origin: true});

initializeApp();
const db = getFirestore();

exports.testCreateSubdomain = onRequest(async (request, response) => {
  try {
    const username = request.query.username;
    const userId = request.query.userId;

    // Create subdomain record
    await db.collection('subdomains')
      .doc(username)
      .set({
        userId: userId,
        createdAt: new Date(),
        status: 'active',
        url: `${username}.blogging-e2ada.web.app`
      });

    response.json({ success: true, message: 'Subdomain created' });
  } catch (error) {
    console.error('Error:', error);
    response.status(500).json({ error: error.message });
  }
});

// Original function with more logging
exports.createSubdomain = onDocumentCreated('Users/{userId}', async (event) => {
  console.log('Function triggered for userId:', event.params.userId);
  
  try {
    const snapshot = event.data;
    if (!snapshot) {
      console.error('No data in snapshot');
      return;
    }

    const userData = snapshot.data();
    console.log('User data:', userData);

    const username = userData.username;
    if (!username) {
      console.error('No username found in user data');
      return;
    }

    console.log('Creating subdomain for:', username);

    // Create subdomain record
    await db.collection('subdomains')
      .doc(username)
      .set({
        userId: event.params.userId,
        createdAt: new Date(),
        status: 'active',
        url: `${username}.blogging-e2ada.web.app`
      });

    console.log('Subdomain document created');
    return { success: true };
  } catch (error) {
    console.error('Error creating subdomain:', error);
    return { success: false, error: error.message };
  }
});

// New function to handle subdomain requests
exports.handleSubdomain = onRequest({
  cors: true,
  enforceAppCheck: false,
  region: ["us-central1"],
}, async (request, response) => {
  try {
    const host = request.headers.host;
    const subdomain = host.split('.')[0];
    
    console.log('Request received for:', host);
    
    const subdomainDoc = await db.collection('subdomains')
      .doc(subdomain)
      .get();
      
    if (!subdomainDoc.exists) {
      response.status(404).send(`
        <html>
          <head>
            <title>Not Found</title>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
          </head>
          <body>
            <h1>Subdomain ${subdomain} not found</h1>
          </body>
        </html>
      `);
      return;
    }

    response.set('Content-Type', 'text/html');
    response.set('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
    response.status(200).send(`
      <html>
        <head>
          <title>${subdomain}'s Page</title>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
        </head>
        <body>
          <h1>Welcome to ${subdomain}'s page!</h1>
        </body>
      </html>
    `);
  } catch (error) {
    console.error('Error:', error);
    response.status(500).send('Server Error');
  }
});

exports.deleteSubdomain = onRequest(async (request, response) => {
  try {
    const username = request.query.username;
    
    // Delete from subdomains collection
    await db.collection('subdomains')
      .doc(username)
      .delete();
      
    // Update user document
    const userSnapshot = await db.collection('Users')
      .where('username', '==', username)
      .get();
      
    if (!userSnapshot.empty) {
      await userSnapshot.docs[0].ref.update({
        subdomain: null
      });
    }
    
    response.json({ success: true });
  } catch (error) {
    console.error('Error:', error);
    response.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});
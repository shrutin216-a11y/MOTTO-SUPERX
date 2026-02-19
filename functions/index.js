// index.js
const admin = require("firebase-admin");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

admin.initializeApp();

exports.sendTripNotification = onDocumentCreated(
  "trips/{tripId}",
  async (event) => {
    const snap = event.data;
    const trip = snap.data();

    const payload = {
      notification: {
        title: "New Trip Posted!",
        body: `A new trip to ${trip.destination} has been added.`,
      },
    };

    const tokensSnapshot = await admin.firestore().collection("fcmTokens").get();
    const tokens = tokensSnapshot.docs.map((doc) => doc.id); // FCM token saved as doc ID

    if (tokens.length > 0) {
      await admin.messaging().sendToDevice(tokens, payload);
      console.log(`Notification sent to ${tokens.length} devices`);
    } else {
      console.log("No FCM tokens available");
    }
  }
);

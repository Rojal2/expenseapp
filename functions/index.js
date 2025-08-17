const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendPushNotification = functions.firestore
    .document("notifications/{docId}")
    .onCreate(async (snap, context) => {
      const message = snap.data().message;

      const payload = {
        notification: {
          title: "New Notification",
          body: message,
        },
      };

      await admin.messaging().sendToTopic("allUsers", payload);
      console.log("Notification sent:", message);
    });

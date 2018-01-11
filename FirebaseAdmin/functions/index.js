const functions = require('firebase-functions');
const admin = require("firebase-admin");

var serviceAccount = require("./serviceAccount.json");

admin.initializeApp(functions.config().firebase);

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.sendNotificationToLocation = functions.database.ref("notifications/{notificationID}").onWrite(event =>{
	if(event.data.val()){
		var registrationToken = event.data.val().registrationToken;
		var message = event.data.val().message;
		var badgeCount = event.data.val().badgeCount;

		const payload = {
			notification: {
				title: "Notification",
				badge: badgeCount.toString()
			}
		};

		admin.messaging().sendToDevice(registrationToken, payload)
			.then(function(response) {
				// See the MessagingDeviceGroupResponse reference documentation for
				// the contents of response.
				console.log("Successfully sent message:", response);
				event.data.ref.remove();
			})
			.catch(function(error) {
				console.log(error);
			});
		}
});

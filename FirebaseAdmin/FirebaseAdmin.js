// FirebaseAdmin.js

const functions = require('firebase-functions');
const admin = require("firebase-admin");

var serviceAccount = require("./serviceAccount.json");


admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://proffr-d0848.firebaseio.com"
});

admin.initializeApp(functions.config().firebase);

exports.sendNotificationToLocation = functions.database.ref("notifications/{notificationID}").onWrite(event =>{
	if(event.data.val()){
		var registrationToken = event.data.val().registrationToken;
		var message = event.data.val().message;

		const payload = {
			notification: {
				title: message
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
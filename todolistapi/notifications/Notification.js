// notification.js

var mongoose = require('mongoose');
var NotificationSchema = new mongoose.Schema({
  createdAt: Object,
  userID: String,
  requestTitle: String,
  requestPrice: Number,
  requestId: String,
  requesterId: String,
  requesterName: String,
  photoUrl: String
});
mongoose.model('Notification', NotificationSchema);
module.exports = mongoose.model('Notification');
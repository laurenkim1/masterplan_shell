// User.js

var mongoose = require('mongoose');
var UserSchema = new mongoose.Schema({
  userId: String,
  userName: String,
  userEmail: String,
  userLocation: Object,
  fcmToken: String,
  userRequests: [String]
});
mongoose.model('User', UserSchema);
module.exports = mongoose.model('User');
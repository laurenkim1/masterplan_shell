// User.js

var mongoose = require('mongoose');

var UserSchema = new mongoose.Schema({
  userId: String,
  userName: String,
  firstName: String,
  lastName: String,
  userEmail: String,
  userLocation: Object,
  fcmToken: String,
  userRequests: [Object]
});
mongoose.model('User', UserSchema, "users");
module.exports = mongoose.model('User');
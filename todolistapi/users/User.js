// User.js

var mongoose = require('mongoose');
var UserSchema = new mongoose.Schema({
  userId: String,
  userName: String,
  userLocation: Object
});
mongoose.model('User', UserSchema);
module.exports = mongoose.model('User');
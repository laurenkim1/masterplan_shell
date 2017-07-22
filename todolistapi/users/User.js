// User.js

var mongoose = require('mongoose');
var UserSchema = new mongoose.Schema({
  userID: String,
  userName: String,
  userPassword: String
});
mongoose.model('User', UserSchema);
module.exports = mongoose.model('User');
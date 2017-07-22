// User.js

var mongoose = require('mongoose');
var UserSchema = new mongoose.Schema({
  userID: String,
  userName: String,
  userPassword: String
});
mongoose.model('Request', RequestSchema);
module.exports = mongoose.model('Request');
// User.js

var mongoose = require('mongoose');
var UserSchema = new mongoose.Schema({
  userName: String,
  userPassword: String
  xCoordinate: Number,
  yCoordinate: Number
});
mongoose.model('User', UserSchema);
module.exports = mongoose.model('User');
// User.js

var mongoose = require('mongoose');
var UserSchema = new mongoose.Schema({
  userName: String,
  userPassword: String
  xCoordinate: req.body.xCoordinate,
  yCoordinate: req.body.yCoordinate
});
mongoose.model('User', UserSchema);
module.exports = mongoose.model('User');
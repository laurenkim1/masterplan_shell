// Request.js

var mongoose = require('mongoose');
var RequestSchema = new mongoose.Schema({
  userID: String,
  requestTitle: String,
  requestPrice: Number,
  fulfilled: Boolean,
  fulfillerID: Number,
  requestTags: String,
  pickUp: Number,
  distance: Number,
  xCoordinate: Number,
  yCoordinate: Number 
});
mongoose.model('Request', RequestSchema);
module.exports = mongoose.model('Request');

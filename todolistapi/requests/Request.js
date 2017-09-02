// Request.js

var mongoose = require('mongoose');
var RequestSchema = new mongoose.Schema({
  createdAt: Object,
  userID: String,
  userName: String,
  requestTitle: String,
  requestPrice: Number,
  fulfilled: Boolean,
  fulfillerID: Number,
  requestTags: String,
  pickUp: Number,
  distance: Number,
  location: Object,
  photoUrl: String,
});
mongoose.model('Request', RequestSchema, "requests");
module.exports = mongoose.model('Request');

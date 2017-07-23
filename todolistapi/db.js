// db.js
var mongoose = require('mongoose');
mongoose.connect('mongodb://laurenkim:jihye197@ds163232.mlab.com:63232/requests');

db.requests.createIndex({ location: "2dsphere" })
db.requests.createIndex({ geometry: "2dsphere" })
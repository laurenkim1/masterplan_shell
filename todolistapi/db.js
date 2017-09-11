// db.js

var mongoose = require('mongoose');
mongoose.Promise = require('bluebird');
var options = {
	useMongoClient: true
};

var db = mongoose.connect('mongodb://laurenkim:jihye197@ds119064.mlab.com:19064/proffr', options);
db.collection("requests").dropIndex("createdAt_1")
// db.collection("requests").createIndex( { "createdAt": 1 }, { expireAfterSeconds: 3600 } );
/*
var promise = mongoose.connect('mongodb://laurenkim:jihye197@ds163232.mlab.com:63232/requests', options);
promise.then( function (db) {
	db.collection("requests").dropIndex("createdAt_1")
	db.collection("requests").createIndex( { "createdAt": 1 }, { expireAfterSeconds: 3600 } );
});
*/
module.exports = db;
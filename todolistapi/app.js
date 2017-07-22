// app.js

var express = require('express');
var app = express();
var db = require('./db');

var RequestController = require('./requests/RequestController');
app.use('/requests', RequestController);

var UserController = require('./user/UserController');
app.use('/users', UserController);

function deleteoldrequests() {
	console.log("delete")
}

var timerID = setInterval(deleteoldrequests, 60000); 
clearInterval(timerID);

module.exports = app;

// app.js

var express = require('express');
var app = express();
var db = require('./db');

var RequestController = require('./requests/RequestController');
app.use('/requests', RequestController);

var UserController = require('./user/UserController');
app.use('/users', UserController);

(deleteoldrequests(){
    // do some stuff
    console.log("delete")
    setTimeout(arguments.callee, 60000);
})();

module.exports = app;

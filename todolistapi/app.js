// app.js

var express = require('express');
var app = express();
var db = require('./db');

var RequestController = require('./requests/RequestController');
app.use('/requests', RequestController);

module.exports = app;

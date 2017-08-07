// app.js

var express = require('express');
var app = express();
var db = require('./db');
var messagebroker = require('./amqp');

var RequestController = require('./requests/RequestController');
app.use('/requests', RequestController);

var UserController = require('./users/UserController');
app.use('/users', UserController);

var NotificationController = require('./notifications/NotificationController');
app.use('/notifications', NotificationController);

module.exports = app;

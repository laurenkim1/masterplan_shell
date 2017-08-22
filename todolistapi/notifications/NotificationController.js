// notificationController.js

//var messagebroker = require('./../amqp');

var express = require('express');
var router = express.Router();
var bodyParser = require('body-parser');

router.use(bodyParser.json());
var Notification = require('./Notification');

router.post('/', function (req, res) {
    let msg = req.body;
    console.log(msg)
    let recipientId = req.body.userID
    //messagebroker.publish("", recipientId, new Buffer(msg));
    Notification.create({
            createdAt: new Date(),
            userID: recipientId,
            requestTitle: req.body.requestTitle,
            requestPrice: req.body.requestPrice,
            requestId: req.body.requestId,
            requesterId: req.body.requesterId,
            requesterName: req.body.requesterName,
            photoUrl: req.body.photoUrl
        },
        function (err, notification) {
            console.log(err)
            if (err) return res.status(500).send("There was a problem adding the information to the notification database.");
            res.status(200).send(notification);
        });
});

router.get('/:recipientId', function (req, res) {
    var userID = req.params.recipientId;
    console.log(userID)
    Notification.find({ userID: userID }, function (err, notification) {
        if (err) return res.status(500).send("There was a problem finding the notification.");
        if (!notification) return res.status(404).send("No notification found.");
        console.log(notification)
        res.status(200).send(notification);
    });
});

module.exports = router;
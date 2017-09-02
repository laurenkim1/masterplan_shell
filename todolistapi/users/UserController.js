// UserController.js

var express = require('express');
var router = express.Router();
var bodyParser = require('body-parser');

router.use(bodyParser.json());
var User = require('./User');
var db = require('../db');

// CREATES A NEW USER
router.post('/', function (req, res) {
    User.create({
            userId: req.body.userId,
            userName: req.body.userName,
            firstName: req.body.firstName,
            lastName: req.body.lastName,
            userEmail: req.body.userEmail,
            userLocation: req.body.userLocation,
            fcmToken: req.body.fcmToken,
            userRequests: []
        },
        function (err, user) {
            if (err) return res.status(500).send("There was a problem adding the information to the user database.");
            res.status(200).send(user);
        });
});
// RETURNS ALL THE USERS IN THE DATABASE
router.get('/', function (req, res) {
    User.find({}, function (err, users) {
        if (err) return res.status(500).send("There was a problem finding the user.");
        res.status(200).send(users);
    });
});

// GETS A SINGLE USER FROM THE DATABASE
router.get('/:id', function (req, res) {
    User.find({ userId: req.params.id }, function (err, user) {
        if (err) return res.status(500).send("There was a problem finding the user.");
        if (!user) return res.status(404).send("No user found.");
        res.status(200).send(user);
    });
});

/*
// GETS USERS FROM THE DATABASE
router.get('/:fbid', function (req, res) {
    var fbid = req.query.id
    console.log(fbid)
    User.find({ userId: fbid }, function (err, user) {
        console.log(err)
        if (err) return res.status(500).send("There was a problem finding the user.");
        if (!user) return res.status(404).send("No user found.");
        res.status(200).send(user);
    });
});
*/

// GETS USER REQUESTS FROM THE DATABASE
router.get('/myRequests/:id', function (req, res) {
    db.collection("users").findOne({ userId: req.params.id }, function (err, user) {
        if (err) return res.status(500).send("There was a problem finding the user requests.");
        if (!user) return res.status(404).send("No user found.");
        let myRequests = user.userRequests;
        if (!myRequests) return res.status(404).send("No requests for user.");
        console.log(myRequests);
        res.status(200).send(myRequests);
    });
});

// DELETES A USER FROM THE DATABASE
router.delete('/:id', function (req, res) {
    User.findByIdAndRemove(req.params.id, function (err, user) {
        if (err) return res.status(500).send("There was a problem deleting the user.");
        res.status(200).send("User "+ user.userName +" was deleted.");
    });
});

// UPDATES A SINGLE USER IN THE DATABASE
router.put('/:id', function (req, res) {
    User.update({ "userId": req.params.id }, req.body, {new: true}, function (err, user) {
        if (err) return res.status(500).send("There was a problem updating the user.");
        res.status(200).send(user);
    });
});

// ADD NEW REQUEST TO USER PROFILE
router.put('/newreq/:id', function (req, res) {
    db.collection("users").update({ "userId": req.params.id }, { $push: { "userRequests": req.body } }, function (err, user) {
        if (err) return res.status(500).send("There was a problem updating the user requests.");
        res.status(200).send(user);
    });
});

module.exports = router;
// UserController.js

// UserController.js

var express = require('express');
var router = express.Router();
var bodyParser = require('body-parser');

router.use(bodyParser.json());
var Request = require('./User');

// CREATES A NEW REQUEST
router.post('/', function (req, res) {
    console.log(req.body)
    Request.create({
            userName: req.body.userID,
            userPassword: req.body.userPassword,
            xCoordinate: req.body.xCoordinate,
            yCoordinate: req.body.yCoordinate
        },
        function (err, user) {
            if (err) return res.status(500).send("There was a problem adding the information to the user database.");
            res.status(200).send(user);
        });
});
// RETURNS ALL THE REQUESTS IN THE DATABASE
router.get('/', function (req, res) {
    Request.find({}, function (err, users) {
        if (err) return res.status(500).send("There was a problem finding the user.");
        res.status(200).send(users);
    });
});

// GETS A SINGLE REQUEST FROM THE DATABASE
router.get('/:id', function (req, res) {
    Request.findById(req.params.id, function (err, user) {
        if (err) return res.status(500).send("There was a problem finding the user.");
        if (!request) return res.status(404).send("No request found.");
        res.status(200).send(user);
    });
});

// DELETES A REQUEST FROM THE DATABASE
router.delete('/:id', function (req, res) {
    Request.findByIdAndRemove(req.params.id, function (err, user) {
        if (err) return res.status(500).send("There was a problem deleting the user.");
        res.status(200).send("Request "+ user.userName +" was deleted.");
    });
});

// UPDATES A SINGLE REQUEST IN THE DATABASE
router.put('/:id', function (req, res) {

    Request.findByIdAndUpdate(req.params.id, req.body, {new: true}, function (err, user) {
        if (err) return res.status(500).send("There was a problem updating the user.");
        res.status(200).send(user);
    });
});

module.exports = router;
// RequestController.js

var express = require('express');
var router = express.Router();
var bodyParser = require('body-parser');

router.use(bodyParser.urlencoded({ extended: true }));
var Request = require('./Request');

// CREATES A NEW REQUEST
router.post('/', function (req, res) {
    Request.create({
            userID: req.body.userID,
            requestTitle: req.body.requestTitle,
            requestPrice: req.body.requestPrice,
            requestID: req.body.requestID,
            fulfilled: req.body.fulfilled,
            fulfillerID: req.body.fulfillerID,
            requestTags: req.body.reqestTags,
            pickUp: req.body.pickUp,
            distance: req.body.distance,
            xCoordinate: req.body.xCoordinate,
            yCoordinate: req.body.yCoordinate
        },
        function (err, request) {
            if (err) return res.status(500).send("There was a problem adding the information to the database.");
            res.status(200).send(request);
        });
});
// RETURNS ALL THE REQUESTS IN THE DATABASE
router.get('/', function (req, res) {
    Request.find({}, function (err, requests) {
        if (err) return res.status(500).send("There was a problem finding the requests.");
        res.status(200).send(requests);
    });
});

// GETS A SINGLE REQUEST FROM THE DATABASE
router.get('/:id', function (req, res) {
    Request.findById(req.params.id, function (err, request) {
        if (err) return res.status(500).send("There was a problem finding the request.");
        if (!request) return res.status(404).send("No request found.");
        res.status(200).send(request);
    });
});

// DELETES A REQUEST FROM THE DATABASE
router.delete('/:id', function (req, res) {
    Request.findByIdAndRemove(req.params.id, function (err, request) {
        if (err) return res.status(500).send("There was a problem deleting the request.");
        res.status(200).send("Request "+ request.requestTitle +" was deleted.");
    });
});

// UPDATES A SINGLE REQUEST IN THE DATABASE
router.put('/:id', function (req, res) {

    Request.findByIdAndUpdate(req.params.id, req.body, {new: true}, function (err, request) {
        if (err) return res.status(500).send("There was a problem updating the request.");
        res.status(200).send(request);
    });
});

module.exports = router;

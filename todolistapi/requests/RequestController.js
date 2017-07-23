// RequestController.js

var express = require('express');
var router = express.Router();
var bodyParser = require('body-parser');

router.use(bodyParser.json());
var Request = require('./Request');

// CREATES A NEW REQUEST
router.post('/', function (req, res) {
    console.log(req.body)
    Request.create({
            userID: req.body.userID,
            requestTitle: req.body.requestTitle,
            requestPrice: req.body.requestPrice,
            fulfilled: req.body.fulfilled,
            fulfillerID: req.body.fulfillerID,
            requestTags: req.body.reqestTags,
            pickUp: req.body.pickUp,
            distance: req.body.distance,
            location: req.body.location
        },
        function (err, request) {
            console.log(err)
            if (err) return res.status(500).send("There was a problem adding the information to the request database.");
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

// GETS REQUESTS WITHIN RADIUS OF LOCATION FROM THE DATABASE
router.get('/:location', function (req, res) {
    Request.createIndex({ location: "2dsphere" })
    Request.find({ location: { $nearSphere: { $geometry: req.params.geoloc, $maxDistance: req.params.radius * METERS_PER_MILE } } }, function (err, request) {
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

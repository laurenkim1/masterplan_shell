// amqp.js

// Access the callback-based API

var express = require('express');
var app = express();
var db = require('./db');

var amqp = require('amqplib/callback_api');
var amqpConn = null;
CLOUDAMQP_URL => "amqp://oiiacwup:s1IsbxuRJ0FYwRFJO1T71R4vDNA3fJ66@wasp.rmq.cloudamqp.com/oiiacwup"

function start() {
  amqp.connect("amqp://oiiacwup:s1IsbxuRJ0FYwRFJO1T71R4vDNA3fJ66@wasp.rmq.cloudamqp.com/oiiacwup" + "?heartbeat=60", function(err, conn) {
    if (err) {
      console.error("[AMQP]", err.message);
      return setTimeout(start, 1000);
    }
    conn.on("error", function(err) {
      if (err.message !== "Connection closing") {
        console.error("[AMQP] conn error", err.message);
      }
    });
    conn.on("close", function() {
      console.error("[AMQP] reconnecting");
      return setTimeout(start, 1000);
    });
    console.log("[AMQP] connected");
    amqpConn = conn;
    whenConnected();
  });
}

function whenConnected() {
  startPublisher();
  startWorker();
}

var pubChannel = null;
var offlinePubQueue = [];
function startPublisher() {
  amqpConn.createConfirmChannel(function(err, ch) {
    if (closeOnErr(err)) return;
      ch.on("error", function(err) {
      console.error("[AMQP] channel error", err.message);
    });
    ch.on("close", function() {
      console.log("[AMQP] channel closed");
    });

    var ex = 'notifications';
    ch.assertExchange(ex, 'direct', {durable: true});

    pubChannel = ch;
    while (true) {
      var m = offlinePubQueue.shift();
      if (!m) break;
      publish(m[0], m[1], m[2]);
    }
  });
}

function publish(exchange, routingKey, content) {
  try {
    pubChannel.publish(exchange, routingKey, content, { persistent: true },
                      function(err, ok) {
                        if (err) {
                          console.error("[AMQP] publish", err);
                          offlinePubQueue.push([exchange, routingKey, content]);
                          pubChannel.connection.close();
                        }
                      });
  } catch (e) {
    console.error("[AMQP] publish", e.message);
    offlinePubQueue.push([exchange, routingKey, content]);
  }
}

// A worker that acks messages only if processed successfully
function startWorker(bindingKey) {
  amqpConn.createChannel(function(err, ch) {
    if (closeOnErr(err)) return;
    ch.on("error", function(err) {
      console.error("[AMQP] channel error", err.message);
    });
    ch.on("close", function() {
      console.log("[AMQP] channel closed");
    });

    var ex = 'notifications';
    ch.assertExchange(ex, 'direct', {durable: true});

    ch.prefetch(10);
    ch.assertQueue("", { durable: true }, function(err, q) {
      if (closeOnErr(err)) return;
      ch.bindQueue(q.queue, ex, bindingKey);
      ch.consume("", processMsg, { noAck: false });
      console.log("Worker is started");
    });

    function processMsg(msg) {
      work(msg, function(ok) {
        try {
          if (ok)
            ch.ack(msg);
          else
            ch.reject(msg, true);
        } catch (e) {
          closeOnErr(e);
        }
      });
    }
  });
}


function work(msg, cb) {
  console.log("PDF processing of ", msg.content.toString());

  msg.fields.routingKey
  cb(true);
}

function closeOnErr(err) {
  if (!err) return false;
  console.error("[AMQP] error", err);
  amqpConn.close();
  return true;
}
/*
setInterval(function() {
  publish("", "jobs", new Buffer("work work work"));
}, 1000);
*/

start();
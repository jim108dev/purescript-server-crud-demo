"use strict";

var bodyParser = require("body-parser");

exports.jsonBodyParser = bodyParser.json({
    limit: "1mb"
});
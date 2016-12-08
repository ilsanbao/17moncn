/*
 * ip17mon
 * tool.17mon.cn
 *
 * Copyright (c) 2014 ilsanbao & other contributors
 * Licensed under the MIT license.
 */

'use strict';

var fs = require('fs'),
    dns = require('dns');

var DATA_PATH = "./17monipdb.dat";

var ready, rawData, queryQueue = [];

/**
 * query ip data
 * @param {String} name ip or domain to query
 * @param {Function} callback
 */
var query = function (ip, format) {

	// check IP format (actually this is not strict enough)
	if (!(ip.match(/^(\d{1,3}\.){3}\d{1,3}$/) && ready)) {
		return format === 'dict' ? {} : [];
	}

    var ipArray = ip.trim().split('.') || ['0'],
        ipInt = new Buffer(ipArray).readInt32BE(0),

        length = rawData.readInt32BE(0),
        partition = ipArray[0] * 4,

        indexBuffer = rawData.slice(4, length),
        indexOffset = -1,
        indexLenth = -1,

        offset = indexBuffer.slice(partition, partition + 4).readInt32LE(0) * 8 + 1024;

    while (offset < length - 1024 - 4) {
        if (indexBuffer.slice(offset, offset + 4).readInt32BE(0) >= ipInt) {
            indexOffset = ((indexBuffer[offset + 6] << 16) + 
            	(indexBuffer[offset + 5] << 8) + indexBuffer[offset + 4]);
            indexLenth = indexBuffer[offset + 7];
            break;
        }
        offset += 8;
    }

    var array = [];
    if (indexOffset !== -1 && indexLenth !== -1) {
    	// found
        offset = length + indexOffset - 1024;
        array = rawData.slice(offset, offset + indexLenth).toString('utf-8').split("\t");
    }
    // convert array to an object
	var wrap = function(array) {
		var dict = {};
		['country', 'province', 'city', 'organization'].forEach(function(key, i) {
            dict[key] = array[i] || '';
        });
        return dict;
	};
    return format === 'dict' ? wrap(array) : array;
};

/**
 * dymantically load data source
 * @param {String} path path to database
 */
var loadDatabase = function (path, callback) {
    path = path;
    callback = callback || function() {};

    module.exports.status = "loading";
    ready = false;

    fs.readFile(path, function (err, data) {
        if (err) {
        	callback(err);
        }

        module.exports.rawData = rawData = data;
        ready = true;
        module.exports.status = "ready";
        
        // process tasks in queue
        while (queryQueue.length) {
            var item = queryQueue.pop();
            item['callback'](query(item.ip));
        }

        callback();
    });
};

// load default database
loadDatabase(DATA_PATH, function (err) {
	if(err) {
		throw err;
	}
});

exports.loadData = loadDatabase;
exports.query = exports.queryIp = query;

/**
 * query via domain
 * @param {String} domain domain to query
 * @param {String} format use 'dict' to return an object, otherwise returns an array
 * @param {Function} callback
 */
exports.queryDomain = function (domain, format, callback) {
	callback = callback || format;

    dns.resolve4(domain, function (err, addresses) {
        var ip = err ? domain : addresses.shift();
        if (ready) {
            callback(query(ip, format));
        } else {
            queryQueue.push({ip: ip, callback: callback});
        }
    });
};

module.exports = exports;
var fs = require('fs');
var dns = require('dns');

var _17monIpDbPath = './17monipdb.dat';

var loadBinaryData = function(filepath){
    var fd = fs.openSync(filepath, 'r');
    var indexLengthBuffer = new Buffer(4);
    var chunkSize = 102400,
        chunkBuffer,
        chunks = [];

    var readLength = 0,
        bufferLength = 0;

    while (true) {
        chunkBuffer = new Buffer(chunkSize);
        readLength = fs.readSync(fd, chunkBuffer, 0, chunkSize, bufferLength);
        bufferLength += readLength;
        chunks.push(chunkBuffer);
        if (readLength < chunkSize) break;
    }
    fs.closeSync(fd);

    return Buffer.concat(chunks);
};

var IpFind = function(ip){
    var ipArray = ip.trim().split('.'),
        ip2long = function(ip){return new Buffer(ip.trim().split('.')).readInt32BE(0)},
        ipInt   = ip2long(ip);

    var offset = dataBuffer.readInt32BE(0);
    var indexBuffer = dataBuffer.slice(4, offset - 4 + 4);
    var tmp_offset = ipArray[0] * 4, max_comp_len = offset - 1028, index_offset = -1, index_length = -1, start = indexBuffer.slice(tmp_offset, tmp_offset + 4).readInt32LE(0);
    for (start = start * 8 + 1024; start < max_comp_len; start += 8) {
        if (indexBuffer.slice(start, start + 4).readInt32BE(0) >= ipInt) {
            index_offset = ((indexBuffer[start + 6] << 16) + (indexBuffer[start + 5] << 8) + indexBuffer[start + 4]);
            index_length = indexBuffer[start + 7];
            break;
        }
    }
    if (index_offset == -1 || index_length == -1) {
        return [];
    } else {
        return dataBuffer.slice(offset + index_offset - 1024, offset + index_offset - 1024 + index_length).toString('utf-8').split("\t");
    }
};

var dataBuffer = loadBinaryData(_17monIpDbPath);

exports.find = function(name, callback){
    dns.resolve4(name, function (err, addresses) {
        if (err) {
            callback(IpFind(name));
        } else {
            callback(IpFind(addresses.shift()));
        }
    });
};
exports.findSync = IpFind;
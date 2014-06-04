# ip17mon [![Build Status](https://travis-ci.org/ChiChou/ip17mon.svg?branch=master)](https://travis-ci.org/ChiChou/ip17mon)

[中文文档](README.md)

A Node.js module to query location information for a given IP or domain name, based on database by [17mon.cn](http://tool.17mon.cn).

Forked from: [ilsanbao/17moncn](https://github.com/ilsanbao/17moncn/tree/master/ip/nodejs)

## Getting Started

Download the [database here](http://s.qdcdn.com/17mon/17monipdb.dat) and put it on the module directory.

    var ip17mon = require('ip17mon');
    console.log(ip17mon.query('202.195.161.30', 'dict')); 
    //domain query must be asynchronous
    ip17mon.queryDomain('ujs.edu.cn', 'dict', function(result) {
        console.log(result);
    });

## Documentation

### Query by IP

query(ip [, format])

**ip**

IP address that you want to query. e.g. `8.8.8.8`

**format** 

Format of the information, shoule be `array` or `dict`. 

When set to `dict` you'll get an object that consists of four keys: `country`, `province`, `city`, `organization`. e.g.:

    {
        country: '中国',
        province: '江苏',
        city: '镇江',
        organization: '江苏大学' 
    }

Otherwise, it returns an array as following format: `['country', 'province', 'city', 'organization']`.

*Note:* Loading database to memory takes some time. During the period you can  still call `query` function, but it does not return anything although the IP does exist in the database. 

### Query by domain name

queryDomain(domain [, format], callback)

Due to dns query, this function must be asynchronous.

**domain**

Domain name that you want to query. e.g. `google.com`

**format** 

The same as `query`. 

**callback**

Fires when result found. Returns `{}` or `[]` when failed, format depends on the former paramer.

Should be declared as: `callback(result)`

## Examples

    ip17mon.query('202.195.161.30', 'dict');

    /*
    returns:
    {
        country: '中国',
        province: '江苏',
        city: '镇江',
        organization: '江苏大学' 
    }
    */

## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History

### r1 Initial Version

Reconstructed from [ilsanbao/17moncn](https://github.com/ilsanbao/17moncn/tree/master/ip/nodejs)

## License

Copyright (c) 2014 ChiChou. Licensed under the MIT license.

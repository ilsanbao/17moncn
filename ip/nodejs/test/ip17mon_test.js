'use strict';

var expect = require('chai').expect,
    ip17mon = require('../lib/ip17mon.js');

describe('#query()', function() {

    it('should handle malformed input', function(done) {

        expect(ip17mon.query('202.x.x.x', 'dict')).to.be.empty;
        expect(ip17mon.query('0.0.0.0')).to.be.empty;

        ip17mon.queryDomain('thisdomainshallneverexsts', 'dict', function(result) {
            expect(result).to.be.empty;
            done();
        });   
    });

    it('should return as dictionary', function(done) {
        expect(ip17mon.query('202.195.161.30', 'dict')).to.have.a.property('city');

        ip17mon.queryDomain('ujs.edu.cn', 'dict', function(result) {
            expect(result).to.have.a.property('city');
            done();
        });      
    });

    it('should return an array', function(done) {
        expect(ip17mon.query('8.8.8.8', 'dict')).to.have.a.property('city');

        ip17mon.queryDomain('google.com', function(result) {
            expect(result).to.be.an('array'); 
            done();
        });  
    });
});

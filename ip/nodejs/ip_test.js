var IP = require('./ip');

/* 异步方法 支持域名 */
IP.find('116.226.54.188', function(data){
    console.log(data);
});

/* 同步方法，不支持域名,仅支持IPv4 */
console.log(IP.findSync('180.73.134.23'));
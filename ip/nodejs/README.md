# ip17mon

适用于 Node.js 的 [17mon.cn](http://tools.17mon.cn) IP 数据库查询模块。

## 入门

首先[下载 IP 地址库](http://s.qdcdn.com/17mon/17monipdb.dat) 并放入同一目录。

	var ip17mon = require('ip17mon');
	console.log(ip17mon.query('202.195.161.30', 'dict')); 
	//域名的接口必须使用异步调用
    ip17mon.queryDomain('ujs.edu.cn', 'dict', function(result) {
        console.log(result);
    });

## 文档

### 查 IP

query(ip [, format])

**ip**

待查询的 IP 地址，如 `8.8.8.8`

**format** 

制定返回数据的格式，可设置为 `array` 或者 `dict`。 

默认是长度为4的数组，包含国家、省份、城市、单位信息。

设为 `dict` 时返回格式如下：

  	{
	    country: '国家',
	    province: '省份',
	    city: '城市',
	    organization: '单位' 
	}

*注意:* 在程序初始化时，加载内容到内存可能需要一定时间（很短），在这段时间内所有查询请求均会失败，返回空值。

### 查询域名

queryDomain(domain [, format], callback)

由于需要查询 DNS，本函数只能通过异步调用。不存在前文中需要等待程序加载的问题。

**domain**

域名，如 `google.com`

**format** 

同上。

**callback**

处理结果的回调函数，只接受一个参数，格式之前的 `format` 参数决定。

## 示例

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


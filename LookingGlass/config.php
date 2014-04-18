<?php

return array(
    'site' => array(
        'home' => array( //首页
            'title' => '17mon网络工具集',
            'logo' => 'http://s.qdcdn.com/loveapp/dpt/theme/images/logo.png',
            'link'  => 'http://tool.17mon.cn',
        ),
        'title' => 'LookingGlass', //站点Title名称
        'location' => '中国北京', //站点服务器机房位置
      //  'ipv4' => '0.0.0.0', // 配置可选
      //  'ipv6' => '0.0.0.0', // 配置可选
        'speedtest' => array( // 下载速度测试 配置可选
            '50MB'  => 'http://example.com/50MB.test',
            '150MB' => 'http://example.com/150MB.test',
            '500MB' => 'http://example.com/500MB.test',
        ),
        'rateLimit' => array(
            'enable' => TRUE,
            'provider' => array(
                'class' => 'session',
            ), // 默认使用session记录
            'minute' => 10, //每分钟 100 次
        ),
        'commands' => array( // key名称不能修改
            'host' => '/usr/bin/host',
            'ping' => '/bin/ping',
            'traceroute' => '/bin/tracert',

            /* IPv6支持尚未实现 */
            'ping6' => '/bin/ping6',           // IPv6
            'traceroute6' => '/bin/tracert6',  // IPv6
        ),
    ),
    'nodes' => array( // 其它监测点 可选配
        array(
            'name' => 'example.com',
            'link' => 'http://tool.17mon.cn',
        ),
    )
);
<?php

return array(
    'site' => array(
        'home' => array( //首页
            'title' => '17mon网络工具集',
            'logo' => '',
            'link'  => 'http://lg.17mon.cn',
        ),
        'title' => 'LookingGlass', //站点名称
        'domain' => 'lg.17mon.cn',
        'location' => '中国北京',
        'ipv4' => '0.0.0.0',
        'ipv6' => '0.0.0.0',
        'speedtest' => array(
            '50MB'  => 'http://lg.17mon.cn/50MB.test',
            '150MB' => 'http://lg.17mon.cn/150MB.test',
            '500MB' => 'http://lg.17mon.cn/500MB.test',
        ),
        'rateLimit' => array(
            'enable' => TRUE,
            'provider' => 'session', // 默认使用session记录
            'minute' => 100, //每分钟 100 次
        ),
        'commands' => array(
            'host' => '/usr/bin/host',
            'ping' => '/bin/ping',
            'traceroute' => '/bin/traceroute',
        ),
    ),
    'nodes' => array(
        array(
            'name' => 'aaaa',
            'link' => '',
        ),
        array(
            'name' => 'bbbbb',
            'link' => '',
        )
    )
);
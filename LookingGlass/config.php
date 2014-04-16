<?php

return array(
    'site' => array(
        'home' => array( //首页
            'title' => '17mon网络工具集',
            'logo' => 'http://s.qdcdn.com/loveapp/dpt/theme/images/logo.png',
            'link'  => 'http://tool.17mon.cn',
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
            'provider' => array(
                'class' => 'session',
                'option' => [
                    'host' => '127.0.0.1',
                    'port' => '6379',
                ],
            ), // 默认使用session记录
            'minute' => 10, //每分钟 100 次
        ),
        'commands' => array( // key名称不能修改
            'host' => '/usr/bin/host',
            'ping' => '/bin/ping',
            'traceroute' => '/bin/tracert',
        ),
    ),
    'nodes' => array(
        array(
            'name' => 'iamtelephone',
            'link' => 'http://lg.iamtelephone.com/',
        ),
    )
);
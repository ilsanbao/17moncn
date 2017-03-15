<?php

/**
 * 本类使用Public Domain许可
 * 本类纯解析 单例和缓存 需自行实现
 * $ip_seeker = new SeventeenMonIPSeeker('IPBase.17Mon.DAT');
 * $location = $ip_seeker->lookup('192.168.1.1');
 * $location->country  # 国家
 * $location->province # 省
 * $location->city     # 市
 * $location->unit     # 学校/单位
 */
class SeventeenMonIPSeeker {
	private static $data_offset = 4;
	private $fp;
	private $index_offset;
	private $max_comp_length;

	/**
	 * @param $path string 文件路径
	 * @throws Exception InvalidDataFile
	 */
	public function __construct($path) {
		$this->fp = fopen($path, 'rb');
		if ($this->fp === false) {
			throw new Exception('invalid data file!');
		}
		$this->index_offset = unpack('N', fread($this->fp, 4))[1];
		if ($this->index_offset < 4) {
			throw new Exception('invalid data file!');
		}
		$this->max_comp_length = self::$data_offset + ($this->index_offset - 1028);
	}

	/**
	 * 查找记录
	 * @param $ip string 十进制点分隔IP
	 * @return null|object
	 */
	public function lookup($ip) {
		if (empty($ip)) {
			return null;
		}

		list($index_offset, $index_length) = $this->locate(ip2long(gethostbyaddr($ip)));

		if ($index_offset === null) {
			return null;
		}

		fseek($this->fp, $this->index_offset + $index_offset - 1024);
		list($country, $province, $city, $unit) = explode("\t", fread($this->fp, $index_length));
		return (object)array(
			'country'  => $country,  # 国家
			'province' => $province, # 省
			'city'     => $city,     # 市
			'unit'     => $unit      # 学校/单位
		);
	}

	/**
	 * 定位记录位置
	 * @param $ip int 十进制IP
	 * @return array [offset, length]
	 */
	private function locate($ip) {
		$ip = pack('N', $ip);
		fseek($this->fp, self::$data_offset + (ord($ip[0]) * 4));

		$offset = unpack('V', fread($this->fp, 4))[1];
		$offset = self::$data_offset + ($offset * 8) + 1024;
		while ($offset < $this->max_comp_length) {
			fseek($this->fp, $offset);
			if (fread($this->fp, 4) >= $ip) {
				$index_offset = unpack('V', fread($this->fp, 3) . "\0")[1];
				$index_length = unpack('C', fread($this->fp, 1))[1];
				return array($index_offset, $index_length);
			}
			$offset += 8;
		}
	}

	public function __destruct() {
		if ($this->fp !== null) {
			fclose($this->fp);
		}
	}
}

/**
 * 本类使用Public Domain许可
 * 单例和缓存 简单实现
 * $location = SeventeenMonIPSeekerCache::lookup('192.168.1.1');
 * $location->country  # 国家
 * $location->province # 省
 * $location->city     # 市
 * $location->unit     # 学校/单位
 */
class SeventeenMonIPSeekerCache {
	private static $_instance;
	private $ip_seeker;
	private $cached = array();

	private function __construct() {
		$path = realpath('IPBase.17Mon.DAT'); // 实际使用时 请修改为您的 IP库 文件路径
		$this->ip_seeker = new SeventeenMonIPSeeker($path);
	}

	public static function lookup($ip) {
		if (!isset(self::$_instance)) {
			$class = __CLASS__;
			self::$_instance = new $class;
		}
		$cached = & self::$_instance->cached;
		if (!in_array($ip, $cached)) {
			$cached[$ip] = self::$_instance->ip_seeker->lookup($ip);
		}
		return $cached[$ip];
	}
}

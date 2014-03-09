/**
 * Created by fanrukuan on 13-12-21.
 */
package main

import (
	"fmt"
	"./ip17mon"
	"time"
)

func main() {

	var ip string = "109.16.235.1"
	fmt.Println(string(ip17mon.Find(ip)))

	var st int64  = time.Now().UnixNano() / 1000000;
	for i:=0; i<10000;i++ {
		ip17mon.Find(ip);
	}

	fmt.Printf("use time: %dms\n", (time.Now().UnixNano() / 1000000) - st)

}
